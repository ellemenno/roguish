import 'package:test/test.dart';

import 'package:rougish/term/typing_buffer.dart';
import 'package:rougish/term/ansi.dart' as ansi;

void testTyping() {
  group('typing_buffer', () {
    late TypingBuffer tb;
    final StringBuffer sb = StringBuffer();

    setUp(() {
      tb = TypingBuffer();
      sb.clear();
    });

    group('.()', () {
      test('creates an empty buffer', () {
        expect(tb.length, equals(0));
      });
      test('is not yet modified', () {
        expect(tb.modified, equals(false));
      });
      test('has a cursorIndex of 0', () {
        expect(tb.cursorIndex, equals(0));
      });
    });

    group('.modified()', () {
      test('is true after a character is inserted', () {
        tb.write('a'.codeUnitAt(0));
        expect(tb.modified, equals(true));
      });
      test('is true after a character is removed', () {
        tb.write('a'.codeUnitAt(0));
        tb.resetModified();
        tb.backspace();
        expect(tb.modified, equals(true));
        tb.write('b'.codeUnitAt(0));
        tb.cursorStart();
        tb.resetModified();
        tb.delete();
        expect(tb.modified, equals(true));
      });
      test('is true when the cursor position changes', () {
        tb.write('a'.codeUnitAt(0));
        tb.resetModified();
        tb.cursorLeft();
        expect(tb.modified, equals(true));
        tb.resetModified();
        tb.cursorRight();
        expect(tb.modified, equals(true));
        tb.resetModified();
        tb.cursorStart();
        expect(tb.modified, equals(true));
        tb.resetModified();
        tb.cursorEnd();
        expect(tb.modified, equals(true));
      });
      test('ignores cursor motion that has no effect', () {
        tb.cursorLeft();
        tb.cursorRight();
        tb.cursorStart();
        tb.cursorEnd();
        expect(tb.modified, equals(false));
      });
    });

    group('.resetModified()', () {
      test('turns the modified flag off', () {
        tb.write('a'.codeUnitAt(0));
        tb.resetModified();
        expect(tb.modified, equals(false));
      });
      test('is safe to call on an unmodified buffer', () {
        tb.resetModified();
        expect(tb.modified, equals(false));
      });
    });

    group('.clear()', () {
      test('removes all characters from the buffer', () {
        tb.write('a'.codeUnitAt(0));
        tb.write('b'.codeUnitAt(0));
        tb.write('c'.codeUnitAt(0));
        expect(tb.length, equals(3));
        tb.clear();
        expect(tb.length, equals(0));
      });
      test('is safe to call on an empty buffer', () {
        expect(tb.length, equals(0));
        tb.clear();
        expect(tb.length, equals(0));
      });
    });

    group('.backspace()', () {
      test('removes one character left of the cursor', () {
        tb.write('a'.codeUnitAt(0));
        tb.write('b'.codeUnitAt(0));
        tb.write('c'.codeUnitAt(0));
        tb.backspace();
        tb.toStringBuffer(sb, withFormatting: false);
        expect('${sb}', equals('ab'));
        tb.cursorLeft();
        tb.backspace();
        tb.toStringBuffer(sb, withFormatting: false);
        expect('${sb}', equals('b'));
      });
      test('has no effect when cursor is at start', () {
        tb.write('a'.codeUnitAt(0));
        tb.cursorStart();
        tb.resetModified();
        tb.backspace();
        expect(tb.modified, equals(false));
        expect(tb.length, equals(1));
      });
    });

    group('.delete()', () {
      test('removes one character right of the cursor', () {
        tb.write('a'.codeUnitAt(0));
        tb.write('b'.codeUnitAt(0));
        tb.write('c'.codeUnitAt(0));
        tb.cursorStart();
        tb.delete();
        tb.toStringBuffer(sb, withFormatting: false);
        expect('${sb}', equals('bc'));
        tb.cursorRight();
        tb.delete();
        tb.toStringBuffer(sb, withFormatting: false);
        expect('${sb}', equals('b'));
      });
      test('has no effect when cursor is at end', () {
        tb.write('a'.codeUnitAt(0));
        tb.resetModified();
        tb.delete();
        expect(tb.modified, equals(false));
        expect(tb.length, equals(1));
      });
    });

    group('.write()', () {
      test('inserts one character at the cursor position', () {
        tb.write('a'.codeUnitAt(0));
        tb.write('c'.codeUnitAt(0));
        tb.toStringBuffer(sb, withFormatting: false);
        expect('${sb}', equals('ac'));
        tb.cursorLeft();
        tb.write('b'.codeUnitAt(0));
        tb.toStringBuffer(sb, withFormatting: false);
        expect('${sb}', equals('abc'));
      });
    });

    group('.cursorLeft()', () {
      test('moves cursor one place closer to start', () {
        tb.write('a'.codeUnitAt(0));
        expect(tb.cursorIndex, equals(1));
        tb.cursorLeft();
        expect(tb.cursorIndex, equals(0));
      });
      test('has no effect when cursor is at start', () {
        tb.cursorLeft();
        expect(tb.cursorIndex, equals(0));
      });
    });

    group('.cursorRight()', () {
      test('moves cursor one place closer to end', () {
        tb.write('a'.codeUnitAt(0));
        tb.cursorStart();
        expect(tb.cursorIndex, equals(0));
        tb.cursorRight();
        expect(tb.cursorIndex, equals(1));
      });
      test('has no effect when cursor is at end', () {
        tb.cursorRight();
        expect(tb.cursorIndex, equals(0));
      });
    });

    group('.cursorStart()', () {
      test('moves cursor to start', () {
        tb.write('a'.codeUnitAt(0));
        tb.write('b'.codeUnitAt(0));
        tb.write('c'.codeUnitAt(0));
        expect(tb.cursorIndex, equals(3));
        tb.cursorStart();
        expect(tb.cursorIndex, equals(0));
      });
    });

    group('.cursorEnd()', () {
      test('moves cursor to end', () {
        tb.write('a'.codeUnitAt(0));
        tb.write('b'.codeUnitAt(0));
        tb.write('c'.codeUnitAt(0));
        tb.cursorStart();
        expect(tb.cursorIndex, equals(0));
        tb.cursorEnd();
        expect(tb.cursorIndex, equals(3));
      });
    });

    group('.toStringBuffer()', () {
      test('highlights the cursor with ANSI codes', () {
        tb.write('a'.codeUnitAt(0));
        tb.write('b'.codeUnitAt(0));
        tb.cursorLeft();
        tb.toStringBuffer(sb);
        expect('${sb}', equals('a${ansi.flip}b${ansi.flop}'));
      });
      test('can disable cursor formatting', () {
        tb.write('a'.codeUnitAt(0));
        tb.write('b'.codeUnitAt(0));
        tb.cursorLeft();
        tb.toStringBuffer(sb, withFormatting: false);
        expect('${sb}', equals('ab'));
      });
    });
  });
}
