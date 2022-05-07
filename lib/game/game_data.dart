import 'dart:math';

import 'src/cell.dart';
import 'src/creature.dart';
import 'src/room.dart';

class GameData {
  final int fps = 60;
  final int scanGap = 1;
  final List<Creature> players = [];
  final List<Room> rooms = [];
  final List<List<Cell>> levelMap = [];
  final int levelMax = 10;

  final List<String> cmdArgs = [];

  final Map<String, String> _conf;
  Map<String, String> get conf => _conf;

  int _seed;
  int get seed => _seed;

  Random _prng;
  Random get prng => _prng;

  bool newLevel = true;
  int level = 1;
  int experience = 0;
  int health = 10;
  int strength = 1;
  int runes = 0;
  int herbs = 0;
  int coins = 0;

  List<int> keyCodes = [];
  int frameMicroseconds = 0;

  void reseed(int seed) {
    _seed = seed;
    _prng = Random(_seed);
  }

  GameData(this._conf, this._seed) : _prng = Random(_seed);
}
