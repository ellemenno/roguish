import 'package:rougish/game/game_data.dart';
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class DebugScreen extends Screen {
  final _frameSamples = List<int>.filled(100, 0);
  int _sampleIndex = 0;

  String _pad(Object n, int w, {String c = ' '}) => n.toString().padLeft(w, c);

  @override
  void onKeySequence(List<int> seq, String hash, GameData state) {}

  @override
  void draw(GameData state) {
    _frameSamples[_sampleIndex] = state.frameMs;
    _sampleIndex = (_sampleIndex + 1) % _frameSamples.length;
    num avg = _frameSamples.reduce((v, e) => v + e) / _frameSamples.length;
    num cost = (1000000 / state.fps) - avg;
    String kc = term.codeHash(state.keyCodes);
    String msg = '${_pad(cost.round(), 6)} µspf ${_pad(kc, 10)} key ${_pad(state.seed, 10)} seed';
    term.placeMessageRelative(screenBuffer, msg,
        xPercent: 100, xOffset: -1 * msg.length, cll: false);
  }

  @override
  void blank() {
    term.placeMessage(screenBuffer, ' ', xPos: 1, yPos: 1, cll: true);
  }
}
