import './creature.dart';
import './item.dart';
import './map_symbols.dart';
import './map_types.dart';

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

  void reset() {
    occupant = Creature.noCreature;
    contents = Item.noItem;
    type = CellType.unexplored;
  }

  Cell(this.col, this.row);
}
