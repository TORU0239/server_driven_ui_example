import 'package:flutter/material.dart';

/// Parses hex color strings like "#RRGGBB" or "#AARRGGBB" to [Color].
/// Returns null for invalid input.
Color? parseHexColor(String? hex) {
  if (hex == null) return null;
  var s = hex.trim();
  if (s.isEmpty) return null;
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s'; // add opaque alpha
  if (s.length != 8) return null;
  final val = int.tryParse(s, radix: 16);
  if (val == null) return null;
  return Color(val);
}
