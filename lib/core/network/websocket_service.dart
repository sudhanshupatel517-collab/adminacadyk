class WebSocketService {
  static void connect() {}
  static void disconnect() {}
  static void subscribe(String destination, Function(dynamic) callback) {}
  static void send(dynamic destinationOrData, {Map<String, dynamic>? body}) {}
}
