import 'package:flutter/widgets.dart';

/// Grid-tile height that grows with the user's font size.
///
/// A fixed `mainAxisExtent` is tuned for one font scale; on a phone with
/// a larger system font (or a different density) the text no longer fits
/// and Flutter paints "BOTTOM OVERFLOWED BY n PIXELS". Scaling the extent
/// by the effective text scale (plus a small safety margin) keeps tiles
/// tall enough on every device.
double scaledExtent(BuildContext context, double base) {
  final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
  return base * (scale < 1 ? 1 : scale) + 6;
}
