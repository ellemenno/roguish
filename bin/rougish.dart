import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rougish/log/log.dart';
import 'package:rougish/term/terminal.dart' as term;
import 'package:rougish/screen/screen.dart';

const logLabel = 'rougish';
final List<Screen> screenStack = [];
final StringBuffer sb = StringBuffer();
Screen pause = Screen.pause();
Screen test = Screen.test();
bool paused = false;
late StreamSubscription<ScreenEvent> screenListener;
late StreamSubscription<List<int>> termListener;
late Screen currentScreen;

void pushScreen(Screen screen, {bool first = false}) {
  if (!first) {
    screenListener.cancel();
  }
  screenStack.add(screen);
  currentScreen = screenStack.last;
  Log.info(logLabel, 'pushScreen() added ${screen.runtimeType} as new current screen');
  screenListener = currentScreen.listen(onScreenEvent);
  currentScreen.draw(sb);
}

Screen popScreen() {
  screenListener.cancel();
  Screen screen = screenStack.removeLast();
  currentScreen = screenStack.last;
  screenListener = currentScreen.listen(onScreenEvent);
  Log.info(logLabel,
      'popScreen() removed ${screen.runtimeType}; current screen is ${currentScreen.runtimeType}');
  currentScreen.draw(sb);
  return screen;
}

Iterable<String> codesToString(List<int> codes) => codes.map((e) => '0x${e.toRadixString(16)}');

void showCodes(List<int> codes) {
  Log.debug(logLabel, () => 'showCodes() ' + codesToString(codes).toString());
  term.centerMessage(sb, '${codesToString(codes)}\n', yOffset: -7);
}

void onResize() {
  Log.info(logLabel, 'onResize() redrawing ${screenStack.length} screens from bottom up..');
  for (final screen in screenStack) {
    screen.draw(sb); // bottom to top
  }
}

void onPause() {
  if (paused) {
    return;
  }
  Log.info(logLabel, 'onPause() pausing..');
  paused = true;
  pushScreen(pause);
}

void onResume() {
  if (!paused) {
    return;
  }
  Log.info(logLabel, 'onResume() resuming..');
  paused = false;
  popScreen();
}

void onQuit() {
  Log.info(logLabel, 'onQuit() quitting..');
  screenListener.cancel();
  termListener.cancel();
  term.clear(sb);
  term.print('thank you for playing.\n');
  term.showCursor();
  exit(0);
}

void onEscape() {
  Log.debug(logLabel, 'onEscape()');
  if (!paused) {
    onPause();
  } else {
    onControlCode(0x1b);
  }
}

void onControlCode(int code) {
  Log.debug(logLabel, () => 'onControlCode() ' + codesToString([code]).toString());
  currentScreen.onControlCode(code);
  currentScreen.draw(sb);
}

void onControlSequence(List<int> seq) {
  Log.debug(logLabel, () => 'onControlSequence() ' + codesToString(seq).toString());
  currentScreen.onControlSequence(seq);
  currentScreen.draw(sb);
}

void onString(String string) {
  Log.debug(logLabel, 'onString() \'${string}\'');
  currentScreen.onString(string);
  currentScreen.draw(sb);
}

void onScreenEvent(ScreenEvent event) {
  Log.debug(logLabel, 'onScreenEvent() ${event.name}');
  switch (event) {
    case ScreenEvent.resume:
      onResume();
      break;
    case ScreenEvent.quit:
      onQuit();
      break;
    default:
      term.centerMessage(sb, 'screen event: ${event}; (no action)\n', yOffset: -6);
  }
}

void onData(List<int> codes) {
  int len = codes.length;
  if (len == 0) {
    return;
  }

  int first = codes.first;
  showCodes(codes);

  if (len == 1) {
    if (first == 0x1b) {
      onEscape();
    } else if (first == 0x7f || first < 0x20) {
      onControlCode(first);
    } else {
      onString(String.fromCharCode(first));
    }
  } else if (first == 0x1b) {
    onControlSequence(codes);
  } else {
    onString(utf8.decode(codes));
  } // need a non-US keyboard to trigger this?
}

void addSignalListeners() {
  ProcessSignal.sigint
      .watch()
      .listen((signal) => onQuit()); // process interrupt from keyboard, e.g. ctrl-c --> sigint
  ProcessSignal.sigterm.watch().listen((signal) => onQuit()); // process termination --> sigterm
  ProcessSignal.sigwinch
      .watch()
      .listen((signal) => onResize()); // notification of term window size change --> sigwinch
}

void main(List<String> arguments) {
  Log.toFile();
  Log.level = LogLevel.info;
  Log.info(logLabel, 'app startup. logging initialized. args = ${arguments}');

  term.clear(sb);
  term.hideCursor();
  termListener = term.listen(onData);
  addSignalListeners();
  pushScreen(test, first: true);

  term.centerMessage(sb, 'now listening (ESC to exit)\n', yOffset: -1);
  Log.info(logLabel, 'test screen added. listening for user input on stdin.');
}
