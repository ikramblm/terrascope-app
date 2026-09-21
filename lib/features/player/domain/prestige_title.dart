/// A flavor title per numeric level (1-50), layered on top of
/// [PlayerProfile.numericLevel] purely for display — never gates
/// anything, unlike [PlayerLevel] or a mode's `requiredLevel`.
///
/// Ten hand-picked words, each covering a 5-level band, rather than 50
/// hand-written unique strings — the two anchor points the design brief
/// named explicitly (Tourist at 1, Cartographer at 15, Globe Trotter at
/// 50) all land correctly with this banding.
class PrestigeTitle {
  PrestigeTitle._();

  static const List<(int minLevel, String title)> _bands = [
    (1, 'Tourist'),
    (6, 'Backpacker'),
    (11, 'Cartographer'),
    (16, 'Navigator'),
    (21, 'Voyager'),
    (26, 'Pathfinder'),
    (31, 'Adventurer'),
    (36, 'Pioneer'),
    (41, 'Vanguard'),
    (46, 'Globe Trotter'),
  ];

  static String forLevel(int numericLevel) {
    var title = _bands.first.$2;
    for (final band in _bands) {
      if (numericLevel >= band.$1) title = band.$2;
    }
    return title;
  }
}
