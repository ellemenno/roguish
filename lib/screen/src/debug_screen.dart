import 'package:rougish/game/game_data.dart';
import 'package:rougish/term/ansi.dart' as ansi;
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class DebugScreen extends Screen {
  final double microsecondsPerSecond = 1e+6;
  final _frameSamples = List<int>.filled(100, 0);
  int _sampleIndex = 0;

  String _pad(Object n, int w, {String c = ' '}) => n.toString().padLeft(w, c);

  void _zero(List<int> list) {
    final int n = list.length;
    for (int i = 0; i < n; i++) {
      list[i] = 0;
    }
  }

  num _microsecondsPerFrame(int sample) {
    // average µspf
    _frameSamples[_sampleIndex] = sample;
    _sampleIndex = (_sampleIndex + 1) % _frameSamples.length;
    int sum = 0, numSamples = 0;
    for (int ms in _frameSamples) {
      if (ms > 0) {
        sum += ms;
        numSamples++;
      }
    }
    return sum / numSamples;
  }

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {}

  @override
  void draw(GameData state) {
    num frameBudget = microsecondsPerSecond / state.fps;
    num frameCost = _microsecondsPerFrame(state.frameMicroseconds);
    num frameBalance = frameBudget - frameCost;
    String keyCode = term.codeHash(state.keyCodes);
    bool neg = frameBalance < 0;
    String msg = [
      '   ',
      '${neg ? ansi.flip : ''}${(frameBalance / 1000).round()}${neg ? ansi.flop : ''} mspf',
      '${_pad(keyCode, 10)} key',
      '${_pad(state.seed, 10)} seed',
    ].join(' ');
    int ansiLength = neg ? ansi.flip.length + ansi.flop.length : 0;
    term.placeMessageRelative(screenBuffer, msg,
        xPercent: 100, xOffset: -1 * (msg.length - ansiLength), cll: false);
  }

  @override
  void blank() {
    _zero(_frameSamples);
    term.placeMessage(screenBuffer, ' ', xPos: 1, yPos: 1, cll: true);
  }
}
