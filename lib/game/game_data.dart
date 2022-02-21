
class GameData {
  late final Map<String, String> _conf;
  Map<String, String> get conf => _conf;

  final List<List<Cell>> levelMap = [];

  GameData(this._conf) {}
}
