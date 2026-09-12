import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// Loads the curated `emoji_clues.json` dataset — a small, explicitly
/// extensible map of country → emoji-clue variants. See
/// `assets/data/README.md` for what it covers and why it's separate from
/// the main country dataset.
class EmojiClueRepository {
  EmojiClueRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  static const String _assetPath = 'assets/data/emoji_clues.json';

  Map<String, List<String>>? _cache;

  Future<Map<String, List<String>>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await _bundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final result = decoded.map(
      (cca3, clues) => MapEntry(cca3, (clues as List<dynamic>).cast<String>()),
    );
    _cache = result;
    return result;
  }

  /// cca3 codes that have at least one curated emoji clue.
  Future<Set<String>> availableCca3s() async {
    final all = await loadAll();
    return all.keys.toSet();
  }

  /// A random clue variant for [cca3], or null if none is curated yet.
  Future<String?> randomClueFor(String cca3, {Random? random}) async {
    final all = await loadAll();
    final clues = all[cca3];
    if (clues == null || clues.isEmpty) return null;
    final rng = random ?? Random();
    return clues[rng.nextInt(clues.length)];
  }
}
