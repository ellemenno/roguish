enum UIType {
  level,
  health,
  strength,
  runes,
  herbs,
  coins,
}

enum CellType {
  unexplored,
  tunnelDim,
  tunnelBright,
  wallDim,
  wallBright,
  doorH,
  doorV,
  floor,
  fireWall,
  fireWallSmall,
  iceWall,
  iceWallSmall,
  exit,
}

enum CreatureType {
  none,
  humanPlayer,
  humanNPC,
  slimeLarge,
  slimeMedium,
  slime,
  bat,
  spiderLarge,
  spider,
  cobraLarge,
  cobra,
  scorpionLarge,
  scorpion,
  dragon,
  skeleton,
}

enum ItemType {
  none,
  // health
  pestle,
  herbYoung,
  herbFresh,
  herbDried,
  potion,
  food,
  // strength
  mace,
  sword,
  arrow,
  bow,
  shield,
  // magic
  staff,
  rune,
  flame,
  fireball,
  iceball,
  // treasure
  grave,
  gold,
  ruby,
  pearl,
  diamond,
  ring,
  bracelet,
}

enum ItemCategory {
  none,
  health,
  strength,
  magic,
  treasure,
}

const Map<ItemCategory, List<ItemType>> itemCatalog = {
  ItemCategory.health: [
    ItemType.pestle,
    ItemType.herbYoung,
    ItemType.herbFresh,
    ItemType.herbDried,
    ItemType.potion,
    ItemType.food,
  ],
  ItemCategory.strength: [
    ItemType.mace,
    ItemType.sword,
    ItemType.arrow,
    ItemType.bow,
    ItemType.shield,
  ],
  ItemCategory.magic: [
    ItemType.staff,
    ItemType.rune,
    ItemType.flame,
    ItemType.fireball,
    ItemType.iceball,
  ],
  ItemCategory.treasure: [
    ItemType.grave,
    ItemType.gold,
    ItemType.ruby,
    ItemType.pearl,
    ItemType.diamond,
    ItemType.ring,
    ItemType.bracelet,
  ],
};

String uiSymbol(UIType type) {
  switch (type) {
    case UIType.level:
      return '\u2261'; //           ≡ 2261
    case UIType.health:
      return '\u2665'; //           ♥ 2665
    case UIType.strength:
      return '\u002B'; //           + 002B
    case UIType.runes:
      return '\u16B9'; //           ᚹ 16B9
    case UIType.herbs:
      return '\u2698'; //           ⚘ 2698
    case UIType.coins:
      return '\u0024'; //           $ 0024
  }
}

String cellSymbol(CellType type) {
  switch (type) {
    case CellType.unexplored:
      return '\u0020'; //             0020 (space)
    case CellType.tunnelDim:
      return '\u2591'; //           ░ 2591
    case CellType.tunnelBright:
      return '\u2592'; //           ▒ 2592
    case CellType.wallDim:
      return '\u2593'; //           ▓ 2593
    case CellType.wallBright:
      return '\u2588'; //           █ 2588
    case CellType.doorH:
      return '\u2501'; //           ━ 2501
    case CellType.doorV:
      return '\u2503'; //           ┃ 2503
    case CellType.floor:
      return '\u002e'; //           . 002e
    case CellType.fireWall:
      return '\u25A0'; //           ■ 25A0
    case CellType.fireWallSmall:
      return '\u25AA'; //           ▪ 25AA
    case CellType.iceWall:
      return '\u25A1'; //           □ 25A1
    case CellType.iceWallSmall:
      return '\u25AB'; //           ▫ 25AB
    case CellType.exit:
      return '\u2261'; //           ≡ 2261
  }
}

String creatureSymbol(CreatureType type) {
  switch (type) {
    case CreatureType.humanPlayer:
      return '\u263B'; //           ☻ 263B
    case CreatureType.humanNPC:
      return '\u263A'; //           ☺ 263A
    case CreatureType.slimeLarge:
      return '\u1E4F'; //           ṏ 1E4F
    case CreatureType.slimeMedium:
      return '\u00D6'; //           ö 00D6
    case CreatureType.slime:
      return '\u00B0'; //           ° 00B0
    case CreatureType.bat:
      return '\u0264'; //           ɤ 0264
    case CreatureType.spiderLarge:
      return '\u0466'; //           Ѧ 0466
    case CreatureType.spider:
      return '\u0467'; //           ѧ 0467
    case CreatureType.cobraLarge:
      return '\u0291'; //           ʑ 0291
    case CreatureType.cobra:
      return '\u1dbd'; //           ᶽ 1dbd
    case CreatureType.scorpionLarge:
      return '\u0255'; //           ɕ 0255
    case CreatureType.scorpion:
      return '\u1d9d'; //           ᶝ 1d9d
    case CreatureType.dragon:
      return '\u1E9F'; //           ẟ 1E9F
    case CreatureType.skeleton:
      return '\u02AD'; //           ʭ 02AD
    default:
      return 'X';
  }
}

String itemSymbol(ItemType type) {
  switch (type) {
    // health
    case ItemType.pestle:
      return '\u26B2'; //           ⚲ 26B2
    case ItemType.herbYoung:
      return '\u27df'; //           ⟟ 27df
    case ItemType.herbFresh:
      return '\u2698'; //           ⚘ 2698
    case ItemType.herbDried:
      return '\u26B5'; //           ⚵ 26B5
    case ItemType.potion:
      return '\u2641'; //           ♁ 2641
    case ItemType.food:
      return '\u0023'; //           # 0023
    // strength
    case ItemType.mace:
      return '\u26B4'; //           ⚴ 26B4
    case ItemType.sword:
      return '\u26B8'; //           ⚸ 26B8
    case ItemType.arrow:
      return '\u{10323}'; //        𐌣 10323
    case ItemType.bow:
      return '\u0028'; //           ( 0028
    case ItemType.shield:
      return '\u005B'; //           [ 005B
    // magic
    case ItemType.staff:
      return '\u0021'; //           ! 0021
    case ItemType.rune:
      return '\u16B9'; //           ᚹ 16B9
    case ItemType.flame:
      return '\u1EFC'; //           Ỽ 1EFC
    case ItemType.fireball:
      return '\u25CF'; //           ● 25CF
    case ItemType.iceball:
      return '\u25CB'; //           ○ 25CB
    // treasure
    case ItemType.grave:
      return '\u2020'; //           † 2020
    case ItemType.gold:
      return '\u24FF'; //           ⓿ 24FF
    case ItemType.ruby:
      return '\u2666'; //           ♦ 2666
    case ItemType.pearl:
      return '\u2022'; //           • 2022
    case ItemType.diamond:
      return '\u22C4'; //           ⋄ 22C4
    case ItemType.ring:
      return '\u2641'; //           ♁ 2641
    case ItemType.bracelet:
      return '\u25CC'; //           ◌ 25CC
    default:
      return 'X';
  }
}

class Item {
  final ItemCategory category;
  final ItemType type;

  Item(this.type, this.category);

  Item.none()
      : category = ItemCategory.none,
        type = ItemType.none;
}

class Creature {
  final CreatureType type;

  Creature(this.type);

  Creature.none() : type = CreatureType.none;
}

class Cell {
  final int col;
  final int row;

  Creature occupant = Creature.none();
  Item contents = Item.none();
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

class MapMaker {
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

  static void generate(List<List<Cell>> map, {cols = 80, rows = 24}) {
    _fill(map, cols, rows);
    // eventually, smart stuff to populate the cells..
    map.first.first.type = CellType.tunnelDim;
    map.first.last.type = CellType.tunnelBright;
    map.last.first.type = CellType.wallBright;
    map.last.last.type = CellType.wallDim;
  }

  static void render(StringBuffer screenBuffer, List<List<Cell>> map) {
    int rows = map.length;
    int cols = map.first.length;
    Cell cell;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        cell = map[r][c];
        screenBuffer.write(cellSymbol(cell.type));
      }
      if (r + 1 < rows) {
        screenBuffer.write('\n');
      }
    }
  }
}
