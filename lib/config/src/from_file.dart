import 'dart:io';

/// Creates a simple key-value map of strings.
///
/// General format is `key:value` on a single line.
/// Lines without the `:` delimiter are ignored.
/// Comments begin with `#` and go to end of line
Map<String, String> fromFile(String fileName) {
  const delim = ':';
  const comment = '#';
  List<String> parts;
  String k, v;
  Map<String, String> config = {};

  File file = File(fileName);
  List<String> lines = file.readAsLinesSync();

  for (var ln in lines) {
    if (!ln.contains(delim)) {
      continue;
    }
    if (ln.contains(comment)) {
      ln = ln.split(comment)[0].trim();
    }
    if (ln.isEmpty) {
      continue;
    }
    parts = ln.split(delim);
    if (parts.length != 2) {
      continue;
    }
    k = parts[0].trim();
    v = parts[1].trim();
    config.putIfAbsent(k, () => v);
  }

  return config;
}
