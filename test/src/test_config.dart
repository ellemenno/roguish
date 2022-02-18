import 'package:rougish/config/config.dart' as config;
import 'package:test/test.dart';

void testConfig() {
  group('invalid config', () {
    late Map<String, String> conf;

    setUp(() => conf = config.fromFile('test/test_invalid.conf'));

    test('fromFile() ignores invalid lines', () {
      expect(conf.keys.length, equals(0));
    });
  });

  group('valid config', () {
    late Map<String, String> conf;

    setUp(() => conf = config.fromFile('test/test_valid.conf'));

    test('fromFile() reads valid lines to create key-value pairs', () {
      expect(conf.keys.length, equals(5));
    });
  });
}
