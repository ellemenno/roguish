/// utilities for reading from and printing to the terminal.
library terminal;

import 'dart:async';
import 'dart:io';

import 'package:rougish/term/ansi.dart' as ansi;

/// horizontal tab
const ht = 0x09;

/// line feed / Enter
const lf = 0x0a;

/// escape
const esc = 0x1b;

/// backspace
const bs = 0x7f;

/// space
const printableLo = 0x20;

/// tilde
const printableHi = 0x7e;

/// keycode sequences that can be reported by the terminal
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

/// Match a given code sequence to a [SeqKey] enumeration, including [SeqKey.none] if no match.
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
              //case 0x??:
              //return SeqKey.f11; // [ 0x1b, 0x5b, 0x32, 0x??, 0x7e ] - \e[2?~ F11
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
StreamSubscription<List<int>> listen(void Function(List<int>) dataHandler) {
  stdin
    ..echoMode = false // for windows sake, echoMode must be disabled first
    ..lineMode = false; // see https://github.com/dart-lang/sdk/issues/28599#issuecomment-615940833
  return stdin.listen(dataHandler);
}

/// Emit the ANSI code to hide the cursor.
void hideCursor() {
  print(ansi.hide);
}

/// Emit the ANSI code to show the cursor.
void showCursor() {
  print(ansi.show);
}

/// Clear the screen and reset the cursor.
///
/// The provided stringbuffer is cleared and filled with ANSI codes to reset styles,
/// clear the screen, and position the cursor in the top left corner.
void clear(StringBuffer sb) {
  sb.clear();
  ansi.reset(sb);
  ansi.xy(sb, 1, 1);
  ansi.cls(sb, n: 2);
  printBuffer(sb);
}

/// Print the provided message in the middle of the screen.
///
/// The provided stringbuffer is cleared and used to assemble the string to print.
/// [xOffset] adjusts the horizontal position of the message.
/// [yOffset] adjusts the vertical position of the message.
/// [msgOffset] adjusts the calculated length of the message before centering.
/// The entire row is cleared before the message is printed.
void centerMessage(StringBuffer sb, String msg,
    {int xOffset = 0, int yOffset = 0, int msgOffset = 0}) {
  List<int> dim = size();
  int x = (dim[0] / 2).floor() - ((msg.length + msgOffset) / 2).floor() + xOffset;
  int y = (dim[1] / 2).floor() + yOffset;
  sb.clear();
  ansi.xy(sb, x, y);
  ansi.cll(sb);
  sb.write(msg);
  ansi.reset(sb);
  printBuffer(sb);
}
