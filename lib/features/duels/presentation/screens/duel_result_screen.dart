import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/color_back_button.dart';
import '../../../../core/widgets/max_width_box.dart';

/// Shown right after playing a duel — either "you just created one" (no
/// opponent yet) or "here's how you did against them." Either way ends
/// with a code to copy and send on, since nothing here can notify the
/// other side automatically.
class DuelResultScreen extends StatelessWidget {
  const DuelResultScreen({
    super.key,
    required this.myScore,
    required this.myName,
    required this.shareCode,
    this.opponentScore,
    this.opponentName,
  });

  final int myScore;
  final String myName;
  final String shareCode;
  final int? opponentScore;
  final String? opponentName;

  bool get _hasOpponent => opponentScore != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? outcomeText;
    Color outcomeColor = AppColors.successEmerald;
    if (_hasOpponent) {
      final opponent = opponentScore!;
      if (myScore > opponent) {
        outcomeText = 'You beat $opponentName!';
        outcomeColor = AppColors.successEmerald;
      } else if (myScore < opponent) {
        outcomeText = '$opponentName wins this round';
        outcomeColor = AppColors.comboFlame;
      } else {
        outcomeText = "It's a tie with $opponentName";
        outcomeColor = AppColors.yellow;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duel Result'),
        leading: const ColorBackButton(),
      ),
      body: AppBackground(
        child: MaxWidthBox(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (outcomeText != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: outcomeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: outcomeColor, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          outcomeText,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: outcomeColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$myName: $myScore   ·   $opponentName: $opponentScore',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "They won't be notified automatically — share your "
                    'code back to let them know.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ] else ...[
                  Text('Duel Created', style: theme.textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    '$myName scored $myScore.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Send this code to a friend — they can paste it in '
                    'Duels to play your exact challenge.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SelectableText(
                    shareCode,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: shareCode));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy Code'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.go(RoutePaths.home),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.oceanBlue,
                    side: const BorderSide(
                      color: AppColors.oceanBlue,
                      width: 1.5,
                    ),
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
