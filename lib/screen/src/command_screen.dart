import 'package:rougish/config/config.dart' as config;
import 'package:rougish/game/game_data.dart';
import 'package:rougish/log/log.dart';
import 'package:rougish/term/terminal.dart' as term;
import 'package:rougish/term/typing_buffer.dart';
import '../screen.dart';

class CommandScreen extends Screen {
  static const logLabel = 'CommandScreen';
  final StringBuffer _cmd = StringBuffer();
  final TypingBuffer _input = TypingBuffer();

  ScreenEvent parseCommand(StringBuffer commandBuffer) {
    String cmd = commandBuffer.toString();

    List<String> parts = cmd.split(' ');
    Log.debug(logLabel, 'parseCommand: ${parts}');

    switch (parts.first) {
      case 'quit':
        return ScreenEvent.quit;
    }
    return ScreenEvent.nothing;
  }

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {
    Log.debug(logLabel, 'onKeySequence: ${hash}');

    ScreenEvent todo = ScreenEvent.nothing;

    if (config.isCommandBar(hash)) {
      todo = ScreenEvent.hideCommandBar;
    } else if (term.isEnter(seq)) {
      _input.toStringBuffer(_cmd, withFormatting: false);
      _input.clear();
      todo = parseCommand(_cmd);
    } else if (config.isCursorLeft(hash)) {
      _input.cursorLeft();
    } else if (config.isCursorRight(hash)) {
      _input.cursorRight();
    } else if (term.isBackspace(seq)) {
      _input.backspace();
    } else if (term.seqKeyFromCodeHash(hash) == term.SeqKey.delete) {
      _input.delete();
    } else if (seq[0] == term.sh) {
      _input.cursorStart();
    } else if (seq[0] == term.eq) {
      _input.cursorEnd();
    }
    // process printables after control keys
    else if (term.isPrintableAscii(seq)) {
      _input.write(seq[0]);
    }

    if (_input.modified) {
      _input.resetModified();
      draw(state);
    }

    if (todo != ScreenEvent.nothing) {
      broadcast(todo);
    }
  }

  @override
  void draw(GameData state) {
    _input.toStringBuffer(_cmd);
    term.placeMessage(screenBuffer, '> ${_cmd}', xPos: 0, yPos: 0, cll: true);
  }
}
