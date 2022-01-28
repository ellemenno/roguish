const CSI = '\x1b['; // Control Sequence Introducer
const RESET = '${CSI}0m'; // reset text styles
const FLIP = '${CSI}7m'; // swap foreground and background
const FLOP = '${CSI}27m'; // restore foreground and background
const CLEAR = '${CSI}2J'; // clear whole screen (see cls method for other options)
const HIDE = '${CSI}?25l'; // hide cursor
const SHOW = '${CSI}?25h'; // show cursor
const NONE = -1; // represents no color

void c16(StringBuffer sb, String msg,
    {int fg = 7, int bg = NONE, bool fb = false, bool bb = false}) {
  // 16 color palette
  //  h: [0..7], +60 for high intensity (0=black, 1=red, 2=green, 3=yellow, 4=blue, 5=magenta, 6=cyan, 7=white)
  // fg: \e[Cm, C = 30 + h [+ 60]
  // bg: \e[Cm, C = 40 + h [+ 60]
  if (fg > NONE && fg < 8) {
    sb.write('${CSI}${30 + fg + (fb ? 60 : 0)}m');
  }
  if (bg > NONE && bg < 8) {
    sb.write('${CSI}${40 + bg + (bb ? 60 : 0)}m');
  }
  sb.write(msg);
  sb.write(RESET);
}

void cRGB(StringBuffer sb, String msg, {int fg = 0x999999, int bg = NONE}) {
  // 16.7M color palette
  // R,G,B: [0..255]
  // fg: \e[38;2;R;G;Bm
  // bg: \e[48;2;R;G;Bm
  if (fg > NONE && fg <= 0xffffff) {
    sb.write('${CSI}38;2;${(fg >> 16) & 255};${(fg >> 8) & 255};${fg & 255}m');
  }
  if (bg > NONE && bg <= 0xffffff) {
    sb.write('${CSI}48;2;${(bg >> 16) & 255};${(bg >> 8) & 255};${bg & 255}m');
  }
  sb.write(msg);
  sb.write(RESET);
}

void reset(StringBuffer sb) {
  // reset text styles
  // \e[0m
  sb.write(RESET);
}

void xy(StringBuffer sb, int x, int y) {
  // position cursor (VT goes line first, then column)
  // x and y are 1-based, up to terminalColumns and terminalLines, inclusive
  // \e[y;xH
  sb.write('${CSI}${y};${x}H');
}

void cls(StringBuffer sb, {int n = 2}) {
  // clear screen
  // \e[nJ, n=0 cursor to start, n=1 cursor to end, n=2 all
  sb.write('${CSI}${n}J');
}

void cll(StringBuffer sb, {int n = 2}) {
  // clear line
  // \e[nK, n=0 cursor to start, n=1 cursor to end, n=2 all
  sb.write('${CSI}${n}K');
}
