import 'package:flutter_test/flutter_test.dart';

import 'package:terrascope_app/features/player/domain/player_profile.dart';
import 'package:terrascope_app/features/player/domain/prestige_title.dart';

PlayerProfile _profileWithXp(int totalXp) =>
    PlayerProfile.newPlayer().copyWith(totalXp: totalXp);

void main() {
  group('PlayerProfile.numericLevel', () {
    test('starts at 1 for a brand-new player, never 0', () {
      expect(_profileWithXp(0).numericLevel, 1);
    });

    test('climbs with totalXp on a sqrt curve', () {
      expect(_profileWithXp(50).numericLevel, 1);
      expect(_profileWithXp(200).numericLevel, 2);
      expect(_profileWithXp(450).numericLevel, 3);
    });

    test('clamps at 50 rather than climbing forever', () {
      expect(_profileWithXp(500000).numericLevel, 50);
    });
  });

  group('PrestigeTitle.forLevel', () {
    test('hits the three anchor points the design brief named', () {
      expect(PrestigeTitle.forLevel(1), 'Tourist');
      expect(PrestigeTitle.forLevel(15), 'Cartographer');
      expect(PrestigeTitle.forLevel(50), 'Globe Trotter');
    });

    test('stays flat within a band and steps at each band boundary', () {
      expect(PrestigeTitle.forLevel(6), 'Backpacker');
      expect(PrestigeTitle.forLevel(10), 'Backpacker');
      expect(PrestigeTitle.forLevel(11), 'Cartographer');
    });
  });
}
