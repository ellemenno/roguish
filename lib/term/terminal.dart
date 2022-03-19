/// utilities for reading from and printing to the terminal.
library terminal;

import 'dart:async';
import 'dart:io';

import 'package:rougish/term/ansi.dart' as ansi;

/// start of heading
const sh = 0x01;

/// enquiry
const eq = 0x05;

/// backspace
const bs = 0x08;

/// horizontal tab
const ht = 0x09;

/// line feed / Enter
const lf = 0x0a;

/// carriage return / Enter
const cr = 0x0d;

/// escape
const esc = 0x1b;

/// delete
const del = 0x7f;

/// space
const printableLo = 0x20;

/// tilde
const printableHi = 0x7e;

/// keycode sequences that can be reported by the terminal
///
/// note: on the keyboards tested, the Delete key reported an escape sequence, not the ASCII [del] code of `0x7f`.
/// Linux and MacOS seem to use [del] for Backspace ([bs]).
enum SeqKey {
  none,
  arrowUp,
  arrowDown,
  arrowRight,
  arrowLeft,
  end,
  home,
  insert,
  delete,
  pageUp,
  pageDown,
  f1,
  f2,
  f3,
  f4,
  f5,
  f6,
  f7,
  f8,
  f9,
  f10,
  f11,
  f12,
}

// make these re-assignable to support test mocks and other options
//  curently, analyzer incorrectly flags:
//  https://github.com/dart-lang/linter/pull/3118
var print = (String msg) => stderr.write(msg);
var printBuffer = (StringBuffer sb) => stderr.write(sb.toString());

/// Determine whether a given sequence of codes represents a printable ASCII character.
/// This implementation only passes single code sequences from `0x20` to `0x7e`
/// (this excludes printable runes like emoji).
bool isPrintableAscii(List<int> seq) {
  if (seq.length != 1) {
    return false;
  }
  if (seq[0] < printableLo) {
    return false;
  }
  if (seq[0] > printableHi) {
    return false;
  }
  return true;
}

/// Determine whether a given sequence of codes represents the Backspace key.
///
/// Windows terminal reports backspace (`0x08`), while Linux shell reports delete (`0x7f`).
bool isBackspace(List<int> seq) {
  if (seq.length != 1) {
    return false;
  }
  if (seq[0] == bs) {
    return true;
  }
  if (seq[0] == del) {
    return true;
  }
  return false;
}

/// Determine whether a given sequence of codes represents the Enter / Return key.
///
/// Windows terminal reports a carriage return (`0x0d`), while Linux and MacOS shells report line feed (`0x0a`).
bool isEnter(List<int> seq) {
  if (seq.length != 1) {
    return false;
  }
  if (seq[0] == lf) {
    return true;
  }
  if (seq[0] == cr) {
    return true;
  }
  return false;
}

/// Create an iterable list of hex code strings from given key codes.
Iterable<String> codesToString(List<int> codes, {prefix = '0x'}) =>
    codes.map((e) => '${prefix}${e.toRadixString(16).padLeft(2, '0')}');

/// Create a string hash of the keycode sequence.
String codeHash(List<int> codes) {
  return codesToString(codes, prefix: '').join('');
}

/// Match a given [codeHash] value to a [SeqKey] enumeration, including [SeqKey.none] if no match.
SeqKey seqKeyFromCodeHash(String hash) {
  switch (hash) {
    case '1b5b41':
      return SeqKey.arrowUp;
    case '1b5b42':
      return SeqKey.arrowDown;
    case '1b5b43':
      return SeqKey.arrowRight;
    case '1b5b44':
      return SeqKey.arrowLeft;
    case '1b5b46':
      return SeqKey.end;
    case '1b5b47':
      return SeqKey.home;
    case '1b5b327e':
      return SeqKey.insert;
    case '1b5b337e':
      return SeqKey.delete;
    case '1b5b357e':
      return SeqKey.pageUp;
    case '1b5b367e':
      return SeqKey.pageDown;
    case '1b4f50':
      return SeqKey.f1;
    case '1b4f51':
      return SeqKey.f2;
    case '1b4f52':
      return SeqKey.f3;
    case '1b4f53':
      return SeqKey.f4;
    case '1b5b31357e':
      return SeqKey.f5;
    case '1b5b31377e':
      return SeqKey.f6;
    case '1b5b31387e':
      return SeqKey.f7;
    case '1b5b31397e':
      return SeqKey.f8;
    case '1b5b32307e':
      return SeqKey.f9;
    case '1b5b32317e':
      return SeqKey.f10;
    case '1b5b32337e':
      return SeqKey.f11;
    case '1b5b32347e':
      return SeqKey.f12;
  }
  return SeqKey.none;
}

/// Match a given code sequence to a [SeqKey] enumeration, including [SeqKey.none] if no match.
///
/// _Note:_ as of Dart 2.16.0, Windows does not recognize `ESC` or any key sequences that start with `ESC`.
/// See https://github.com/dart-lang/sdk/issues/48329
SeqKey seqKeyFromCodes(List<int> codes) {
  int n = codes.length;
  if (n < 3) {
    return SeqKey.none;
  }
  if (codes.first != esc) {
    return SeqKey.none;
  }

  if (codes[1] == 0x5b) {
    switch (codes[2]) {
      case 0x41:
        return SeqKey.arrowUp; //    [ 0x1b, 0x5b, 0x41 ] - \e[A Up Arrow
      case 0x42:
        return SeqKey.arrowDown; //  [ 0x1b, 0x5b, 0x42 ] - \e[B Down Arrow
      case 0x43:
        return SeqKey.arrowRight; // [ 0x1b, 0x5b, 0x43 ] - \e[C Right Arrow
      case 0x44:
        return SeqKey.arrowLeft; //  [ 0x1b, 0x5b, 0x44 ] - \e[D Left Arrow
      case 0x46:
        return SeqKey.end; //         [ 0x1b, 0x5b, 0x46 ] - \e[F End
      case 0x48:
        return SeqKey.home; //        [ 0x1b, 0x5b, 0x48 ] - \e[H Home
      case 0x31:
        if (n == 5 && codes.last == 0x7e) {
          switch (codes[3]) {
            case 0x35:
              return SeqKey.f5; // [ 0x1b, 0x5b, 0x31, 0x35, 0x7e ] - \e[15~ F5
            case 0x37:
              return SeqKey.f6; // [ 0x1b, 0x5b, 0x31, 0x37, 0x7e ] - \e[17~ F6
            case 0x38:
              return SeqKey.f7; // [ 0x1b, 0x5b, 0x31, 0x38, 0x7e ] - \e[18~ F7
            case 0x39:
              return SeqKey.f8; // [ 0x1b, 0x5b, 0x31, 0x39, 0x7e ] - \e[19~ F8
          }
        }
        break;
      case 0x32:
        if (codes.last == 0x7e) {
          if (n == 4) {
            return SeqKey.insert; //  [ 0x1b, 0x5b, 0x32, 0x7e ] - \e[2~ Insert
          }
          if (n == 5) {
            switch (codes[3]) {
              case 0x30:
                return SeqKey.f9; //  [ 0x1b, 0x5b, 0x32, 0x30, 0x7e ] - \e[20~ F9
              case 0x31:
                return SeqKey.f10; // [ 0x1b, 0x5b, 0x32, 0x31, 0x7e ] - \e[21~ F10
              case 0x33:
                return SeqKey.f11; //   [ 0x1b, 0x5b, 0x32, 0x33, 0x7e ] - \e[23~ F11
              case 0x34:
                return SeqKey.f12; // [ 0x1b, 0x5b, 0x32, 0x34, 0x7e ] - \e[24~ F12
            }
          }
        }
        break;
      case 0x33:
        if (n == 4 && codes.last == 0x7e) {
          return SeqKey.delete; //    [ 0x1b, 0x5b, 0x33, 0x7e ] - \e[3~ Delete
        }
        break;
      case 0x35:
        if (n == 4 && codes.last == 0x7e) {
          return SeqKey.pageUp; //   [ 0x1b, 0x5b, 0x35, 0x7e ] - \e[5~ PgUp
        }
        break;
      case 0x36:
        if (n == 4 && codes.last == 0x7e) {
          return SeqKey.pageDown; // [ 0x1b, 0x5b, 0x36, 0x7e ] - \e[6~ PgDn
        }
        break;
    }
  } else if (codes[1] == 0x4f) {
    switch (codes[2]) {
      case 0x50:
        return SeqKey.f1; // [ 0x1b, 0x4f, 0x50 ] - \eOP F1
      case 0x51:
        return SeqKey.f2; // [ 0x1b, 0x4f, 0x51 ] - \eOQ F2
      case 0x52:
        return SeqKey.f3; // [ 0x1b, 0x4f, 0x52 ] - \eOR F3
      case 0x53:
        return SeqKey.f4; // [ 0x1b, 0x4f, 0x53 ] - \eOS F4
    }
  }

  return SeqKey.none;
}

/// Retrieve terminal width (columns), and height (rows) as a two-element list.
List<int> size() {
  return [stderr.terminalColumns, stderr.terminalLines];
}

/// Subscribe a listener function for key sequences emitted from the terminal.
StreamSubscription<List<int>> listen(
    void Function(List<int>) dataHandler, void Function(Object error) errorHandler) {
  stdin
    ..echoMode = false // for windows sake, echoMode must be disabled first
    ..lineMode = false; // see https://github.com/dart-lang/sdk/issues/28599#issuecomment-615940833
  return stdin.listen(dataHandler, onError: errorHandler);
}

/// Emit the ANSI code to hide the cursor.
void hideCursor() {
  print(ansi.hide);
}

/// Emit the ANSI code to show the cursor.
void showCursor() {
  print(ansi.show);
}

/// Clear the screen and move the cursor to 0,0 (top left corner).
///
/// The provided stringbuffer is cleared and filled with ANSI codes to reset styles,
/// clear the screen, and position the cursor in the top left corner.
/// Optionally, scrollback history can be cleared, and the cursor can be hidden.
/// The provided stringbuffer is left empty.
void clear(StringBuffer sb, {hideCursor = false, clearHistory = false}) {
  sb.clear();
  ansi.reset(sb);
  ansi.xy(sb, 1, 1);
  if (clearHistory) {
    sb.write(ansi.ris);
  } else {
    ansi.cls(sb, n: 2);
  }
  if (hideCursor) {
    sb.write(ansi.hide);
  }
  printBuffer(sb);
  sb.clear();
}

/// Add ANSI codes to the provided string buffer to print a message at specific coordinates of the screen.
/// The provided stringbuffer is concatened to (not cleared). The buffer is not sent to stderr in this method (see [printBuffer]).
///
/// [xPos] sets the horizontal position of the message.
/// [yPos] sets the vertical position of the message.
/// [cll] if `true`, clears the row before printing.
void placeMessage(StringBuffer sb, String msg, {int xPos = 0, int yPos = 0, bool cll = false}) {
  //sb.clear();
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
  List<int> dim = size();
  int x = (dim[0] * xPercent / 100).floor() + xOffset;
  int y = (dim[1] * yPercent / 100).floor() + yOffset;
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
  List<int> dim = size();
  int x = (dim[0] / 2).floor() - ((msg.length + msgOffset) / 2).floor() + xOffset;
  int y = (dim[1] / 2).floor() + yOffset;
  placeMessage(sb, msg, xPos: x, yPos: y, cll: cll);
}
