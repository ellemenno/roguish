import './connector.dart';
import './location.dart';
import './map_types.dart';
import './rectangle.dart';

class Room extends Connector {
  Rectangle coords;

  @override
  bool contains(int c, int r) => Rectangle.isWithin(c, r, coords);

  void spawnPoint(Location loc, CreatureType creatureType) {
    // TODO: account for creature type
    loc.col = coords.midX;
    loc.row = coords.midY;
  }

  Room(this.coords);
}
