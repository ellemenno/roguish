import 'package:rougish/config/config.dart' as config;
import 'package:rougish/game/game_data.dart';
import 'package:rougish/game/map.dart' as map;
import 'package:rougish/log/log.dart';
import 'package:rougish/term/scanline_buffer.dart';
import '../screen.dart';

class LevelScreen extends Screen {
  static const _logLabel = 'LevelScreen';
  final _dim = List<int>.filled(2, 0);

  void _newLevel(ScanlineBuffer screenBuffer, GameData state) {
    state.newLevel = false;
    screenBuffer.size(_dim);
    // leave a row at the top and bottom for the ui
    int cols = _dim[0], rows = _dim[1] - 2;
    Log.debug(_logLabel, 'draw() new level - level: ${state.level}, rows: ${rows}, cols: ${cols}');
    // if new dimensions:  dispose, allocate, generate
    // if empty:           ..       allocate, generate
    // if same dimensions: ..       ..        generate (will handle reset internally)
    if (rows != state.levelMap.length || cols != state.levelMap.first.length) {
      Log.debug(_logLabel, 'draw() new dimensions require map reallocation');
      if (state.levelMap.isNotEmpty) {
        map.LevelGenerator.dispose(state.levelMap, state.rooms, state.players);
      }
      map.LevelGenerator.allocate(state.levelMap, cols, rows);
    }
    map.LevelGenerator.generate(
        state.levelMap, state.rooms, state.players, state.prng, state.level, state.levelMax);
  }

  void _drawMap(ScanlineBuffer screenBuffer, GameData state) {
    screenBuffer.placeMessage('', yPos: 1, cll: true);
    map.LevelManager.render(screenBuffer, state.levelMap, yOffset: 1);
  }

  void _drawUI(ScanlineBuffer screenBuffer, GameData state) {
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
    screenBuffer.placeMessageRelative(msg, yPercent: 100);
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
      _newLevel(Screen.screenBuffer, state);
    }
    _drawMap(Screen.screenBuffer, state);
    _drawUI(Screen.screenBuffer, state);
  }
}
