import 'dart:math' as math;

import 'package:rougish/log/log.dart';

import './cell.dart';
import './creature.dart';
import './level_manager.dart';
import './map_types.dart';
import './rectangle.dart';

class LevelGenerator {
  static const logLabel = 'LevelGenerator';

  static void _fill(List<List<Cell>> map, int cols, int rows) {
    map.clear();
    for (int r = 0; r < rows; r++) {
      List<Cell> row = [];
      for (int c = 0; c < cols; c++) {
        row.add(Cell(c, r));
      }
      map.add(row);
    }
  }

  static void _paintRoom(List<List<Cell>> map, Rectangle coords) {
    int c1 = coords.left;
    int c2 = coords.right - 1;
    int r1 = coords.top;
    int r2 = coords.bottom - 1;

    for (int r = r1; r <= r2; r++) {
      for (int c = c1; c <= c2; c++) {
        map[r][c].type =
            (r == r1 || r == r2 || c == c1 || c == c2) ? CellType.wallDim : CellType.floor;
      }
    }
  }

  static List<Rectangle> _bombByFrequency(List<Rectangle> input, math.Random prng, {freq = 0.66}) {
    List<Rectangle> result = [];
    int n = input.length;
    for (int i = 0; i < n; i++) {
      if (prng.nextDouble() >= freq) {
        result.add(input.removeAt(i));
        i -= 1;
        n = input.length;
      }
    }
    return result;
  }

  static List<Rectangle> _splitFurther(List<Rectangle> input,
      {maxR = 2.5, minDim = 4, halfGap = 2}) {
    List<Rectangle> result = [];
    Rectangle r1;
    Rectangle r2;
    bool shouldSplit(int w, int h) => (math.max(w, h) / math.min(w, h) >= maxR);
    bool isSplittable(int dim) => dim >= ((minDim + 2) * 2);

    while (input.isNotEmpty) {
      r1 = input.removeLast();
      if (shouldSplit(r1.width, r1.height)) {
        if (isSplittable(r1.width)) {
          r2 = Rectangle.splitH(r1, r1.width ~/ 2, halfGap: halfGap);
          input.addAll([r1, r2]);
        } else if (isSplittable(r1.height)) {
          r2 = Rectangle.splitV(r1, r1.height ~/ 2, halfGap: halfGap);
          input.addAll([r1, r2]);
        } else {
          result.add(r1);
        }
      } else {
        result.add(r1);
      }
    }

    return result;
  }

  static List<Rectangle> _splitHorV(Rectangle r, math.Random prng, {minDim = 3, halfGap = 1}) {
    List<Rectangle> input = [r];
    List<Rectangle> result = [];
    Rectangle r1;
    Rectangle r2;
    bool isSplittable(int dim) => dim >= ((minDim + 2) * 2);

    while (input.isNotEmpty) {
      r1 = input.removeLast();
      if (prng.nextBool() == true) {
        if (isSplittable(r1.width)) {
          r2 = Rectangle.splitH(r1, r1.width ~/ 2, halfGap: halfGap);
          input.addAll([r1, r2]);
        } else {
          result.add(r1);
        }
      } else {
        if (isSplittable(r1.height)) {
          r2 = Rectangle.splitV(r1, r1.height ~/ 2, halfGap: halfGap);
          input.addAll([r1, r2]);
        } else {
          result.add(r1);
        }
      }
    }

    return result;
  }

  static void generate(List<List<Cell>> map, List<Creature> players, math.Random prng,
      {cols = 80, rows = 24}) {
    _fill(map, cols, rows);

    List<Rectangle> rooms;
    rooms = _splitHorV(Rectangle.byDimension(cols, rows), prng);
    rooms = _splitFurther(rooms);
    rooms = _bombByFrequency(rooms, prng);
    Log.debug(logLabel, 'created ${rooms.length} incredible rooms');

    Rectangle r;
    for (r in rooms) {
      _paintRoom(map, r);
    }

    for (Creature player in players) {
      r = rooms[prng.nextInt(rooms.length)];
      //FIXME: prevent same room selection
      LevelManager.spawn(map, player, r.midX, r.midY);
    }
  }
}
