import 'dart:math';

import 'src/cell.dart';
import 'src/creature.dart';
import 'src/room.dart';

class GameData {
  final Random prng;
  final List<Creature> players = [];
  final List<Room> rooms = [];
  final List<List<Cell>> levelMap = [];
  final int levelMax = 10;

  late final Map<String, String> _conf;
  Map<String, String> get conf => _conf;

  bool newLevel = true;
  int level = 1;
  int experience = 0;
  int health = 10;
  int strength = 1;
  int runes = 0;
  int herbs = 0;
  int coins = 0;

  GameData(this._conf, {int seed = 1234}) : prng = Random(seed);
}
