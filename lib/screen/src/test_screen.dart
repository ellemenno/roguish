import 'package:rougish/game/game_data.dart';
import 'package:rougish/game/map.dart' as map;
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class TestScreen extends Screen {
  final StringBuffer _charSeq = StringBuffer();
  final StringBuffer _nextMsg = StringBuffer();

  void _announceSize(StringBuffer sb) {
    List<int> dim = term.size();
    term.centerMessage(sb, 'terminal is ${dim[0]} columns x ${dim[1]} lines', yOffset: -2);
  }

  void _stateMessage(StringBuffer sb) {
    term.centerMessage(sb, '${_nextMsg}', yOffset: -1);
  }

  void _paintSymbols(StringBuffer sb) {
    term.placeMessage(sb, '      ui: ', xPos: 0, yPos: 3);
    for (var t in map.UIType.values) {
      sb.write(map.uiSymbol(t));
    }
    sb.write('\n');
    sb.write('          ');
    for (var i = 0; i < map.UIType.values.length; i++) {
      sb.write('-');
    }

    sb.write('\n');
    sb.write('    cell: ');
    for (var t in map.CellType.values) {
      sb.write(map.cellSymbol(t));
    }
    sb.write('\n');
    sb.write('          ');
    for (var i = 0; i < map.CellType.values.length; i++) {
      sb.write('-');
    }

    sb.write('\n');
    sb.write('creature: ');
    for (var t in map.CreatureType.values) {
      sb.write(map.creatureSymbol(t));
    }
    sb.write('\n');
    sb.write('          ');
    for (var i = 0; i < map.CreatureType.values.length; i++) {
      sb.write('-');
    }

    sb.write('\n');
    sb.write('    item: ');
    for (var t in map.ItemType.values) {
      sb.write(map.itemSymbol(t));
    }
    sb.write('\n');
    sb.write('          ');
    for (var i = 0; i < map.ItemType.values.length; i++) {
      sb.write('-');
    }
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
    _announceSize(screenBuffer);
    _stateMessage(screenBuffer);
    _paintSymbols(screenBuffer);

    term.centerMessage(screenBuffer, 'listening for keys. ${state.conf['key-pause']} for menu.',
        yOffset: 3);
  }
}
