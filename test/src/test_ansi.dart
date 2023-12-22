import 'package:test/test.dart';

import 'package:roguish/term/ansi.dart' as ansi;

void testAnsi() {
  group('ansi', () {
    var sb = StringBuffer();
    var msg = 'msg';

    setUp(() => sb.clear());

    group('.c16()', () {
      test('sets a default foreground of dim white', () {
        ansi.c16(sb, msg);
        expect('${sb}', equals('\x1B[37m${msg}\x1B[0m'));
      });
      test('can skip both foreground and background', () {
        ansi.c16(sb, msg, fg: -1, bg: -1);
        expect('${sb}', equals('${msg}\x1B[0m'));
      });

      test('ignores fg values under range', () {
        ansi.c16(sb, msg, fg: -1);
        expect('${sb}', equals('${msg}\x1B[0m'));
      });
      test('ignores fg values over range', () {
        ansi.c16(sb, msg, fg: 8);
        expect('${sb}', equals('${msg}\x1B[0m'));
      });
      test('adds 30 for dim fg colors', () {
        ansi.c16(sb, msg, fg: 0);
        expect('${sb}', equals('\x1B[30m${msg}\x1B[0m'));
      });
      test('adds 60 for bright fg colors', () {
        ansi.c16(sb, msg, fg: 0, fb: true);
        expect('${sb}', equals('\x1B[90m${msg}\x1B[0m'));
      });

      test('ignores bg values under range', () {
        ansi.c16(sb, msg, fg: -1, bg: -1);
        expect('${sb}', equals('${msg}\x1B[0m'));
      });
      test('ignores bg values over range', () {
        ansi.c16(sb, msg, fg: -1, bg: 8);
        expect('${sb}', equals('${msg}\x1B[0m'));
      });
      test('adds 40 for dim bg colors', () {
        ansi.c16(sb, msg, fg: -1, bg: 0);
        expect('${sb}', equals('\x1B[40m${msg}\x1B[0m'));
      });
      test('adds 90 for bright bg colors', () {
        ansi.c16(sb, msg, fg: -1, bg: 0, bb: true);
        expect('${sb}', equals('\x1B[100m${msg}\x1B[0m'));
      });

      test('can set dim foreground and background', () {
        ansi.c16(sb, msg, fg: 0, bg: 0);
        expect('${sb}', equals('\x1B[30m\x1B[40m${msg}\x1B[0m'));
      });
      test('can set bright foreground and background', () {
        ansi.c16(sb, msg, fg: 0, bg: 0, fb: true, bb: true);
        expect('${sb}', equals('\x1B[90m\x1B[100m${msg}\x1B[0m'));
      });
    });

    group('.cRGB()', () {
      test('sets a default foreground of #999999 (dim white)', () {
        ansi.cRGB(sb, msg);
        expect('${sb}', equals('\x1B[38;2;153;153;153m${msg}\x1B[0m'));
      });
      test('can skip both foreground and background', () {
        ansi.cRGB(sb, msg, fg: -1, bg: -1);
        expect('${sb}', equals('${msg}\x1B[0m'));
      });

      test('ignores fg values under range', () {
        ansi.cRGB(sb, msg, fg: -1);
        expect('${sb}', equals('${msg}\x1B[0m'));
      });
      test('ignores fg values over range', () {
        ansi.cRGB(sb, msg, fg: 0xffffff + 1);
        expect('${sb}', equals('${msg}\x1B[0m'));
      });
      test('ignores bg values under range', () {
        ansi.cRGB(sb, msg, fg: -1, bg: -1);
        expect('${sb}', equals('${msg}\x1B[0m'));
      });
      test('ignores bg values over range', () {
        ansi.cRGB(sb, msg, fg: -1, bg: 0xffffff + 1);
        expect('${sb}', equals('${msg}\x1B[0m'));
      });
      test('can set arbitrary rgb colors, like #0818A8 (zaffre)', () {
        ansi.cRGB(sb, msg, fg: 0x0818A8);
        expect('${sb}', equals('\x1B[38;2;8;24;168m${msg}\x1B[0m'));
      });
    });
  });
}
