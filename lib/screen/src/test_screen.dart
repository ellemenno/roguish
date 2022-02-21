import 'dart:math';

import 'package:rougish/game/game_data.dart';
import 'package:rougish/term/ansi.dart' as ansi;
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class TestScreen extends Screen {
  final StringBuffer _charSeq = StringBuffer();
  final StringBuffer _nextMsg = StringBuffer();
  final _rnd = Random();

  void _testAnsi(StringBuffer sb) {
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

  void _blockAt(StringBuffer sb, int x, int y, {int color = 0xffffff}) {
    ansi.xy(sb, x, y);
    ansi.cRGB(sb, '+', fg: 0, bg: color);
    ansi.reset(sb);
  }

  void _randoBlocks(StringBuffer sb, {n = 5}) {
    List<int> dim = term.size();
    int x, y;
    sb.clear();
    for (var i = 0; i < n; i++) {
      x = _rnd.nextInt(dim[0]) + 1;
      y = _rnd.nextInt(dim[1]) + 1;
      _blockAt(sb, x, y, color: 0x004585);
    }
    term.printBuffer(sb);
  }

  void _announceSize(StringBuffer sb) {
    List<int> dim = term.size();
    term.centerMessage(sb, 'terminal is ${dim[0]} columns x ${dim[1]} lines', yOffset: -2);
  }

  void _stateMessage(StringBuffer sb) {
    term.centerMessage(sb, '${_nextMsg}', yOffset: -1);
  }

  void _paintCorners(StringBuffer sb) {
    List<int> dim = term.size();
    sb.clear();
    _blockAt(sb, 1, 1);
    _blockAt(sb, dim[0], 1);
    _blockAt(sb, dim[0], dim[1]);
    _blockAt(sb, 1, dim[1]);
    term.printBuffer(sb);
  }

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {
    if (!term.isPrintableAscii(seq)) {
      return;
    }

    _charSeq.write(String.fromCharCode(seq[0]));
    if (_charSeq.length > 3) {
      _nextMsg.clear();
      _nextMsg.write(_charSeq);
      _charSeq.clear();
    }
  }

  @override
  void draw(GameData state) {
    term.clear(screenBuffer, hideCursor: true, clearHistory: true);

    _randoBlocks(screenBuffer, n: 35);
    _testAnsi(screenBuffer);
    _announceSize(screenBuffer);
    _stateMessage(screenBuffer);
    _paintCorners(screenBuffer);

    term.centerMessage(screenBuffer, 'listening for keys. ${state.conf['key-pause']} for menu.',
        yOffset: 3);
  }
}
