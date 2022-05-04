import 'dart:async';
import 'dart:io';

import 'package:rougish/game/game_data.dart';
import 'package:rougish/term/ansi.dart' as ansi;
import 'package:rougish/term/scanline_buffer.dart';
import 'package:rougish/term/terminal_printer.dart';

import 'src/command_screen.dart';
import 'src/debug_screen.dart';
import 'src/debrief_screen.dart';
import 'src/level_screen.dart';
import 'src/pause_screen.dart';
import 'src/setup_screen.dart';
import 'src/title_screen.dart';
import 'src/test_screen.dart';

enum ScreenEvent {
  nothing,
  debrief,
  hideCommandBar,
  quit,
  regen,
  resume,
  setLevel,
  setupToLevel,
  title,
  titleToSetup,
}

abstract class Screen {
  static late ScanlineBuffer _sb; // all screens share/reuse the same temp string buffer
  static ScanlineBuffer get screenBuffer => _sb;
  static set screenBuffer(ScanlineBuffer sb) => _sb = sb;

  static void blankScreen() {
    _sb.blankScreen();
  }


  final StreamController<ScreenEvent> _eventBroadcaster = StreamController<ScreenEvent>.broadcast();

  StreamSubscription<ScreenEvent> listen(void Function(ScreenEvent) eventHandler) {
    return _eventBroadcaster.stream.listen(eventHandler);
  }

  @override
  String toString() => runtimeType.toString();

  void broadcast(ScreenEvent event) {
    _eventBroadcaster.add(event);
  }

  void onKeySequence(List<int> seq, String hash, GameData state);

  void draw(GameData state);

  void blank() => blankScreen();

  Screen();

  factory Screen.test() {
    return TestScreen();
  }
  factory Screen.debug() {
    return DebugScreen();
  }
  factory Screen.command() {
    return CommandScreen();
  }
  factory Screen.pause() {
    return PauseScreen();
  }
  factory Screen.title() {
    return TitleScreen();
  }
  factory Screen.setup() {
    return SetupScreen();
  }
  factory Screen.level() {
    return LevelScreen();
  }
  factory Screen.debrief() {
    return DebriefScreen();
  }
}
