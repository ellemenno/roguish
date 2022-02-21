import 'package:rougish/game/game_data.dart';
import 'package:rougish/log/log.dart';
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class SetupScreen extends Screen {
  static const logLabel = 'SetupScreen';

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {
    Log.info(logLabel, '${hash}');
  }

  @override
  void draw(StringBuffer buffer, GameData state) {
    term.clear(buffer, hideCursor: true, clearHistory: true);
    term.centerMessage(buffer, 'setup screen');
  }
}
