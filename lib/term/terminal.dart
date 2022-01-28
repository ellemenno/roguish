
import 'dart:async';
import 'dart:io';

import 'package:rougish/term/ansi.dart' as ansi;

const HT  = 0x09; // horizontal tab
const LF  = 0x0a; // line feed / Enter
const ESC = 0x1b; // escape
const BS  = 0x7f; // backspace
const PRINTABLE_LO = 0x20; // space
const PRINTABLE_HI = 0x7e; // tilde

enum SeqKey {
  NONE,
  ARROW_UP, ARROW_DOWN, ARROW_RIGHT, ARROW_LEFT,
  END, HOME,
  INSERT, DELETE,
  PAGE_UP, PAGE_DOWN,
  F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12,
}

// make these re-assignable to support test mocks and other options
var print = (String msg) => stderr.write(msg);
var printBuffer = (StringBuffer sb) => stderr.write(sb.toString());


SeqKey seqKeyFromCodes(List<int> codes) {
  int n = codes.length;
  if (n < 3) { return SeqKey.NONE; }
  if (codes.first != ESC) { return SeqKey.NONE; }

  if (codes[1] == 0x5b) { // \e[
    switch(codes[2]) {
      case 0x41: return SeqKey.ARROW_UP;      // [ 0x1b, 0x5b, 0x41 ] - \e[A Up Arrow
      case 0x42: return SeqKey.ARROW_DOWN;    // [ 0x1b, 0x5b, 0x42 ] - \e[B Down Arrow
      case 0x43: return SeqKey.ARROW_RIGHT;   // [ 0x1b, 0x5b, 0x43 ] - \e[C Right Arrow
      case 0x44: return SeqKey.ARROW_LEFT;    // [ 0x1b, 0x5b, 0x44 ] - \e[D Left Arrow
      case 0x46: return SeqKey.END;           // [ 0x1b, 0x5b, 0x46 ] - \e[F End
      case 0x48: return SeqKey.HOME;          // [ 0x1b, 0x5b, 0x48 ] - \e[H Home
      case 0x31:
        if (n == 5 && codes.last == 0x7e) {
          switch(codes[3]) {
            case 0x35: return SeqKey.F5;        // [ 0x1b, 0x5b, 0x31, 0x35, 0x7e ] - \e[15~ F5
            case 0x37: return SeqKey.F6;        // [ 0x1b, 0x5b, 0x31, 0x37, 0x7e ] - \e[17~ F6
            case 0x38: return SeqKey.F7;        // [ 0x1b, 0x5b, 0x31, 0x38, 0x7e ] - \e[18~ F7
            case 0x39: return SeqKey.F8;        // [ 0x1b, 0x5b, 0x31, 0x39, 0x7e ] - \e[19~ F8
          }
        }
        break;
      case 0x32:
        if (codes.last == 0x7e) {
          if (n == 4) { return SeqKey.INSERT; } // [ 0x1b, 0x5b, 0x32, 0x7e ] - \e[2~ Insert
          if (n == 5) {
            switch(codes[3]) {
              case 0x30: return SeqKey.F9;      // [ 0x1b, 0x5b, 0x32, 0x30, 0x7e ] - \e[20~ F9
              case 0x31: return SeqKey.F10;     // [ 0x1b, 0x5b, 0x32, 0x31, 0x7e ] - \e[21~ F10
              //case 0x: return SeqKey.F11;     // [ 0x1b, 0x5b, 0x32, 0x??, 0x7e ] - \e[2?~ F11
              case 0x34: return SeqKey.F12;     // [ 0x1b, 0x5b, 0x32, 0x34, 0x7e ] - \e[24~ F12
            }
          }
        }
        break;
      case 0x33:
        if (n == 4 && codes.last == 0x7e) { return SeqKey.DELETE; }    // [ 0x1b, 0x5b, 0x33, 0x7e ] - \e[3~ Delete
        break;
      case 0x35:
        if (n == 4 && codes.last == 0x7e) { return SeqKey.PAGE_UP; }   // [ 0x1b, 0x5b, 0x35, 0x7e ] - \e[5~ PgUp
        break;
      case 0x36:
        if (n == 4 && codes.last == 0x7e) { return SeqKey.PAGE_DOWN; } // [ 0x1b, 0x5b, 0x36, 0x7e ] - \e[6~ PgDn
        break;
    }
  }
  else if (codes[1] == 0x4f) { // \eO
    switch(codes[2]) {
      case 0x50: return SeqKey.F1; // [ 0x1b, 0x4f, 0x50 ] - \eOP F1
      case 0x51: return SeqKey.F2; // [ 0x1b, 0x4f, 0x51 ] - \eOQ F2
      case 0x52: return SeqKey.F3; // [ 0x1b, 0x4f, 0x52 ] - \eOR F3
      case 0x53: return SeqKey.F4; // [ 0x1b, 0x4f, 0x53 ] - \eOS F4
    }
  }

  return SeqKey.NONE;
}

List<int> size() {
  return [stderr.terminalColumns, stderr.terminalLines];
}

StreamSubscription<List<int>> listen(void Function(List<int>) dataHandler) {
  stdin
    ..lineMode = false
    ..echoMode = false;
  return stdin.listen(dataHandler);
}

void hideCursor() {
  print(ansi.HIDE);
}

void showCursor() {
  print(ansi.SHOW);
}

void clear(StringBuffer sb) {
  sb.clear();
  ansi.reset(sb);
  ansi.xy(sb, 1, 1);
  ansi.cls(sb, n: 2);
  printBuffer(sb);
}

void centerMessage(StringBuffer sb, String msg, {int xOffset: 0, int yOffset: 0, int msgOffset: 0}) {
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
