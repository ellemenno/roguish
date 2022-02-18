import 'package:rougish/log/log.dart';
import 'package:rougish/term/terminal.dart' as term;

export 'src/from_file.dart' show fromFile;

String _keyPauseHash = '';
String _keyUpHash = '';
String _keyDownHash = '';
String _keyLeftHash = '';
String _keyRightHash = '';

Map<String, String> _globalConf = {};
Map<String, String> get globalConf => _globalConf;

void setGlobalConf(Map<String, String> conf) {
  _globalConf = conf;
}

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

LogLevel logLevel(Map<String, String> conf, {defaultLevel = LogLevel.none}) {
  return toLogLevel(conf['log_level'] ?? defaultLevel);
}

int numBlocks(Map<String, String> conf, {defaultCount = 35}) {
  return int.parse(conf['screen-test-num_blocks'] ?? defaultCount);
}

List<int> keyPause(Map<String, String> conf, {defaultCodes = '0x20'}) {
  return toCodes(conf, 'key-pause', defaultCodes);
}

List<int> keyUp(Map<String, String> conf, {player = 1, defaultCodes = '0x1b,0x5b,0x41'}) {
  return toCodes(conf, 'key-p${player}_up', defaultCodes);
}

List<int> keyDown(Map<String, String> conf, {player = 1, defaultCodes = '0x1b,0x5b,0x42'}) {
  return toCodes(conf, 'key-p${player}_down', defaultCodes);
}

List<int> keyLeft(Map<String, String> conf, {player = 1, defaultCodes = '0x1b,0x5b,0x44'}) {
  return toCodes(conf, 'key-p${player}_left', defaultCodes);
}

List<int> keyRight(Map<String, String> conf, {player = 1, defaultCodes = '0x1b,0x5b,0x43'}) {
  return toCodes(conf, 'key-p${player}_right', defaultCodes);
}

String codeHash(List<int> codes) {
  return term.codesToString(codes, prefix: '').join('');
}

void setKeys(Map<String, String> conf) {
  _keyPauseHash = codeHash(keyPause(conf));
  _keyUpHash = codeHash(keyUp(conf));
  _keyDownHash = codeHash(keyDown(conf));
  _keyLeftHash = codeHash(keyLeft(conf));
  _keyRightHash = codeHash(keyRight(conf));
}

bool isPause(String hash) {
  return hash == _keyPauseHash;
}

bool isUp(String hash) {
  return hash == _keyUpHash;
}

bool isDown(String hash) {
  return hash == _keyDownHash;
}

bool isLeft(String hash) {
  return hash == _keyLeftHash;
}

bool isRight(String hash) {
  return hash == _keyRightHash;
}
