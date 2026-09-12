import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';

/// Leaderboard tab.
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
  late final TabController _tabController =
      TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'You'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _LeaderboardEmptyTab(
            message: 'Global rankings appear once players start competing.',
          ),
          _LeaderboardEmptyTab(
            message: "Today's ranking will appear once scores come in.",
          ),
          _LeaderboardEmptyTab(
            message: "This week's ranking will appear once scores come in.",
          ),
          _LeaderboardEmptyTab(
            message: 'Play a game to see how you rank.',
          ),
        ],
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
      icon: Icons.leaderboard_outlined,
      title: 'No rankings yet',
      message: message,
    );
  }
}
