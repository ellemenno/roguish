import 'dart:io';

import './ansi.dart' as ansi;

/// Print strings to a given output stream (`stdout` or `stderr`).
class TerminalPrinter {
  /// Instantiate a terminal printer that will write to a given output stream (`stdout` or `stderr`, both instances of `Stdout`).
  ///
  /// _note:_ shell scripting convention is to use `stderr` for messages that will be read by users,
  /// and `stdout` for messages that will be consumed by programs. So `stderr` may include decorations
  /// like ANSI color codes, while `stdout` should be easily parseable by another script.
  ///
  /// _also note:_ `stderr` is typically unbuffered, while `stdout` is typically line-buffered.
  /// these defaults have performance and user perception implications: unbufferd output may show up 'faster'
  /// for the user, but be less performant for the application, since it is performing more writes to
  /// the terminal device. buffered output won't appear until the buffer is flushed (triggerd by newlines),
  /// but this spends less cpu time since there are fewer writes.
  TerminalPrinter(this._fd);

  final Stdout _fd;
  Stdout get outputStream => _fd;

  final _dim = List<int>.filled(2, 0);
  int _columns = -1;
  int _lines = -1;

  /// Retrieve terminal width (columns), and height (rows) in a two-element list.
  ///
  /// Unless [useCache] is set to `false`, dimensions will be provided from cached values.
  void size(List<int> dim, {bool useCache = true}) {
    if (useCache == false || _columns < 0 || _lines < 0) {
      _columns = _fd.terminalColumns;
      _lines = _fd.terminalLines;
    }
    dim[0] = _columns;
    dim[1] = _lines;
  }

  /// Print provided string [msg] to the output stream.
  void print(String msg) => _fd.write(msg);

  /// Print provided string buffer [sb] to the output stream. Optionally clear the buffer after.
  void printBuffer(StringBuffer sb, {clearOnWrite = true}) {
    if (sb.length == 0) {
      return;
    }
    _fd.write(sb.toString());
    if (clearOnWrite) {
      sb.clear();
    }
  }

  /// Add ANSI codes to the provided string buffer to clear the screen and move the cursor to 0,0 (top left corner).
  ///
  /// The provided stringbuffer is cleared and filled with ANSI codes to reset styles,
  /// clear the screen, and position the cursor in the top left corner.
  /// Optionally, scrollback history can be cleared, and the cursor can be hidden.
  void clear(StringBuffer sb, {hideCursor = false, clearHistory = false}) {
    sb.clear();
    ansi.reset(sb);
    ansi.xy(sb, 1, 1);
    if (clearHistory) {
      ansi.clh(sb);
    } else {
      ansi.cls(sb, n: 2);
    }
    if (hideCursor) {
      sb.write(ansi.hide);
    }
  }

  /// Add ANSI codes to the provided string buffer to print a message at specific coordinates of the screen.
  /// The provided stringbuffer is concatened to (not cleared). The buffer is not sent to stdout in this method (see [printBuffer]).
  ///
  /// [xPos] sets the horizontal position of the message.
  /// [yPos] sets the vertical position of the message.
  /// [cll] if `true`, clears the row before printing.
  void placeMessage(StringBuffer sb, String msg, {int xPos = 1, int yPos = 1, bool cll = false}) {
    ansi.xy(sb, xPos, yPos);
    if (cll) {
      ansi.cll(sb);
    }
    sb.write(msg);
    ansi.reset(sb);
  }

  /// Add ANSI codes to the provided string buffer to print the provided message at relative coordinates of the screen.
  ///
  /// The provided stringbuffer is concatened to (not cleared).
  /// [xPercent] sets the horizontal position of the message. `0` maps to the first column (left-most), `100` to the last (right-most).
  /// [yPercent] sets the vertical position of the message. `0` maps to the first row (top), `100` maps to the last row (bottom).
  /// [xOffset] adjusts the horizontal position of the message (in absolute columns, not percent).
  /// [yOffset] adjusts the vertical position of the message (in absolute rows, not percent).
  /// [cll] if `true`, clears the row before printing.
  void placeMessageRelative(StringBuffer sb, String msg,
      {int xPercent = 0, int yPercent = 0, int xOffset = 0, int yOffset = 0, bool cll = false}) {
    size(_dim);
    int x = (_dim[0] * xPercent / 100).floor() + xOffset;
    int y = (_dim[1] * yPercent / 100).floor() + yOffset;
    placeMessage(sb, msg, xPos: x, yPos: y, cll: cll);
  }

  /// Add ANSI codes to the provided string buffer to print the provided message in the middle of the screen.
  ///
  /// The provided stringbuffer is concatened to (not cleared).
  /// [xOffset] adjusts the horizontal position of the message.
  /// [yOffset] adjusts the vertical position of the message.
  /// [msgOffset] adjusts the calculated length of the message before centering.
  /// [cll] if `true`, clears the row before printing.
  void centerMessage(StringBuffer sb, String msg,
      {int xOffset = 0, int yOffset = 0, int msgOffset = 0, bool cll = false}) {
    size(_dim);
    int x = (_dim[0] / 2).floor() - ((msg.length + msgOffset) / 2).floor() + xOffset;
    int y = (_dim[1] / 2).floor() + yOffset;
    placeMessage(sb, msg, xPos: x, yPos: y, cll: cll);
  }
}
