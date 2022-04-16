import './creature.dart';
import './item.dart';
import './map_symbols.dart';
import './map_types.dart';

class Cell {
  final int col;
  final int row;
  String _creatureSymbol = '?';
  String _itemSymbol = '?';
  String _cellSymbol = '?';

  Creature _occupant = Creature.noCreature;
  Creature get occupant => _occupant;
  set occupant(Creature creature) {
    _occupant = creature;
    _creatureSymbol = creatureSymbol(creature.type);
  }

  Item _contents = Item.noItem;
  Item get contents => _contents;
  set contents(Item item) {
    _contents = item;
    _itemSymbol = itemSymbol(item.type);
  }

  CellType _type = CellType.unexplored;
  CellType get type => _type;
  set type(CellType cellType) {
    _type = cellType;
    _cellSymbol = cellSymbol(cellType);
  }

  @override
  String toString() {
    if (_occupant.type != CreatureType.none) return _creatureSymbol;
    if (_contents.type != ItemType.none) return _itemSymbol;
    return _cellSymbol;
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
