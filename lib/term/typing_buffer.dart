import 'dart:math' as math;
import 'package:rougish/term/ansi.dart' as ansi;

/// Cursor-based typing API for collecting and modifying a sequence of characters.
///
/// A [TypingBuffer] represents one line of text with a cursor that determines
/// where characters are inserted to or removed from the sequence.
class TypingBuffer {
  final List<int> _chars = [];
  bool _modified = false;
  int _cursor = 0;

  /// Zero-based position of cursor
  ///
  /// When typing, the cursor stays one position ahead of the text; typing `'abc'` would result in [cursorIndex] of `3`.
  int get cursorIndex => _cursor;

  /// Number of characters currently in the buffer
  int get length => _chars.length;

  /// `true` when the buffer has changed since the last time [resetModified] was called.
  bool get modified => _modified;

  /// Turns off the modified flag so new changes can be detected.
  void resetModified() => _modified = false;

  /// Removes all characters from the buffer and resets the cursor position to `0`.
  void clear() {
    _chars.clear();
    _cursor = _chars.length;
    _modified = true;
  }

  /// Removes one character to the left of the cursor.
  ///
  /// If the cursor is at the start of the text, calling this has no effect.
  void backspace() {
    if (_cursor == 0) {
      return;
    }
    _cursor -= 1;
    _chars.removeAt(_cursor);
    _modified = true;
  }

  /// Removes one character to the right of the cursor.
  ///
  /// If the cursor is at the end of the text, calling this has no effect.
  void delete() {
    if (_cursor == _chars.length) {
      return;
    }
    _chars.removeAt(_cursor);
    _modified = true;
  }

  /// Inserts one character at the cursor position.
  ///
  /// This advances the cursor forward one position, to remain in front of the inserted character.
  void write(int charCode) {
    _chars.insert(_cursor, charCode);
    _cursor += 1;
    _modified = true;
  }

  /// Moves the cursor one position closer to the start of the text, if possible.
  ///
  /// If the cursor is already at the start of the text, calling this has no effect.
  void cursorLeft() {
    int oldCursor = _cursor;
    _cursor = math.max(0, _cursor - 1);
    _modified = (oldCursor != _cursor);
  }

  /// Moves the cursor one position closer to the end of the text, if possible.
  ///
  /// If the cursor is already at the end of the text, calling this has no effect.
  void cursorRight() {
    int oldCursor = _cursor;
    _cursor = math.min(_chars.length, _cursor + 1);
    _modified = (oldCursor != _cursor);
  }

  /// Moves the cursor to the start of the text.
  ///
  /// If the cursor is already at the start of the text, calling this has no effect.
  void cursorStart() {
    int oldCursor = _cursor;
    _cursor = 0;
    _modified = (oldCursor != _cursor);
  }

  /// Moves the cursor to the end of the text.
  ///
  /// If the cursor is already at the end of the text, calling this has no effect.
  void cursorEnd() {
    int oldCursor = _cursor;
    _cursor = _chars.length;
    _modified = (oldCursor != _cursor);
  }

  /// Writes the current contents of the typing buffer into a provided string buffer.
  ///
  /// By default, the cursor will be illustrated via ANSI codes for 'inverted' text.
  /// Set [withFormatting] `false` to keep ANSI codes out of the string buffer.
  void toStringBuffer(StringBuffer sb, {withFormatting = true}) {
    sb.clear();
    int n = _chars.length;
    int i = 0;
    for (i = 0; i < n; i++) {
      if (i == _cursor && withFormatting) {
        sb.write('${ansi.flip}${String.fromCharCode(_chars[i])}${ansi.flop}');
      } else {
        sb.write(String.fromCharCode(_chars[i]));
      }
    }
    if (i == _cursor && withFormatting) {
      sb.write('${ansi.flip} ${ansi.flop}');
    }
  }
}
