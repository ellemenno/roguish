import 'package:rougish/term/ansi.dart' as ansi;
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class PauseScreen extends Screen {
  static const List<ScreenEvent> options = [ScreenEvent.resume, ScreenEvent.quit];
  final numOptions = options.length;

  static const List<String> _dlg = [
    '-----------------------',
    ' PAUSED                ',
    '                       ',
    ' resume                ', // 0
    ' quit                  ', // 1
    '                       ',
    ' (arrow up/down+enter) ',
    '-----------------------',
  ];
  int _curOption = 0;

  int _wrap(int i, int n, int limit) {
    return (i + n).abs() % limit;
  }

  String _hilightSelected(String label, int item) {
    return (item == _curOption) ? '${ansi.FLIP}${label}${ansi.FLOP}' : label;
  }

  void _dialog(StringBuffer sb) {
    String lh;
    sb.clear();
    term.centerMessage(sb, '.${_dlg[0]}.', yOffset: -3);
    term.centerMessage(sb, '|${_dlg[1]}|', yOffset: -2);
    term.centerMessage(sb, '|${_dlg[2]}|', yOffset: -1);
    lh = _hilightSelected(_dlg[3], 0);
    term.centerMessage(sb, '|${lh}|', yOffset: 0, msgOffset: (_dlg[3].length - lh.length));
    lh = _hilightSelected(_dlg[4], 1);
    term.centerMessage(sb, '|${lh}|', yOffset: 1, msgOffset: (_dlg[4].length - lh.length));
    term.centerMessage(sb, '|${_dlg[5]}|', yOffset: 2);
    term.centerMessage(sb, '|${_dlg[6]}|', yOffset: 3);
    term.centerMessage(sb, '\'${_dlg[7]}\'', yOffset: 4);
    term.printBuffer(sb);
  }

  void onString(String string) {/* no-op */}

  void onControlCode(int code) {
    ScreenEvent todo = ScreenEvent.nothing;
    switch (code) {
      case term.ESC:
        todo = options[0];
        break;
      case term.LF:
        todo = options[_curOption];
        break;
      default:
        break;
    }
    term.centerMessage(StringBuffer(), 'todo: \'${todo}\'', yOffset: 6);
    broadcast(todo);
  }

  void onControlSequence(List<int> codes) {
    var seqKey = term.seqKeyFromCodes(codes);
    switch (seqKey) {
      case term.SeqKey.ARROW_UP:
        _curOption = _wrap(_curOption, -1, numOptions);
        break;
      case term.SeqKey.ARROW_DOWN:
        _curOption = _wrap(_curOption, 1, numOptions);
        break;
      default:
        break;
    }
    term.centerMessage(StringBuffer(), 'seqKey: ${seqKey}  curOption: ${_curOption}', yOffset: 6);
  }

  void draw(StringBuffer sb) {
    _dialog(sb);
  }
}
