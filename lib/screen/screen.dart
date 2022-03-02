import 'dart:async';

import 'package:rougish/game/game_data.dart';

import 'src/command_screen.dart';
import 'src/debrief_screen.dart';
import 'src/level_screen.dart';
import 'src/pause_screen.dart';
import 'src/setup_screen.dart';
import 'src/title_screen.dart';
import 'src/test_screen.dart';

enum ScreenEvent {
  nothing,
  quit,
  resume,
  hideCommandBar,
  titleToSetup,
  setupToLevel,
  debrief,
  title,
}

abstract class Screen {
  static final StringBuffer _sb = StringBuffer();

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

  Screen();

  factory Screen.test() {
    return TestScreen();
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
