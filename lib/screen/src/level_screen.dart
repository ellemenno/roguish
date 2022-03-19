import 'package:rougish/config/config.dart' as config;
import 'package:rougish/game/game_data.dart';
import 'package:rougish/game/map.dart' as map;
import 'package:rougish/log/log.dart';
import 'package:rougish/term/ansi.dart' as ansi;
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class LevelScreen extends Screen {
  static const logLabel = 'LevelScreen';

  List<int> _mapSize() {
    List<int> dim = term.size();
    // leave a row at the top and bottom for the ui
    dim[1] -= 2;
    return dim;
  }

  void _drawMap(StringBuffer screenBuffer, GameData state) {
    ansi.xy(screenBuffer, 0, 2);
    map.LevelManager.render(screenBuffer, state.levelMap);
  }

  void _drawUI(StringBuffer screenBuffer, GameData state) {
    //    ≡ 1  xp 00  ♥ 00    + 00  ᚹ 00  ⚘ 00  $ 0
    String msg = ''
        '  '
        '  ${map.uiSymbol(map.UIType.level)} ${state.level}'
        '  xp ${state.experience.toString().padLeft(2, '0')}'
        '  ${map.uiSymbol(map.UIType.health)} ${state.health.toString().padLeft(2, '0')}'
        '  '
        '  ${map.uiSymbol(map.UIType.strength)} ${state.strength.toString().padLeft(2, '0')}'
        '  ${map.uiSymbol(map.UIType.runes)} ${state.runes.toString().padLeft(2, '0')}'
        '  ${map.uiSymbol(map.UIType.herbs)} ${state.herbs.toString().padLeft(2, '0')}'
        '  ${map.uiSymbol(map.UIType.coins)} ${state.coins}';
    term.placeMessageRelative(screenBuffer, msg, yPercent: 100);
  }

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {
    if (config.isUp(hash)) {
      // player towards N
      map.LevelManager.towards(state.levelMap, state.players.first, 0, -1);
    } else if (config.isRight(hash)) {
      // player towards E
      map.LevelManager.towards(state.levelMap, state.players.first, 1, 0);
    } else if (config.isDown(hash)) {
      // player towards S
      map.LevelManager.towards(state.levelMap, state.players.first, 0, 1);
    } else if (config.isLeft(hash)) {
      // player towards W
      map.LevelManager.towards(state.levelMap, state.players.first, -1, 0);
    }
  }

  @override
  void draw(GameData state) {
    if (state.newLevel) {
      state.newLevel = false;
      List<int> dim = _mapSize();
      int cols = dim[0], rows = dim[1];
      Log.debug(logLabel, 'draw() new map - rows: ${rows}, cols: ${cols}');
      // if new dimensions:  dispose, allocate, generate
      // if empty:           ..       allocate, generate
      // if same dimensions: ..       ..        generate (will handle reset internally)
      if (rows != state.levelMap.length || cols != state.levelMap.first.length) {
        Log.debug(logLabel, 'draw() new dimensions require new map');
        if (state.levelMap.isNotEmpty) {
          map.LevelGenerator.dispose(state.levelMap, state.rooms, state.players);
        }
        map.LevelGenerator.allocate(state.levelMap, cols, rows);
      }
      map.LevelGenerator.generate(state.levelMap, state.rooms, state.players, state.prng);
    }
    _drawMap(screenBuffer, state);
    _drawUI(screenBuffer, state);
  }
}
