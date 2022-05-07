
import 'package:rougish/log/log.dart';

import './ansi.dart' as ansi;
import './terminal_printer.dart';


class ScanlineBuffer {
  static const _logLabel = 'ScanlineBuffer';
  static final _dim = List<int>.filled(2, 0);
  static final StringBuffer _buffer = StringBuffer();
  final TerminalPrinter _printer;
  late final List<StringBuffer> _lines;
  late final List<int> _hashes;
  int _currentScanline = 0;
  int scanGap = 3;

  ScanlineBuffer(this._printer) {
    _printer.size(_dim, useCache: false);
    _lines = List.generate(_dim[1], (_) => StringBuffer(), growable: false);
    _hashes = List.generate(_dim[1], (_) => 0, growable: false);
  }

  void size(List<int> dim) {
    dim[0] = _dim[0]; // columns
    dim[1] = _dim[1]; // rows
  }

  void clear() {
    for (var ln in _lines) {
      ln.clear();
    }
  }

  void placeMessage(String msg, {int xPos = 1, int yPos = 1, bool cll = false}) {
    _buffer.clear();
    if (cll) { ansi.cll(_buffer); }
    if (msg.isNotEmpty) {
      ansi.cha(_buffer, xPos);
      _buffer.write(msg);
      ansi.reset(_buffer);
    }
    if (_buffer.length > 0) { _lines[yPos-1].write(_buffer.toString()); }
  }

  void placeMessageRelative(String msg,
      {int xPercent = 0, int yPercent = 0, int xOffset = 0, int yOffset = 0, bool cll = false}) {
    final int x = 1 + ((_dim[0]-1) * xPercent / 100).floor() + xOffset;
    final int y = 1 + ((_dim[1]-1) * yPercent / 100).floor() + yOffset;
    placeMessage(msg, xPos: x, yPos: y, cll: cll);
  }

  void centerMessage(String msg,
      {int xOffset = 0, int yOffset = 0, int msgOffset = 0, bool cll = false}) {
    final int x = (_dim[0] / 2).floor() - ((msg.length + msgOffset) / 2).floor() + xOffset;
    final int y = (_dim[1] / 2).floor() + yOffset;
    placeMessage(msg, xPos: x, yPos: y, cll: cll);
  }

  bool printNextScanline() {
    bool scanningComplete = false;
    int i = _currentScanline;
    final int m = _lines.length;

    _buffer.clear();
    int oldHash, newHash;
    while (i < m) {
      oldHash = _hashes[i];
      newHash = _lines[i].toString().hashCode;
      if (_lines[i].length > 0 && newHash != oldHash) {
        _hashes[i] = newHash;
        ansi.xy(_buffer, 1, 1+i);
        _buffer.write(_lines[i].toString());
      }
      i += scanGap;
    }
    //Log.debug(_logLabel, 'printNextScanline() printing ${_buffer.length} chars for scanline ${_currentScanline}');
    _printer.printBuffer(_buffer);

    _currentScanline++;
    if (_currentScanline >= scanGap) {
      scanningComplete = true;
      _currentScanline = 0;
      clear();
    }

    return scanningComplete;
  }

  void blankScreen() {
    clear();
    _buffer.clear();
    _hashes.fillRange(0, _hashes.length, 0);
    ansi.xy(_buffer, 1, 1);
    ansi.clh(_buffer, hideCursor: true);
    _printer.printBuffer(_buffer);
  }

}