import 'package:rougish/game/game_data.dart';
import 'package:rougish/term/ansi.dart' as ansi;
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class Sampler {
  late final List<int> _history;
  int _index = 0;
  num _sma = 0.0;

  static void _zero(List<int> list) {
    final int n = list.length;
    for (int i = 0; i < n; i++) {
      list[i] = 0;
    }
  }

  Sampler(numSamples) {
    _history = List<int>.filled(numSamples, 0);
  }

  addSample(int sample) {
    _history[_index] = sample;
    _index = (_index + 1) % _history.length;
    int sum = 0, numSamples = 0;
    for (int s in _history) {
      if (s > 0) {
        sum += s;
        numSamples++;
      }
    }
    _sma = numSamples > 0 ? sum / numSamples : 0.0;
  }

  void zero() => _zero(_history);

  num get simpleMovingAverage => _sma;
}

class DebugScreen extends Screen {
  static const double _microsecondsPerSecond = 1e+6;
  static const int _numSamples = 90;
  final StringBuffer _msgBuffer = StringBuffer();
  final Sampler _frameSampler = Sampler(_numSamples);
  final Sampler _charsSampler = Sampler(_numSamples);

  String _pad(Object n, int w, {String c = ' '}) => n.toString().padLeft(w, c);

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {}

  @override
  void draw(GameData state) {
    _frameSampler.addSample(state.frameMicroseconds);
    _charsSampler.addSample(state.frameCharacters);

    num frameBudget = _microsecondsPerSecond / state.fps;
    num frameCost = _frameSampler.simpleMovingAverage;
    num frameChars = _charsSampler.simpleMovingAverage;
    String keyCode = term.codeHash(state.keyCodes);

    int ansiLength = 0;
    int formatLabel(lbl) => ansi.c16(_msgBuffer, lbl, fg: ansi.c16_black, fb: true);

    _msgBuffer.clear();
    _msgBuffer.write('   ');
    if (frameCost > frameBudget) {
      ansiLength += ansi.reverse(_msgBuffer, '${frameCost.round()}');
    }
    else {
      _msgBuffer.write('${frameCost.round()}');
    }
    _msgBuffer.write('/${frameBudget.round()} ');
    ansiLength += formatLabel('µspf');
    _msgBuffer.write('${_pad(frameChars.round(), 5)} ');
    ansiLength += formatLabel('cpf');
    _msgBuffer.write('${_pad(keyCode, 10)} ');
    ansiLength += formatLabel('key');
    _msgBuffer.write('${_pad(state.seed, 10)} ');
    ansiLength += formatLabel('seed');

    Screen.screenBuffer.placeMessageRelative(_msgBuffer.toString(),
        xPercent: 100, xOffset: -1 * (_msgBuffer.length - ansiLength), cll: false);
  }

  @override
  void blank() {
    _frameSampler.zero();
    _charsSampler.zero();
    Screen.screenBuffer.placeMessage(' ', xPos: 1, yPos: 1, cll: true);
  }
}
