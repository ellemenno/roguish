import 'dart:math' as math;

/// A class for representing two-dimensional rectangles whose integer-based properties are mutable.
///
/// Similar, but different: [dart:math.Rectangle] offers immutable properties and requires use of the [dart:math.Point] class.
class Rectangle {
  static bool isWithin(int col, int row, Rectangle r) {
    if (col < r.left) {
      return false;
    }
    if (col >= r.right) {
      return false;
    }
    if (row < r.top) {
      return false;
    }
    if (row >= r.bottom) {
      return false;
    }
    return true;
  }

  static bool isIntersecting(Rectangle r1, Rectangle r2) {
    if (r1.right < r2.left) {
      return false;
    }
    if (r1.left > r2.right) {
      return false;
    }
    if (r1.bottom < r2.top) {
      return false;
    }
    if (r1.top > r2.bottom) {
      return false;
    }
    return true;
  }

  static int leftMost(List<Rectangle> list) =>
      list.fold(list.first.left, (v, e) => math.min(v, e.left));

  static int rightMost(List<Rectangle> list) =>
      list.fold(list.first.right, (v, e) => math.max(v, e.right));

  static int topMost(List<Rectangle> list) =>
      list.fold(list.first.top, (v, e) => math.min(v, e.top));

  static int bottomMost(List<Rectangle> list) =>
      list.fold(list.first.bottom, (v, e) => math.max(v, e.bottom));

  static Rectangle bounding(Rectangle r1, Rectangle r2) {
    return Rectangle(math.min(r1.left, r2.left), math.min(r1.top, r2.top),
        math.max(r1.right, r2.right), math.max(r1.bottom, r2.bottom));
  }

  static Rectangle splitH(Rectangle r1, int distance, {int halfGap = 1}) {
    if (distance >= r1.width) {
      throw Exception('rectangle of width ${r1.width} can not be split at ${distance}');
    }
    Rectangle r2 = Rectangle(r1.right - distance + halfGap, r1.top, r1.right, r1.bottom);
    r1.right = r2.left - halfGap;
    return r2;
  }

  static Rectangle splitV(Rectangle r1, int distance, {int halfGap = 1}) {
    if (distance >= r1.height) {
      throw Exception('rectangle of height ${r1.height} can not be split at ${distance}');
    }
    Rectangle r2 = Rectangle(r1.left, r1.bottom - distance + halfGap, r1.right, r1.bottom);
    r1.bottom = r2.top - halfGap;
    return r2;
  }

  static void randomShrink(Rectangle r, math.Random prng, {int minW = 4, int minH = 4}) {
    if (r.width < minW) {
      throw Exception('rectangle width ${r.width} is already smaller than minW ${minW}');
    }
    if (r.height < minH) {
      throw Exception('rectangle height ${r.height} is already smaller than minH ${minH}');
    }
    int dw = r.width - minW;
    int dh = r.height - minH;
    int ilerp(int a, int b, num t) => a + ((b - a) * t).round();

    int dl = ilerp(0, dw, prng.nextDouble());
    int dr = -1 * ilerp(0, (dw - dl), prng.nextDouble());
    int dt = ilerp(0, dh, prng.nextDouble());
    int db = -1 * ilerp(0, (dh - dt), prng.nextDouble());

    resize(r, dl: dl, dt: dt, dr: dr, db: db, minW: minW, minH: minH);
  }

  static void resize(Rectangle r,
      {int dl = 0, int dt = 0, int dr = 0, int db = 0, int minW = 3, int minH = 3}) {
    r.left += dl;
    r.top += dt;
    r.right += dr;
    r.bottom += db;
    if (r.width < minW) {
      throw Exception('rectangle resized to invalid width');
    }
    if (r.height < minH) {
      throw Exception('rectangle resized to invalid height');
    }
  }

  static void translate(Rectangle r, {int dx = 0, int dy = 0}) {
    r.left += dx;
    r.top += dy;
    r.right += dx;
    r.bottom += dy;
  }

  int left;
  int top;
  int right;
  int bottom;

  int get width => right - left;
  int get height => bottom - top;
  int get midX => left + (width ~/ 2);
  int get midY => top + (height ~/ 2);

  @override
  String toString() => '[${left},${top},${right},${bottom}]';

  Rectangle clone() => Rectangle.byDimension(width, height);

  Rectangle(this.left, this.top, this.right, this.bottom);

  Rectangle.square(int size)
      : left = 0,
        top = 0,
        right = size,
        bottom = size;

  Rectangle.byDimension(int width, int height)
      : left = 0,
        top = 0,
        right = width,
        bottom = height;
}
