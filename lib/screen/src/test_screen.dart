import 'package:rougish/game/game_data.dart';
import 'package:rougish/game/map.dart' as map;
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class TestScreen extends Screen {
  final StringBuffer _charSeq = StringBuffer();

  void _announceSize(StringBuffer sb) {
    List<int> dim = term.size();
    term.centerMessage(sb, 'terminal is ${dim[0]} columns x ${dim[1]} lines', yOffset: 0);
  }

  void _printInput(StringBuffer sb) {
    term.centerMessage(sb, '${_charSeq}', yOffset: 3);
    _charSeq.clear();
  }

  void _paintSymbols(StringBuffer sb) {
    term.placeMessage(sb, 'font check for symbol coverage', xPos:0, yPos: 2);
    term.placeMessage(sb, '      ui: ', xPos: 0, yPos: 4);
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
    _charSeq.write(term.asciiToString(seq[0]));
  }

  @override
  void draw(GameData state) {
    _announceSize(screenBuffer);
    _printInput(screenBuffer);
    _paintSymbols(screenBuffer);

    int pauseCode = int.parse(state.conf['key-pause']!);
    int commandCode = int.parse(state.conf['key-command']!);
    term.centerMessage(
      screenBuffer,
      [
        'listening for keys.',
        '${term.asciiToString(pauseCode)} for menu.',
        '${term.asciiToString(commandCode)} for command bar.',
      ].join(' '),
      yOffset: 2
    );
  }
}
