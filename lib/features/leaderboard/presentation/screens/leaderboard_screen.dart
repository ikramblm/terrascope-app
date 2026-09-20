import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/max_width_box.dart';

/// Rankings tab.
///
/// Real leaderboards need a backend (Phase 7: server-side score
/// validation) — this screen's tab structure is real, but until that
/// backend exists it honestly shows an empty state rather than inventing
/// rankings.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 4,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: MaxWidthBox(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rankings', style: theme.textTheme.headlineLarge),
                    const SizedBox(height: 4),
                    Text(
                      'See how you stack up against other explorers.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(text: 'Global'),
                  Tab(text: 'Daily'),
                  Tab(text: 'Weekly'),
                  Tab(text: 'You'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _LeaderboardEmptyTab(
                      message:
                          'Global rankings appear once players start competing.',
                    ),
                    _LeaderboardEmptyTab(
                      message:
                          "Today's ranking will appear once scores come in.",
                    ),
                    _LeaderboardEmptyTab(
                      message:
                          "This week's ranking will appear once scores come in.",
                    ),
                    _LeaderboardEmptyTab(
                      message: 'Play a game to see how you rank.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardEmptyTab extends StatelessWidget {
  const _LeaderboardEmptyTab({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.emoji_events_outlined,
      title: 'No rankings yet',
      message: message,
    );
  }
}
