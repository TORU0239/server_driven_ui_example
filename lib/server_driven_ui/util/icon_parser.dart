// Maps a small, curated set of icon names to Material Icons.
// Unknown names fall back to a neutral icon.

import 'package:flutter/material.dart';

IconData iconFromName(String? name) {
  switch ((name ?? '').toLowerCase().trim()) {
    case 'person':
      return Icons.person_outline;
    case 'shopping_cart':
      return Icons.shopping_cart_outlined;
    case 'receipt':
      return Icons.receipt_long_outlined;
    case 'attach_money':
      return Icons.attach_money;
    case 'bolt':
      return Icons.bolt_outlined;
    case 'brush':
      return Icons.brush_outlined;
    case 'book':
      return Icons.book_outlined;
    default:
      return Icons.insert_chart_outlined; // fallback
  }
}
