import 'package:rougish/game/game_data.dart';
import 'package:rougish/log/log.dart';
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class LevelScreen extends Screen {
  static const logLabel = 'LevelScreen';

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {
  }

  @override
  void draw(GameData state) {
    if (state.levelMap.length == 0) {
      term.centerMessage(screenBuffer, 'time to make the donuts!', yOffset: 0);
      //mapMaker.generate(state.levelMap);
    }
    // TODO: draw state.levelMap
  }
}
