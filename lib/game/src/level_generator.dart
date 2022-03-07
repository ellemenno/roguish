import './cell.dart';
import './creature.dart';
import './level_manager.dart';
import './map_types.dart';
import './rectangle.dart';

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

    for (int r = r1; r <= r2; r++) {
      for (int c = c1; c <= c2; c++) {
        map[r][c].type =
            (r == r1 || r == r2 || c == c1 || c == c2) ? CellType.wallDim : CellType.floor;
      }
    }
  }

  static void generate(List<List<Cell>> map, List<Creature> players, {cols = 80, rows = 24}) {
    _fill(map, cols, rows);

    // eventually, smart stuff to populate the cells..
    Rectangle coords1 = Rectangle(2, 4, 8, 12);
    _room(map, coords1);
    Rectangle.translate(coords1, dx: coords1.width + 2);
    Rectangle.resize(coords1, dr: 8);
    _room(map, coords1);
    Rectangle coords2 = Rectangle.byDimension(6, 4);
    Rectangle.translate(coords2, dx: coords1.right + 6, dy: 5);
    _room(map, coords2);

    map.first.first.type = CellType.tunnelDim;
    map.first.last.type = CellType.tunnelBright;
    map.last.first.type = CellType.wallBright;
    map.last.last.type = CellType.wallDim;

    int pc = (cols / 2).floor();
    int pr = (rows / 2).floor();

    int i = 0;
    for (Creature player in players) {
      LevelManager.spawn(map, player, pc + i, pr);
      i++;
    }
  }
}
