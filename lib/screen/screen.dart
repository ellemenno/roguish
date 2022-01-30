import 'dart:async';

import 'src/pause_screen.dart';
import 'src/test_screen.dart';

enum ScreenEvent {
  nothing,
  quit,
  resume,
}

abstract class Screen {
  final StreamController<ScreenEvent> _eventBroadcaster = StreamController<ScreenEvent>.broadcast();

  StreamSubscription<ScreenEvent> listen(void Function(ScreenEvent) eventHandler) {
    return _eventBroadcaster.stream.listen(eventHandler);
  }

  void broadcast(ScreenEvent event) {
    _eventBroadcaster.add(event);
  }

  void onControlCode(int code);
  void onControlSequence(List<int> codes);
  void onString(String string);
  void draw(StringBuffer buffer);

  Screen();

  factory Screen.pause() {
    return PauseScreen();
  }
  factory Screen.test() {
    return TestScreen();
  }
}
