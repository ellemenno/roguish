import 'package:rougish/game/game_data.dart';
import 'package:rougish/log/log.dart';
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class TitleScreen extends Screen {
  static const _logLabel = 'TitleScreen';

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {
    if (term.isEnter(seq)) {
      Log.info(_logLabel, 'Enter key detected. advancing to title..');
      broadcast(ScreenEvent.titleToSetup);
    }
  }

  @override
  void draw(GameData state) {
    term.centerMessage(screenBuffer, 'Rougish', yOffset: -3);
    term.centerMessage(screenBuffer, '<press Enter key to continue>', yOffset: 3);
  }
}
