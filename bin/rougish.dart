import 'dart:async';
import 'dart:io';

import 'package:rougish/config/config.dart' as config;
import 'package:rougish/game/game_data.dart';
import 'package:rougish/log/log.dart';
import 'package:rougish/term/terminal.dart' as term;
import 'package:rougish/screen/screen.dart';

const logLabel = 'rougish';
final List<Screen> screenStack = [];
final Screen test = Screen.test();
final Screen command = Screen.command();
final Screen pause = Screen.pause();
final Screen title = Screen.title();
final Screen setup = Screen.setup();
final Screen level = Screen.level();
final Screen debrief = Screen.debrief();
final StringBuffer screenBuffer = title.screenBuffer;
late final StreamSubscription<List<int>> termListener;
late final GameData state;
late Screen currentScreen;
late StreamSubscription<ScreenEvent> screenListener;
bool paused = false;
bool commandBarOpen = false;

void pushScreen(Screen screen) {
  if (screenStack.isNotEmpty) {
    screenListener.cancel();
  }
  screenStack.add(screen);
  currentScreen = screenStack.last;
  Log.info(logLabel, 'pushScreen() added ${screen.runtimeType} as new current screen');
  screenListener = currentScreen.listen(onScreenEvent);
  redrawScreens();
}

Screen popScreen() {
  if (screenStack.isEmpty) {
    throw Exception('popScreen() called when screenStack was empty.');
  }
  screenListener.cancel();
  Screen screen = screenStack.removeLast();
  if (screenStack.isNotEmpty) {
    currentScreen = screenStack.last;
    screenListener = currentScreen.listen(onScreenEvent);
    Log.info(logLabel,
        'popScreen() removed ${screen.runtimeType}; current screen is ${currentScreen.runtimeType}');
    redrawScreens();
  }
  return screen;
}

void popAllScreens() {
  if (screenStack.isEmpty) {
    throw Exception('popAllScreens() called when screenStack was empty.');
  }
  screenListener.cancel();
  while (screenStack.isNotEmpty) {
    screenStack.removeLast();
  }
}

void redrawScreens() {
  Log.debug(logLabel, 'redrawScreens() redrawing ${screenStack.length} screens from bottom up..');
  term.clear(screenBuffer, hideCursor: true, clearHistory: true);
  // dart lists iterate from first added to last added, which gives us bottom to top of stack
  for (final screen in screenStack) {
    screen.draw(state);
  }
  term.printBuffer(screenBuffer);
}

void showCodes(List<int> codes) {
  Log.debug(logLabel, () => term.codesToString(codes));
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

void onTitleToSetup() {
  Log.info(logLabel, 'onTitleToSetup() advancing from title screen to setup screen..');
  popScreen(); // remove title
  pushScreen(setup); // add setup
}

void onSetupToLevel() {
  Log.info(logLabel, 'onSetupToLevel() advancing from setup screen to level screen..');
  popScreen(); // remove setup
  pushScreen(level); // add level
}

void onDebrief() {
  Log.info(logLabel, 'onDebrief() game over, showing stats summary..');
  popScreen(); // remove level
  pushScreen(debrief); // add debrief
}

void onTitle() {
  Log.info(logLabel, 'onTitle() returning to title..');
  popAllScreens(); // reset
  pushScreen(title); // add title
}

void onLevelRegen() {
  if (currentScreen != level) {
    Log.warn(logLabel, 'onLevelRegen() not currently on the level screen; ignoring command');
  }
  Log.info(logLabel, 'onLevelRegen() clearing and regenerating level..');
  state.levelMap.clear();
  redrawScreens();
}

void onQuit() {
  Log.info(logLabel, 'onQuit() quitting..');
  screenListener.cancel();
  termListener.cancel();
  term.clear(screenBuffer, hideCursor: true, clearHistory: true);
  term.print('thank you for playing.\n');
  term.showCursor();
  exit(0);
}

void onKeySequence(List<int> seq, String hash) {
  Log.debug(logLabel, 'onKeySequence() ${hash}');
  currentScreen.onKeySequence(seq, hash, state);
  redrawScreens();
}

void onScreenEvent(ScreenEvent event) {
  Log.debug(logLabel, 'onScreenEvent() ${event.name}');
  if (commandBarOpen && event != ScreenEvent.hideCommandBar) {
    onHideCommandBar();
  }
  switch (event) {
    case ScreenEvent.quit:
      onQuit();
      break;
    case ScreenEvent.resume:
      onResume();
      break;
    case ScreenEvent.hideCommandBar:
      onHideCommandBar();
      break;
    case ScreenEvent.titleToSetup:
      onTitleToSetup();
      break;
    case ScreenEvent.setupToLevel:
      onSetupToLevel();
      break;
    case ScreenEvent.debrief:
      onDebrief();
      break;
    case ScreenEvent.title:
      onTitle();
      break;
    case ScreenEvent.regen:
      onLevelRegen();
      break;
    default:
      Log.warn(logLabel, 'screen event: ${event}; (no action)');
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

  if (!commandBarOpen && config.isCommandBar(codeHash)) {
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
  Map<String, String> conf = config.fromFile('bin/rougish.conf');
  state = GameData(conf, seed: config.prngSeed(conf));

  Log.toFile();
  Log.level = config.logLevel(state.conf);
  Log.info(logLabel, 'app startup. logging initialized at ${Log.level}. args = ${arguments}');
  Log.debug(logLabel, 'conf = ${state.conf}');

  config.setKeys(state.conf);

  runZonedGuarded(() {
    termListener = term.listen(onData, onError);
    addSignalListeners();
  }, (e, s) {
    Log.warn(logLabel, 'listener zone exception: ${e}');
  });

  //pushScreen(test);
  pushScreen(title);
  redrawScreens();
}
