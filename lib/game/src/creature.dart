import './map_types.dart';

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
