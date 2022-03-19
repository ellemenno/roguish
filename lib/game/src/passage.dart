import 'dart:math' as math;

import './connector.dart';

class Passage extends Connector {
  static bool isWithin(int col, int row, Passage p) {
    if (p.isVertical) {
      if (col != p.c1) {
        return false;
      }
      if (row >= p.startRow && row <= p.endRow) {
        return true;
      }
    } else {
      if (row != p.r1) {
        return false;
      }
      if (col >= p.startCol && col <= p.endCol) {
        return true;
      }
    }
    return false;
  }

  int c1, r1;
  int c2, r2;

  @override
  bool contains(int c, int r) => Passage.isWithin(c, r, this);

  bool get isHorizontal => (r1 == r2);
  bool get isVertical => (c1 == c2);
  int get startCol => math.min(c1, c2);
  int get startRow => math.min(r1, r2);
  int get endCol => math.max(c1, c2);
  int get endRow => math.max(r1, r2);

  Passage(this.c1, this.r1, this.c2, this.r2) : assert((c1 == c2) || (r1 == r2));
}
