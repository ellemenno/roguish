class Connector {
  static final Connector noConnector = Connector._empty();

  static void mergeConnections(Connector peer1, Connector peer2) {
    peer1.shareConnectionsWith(peer2);
    peer2.shareConnectionsWith(peer1);
  }

  static void twoWayConnection(Connector peer1, Connector peer2) {
    peer1.connectTo(peer2);
    peer2.connectTo(peer1);
  }

  final Set<Connector> _connections = {};

  int get numConnections => _connections.length;
  bool isConnectedTo(Connector node) => _connections.contains(node);
  void connectTo(Connector node) => _connections.add(node);
  void shareConnectionsWith(Connector peer) {
    for (Connector node in _connections) {
      peer.connectTo(node);
    }
  }

  void disconnectFrom(Connector node) => _connections.remove(node);
  void removeAllConnections() => _connections.clear();

  String toConnectionString() => '[${_connections.join(', ')}]';

  // for extenders to override
  bool contains(int c, int r) => false;
  String toScreenString() => '';

  Connector();
  Connector._empty();
}
