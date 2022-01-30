import 'package:rougish/term/terminal.dart' as term;
import 'package:test/test.dart';

void testTerminal() {
  group('key sequences', () {
    test('seqKeyFromCodes() provides a non-match value', () {
      expect(term.seqKeyFromCodes([]), equals(term.SeqKey.none));
      expect(term.seqKeyFromCodes([term.printableLo]), equals(term.SeqKey.none));
    });
    test('seqKeyFromCodes() matches arrow keys', () {
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x41]), equals(term.SeqKey.arrowUp));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x42]), equals(term.SeqKey.arrowDown));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x43]), equals(term.SeqKey.arrowRight));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x44]), equals(term.SeqKey.arrowLeft));
    });
    test('seqKeyFromCodes() matches numpad control keys', () {
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x46]), equals(term.SeqKey.end));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x48]), equals(term.SeqKey.home));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x32, 0x7e]), equals(term.SeqKey.insert));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x33, 0x7e]), equals(term.SeqKey.delete));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x35, 0x7e]), equals(term.SeqKey.pageUp));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x36, 0x7e]), equals(term.SeqKey.pageDown));
    });
    test('seqKeyFromCodes() matches function keys', () {
      expect(term.seqKeyFromCodes([0x1b, 0x4f, 0x50]), equals(term.SeqKey.f1));
      expect(term.seqKeyFromCodes([0x1b, 0x4f, 0x51]), equals(term.SeqKey.f2));
      expect(term.seqKeyFromCodes([0x1b, 0x4f, 0x52]), equals(term.SeqKey.f3));
      expect(term.seqKeyFromCodes([0x1b, 0x4f, 0x53]), equals(term.SeqKey.f4));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x31, 0x35, 0x7e]), equals(term.SeqKey.f5));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x31, 0x37, 0x7e]), equals(term.SeqKey.f6));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x31, 0x38, 0x7e]), equals(term.SeqKey.f7));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x31, 0x39, 0x7e]), equals(term.SeqKey.f8));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x32, 0x30, 0x7e]), equals(term.SeqKey.f9));
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x32, 0x31, 0x7e]), equals(term.SeqKey.f10));
      //expect(term.seqKeyFromCodes([ 0x1b, 0x5b, 0x32, 0x??, 0x7e ]), equals(term.SeqKey.f11)); // FIXME: find out the code sequence
      expect(term.seqKeyFromCodes([0x1b, 0x5b, 0x32, 0x34, 0x7e]), equals(term.SeqKey.f12));
    });
  });
}
