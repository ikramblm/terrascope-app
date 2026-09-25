import 'package:flutter/material.dart';

/// An AppBar action that lets the player give up on the current game
/// session early, shown as a flag icon. Confirms first since ending a
/// session is irreversible — [onSurrender] should end the engine's
/// session (e.g. its `surrender()`/`finish()` method); the screen's own
/// `isComplete`-driven rebuild takes it from there, exactly as if the
/// clock had simply run out.
class SurrenderButton extends StatelessWidget {
  const SurrenderButton({super.key, required this.onSurrender});

  final VoidCallback onSurrender;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.outlined_flag_rounded),
      tooltip: 'Give up',
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('End this game?'),
            content: const Text(
              "You'll see your results with whatever you've got so "
              "far — this can't be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep Playing'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('End Game'),
              ),
            ],
          ),
        );
        if (confirmed == true) onSurrender();
      },
    );
  }
}
