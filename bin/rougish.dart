import 'dart:async';
import 'dart:io';

import 'package:rougish/config/config.dart' as config;
import 'package:rougish/game/game_data.dart';
import 'package:rougish/log/log.dart';
import 'package:rougish/term/terminal.dart' as term;
import 'package:rougish/screen/screen.dart';

const logLabel = 'rougish';
final StringBuffer sb = StringBuffer();
final List<Screen> screenStack = [];
final Screen command = Screen.command();
final Screen pause = Screen.pause();
final Screen test = Screen.test();
late final StreamSubscription<List<int>> termListener;
late final GameData state;
late Map<String, String> conf;
late Screen currentScreen;
late StreamSubscription<ScreenEvent> screenListener;
bool paused = false;
bool commandBarOpen = false;

void pushScreen(Screen screen, {bool first = false}) {
  if (!first) {
    screenListener.cancel();
  }
  screenStack.add(screen);
  currentScreen = screenStack.last;
  Log.info(logLabel, 'pushScreen() added ${screen.runtimeType} as new current screen');
  screenListener = currentScreen.listen(onScreenEvent);
  currentScreen.draw(sb, state); // push is additive; can get away with only drawing new screen
}

Screen popScreen() {
  screenListener.cancel();
  Screen screen = screenStack.removeLast();
  currentScreen = screenStack.last;
  screenListener = currentScreen.listen(onScreenEvent);
  Log.info(logLabel,
      'popScreen() removed ${screen.runtimeType}; current screen is ${currentScreen.runtimeType}');
  redrawScreens(); // pop is subtractive, new to redraw full stack
  return screen;
}

void redrawScreens() {
  Log.debug(logLabel, 'redrawScreens() redrawing ${screenStack.length} screens from bottom up..');
  // dart lists iterate from first added to last added, which gives us bottom to top of stack
  for (final screen in screenStack) {
    screen.draw(sb, state);
  }
}

void showCodes(List<int> codes) {
  term.centerMessage(sb, '${term.codesToString(codes)}\n', yOffset: -7);
}

void onResize() {
  Log.info(logLabel, 'onResize() call for redraw at new size..');
  redrawScreens();
}

void onShowCommandBar() {
  if (commandBarOpen) {
    return;
  }
  Log.info(logLabel, 'onShowCommandBar() showing..');
  commandBarOpen = true;
  pushScreen(command);
}

void onHideCommandBar() {
  if (!commandBarOpen) {
    return;
  }
  Log.info(logLabel, 'onHideCommandBar() hiding..');
  commandBarOpen = false;
  popScreen();
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

void onKeySequence(List<int> seq, String hash) {
  Log.debug(logLabel, 'onKeySequence() ${hash}');
  currentScreen.onKeySequence(seq, hash, state);
  currentScreen.draw(sb, state);
}

void onScreenEvent(ScreenEvent event) {
  Log.debug(logLabel, 'onScreenEvent() ${event.name}');
  switch (event) {
    case ScreenEvent.resume:
      onResume();
      break;
    case ScreenEvent.hideCommandBar:
      onHideCommandBar();
      break;
    case ScreenEvent.quit:
      onQuit();
      break;
    default:
      term.centerMessage(sb, 'screen event: ${event}; (no action)\n', yOffset: -6);
  }
}

void onError(Object error) {
  Log.error(logLabel, 'error from terminal: ${error.runtimeType} - ${error}');
}

void onData(List<int> codes) {
  int len = codes.length;
  if (len == 0) {
    Log.debug(logLabel, 'zero-length code sequence');
    return;
  }

  showCodes(codes);

  String codeHash = term.codeHash(codes);

  if (commandBarOpen) {
    onKeySequence(codes, codeHash);
  } else if (config.isCommandBar(codeHash)) {
    onShowCommandBar();
  } else if (!paused && config.isPause(codeHash)) {
    onPause();
  } else {
    onKeySequence(codes, codeHash);
  }
}

void addSignalListeners() {
  try {
    ProcessSignal.sigint
        .watch()
        .listen((signal) => onQuit()); // process interrupt from keyboard, e.g. ctrl-c --> sigint

    // the following are not supported on Windows, but the exceptions they raise
    // are caught here and in the guarded zone in main
    ProcessSignal.sigterm.watch().listen((signal) => onQuit()); // process termination --> sigterm
    ProcessSignal.sigwinch
        .watch()
        .listen((signal) => onResize()); // notification of term window size change --> sigwinch
  } on SignalException catch (e) {
    Log.warn(logLabel, e.message);
  }
}

void main(List<String> arguments) {
  conf = config.fromFile('bin/rougish.conf');
  state = GameData(conf);

  Log.toFile();
  Log.level = config.logLevel(conf);
  Log.info(logLabel, 'app startup. logging initialized at ${Log.level}. args = ${arguments}');
  Log.debug(logLabel, 'conf = ${conf}');

  config.setKeys(conf);

  term.clear(sb);
  term.hideCursor();

  runZonedGuarded(() {
    termListener = term.listen(onData, onError);
    addSignalListeners();
  }, (e, s) {
    Log.warn(logLabel, 'listener zone exception: ${e}');
  });

  pushScreen(test, first: true);
}
