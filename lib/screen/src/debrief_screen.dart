import 'package:roguish/game/game_data.dart';
import 'package:roguish/log/log.dart';
import 'package:roguish/term/terminal.dart' as term;
import '../screen.dart';

class DebriefScreen extends Screen {
  static const _logLabel = 'DebriefScreen';

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {
    if (term.isEnter(seq)) {
      Log.info(_logLabel, 'Enter key detected. Exiting game..');
      broadcast(ScreenEvent.quit);
    }
  }

  @override
  void draw(GameData state) {
    Screen.screenBuffer.centerMessage('debrief screen', yOffset: -3);
    Screen.screenBuffer.centerMessage('stats and stuff..', yOffset: 1);
    Screen.screenBuffer.centerMessage('<press Enter key to exit>', yOffset: 3);
  }
}
