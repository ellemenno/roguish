import './cell.dart';
import './creature.dart';
import './map_types.dart';

class LevelManager {
  static bool _isUnoccupied(Cell cell) {
    return (cell.occupant.type == CreatureType.none);
  }

  static bool _isTraversable(Cell cell) {
    switch (cell.type) {
      case CellType.unexplored:
        return false;
      case CellType.tunnelDim:
        return true;
      case CellType.tunnelBright:
        return true;
      case CellType.wallDim:
        return false;
      case CellType.wallBright:
        return false;
      case CellType.doorH:
        return true;
      case CellType.doorV:
        return true;
      case CellType.floor:
        return true;
      case CellType.fireWall:
        return false;
      case CellType.fireWallSmall:
        return false;
      case CellType.iceWall:
        return false;
      case CellType.iceWallSmall:
        return false;
      case CellType.exit:
        return true;
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
      } else {
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
