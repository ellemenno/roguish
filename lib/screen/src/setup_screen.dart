import 'package:roguish/game/game_data.dart';
import 'package:roguish/game/map.dart';
import 'package:roguish/log/log.dart';
import 'package:roguish/term/ansi.dart' as ansi;
import 'package:roguish/term/terminal.dart' as term;
import '../screen.dart';

class SetupScreen extends Screen {
  static const _logLabel = 'SetupScreen';

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {
    if (term.isEnter(seq)) {
      Log.info(_logLabel, 'Enter key detected. advancing to level 1..');
      state.players.add(Creature(CreatureType.humanPlayer));
      broadcast(ScreenEvent.setupToLevel);
    }
  }

  @override
  void draw(GameData state) {
    Screen.screenBuffer.centerMessage('setup screen', yOffset: -3);
    Screen.screenBuffer
        .centerMessage('choose number of players: [${ansi.flip}1${ansi.flop}] [2]', yOffset: 1);
    Screen.screenBuffer.centerMessage('<press Enter key to begin>', yOffset: 3);
  }
}
