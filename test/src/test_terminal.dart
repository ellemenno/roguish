import 'package:rougish/term/terminal.dart' as term;
import 'package:test/test.dart';

void testTerminal() {
  group('key sequences', () {
    test('seqKeyFromCodes() provides a non-match value', () {
      expect(term.seqKeyFromCodes([ ]), equals(term.SeqKey.NONE));
      expect(term.seqKeyFromCodes([ term.PRINTABLE_LO ]), equals(term.SeqKey.NONE));
    });
    test('seqKeyFromCodes() matches arrow keys', () {
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x41 ]), equals(term.SeqKey.ARROW_UP));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x42 ]), equals(term.SeqKey.ARROW_DOWN));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x43 ]), equals(term.SeqKey.ARROW_RIGHT));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x44 ]), equals(term.SeqKey.ARROW_LEFT));
    });
    test('seqKeyFromCodes() matches numpad control keys', () {
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x46 ]), equals(term.SeqKey.END));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x48 ]), equals(term.SeqKey.HOME));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x32, 0x7e ]), equals(term.SeqKey.INSERT));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x33, 0x7e ]), equals(term.SeqKey.DELETE));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x35, 0x7e ]), equals(term.SeqKey.PAGE_UP));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x36, 0x7e ]), equals(term.SeqKey.PAGE_DOWN));
    });
    test('seqKeyFromCodes() matches function keys', () {
      expect(term.seqKeyFromCodes([ 0x1b, 0x4f, 0x50 ]), equals(term.SeqKey.F1));
      expect(term.seqKeyFromCodes([ 0x1b, 0x4f, 0x51 ]), equals(term.SeqKey.F2));
      expect(term.seqKeyFromCodes([ 0x1b, 0x4f, 0x52 ]), equals(term.SeqKey.F3));
      expect(term.seqKeyFromCodes([ 0x1b, 0x4f, 0x53 ]), equals(term.SeqKey.F4));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x31, 0x35, 0x7e ]), equals(term.SeqKey.F5));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x31, 0x37, 0x7e ]), equals(term.SeqKey.F6));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x31, 0x38, 0x7e ]), equals(term.SeqKey.F7));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x31, 0x39, 0x7e ]), equals(term.SeqKey.F8));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x32, 0x30, 0x7e ]), equals(term.SeqKey.F9));
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x32, 0x31, 0x7e ]), equals(term.SeqKey.F10));
      //expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x32, 0x??, 0x7e ]), equals(term.SeqKey.F11)); // FIXME: find out the code sequence
      expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x32, 0x34, 0x7e ]), equals(term.SeqKey.F12));
    });
  });
}