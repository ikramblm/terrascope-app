import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules the one on-device reminder TerraScope ever sends: a nudge
/// late in the day when today's streak is still at risk. Nothing else —
/// no marketing pushes, no re-engagement spam for its own sake.
///
/// Every call here fails silently, the same philosophy as SoundService:
/// a reminder is a nice-to-have nudge, never something app startup or
/// gameplay should crash over. Not supported on web (no OS-level
/// scheduler to hook into there), where every method is a no-op.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _streakReminderId = 1001;
  static const _eveningReminderHour = 20;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  bool _permissionRequested = false;

  /// Sets up the plugin and time zone database. Safe to call more than
  /// once — later calls are no-ops. Must complete before any schedule
  /// call does anything (both check [_ready]).
  Future<void> initialize() async {
    if (_ready || kIsWeb) return;
    try {
      tz_data.initializeTimeZones();
      // zonedSchedule only needs a self-consistent instant, not the
      // device's real IANA zone name — TZDateTime.from below converts
      // an already-correct local DateTime by its absolute instant, so
      // leaving tz.local at its UTC default doesn't shift when the
      // notification actually fires.
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );
      _ready = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationService: initialize failed ($e)');
      }
    }
  }

  /// Requests OS notification permission. Asked lazily — the first time
  /// there's an actual streak worth protecting — rather than as an
  /// empty cold-start prompt with no context behind it.
  Future<void> _ensurePermission() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationService: permission request failed ($e)');
      }
    }
  }

  /// Schedules (or replaces) today's streak-expiry reminder for this
  /// evening. A no-op once it's too late today for the reminder to be
  /// useful — cancels any stale one instead of firing it immediately.
  Future<void> scheduleStreakReminder({required int streakDays}) async {
    if (!_ready) return;
    if (streakDays <= 0) {
      await cancelStreakReminder();
      return;
    }
    final now = DateTime.now();
    final fireAt = DateTime(now.year, now.month, now.day, _eveningReminderHour);
    if (!fireAt.isAfter(now)) {
      await cancelStreakReminder();
      return;
    }
    await _ensurePermission();
    try {
      await _plugin.zonedSchedule(
        id: _streakReminderId,
        title: 'Your $streakDays-day streak is waiting',
        body: "You haven't played today yet — a few minutes keeps it alive.",
        scheduledDate: tz.TZDateTime.from(fireAt, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'streak_reminder',
            'Streak reminders',
            channelDescription:
                'A once-a-day nudge if your streak is still at risk',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationService: schedule failed ($e)');
      }
    }
  }

  /// Clears today's streak-expiry reminder — called once the player has
  /// played today, so a stale nudge never arrives after it's moot.
  Future<void> cancelStreakReminder() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _streakReminderId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationService: cancel failed ($e)');
      }
    }
  }
}
