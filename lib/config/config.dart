import 'package:roguish/log/log.dart';
import 'package:roguish/term/terminal.dart' as term;

export 'src/from_file.dart' show fromFile;

String _keyCommandBarHash = '';
String _keyDebugPanelHash = '';
String _keyCursorLeftHash = '';
String _keyCursorRightHash = '';
String _keyPauseHash = '';
String _keyP1UpHash = '';
String _keyP1DownHash = '';
String _keyP1LeftHash = '';
String _keyP1RightHash = '';

LogLevel toLogLevel(String levelName) {
  switch (levelName.toLowerCase()) {
    case 'fatal':
      return LogLevel.fatal;
    case 'error':
      return LogLevel.error;
    case 'warn':
      return LogLevel.warn;
    case 'info':
      return LogLevel.info;
    case 'debug':
      return LogLevel.debug;
    default:
      return LogLevel.none;
  }
}

List<int> toCodes(Map<String, String> conf, String key, String alt) {
  List<int> codes = [];
  (conf[key] ?? alt).split(',').forEach((c) => codes.add(int.parse(c.trim())));
  return codes;
}

LogLevel logLevel(Map<String, String> conf, {LogLevel defaultLevel = LogLevel.none}) {
  return toLogLevel(conf['log_level'] ?? defaultLevel.name);
}

int prngSeed(Map<String, String> conf) {
  return int.parse(
      conf['prng_seed'] ?? '${DateTime.now().microsecond * DateTime.now().millisecond}');
}

List<int> keyCommandBar(Map<String, String> conf, {String defaultCodes = '0x20'}) {
  return toCodes(conf, 'key-command', defaultCodes);
}

List<int> keyDebugPanel(Map<String, String> conf, {String defaultCodes = '0x7e'}) {
  return toCodes(conf, 'key-debug', defaultCodes);
}

List<int> keyCursorLeft(Map<String, String> conf, {String defaultCodes = '0x1b,0x5b,0x44'}) {
  return toCodes(conf, 'key-cursor_left', defaultCodes);
}

List<int> keyCursorRight(Map<String, String> conf, {String defaultCodes = '0x1b,0x5b,0x43'}) {
  return toCodes(conf, 'key-cursor_right', defaultCodes);
}

List<int> keyPause(Map<String, String> conf, {String defaultCodes = '0x60'}) {
  return toCodes(conf, 'key-pause', defaultCodes);
}

List<int> keyUp(Map<String, String> conf,
    {int player = 1, String defaultCodes = '0x1b,0x5b,0x41'}) {
  return toCodes(conf, 'key-p${player}_up', defaultCodes);
}

List<int> keyDown(Map<String, String> conf,
    {int player = 1, String defaultCodes = '0x1b,0x5b,0x42'}) {
  return toCodes(conf, 'key-p${player}_down', defaultCodes);
}

List<int> keyLeft(Map<String, String> conf,
    {int player = 1, String defaultCodes = '0x1b,0x5b,0x44'}) {
  return toCodes(conf, 'key-p${player}_left', defaultCodes);
}

List<int> keyRight(Map<String, String> conf,
    {int player = 1, String defaultCodes = '0x1b,0x5b,0x43'}) {
  return toCodes(conf, 'key-p${player}_right', defaultCodes);
}

void setKeys(Map<String, String> conf) {
  _keyCommandBarHash = term.codeHash(keyCommandBar(conf));
  _keyDebugPanelHash = term.codeHash(keyDebugPanel(conf));
  _keyCursorLeftHash = term.codeHash(keyCursorLeft(conf));
  _keyCursorRightHash = term.codeHash(keyCursorRight(conf));
  _keyPauseHash = term.codeHash(keyPause(conf));
  _keyP1UpHash = term.codeHash(keyUp(conf));
  _keyP1DownHash = term.codeHash(keyDown(conf));
  _keyP1LeftHash = term.codeHash(keyLeft(conf));
  _keyP1RightHash = term.codeHash(keyRight(conf));
}

bool isCommandBar(String hash) {
  return (hash == _keyCommandBarHash);
}

bool isDebugPanel(String hash) {
  return (hash == _keyDebugPanelHash);
}

bool isCursorLeft(String hash) {
  return (hash == _keyCursorLeftHash);
}

bool isCursorRight(String hash) {
  return (hash == _keyCursorRightHash);
}

bool isPause(String hash) {
  return (hash == _keyPauseHash);
}

bool isUp(String hash, {int player = 1}) {
  switch (player) {
    case 1:
      return (hash == _keyP1UpHash);
  }
  return false;
}

bool isDown(String hash, {int player = 1}) {
  switch (player) {
    case 1:
      return (hash == _keyP1DownHash);
  }
  return false;
}

bool isLeft(String hash, {int player = 1}) {
  switch (player) {
    case 1:
      return (hash == _keyP1LeftHash);
  }
  return false;
}

bool isRight(String hash, {int player = 1}) {
  switch (player) {
    case 1:
      return (hash == _keyP1RightHash);
  }
  return false;
}
