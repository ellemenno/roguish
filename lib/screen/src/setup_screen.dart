import 'package:rougish/game/game_data.dart';
import 'package:rougish/log/log.dart';
import 'package:rougish/term/ansi.dart' as ansi;
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class SetupScreen extends Screen {
  static const logLabel = 'SetupScreen';

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {
    if (term.isEnter(seq)) {
      Log.info(logLabel, 'Enter key detected. advancing to level 1..');
      broadcast(ScreenEvent.setupToLevel);
    }
  }

  @override
  void draw(GameData state) {
    term.clear(screenBuffer, hideCursor: true, clearHistory: true);
    term.centerMessage(screenBuffer, 'setup screen', yOffset: -3);
    term.centerMessage(screenBuffer, 'choose number of players: [${ansi.flip}1${ansi.flop}] [2]', yOffset: 1);
    term.centerMessage(screenBuffer, '<press Enter key to begin>', yOffset: 3);
  }
}
