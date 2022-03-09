import 'dart:math';

import 'src/cell.dart';
import 'src/creature.dart';

class GameData {
  final Random prng;
  late final Map<String, String> _conf;
  Map<String, String> get conf => _conf;

  final List<Creature> players = [];

  final List<List<Cell>> levelMap = [];
  int level = 1;
  int experience = 0;
  int health = 10;
  int strength = 1;
  int runes = 0;
  int herbs = 0;
  int coins = 0;

  GameData(this._conf, {int seed = 1234}) : prng = Random(seed);
}
