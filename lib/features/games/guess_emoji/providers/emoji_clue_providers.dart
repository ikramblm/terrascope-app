import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/emoji_clue_repository.dart';

final emojiClueRepositoryProvider = Provider<EmojiClueRepository>((ref) {
  return EmojiClueRepository();
});

final emojiCluesProvider = FutureProvider<Map<String, List<String>>>((
  ref,
) async {
  final repo = ref.watch(emojiClueRepositoryProvider);
  return repo.loadAll();
});
