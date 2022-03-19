class Connector {
  static final Connector noConnector = Connector._empty();

  static mergeConnections(Connector peer1, Connector peer2) {
    peer1.shareConnectionsWith(peer2);
    peer2.shareConnectionsWith(peer1);
  }

  static twoWayConnection(Connector peer1, Connector peer2) {
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
  bool contains(int c, int r) => false; // for extenders to override

  Connector();
  Connector._empty();
}
