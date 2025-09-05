// Helper to parse string values (from JSON) into BoxFit enum.

import 'package:flutter/material.dart';

/// Parses a string (e.g., "cover", "contain") to a [BoxFit] value.
/// Unknown input defaults to [BoxFit.cover].
BoxFit parseBoxFit(String? v) {
  switch ((v ?? '').toLowerCase()) {
    case 'contain':
      return BoxFit.contain;
    case 'cover':
      return BoxFit.cover;
    case 'fill':
      return BoxFit.fill;
    case 'fitwidth':
      return BoxFit.fitWidth;
    case 'fitheight':
      return BoxFit.fitHeight;
    default:
      return BoxFit.cover;
  }
}
