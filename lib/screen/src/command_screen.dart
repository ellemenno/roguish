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

  static bool _hasNumArgs(List<String> args, int n) {
    if (args.length == n + 1) {
      return true;
    }

    Log.warn(_logLabel,
        '${args.first} expects ${n} arg${(n != 1) ? 's' : ''}; got ${args.length - 1} instead');
    return false;
  }

  static bool _intTest(String val, String obj, {bool throwErr = false}) {
    if (int.tryParse(val) != null) {
      return true;
    }

    if (throwErr) {
      throw Exception('${_logLabel} Error: invalid ${obj}: ${val} (expected int)');
    } else {
      Log.warn(_logLabel, 'invalid ${obj}: ${val} (expected int)');
    }
    return false;
  }

  static bool _argTest(bool Function(String) test, String val, String msg,
      {bool throwErr = false}) {
    if (test(val)) {
      return true;
    }

    if (throwErr) {
      throw Exception('${_logLabel} Error: ${msg}');
    } else {
      Log.warn(_logLabel, msg);
    }
    return false;
  }

  ScreenEvent _parseCommand(StringBuffer commandBuffer, GameData state) {
    String cmd = commandBuffer.toString();

    List<String> parts = cmd.split(' ');
    Log.debug(_logLabel, '_parseCommand() ${parts}');
    state.cmdArgs.clear();

    switch (parts.first) {
      case 'quit':
      case 'exit':
        return ScreenEvent.quit;
      case 'debrief':
        return ScreenEvent.debrief;
      case 'level':
        if (!_hasNumArgs(parts, 1)) {
          break;
        }
        if (!_intTest(parts[1], parts.first)) {
          break;
        }
        state.cmdArgs.add(parts[1]);
        return ScreenEvent.setLevel;
      case 'regen':
        return ScreenEvent.regen;
      case 'seed':
        if (!_hasNumArgs(parts, 2)) {
          break;
        }
        if (!_intTest(parts[1], parts.first)) {
          break;
        }
        if (!_intTest(parts[2], 'level')) {
          break;
        }
        state.reseed(int.parse(parts[1]));
        state.cmdArgs.add(parts[2]);
        return ScreenEvent.setLevel;
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
      todo = _parseCommand(_cmd, state);
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
    Screen.screenBuffer.placeMessage('> ${_cmd}', xPos: 1, yPos: 1, cll: true);
  }

  @override
  void blank() {
    Screen.screenBuffer.placeMessage(' ', xPos: 1, yPos: 1, cll: true);
  }
}
