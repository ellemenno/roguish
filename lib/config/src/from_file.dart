import 'dart:io';

/// Creates a simple key-value map of strings.
///
/// General format is `key:value` on a single line.
///
/// Lines without the `:` delimiter are ignored.
///
/// Comments begin with `#` and go to end of line.
///
/// Keys are only defined once;
/// setting the same key again later in the file will have no effect
///
/// ```text
/// key1: val1 # comment
/// key-with-arbitrary_punctuation: value2
/// key3  :    val3     # whitespace around keys and values is trimmed
///
/// invalid-pair  val4  # blank lines and lines without ':' are ignored
/// missing-val:        # keys with no value are ignored
/// key1: otherVal # key1 is already set; this line has no effect
/// ```
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
    if (parts.first.isEmpty || parts.last.isEmpty) {
      continue;
    }
    k = parts[0].trim();
    v = parts[1].trim();
    config.putIfAbsent(k, () => v);
  }

  return config;
}
