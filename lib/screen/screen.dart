import 'dart:async';

import 'package:rougish/game/game_data.dart';
import 'package:rougish/term/ansi.dart' as ansi;

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
  static final StringBuffer _sb = StringBuffer();

  static void blankScreen() {
    ansi.xy(_sb, 1, 1);
    ansi.clh(_sb, hideCursor: true);
  }

  StringBuffer get screenBuffer => _sb; // all screens share/reuse the same temp string buffer

  final StreamController<ScreenEvent> _eventBroadcaster = StreamController<ScreenEvent>.broadcast();

  StreamSubscription<ScreenEvent> listen(void Function(ScreenEvent) eventHandler) {
    return _eventBroadcaster.stream.listen(eventHandler);
  }

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
