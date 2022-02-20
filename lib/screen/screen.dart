import 'dart:async';

import 'package:rougish/game/game_data.dart';

import 'src/command_screen.dart';
import 'src/level_screen.dart';
import 'src/pause_screen.dart';
import 'src/test_screen.dart';

enum ScreenEvent {
  nothing,
  quit,
  resume,
  hideCommandBar,
}

abstract class Screen {
  final StreamController<ScreenEvent> _eventBroadcaster = StreamController<ScreenEvent>.broadcast();

  StreamSubscription<ScreenEvent> listen(void Function(ScreenEvent) eventHandler) {
    return _eventBroadcaster.stream.listen(eventHandler);
  }

  void broadcast(ScreenEvent event) {
    _eventBroadcaster.add(event);
  }

  void onKeySequence(List<int> seq, String hash, GameData state);
  void draw(StringBuffer buffer, GameData state);

  Screen();

  factory Screen.command() {
    return CommandScreen();
  }
  factory Screen.pause() {
    return PauseScreen();
  }
  factory Screen.test() {
    return TestScreen();
  }
}
