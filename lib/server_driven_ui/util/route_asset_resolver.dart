// Resolves a route string to possible local asset JSON paths in priority order.
// 1) Mirrored: /detail           -> assets/json/detail.json
//               /products/42     -> assets/json/products/42.json
// 2) Flat:     /products/42      -> assets/json/products_42.json
// 3) Root:     '/'               -> assets/json/home.json
//
// This lets you add new screens by simply placing JSON files under assets/json/
// without changing code.

List<String> resolveAssetCandidates(String route) {
  // Strip query/hash and normalize.
  var r = route.split('?').first.split('#').first.trim();
  if (r.isEmpty) r = '/';
  if (r == '/') return const ['assets/json/home.json'];

  // Remove leading slash for relative path building.
  final path = r.startsWith('/') ? r.substring(1) : r;

  // Sanitize each segment to a safe file name.
  final segments = path.split('/').map((s) {
    final lower = s.toLowerCase();
    final buf = StringBuffer();
    for (final ch in lower.runes) {
      final c = String.fromCharCode(ch);
      final code = c.codeUnitAt(0);
      final ok =
          (code >= 97 && code <= 122) || // a-z
          (code >= 48 && code <= 57) || // 0-9
          c == '-' ||
          c == '_';
      buf.write(ok ? c : '_');
    }
    return buf.toString();
  }).toList();

  final mirrored = 'assets/json/${segments.join('/')}.json';
  final flat = 'assets/json/${segments.join('_')}.json';

  // Return candidates in order, removing duplicates.
  return {mirrored, flat}.toList();
}
