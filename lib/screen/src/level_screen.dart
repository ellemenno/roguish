import 'package:rougish/game/game_data.dart';
import 'package:rougish/game/map.dart';
import 'package:rougish/log/log.dart';
import 'package:rougish/term/ansi.dart' as ansi;
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class LevelScreen extends Screen {
  static const logLabel = 'LevelScreen';

  void _drawMap(StringBuffer screenBuffer, GameData state) {
    ansi.xy(screenBuffer, 0, 2);
    MapMaker.render(screenBuffer, state.levelMap);
  }

  void _drawUI(StringBuffer screenBuffer, GameData state) {
    //    ≡ 1  xp 00  ♥ 00    + 00  ᚹ 00  ⚘ 00  $ 0
    String msg = ''
        '  '
        '  ${uiSymbol(UIType.level)} ${state.level}'
        '  xp ${state.experience.toString().padLeft(2, '0')}'
        '  ${uiSymbol(UIType.health)} ${state.health.toString().padLeft(2, '0')}'
        '  '
        '  ${uiSymbol(UIType.strength)} ${state.strength.toString().padLeft(2, '0')}'
        '  ${uiSymbol(UIType.runes)} ${state.runes.toString().padLeft(2, '0')}'
        '  ${uiSymbol(UIType.herbs)} ${state.herbs.toString().padLeft(2, '0')}'
        '  ${uiSymbol(UIType.coins)} ${state.coins}';
    term.placeMessageRelative(screenBuffer, msg, yPercent: 100);
  }

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {}

  @override
  void draw(GameData state) {
    if (state.levelMap.isEmpty) {
      List<int> dim = term.size();
      // leave a row at the top and bottom for the ui
      MapMaker.generate(state.levelMap, cols: dim[0], rows: dim[1] - 2);
      Log.debug(logLabel, '${state.levelMap}');
    }
    _drawMap(screenBuffer, state);
    _drawUI(screenBuffer, state);
  }
}
