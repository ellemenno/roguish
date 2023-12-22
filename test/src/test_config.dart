import 'package:test/test.dart';

import 'package:roguish/config/config.dart' as config;

void testConfig() {
  group('config', () {
    late Map<String, String> conf;

    group('.fromFile()', () {
      test('ignores invalid lines', () {
        conf = config.fromFile('test/test_invalid.conf');
        expect(conf.keys.length, equals(0));
      });
      test('reads valid lines to create key-value pairs', () {
        conf = config.fromFile('test/test_valid.conf');
        expect(conf.keys.length, equals(5));
      });
    });
  });
}
