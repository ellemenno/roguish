import 'dart:math' as math;

import 'package:rougish/log/log.dart';

import './cardinal.dart';
import './cell.dart';
import './connector.dart';
import './creature.dart';
import './level_manager.dart';
import './location.dart';
import './map_types.dart';
import './passage.dart';
import './rectangle.dart';
import './room.dart';

class LevelGenerator {
  static const _logLabel = 'LevelGenerator';
  static final Set<Connector> _connectors = {};

  static bool _inbounds(int c, int r, List<List<Cell>> map) =>
      (c >= 0 && c < map.first.length && r >= 0 && r < map.length);

  static Connector _getConnectorAt(int col, int row, Set<Connector> connections) {
    for (Connector c in connections) {
      if (c.contains(col, row)) {
        return c;
      }
    }
    return Connector.noConnector;
  }

  static void _blank(List<List<Cell>> map) {
    for (List<Cell> row in map) {
      for (Cell cell in row) {
        cell.reset();
      }
    }
  }

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

  static void _reset(List<List<Cell>> map, List<Room> rooms) {
    _blank(map);
    for (Connector c in _connectors) {
      c.removeAllConnections();
    }
    for (Connector c in rooms) {
      c.removeAllConnections();
    }
    _connectors.clear();
    rooms.clear();
  }

  static void _paintPassage(List<List<Cell>> map, int sc, int sr, int dc, int dr) {
    map[sr][sc].type = (dc == 0) ? CellType.doorH : CellType.doorV;
    int c = sc + dc, r = sr + dr;
    bool painting = true;
    while (painting) {
      switch (map[r][c].type) {
        case CellType.unexplored:
          map[r][c].type = CellType.tunnelDim;
          c += dc;
          r += dr;
          break;
        case CellType.wallDim:
        case CellType.wallBright:
          map[r][c].type = (dc == 0) ? CellType.doorH : CellType.doorV;
          painting = false;
          break;
        default:
          painting = false;
          break;
      }
    }
  }

  static void _paintRoom(List<List<Cell>> map, Rectangle coords, {erasing = false}) {
    int c1 = coords.left;
    int c2 = coords.right - 1;
    int r1 = coords.top;
    int r2 = coords.bottom - 1;
    CellType typeForCoords(int c, int r) {
      if (erasing) {
        return CellType.unexplored;
      }
      if (r == r1 || r == r2 || c == c1 || c == c2) {
        return CellType.wallDim;
      }
      return CellType.floor;
    }

    for (int r = r1; r <= r2; r++) {
      for (int c = c1; c <= c2; c++) {
        map[r][c].type = typeForCoords(c, r);
      }
    }
  }

  static void _unpaintRoom(List<List<Cell>> map, Rectangle coords) {
    _paintRoom(map, coords, erasing: true);
  }

  static bool _attemptPassage(List<List<Cell>> map, Room room, Cardinal d, Set<Connector> cnx) {
    Rectangle r = room.coords;
    int dc = 0, dr = 0;
    int sc = r.midX, sr = r.midY;
    switch (d) {
      case Cardinal.north:
        dr = -1;
        sr = r.top;
        break;
      case Cardinal.east:
        dc = 1;
        sc = r.right - 1;
        break;
      case Cardinal.south:
        dr = 1;
        sr = r.bottom - 1;
        break;
      case Cardinal.west:
        dc = -1;
        sc = r.left;
        break;
    }

    bool connected = false;
    int ic = sc + dc, ir = sr + dr;

    CellType t = map[sr][sc].type;
    if (t == CellType.doorH || t == CellType.doorV) {
      connected = true;
      Connector passage = _getConnectorAt(ic, ir, cnx);
      assert(passage is Passage);
      room.connectTo(passage);
      Log.debug(_logLabel,
          '_attemptPassage() .. door already exists at ${sc}, ${sr} to passage at ${ic}, ${ir}');
      return connected;
    }

    bool stepping = true;
    Log.debug(_logLabel, '_attemptPassage() starting stepping from ${ic}, ${ir}');
    while (!connected && stepping && _inbounds(ic, ir, map)) {
      switch (map[ir][ic].type) {
        case CellType.unexplored:
          ic += dc;
          ir += dr;
          break;
        case CellType.tunnelDim:
        case CellType.tunnelBright:
          connected = true;
          break;
        case CellType.wallDim:
        case CellType.wallBright:
          // test that next cell is inside to avoid joining a corner
          connected = (map[ir + dr][ic + dc].type == CellType.floor);
          if (!connected) {
            Log.debug(_logLabel,
                '_attemptPassage() .. skipping corner at ${ic}, ${ir}, next cell is ${map[ir + dr][ic + dc].type}');
          }
          stepping = false;
          break;
        default:
          connected = false;
          stepping = false;
          break;
      }
    }

    if (connected) {
      Connector c = _getConnectorAt(ic, ir, cnx);
      assert(c != Connector.noConnector);
      // create a new Passage, connect to initial room and newly found connector
      //   if connector is another passage, merge connections
      // add the new passage to _connectors
      Log.debug(
          _logLabel, '_attemptPassage() .. pathway found to ${c.runtimeType}; creating passage');
      Passage passage = Passage(sc, sr, ic - dc, ir - dr);
      Connector.twoWayConnection(passage, room);
      if (c is Passage) {
        Connector.mergeConnections(passage, c);
      } else {
        Connector.twoWayConnection(passage, c);
      }
      _connectors.add(passage);
      _paintPassage(map, sc, sr, dc, dr);
    }

    Log.debug(_logLabel, '_attemptPassage() from ${r}, headed ${d}, success? ${connected}');
    return connected;
  }

  static List<Rectangle> _bombByTotal(List<Rectangle> input, math.Random prng, {retention = 0.66}) {
    List<Rectangle> result = [];
    int n = (input.length * retention).round();
    for (int i = 0; i < n; i++) {
      result.add(input.removeAt(prng.nextInt(input.length)));
    }
    return result;
  }

  static List<Rectangle> _splitFurther(List<Rectangle> input,
      {maxRatio = 2.5, minDim = 4, halfGap = 2}) {
    List<Rectangle> result = [];
    Rectangle r1;
    Rectangle r2;
    bool shouldSplit(int w, int h) => (math.max(w, h) / math.min(w, h) >= maxRatio);
    bool isSplittable(int dim) => dim >= ((minDim + 2) * 2);

    while (input.isNotEmpty) {
      r1 = input.removeLast();
      if (shouldSplit(r1.width, r1.height)) {
        if (isSplittable(r1.width)) {
          r2 = Rectangle.splitH(r1, r1.width ~/ 2, halfGap: halfGap);
          input.addAll([r1, r2]);
        } else if (isSplittable(r1.height)) {
          r2 = Rectangle.splitV(r1, r1.height ~/ 2, halfGap: halfGap);
          input.addAll([r1, r2]);
        } else {
          result.add(r1);
        }
      } else {
        result.add(r1);
      }
    }

    return result;
  }

  static List<Rectangle> _splitHorV(Rectangle r, math.Random prng, {minDim = 3, halfGap = 1}) {
    List<Rectangle> input = [r];
    List<Rectangle> result = [];
    Rectangle r1;
    Rectangle r2;
    bool isSplittable(int dim) => dim >= ((minDim + 2) * 2);

    while (input.isNotEmpty) {
      r1 = input.removeLast();
      if (prng.nextBool() == true) {
        if (isSplittable(r1.width)) {
          r2 = Rectangle.splitH(r1, r1.width ~/ 2, halfGap: halfGap);
          input.addAll([r1, r2]);
        } else {
          result.add(r1);
        }
      } else {
        if (isSplittable(r1.height)) {
          r2 = Rectangle.splitV(r1, r1.height ~/ 2, halfGap: halfGap);
          input.addAll([r1, r2]);
        } else {
          result.add(r1);
        }
      }
    }

    return result;
  }

  static void allocate(List<List<Cell>> map, int cols, int rows) {
    _fill(map, cols, rows);
  }

  static void dispose(List<List<Cell>> map, List<Room> rooms, List<Creature> players) {
    _reset(map, rooms);
    map.clear();
  }

  static List<Rectangle> makeSpaces(int cols, int rows, math.Random prng, {density = 0.50}) {
    List<Rectangle> spaces;
    // super dense:
    //   _splitHorV(.. minDim: 3, halfGap: 1)
    //   _splitFurther(.. maxRatio: 2.5, minDim: 4, halfGap: 2)
    //   _bombByTotal(.. retention: 1.0)
    // light and open:
    //   _splitHorV(.. minDim: 6, halfGap: 2)
    //   _splitFurther(.. maxRatio: 2.0, minDim: 5, halfGap: 4)
    //   _bombByTotal(.. retention: 0.45)
    int ilerp(int a, int b, num t) => a + ((b - a) * t).round();
    num nlerp(num a, num b, num t) => a + (b - a) * t;
    spaces = _splitHorV(Rectangle.byDimension(cols, rows), prng,
        minDim: ilerp(6, 3, density), halfGap: ilerp(2, 1, density));
    spaces = _splitFurther(spaces,
        maxRatio: nlerp(2.0, 2.5, density),
        minDim: ilerp(5, 3, density),
        halfGap: ilerp(4, 2, density));
    spaces = _bombByTotal(spaces, prng, retention: nlerp(0.45, 1.0, density));
    Log.debug(_logLabel, 'makeSpaces() created ${spaces.length} incredible spaces');
    return spaces;
  }

  static void generate(List<List<Cell>> map, List<Room> rooms, List<Creature> players,
      math.Random prng, int level, int maxLevel) {
    _reset(map, rooms);

    Room room;
    List<Rectangle> spaces =
        makeSpaces(map.first.length, map.length, prng, density: level / maxLevel);
    for (Rectangle s in spaces) {
      room = Room(s);
      rooms.add(room);
      _connectors.add(room);
      _paintRoom(map, s);
    }

    List<Cardinal> directions = [Cardinal.north, Cardinal.east, Cardinal.south, Cardinal.west];
    List<int> toConnect = List<int>.generate(rooms.length, (int i) => i, growable: false);
    toConnect.shuffle(prng);
    for (int i in toConnect) {
      room = rooms[i];
      directions.shuffle(prng);
      for (Cardinal d in directions) {
        _attemptPassage(map, room, d, _connectors);
      }
    }
    // unpaint and remove rooms without any connections
    bool purging = true;
    while (purging) {
      int i = rooms.indexWhere((r) => r.numConnections == 0);
      if (i >= 0) {
        room = rooms.removeAt(i);
        Log.debug(_logLabel, '.. room at ${room.coords} has zero connections');
        _unpaintRoom(map, room.coords);
        _connectors.remove(room);
      } else {
        purging = false;
      }
    }
    Log.info(_logLabel, 'generate() created ${rooms.length} rooms from ${spaces.length} spaces');
    Log.debug(_logLabel, 'generate() established ${_connectors.length} connectors');

    String ctype(Connector c) {
      if (c is Room) {
        return 'Room';
      }
      if (c is Passage) {
        return 'Passage';
      }
      return c.runtimeType.toString();
    }

    for (Connector c in _connectors) {
      Log.debug(_logLabel, '.. ${ctype(c)} ${c.toScreenString()}');
    }

    Location loc = Location(-1, -1);
    for (Creature player in players) {
      room = rooms[prng.nextInt(rooms.length)];
      //FIXME: prevent same room selection
      //TODO: add exit far away
      //TODO: use connection graph to select rooms farthest from each other to spawn players and exit
      //TODO: items!
      //TODO: creatures!
      room.spawnPoint(loc, player.type);
      LevelManager.spawn(map, player, loc.col, loc.row);
    }
  }
}
