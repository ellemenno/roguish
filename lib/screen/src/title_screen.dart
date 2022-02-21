import 'package:rougish/game/game_data.dart';
import 'package:rougish/log/log.dart';
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class TitleScreen extends Screen {
  static const logLabel = 'TitleScreen';

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {
    Log.info(logLabel, 'any key detected. advancing to title..');
    broadcast(ScreenEvent.titleToSetup);
  }

  @override
  void draw(StringBuffer buffer, GameData state) {
    term.clear(buffer, hideCursor: true, clearHistory: true);
    term.centerMessage(buffer, 'Rougish', yOffset: -3);
    term.centerMessage(buffer, '<press any key to begin>', yOffset: 3);
  }
}
