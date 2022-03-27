import './connector.dart';
import './location.dart';
import './map_types.dart';
import './rectangle.dart';

class Room extends Connector {
  Rectangle coords;

  @override
  String toString() => 'R${coords.toString()}';

  // ln:col format
  @override
  String toScreenString() =>
      '${coords.top + 1}:${coords.left + 1}->${coords.bottom + 1}:${coords.right + 1}';

  @override
  bool contains(int c, int r) => Rectangle.isWithin(c, r, coords);

  void spawnPoint(Location loc, CreatureType creatureType) {
    // TODO: account for creature type
    loc.col = coords.midX;
    loc.row = coords.midY;
  }

  Room(this.coords);
}
