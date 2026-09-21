import 'package:flutter/material.dart';

/// A consumable gameplay lifeline, spent from a player's stock (or
/// bought on the spot with coins once that stock runs out).
enum PowerUpType {
  fiftyFifty('50/50', 'Removes two wrong answers', Icons.filter_2_rounded, 20),
  timeFreeze(
    'Time Freeze',
    'Adds 5 seconds to the clock',
    Icons.ac_unit_rounded,
    20,
  ),
  radar('Radar', "Reveals the answer's continent", Icons.radar_rounded, 15);

  const PowerUpType(this.label, this.description, this.icon, this.coinCost);

  final String label;
  final String description;
  final IconData icon;

  /// Coins to buy one more use once the free stock is at zero.
  final int coinCost;
}
