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
