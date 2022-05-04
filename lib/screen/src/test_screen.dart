import 'package:rougish/game/game_data.dart';
import 'package:rougish/game/map.dart' as map;
import 'package:rougish/term/scanline_buffer.dart';
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class TestScreen extends Screen {
  final StringBuffer _charSeq = StringBuffer();
  final _dim = List<int>.filled(2, 0);

  void _announceSize(ScanlineBuffer sb) {
    sb.size(_dim);
    sb.centerMessage('terminal is ${_dim[0]} columns x ${_dim[1]} lines', yOffset: 0);
  }

  void _printInput(ScanlineBuffer sb) {
    sb.centerMessage('${_charSeq}', yOffset: 3);
    _charSeq.clear();
  }

  void _paintSymbols(ScanlineBuffer sb) {
    String s = '';
    int y = 2;
    sb.placeMessage('font check for symbol coverage', xPos: 1, yPos: y);

    y++; s = '';
    sb.placeMessage('      ui: ', yPos: y++);
    for (var t in map.UIType.values) {
      s += map.uiSymbol(t);
    }
    sb.placeMessage(s, yPos: y++);
    s = '          ';
    for (var i = 0; i < map.UIType.values.length; i++) {
      s += '-';
    }
    sb.placeMessage(s, yPos: y++);

    y++; s = '';
    sb.placeMessage('    cell: ', yPos: y++);
    for (var t in map.CellType.values) {
      s += map.cellSymbol(t);
    }
    sb.placeMessage(s, yPos: y++);
    s = '          ';
    for (var i = 0; i < map.CellType.values.length; i++) {
      s += '-';
    }
    sb.placeMessage(s, yPos: y++);

    y++; s = '';
    sb.placeMessage('creature: ', yPos: y++);
    for (var t in map.CreatureType.values) {
      s += map.creatureSymbol(t);
    }
    sb.placeMessage(s, yPos: y++);
    s = '          ';
    for (var i = 0; i < map.CreatureType.values.length; i++) {
      s += '-';
    }
    sb.placeMessage(s, yPos: y++);

    y++; s = '';
    sb.placeMessage('    item: ', yPos: y++);
    for (var t in map.ItemType.values) {
      s += map.itemSymbol(t);
    }
    sb.placeMessage(s, yPos: y++);
    s = '          ';
    for (var i = 0; i < map.ItemType.values.length; i++) {
      s += '-';
    }
    sb.placeMessage(s, yPos: y++);
  }

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {
    _charSeq.write(term.asciiToString(seq[0]));
  }

  @override
  void draw(GameData state) {
    _announceSize(Screen.screenBuffer);
    _printInput(Screen.screenBuffer);
    _paintSymbols(Screen.screenBuffer);

    int pauseCode = int.parse(state.conf['key-pause']!);
    int commandCode = int.parse(state.conf['key-command']!);
    Screen.screenBuffer.centerMessage(
        [
          'listening for keys.',
          '${term.asciiToString(pauseCode)} for menu.',
          '${term.asciiToString(commandCode)} for command bar.',
        ].join(' '),
        yOffset: 2);
  }
}
