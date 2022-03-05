import 'map_types.dart';

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
