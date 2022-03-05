import 'dart:math' as math;

import 'package:rougish/game/game_data.dart';

//import 'src/creature.dart';
//import 'src/item.dart';
import 'src/map_types.dart';
import 'src/map_symbols.dart';

export 'src/map_types.dart';
export 'src/map_symbols.dart';


class Item {
  static final Item noItem = Item.none();

  final ItemCategory category;
  final ItemType type;

  Item(this.type, this.category);

  Item.none()
      : category = ItemCategory.none,
        type = ItemType.none;
}

class Creature {
  static final Creature noCreature = Creature.none();

  final CreatureType type;

  int col = -1;
  int row = -1;
  int health = 0;
  int strength = 0;
  int runes = 0;
  int herbs = 0;
  int coins = 0;

  Creature(this.type);

  Creature.none() : type = CreatureType.none;
}

class Cell {
  final int col;
  final int row;

  Creature occupant = Creature.noCreature;
  Item contents = Item.noItem;
  CellType type = CellType.unexplored;

  @override
  String toString() {
    if (occupant.type != CreatureType.none) return creatureSymbol(occupant.type);
    if (contents.type != ItemType.none) return itemSymbol(contents.type);
    return cellSymbol(type);
  }

  String toDebugString() {
    return '[${col.toString().padLeft(2, '0')},${row.toString().padLeft(2, '0')}:${this}]';
  }

  Cell(this.col, this.row);
}

class Rectangle {
  int left;
  int top;
  int right;
  int bottom;

  int get width => right - left;
  int get height => bottom - top;

  @override
  String toString() { return '[${left},${top},${right},${bottom}]'; }

  Rectangle(this.left, this.top, this.right, this.bottom);

  Rectangle.square(int size) :
    left = 0,
    top = 0,
    right = size,
    bottom = size;

  Rectangle.byDimension(int width, int height) :
    left = 0,
    top = 0,
    right = width,
    bottom = height;

  static Rectangle bounding(Rectangle r1, Rectangle r2) {
    return Rectangle(
      math.min(r1.left, r2.left),
      math.min(r1.top, r2.top),
      math.max(r1.right, r2.right),
      math.max(r1.bottom, r2.bottom)
    );
  }

  static Rectangle splitH(Rectangle r1, int distance) {
    if (distance >= r1.width) { throw Exception('rectangle of width ${r1.width} can not be split at ${distance}'); }
    Rectangle r2 = Rectangle(r1.right - distance, r1.top, r1.right, r1.bottom);
    r1.right -= distance;
    return r2;
  }

  static Rectangle splitV(Rectangle r1, int distance) {
    if (distance >= r1.height) { throw Exception('rectangle of height ${r1.height} can not be split at ${distance}'); }
    Rectangle r2 = Rectangle(r1.left, r1.top + distance, r1.right, r1.bottom);
    r1.bottom -= distance;
    return r2;
  }

  static void resize(Rectangle r, { int dl = 0, int dt = 0, int dr = 0, int db = 0 }) {
    r.left += dl;
    r.top += dt;
    r.right += dr;
    r.bottom += db;
    if (r.width <= 3) { throw Exception('rectangle resized to invalid width'); }
    if (r.height <= 3) { throw Exception('rectangle resized to invalid height'); }
  }

  static void translate(Rectangle r, { int dx = 0, int dy = 0 }) {
    r.left += dx;
    r.top += dy;
    r.right += dx;
    r.bottom += dy;
  }
}

class LevelGenerator {

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

  static void _room(List<List<Cell>> map, Rectangle coords) {
    int c1 = coords.left;
    int c2 = coords.right;
    int r1 = coords.top;
    int r2 = coords.bottom;
    for (int c = c1; c <= c2; c++) {
      map[r1][c].type = CellType.wallDim;
      map[r2][c].type = CellType.wallDim;
    }
    for (int r = r1+1; r < r2; r++) {
      map[r][c1].type = CellType.wallDim;
      map[r][c2].type = CellType.wallDim;
    }
  }

  static void generate(GameData gameData, {cols = 80, rows = 24}) {
    List<List<Cell>> map = gameData.levelMap;
    _fill(map, cols, rows);

    // eventually, smart stuff to populate the cells..
    Rectangle coords = Rectangle(2,4,8,12);
    _room(map, coords);
    map.first.first.type = CellType.tunnelDim;
    map.first.last.type = CellType.tunnelBright;
    map.last.first.type = CellType.wallBright;
    map.last.last.type = CellType.wallDim;

    int mc = (cols / 2).floor();
    int mr = (rows / 2).floor();

    int i = 0;
    for (Creature player in gameData.players) {
      LevelManager.spawn(map, player, mc+i, mr);
      i++;
    }
  }

}

class LevelManager {

  static bool _isUnoccupied(Cell cell) {
    return (cell.occupant.type == CreatureType.none);
  }

  static bool _isTraversable(Cell cell) {
    switch (cell.type) {
      case CellType.unexplored: return true; // but if we occupy the cell, it's no longer unexplored..
      case CellType.tunnelDim: return true;
      case CellType.tunnelBright: return true;
      case CellType.wallDim: return false;
      case CellType.wallBright: return false;
      case CellType.doorH: return true;
      case CellType.doorV: return true;
      case CellType.floor: return true;
      case CellType.fireWall: return false;
      case CellType.fireWallSmall: return false;
      case CellType.iceWall: return false;
      case CellType.iceWallSmall: return false;
      case CellType.exit: return true;
    }
  }

  static void spawn(List<List<Cell>> map, Creature c, int col, int row) {
    map[row][col].occupant = c;
    c.col = col;
    c.row = row;
  }

  static void towards(List<List<Cell>> map, Creature c, int dc, int dr) {
    int oldCol = c.col;
    int oldRow = c.row;
    int newCol = oldCol + dc;
    int newRow = oldRow + dr;
    Cell targetCell = map[newRow][newCol];

    if (_isTraversable(targetCell)) {
      if (_isUnoccupied(targetCell)) {
        move(map, c, newCol, newRow);
      }
      else {
        // TODO: initiate interaction, e.g. attack
      }
    }
  }

  static void move(List<List<Cell>> map, Creature c, int newCol, int newRow) {
    int oldCol = c.col;
    int oldRow = c.row;
    map[oldRow][oldCol].occupant = Creature.noCreature;
    map[newRow][newCol].occupant = c;
    // TODO: acquire items
    c.col = newCol;
    c.row = newRow;
  }

  static void render(StringBuffer screenBuffer, List<List<Cell>> map) {
    int rows = map.length;
    int cols = map.first.length;
    Cell cell;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        cell = map[r][c];
        screenBuffer.write(cell.toString());
      }
      if (r + 1 < rows) {
        screenBuffer.write('\n');
      }
    }
  }
}
