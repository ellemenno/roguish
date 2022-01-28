import 'dart:math';

import 'package:rougish/term/ansi.dart' as ansi;
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class TestScreen extends Screen {
  final StringBuffer _charSeq = StringBuffer();
  final StringBuffer _nextMsg = StringBuffer();
  final _rnd = Random();

  void testAnsi(StringBuffer sb) {
    // c16: (0=black, 1=red, 2=green, 3=yellow, 4=blue, 5=magenta, 6=cyan, 7=white)
    sb.clear();
    ansi.xy(sb, 1, 3);
    ansi.c16(sb, 'blue', fg: 6, bg: 4, fb: true);
    sb.write(' ');
    ansi.c16(sb, 'red', fg: 5, bg: 1, fb: true);
    sb.write(' ');
    ansi.c16(sb, 'green', fg: 2, bg: 2, fb: true);
    sb.write('\n');
    ansi.cRGB(sb, 'blornge', fg: 0xf7ac6e, bg: 0x004585);
    sb.write('\n');
    term.printBuffer(sb);
  }

  void blockAt(StringBuffer sb, int x, int y, {int color = 0xffffff}) {
    ansi.xy(sb, x, y);
    ansi.cRGB(sb, '+', fg: 0, bg: color);
    ansi.reset(sb);
  }

  void randoBlocks(StringBuffer sb, {n = 5}) {
    List<int> dim = term.size();
    int x, y;
    sb.clear();
    Iterable.generate(n).forEach((i) {
      x = _rnd.nextInt(dim[0]) + 1;
      y = _rnd.nextInt(dim[1]) + 1;
      blockAt(sb, x, y, color: 0x004585);
    });
    term.printBuffer(sb);
  }

  void announceSize(StringBuffer sb) {
    List<int> dim = term.size();
    term.centerMessage(sb, 'terminal is ${dim[0]} columns x ${dim[1]} lines', yOffset: -2);
  }

  void stateMessage(StringBuffer sb) {
    term.centerMessage(sb, '${_nextMsg}', yOffset: -1);
  }

  void paintCorners(StringBuffer sb) {
    List<int> dim = term.size();
    sb.clear();
    blockAt(sb, 1, 1);
    blockAt(sb, dim[0], 1);
    blockAt(sb, dim[0], dim[1]);
    blockAt(sb, 1, dim[1]);
    term.printBuffer(sb);
  }

  void onControlCode(int code) {/* no-op */}
  void onControlSequence(List<int> codes) {/* no-op */}

  void onString(String string) {
    _charSeq.write(string);
    if (_charSeq.length > 3) {
      _nextMsg.clear();
      _nextMsg.write(_charSeq);
      _charSeq.clear();
    }
  }

  void draw(StringBuffer sb) {
    term.clear(sb);

    randoBlocks(sb, n: 35);
    testAnsi(sb);
    announceSize(sb);
    stateMessage(sb);
    paintCorners(sb);
  }
}
