/// helper functions for ansi codes.
///
/// references:
/// - https://en.wikipedia.org/wiki/ANSI_escape_code
/// - https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
library ansi;

/// Reset to Initial State: clears screen and history and shows cursor
const ris = '\x1bc';

/// Control Sequence Introducer
const csi = '\x1b[';

/// Resets text styles to defaults
const plain = '${csi}0m';

/// Swaps foreground and background
const flip = '${csi}7m';

/// Restores foreground and background
const flop = '${csi}27m';

/// Clears whole screen (but not scrollback history); see [cls] for more options.
const clear = '${csi}2J';

/// Hides cursor
const hide = '${csi}?25l';

/// Shows cursor
const show = '${csi}?25h';

/// Enters new screen buffer
const enterBuffer = '${csi}?1049h';

/// Leaves screen buffer, returning to previous
const leaveBuffer = '${csi}?1049l';

/// Represents no color (not an ANSI code)
const none = -1;

/// Decorates [msg] with optional foreground and background colors, and prints it to [sb].
///
/// [c16] supports 8 hues at two intensity levels: dim (default), or bright
/// (set [fb] `true` for foreground bright, [bb] for background bright)
///
/// the ansi color codes for [fg] or [bg] are:
/// - `0` black
/// - `1` red
/// - `2` green
/// - `3` yellow
/// - `4` blue
/// - `5` magenta
/// - `6` cyan
/// - `7` white
///
/// `-1` is interpreted as 'no color', meaning that ansi code is omitted
///
/// note that a terminal color scheme may remap the ansi colors to custom values
void c16(StringBuffer sb, String msg,
    {int fg = 7, int bg = none, bool fb = false, bool bb = false}) {
  // 16 color palette
  //  h: [0..7], +60 for high intensity (0=black, 1=red, 2=green, 3=yellow, 4=blue, 5=magenta, 6=cyan, 7=white)
  // fg: \e[Cm, C = 30 + h [+ 60]
  // bg: \e[Cm, C = 40 + h [+ 60]
  if (fg > none && fg < 8) {
    sb.write('${csi}${30 + fg + (fb ? 60 : 0)}m');
  }
  if (bg > none && bg < 8) {
    sb.write('${csi}${40 + bg + (bb ? 60 : 0)}m');
  }
  sb.write(msg);
  sb.write(plain);
}

/// Decorates [msg] with optional foreground and background colors, and prints it to [sb].
///
/// [cRGB] supports 16.7M colors from 8-bit RGB hex strings (commonly used for CSS web colors).
///
/// `-1` ([none]) is interpreted as 'no color', meaning that ansi code is omitted
void cRGB(StringBuffer sb, String msg, {int fg = 0x999999, int bg = none}) {
  // 16.7M color palette
  // R,G,B: [0..255]
  // fg: \e[38;2;R;G;Bm
  // bg: \e[48;2;R;G;Bm
  if (fg > none && fg <= 0xffffff) {
    sb.write('${csi}38;2;${(fg >> 16) & 255};${(fg >> 8) & 255};${fg & 255}m');
  }
  if (bg > none && bg <= 0xffffff) {
    sb.write('${csi}48;2;${(bg >> 16) & 255};${(bg >> 8) & 255};${bg & 255}m');
  }
  sb.write(msg);
  sb.write(plain);
}

/// Prints an ansi code into [sb] for font style reset (i.e. [plain]).
void reset(StringBuffer sb) {
  // reset text styles
  // \e[0m
  sb.write(plain);
}

/// Prints an ansi code into [sb] to position the terminal cursor at column [x] of line [y].
///
/// [x] and [y] are 1-based, up to `dart:io.Stdout.terminalColumns` and `dart:io.Stdout.terminalLines`.
void xy(StringBuffer sb, int x, int y) {
  // cursor position (VT goes line first, then column)
  // \e[y;xH
  sb.write('${csi}${y};${x}H');
}

/// Prints an ansi code into [sb] to position the terminal cursor at column [x] of the current line.
///
/// [x] is 1-based, up to `dart:io.Stdout.terminalLines`.
void cha(StringBuffer sb, [int x = 1]) {
  // cursor horizontal absolute
  // \e[xG
  sb.write('${csi}${x}G');
}

/// Prints an ansi code into [sb] to position the terminal cursor at beginning of the line [y] lines down (default `1`).
///
/// [y] is 1-based, up to `dart:io.Stdout.terminalLines`.
void cnl(StringBuffer sb, [int y = 1]) {
  // cursor next line
  // \e[yE
  sb.write('${csi}${y}E');
}

/// Prints an ansi code into [sb] to clear some or all of the terminal screen.
///
/// The portion of the screen to be cleared is controlled by [n]:
/// - `0` from cursor to start (0,0)
/// - `1` from cursor to end (terminalColumns, terminalLines)
/// - `2` entire screen
/// - `3` entire screen and scrollback buffer (not supported in all terminals, see [clh] and [ris] for an alternative)
void cls(StringBuffer sb, {int n = 2}) {
  // clear screen
  // \e[nJ, n=0 cursor to start, n=1 cursor to end, n=2 all
  sb.write('${csi}${n}J');
}

/// Prints an ansi code into [sb] to clear the terminal screen and history (scrollback buffer).
///
/// This will unhide the cursor if it was previously hidden. To re-hide the cursor, provide [hideCursor] as `true`
void clh(StringBuffer sb, {hideCursor = false}) {
  sb.write(ris);
  if (hideCursor) {
    sb.write(hide);
  }
}

/// Prints an ansi code into [sb] to clear some or all of the current line.
///
/// The portion of the line to be cleared is controlled by [n]:
/// - `0` from cursor to start of line
/// - `1` from cursor to end of line
/// - `2` entire line
void cll(StringBuffer sb, {int n = 2}) {
  // clear line
  // \e[nK, n=0 cursor to start, n=1 cursor to end, n=2 all
  sb.write('${csi}${n}K');
}
