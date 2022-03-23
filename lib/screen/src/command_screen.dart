import 'package:rougish/config/config.dart' as config;
import 'package:rougish/game/game_data.dart';
import 'package:rougish/log/log.dart';
import 'package:rougish/term/terminal.dart' as term;
import 'package:rougish/term/typing_buffer.dart';
import '../screen.dart';

class CommandScreen extends Screen {
  static const _logLabel = 'CommandScreen';
  final StringBuffer _cmd = StringBuffer();
  final TypingBuffer _input = TypingBuffer();

  ScreenEvent parseCommand(StringBuffer commandBuffer, GameData state) {
    String cmd = commandBuffer.toString();

    List<String> parts = cmd.split(' ');
    Log.debug(_logLabel, 'parseCommand() ${parts}');
    state.cmdArgs.clear();

    switch (parts.first) {
      case 'quit':
      case 'exit':
        return ScreenEvent.quit;
      case 'debrief':
        return ScreenEvent.debrief;
      case 'level':
        if (parts.length != 2) {
          Log.warn(
              _logLabel, '.. expected one arg for level, got ${parts.length - 1} values instead');
          break;
        }
        if (int.tryParse(parts[1]) != null) {
          state.cmdArgs.add(parts[1]);
          return ScreenEvent.setLevel;
        } else {
          Log.warn(_logLabel, '.. invalid level: ${parts[1]} (expected int)');
          break;
        }
      case 'regen':
        return ScreenEvent.regen;
      case 'title':
        return ScreenEvent.title;
    }
    return ScreenEvent.nothing;
  }

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {
    ScreenEvent todo = ScreenEvent.nothing;

    if (config.isCommandBar(hash)) {
      todo = ScreenEvent.hideCommandBar;
    } else if (term.isEnter(seq)) {
      _input.toStringBuffer(_cmd, withFormatting: false);
      _input.clear();
      todo = parseCommand(_cmd, state);
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
