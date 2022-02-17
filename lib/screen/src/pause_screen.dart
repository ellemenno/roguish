import 'package:rougish/config/config.dart' as config;
import 'package:rougish/log/log.dart';
import 'package:rougish/term/ansi.dart' as ansi;
import 'package:rougish/term/terminal.dart' as term;
import '../screen.dart';

class PauseScreen extends Screen {
  static const logLabel = 'PauseScreen';
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
    return (item == _curOption) ? '${ansi.flip}${label}${ansi.flop}' : label;
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

  @override
  void onKeySequence(List<int> seq, String hash) {
    Log.debug(logLabel, 'onKeySequence: ${hash}');
    ScreenEvent todo = ScreenEvent.nothing;

    if (config.isPause(hash)) {
      todo = options[0];
    } else if (config.isUp(hash)) {
      _curOption = _wrap(_curOption, -1, numOptions);
    } else if (config.isDown(hash)) {
      _curOption = _wrap(_curOption, 1, numOptions);
    } else if (term.isEnter(seq)) {
      todo = options[_curOption];
    }

    term.centerMessage(StringBuffer(), 'key hash: ${hash}  curOption: ${_curOption}', yOffset: 6);

    if (todo != ScreenEvent.nothing) {
      term.centerMessage(StringBuffer(), 'todo: \'${todo}\'', yOffset: 5);
      _curOption = 0;
      broadcast(todo);
    }
  }

  @override
  void draw(StringBuffer buffer) {
    _dialog(buffer);
  }
}
