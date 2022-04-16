import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:udp/udp.dart';

void main(List<String> args) async {
  Map<String, int> peers = {};
  var p1 = Port(55002);
  print("Starting Awesome Chatapp...");
  var endp1 = Endpoint.unicast(InternetAddress("0.0.0.0"), port: p1);
  var socket = await UDP.bind(endp1);

  // listen for connections
  socket.asStream().listen((event) {
    String response = String.fromCharCodes(event!.data);
    try {
      Map<String, dynamic> responseData = jsonDecode(response);
      if (responseData["type"] == "CONNECTIONS") {
        peers = responseData["data"];
        connectAllPeers(peers, socket);
      } else if (responseData["type"] == "DATA") {
        print("${event.address.address}:${event.port}/ $responseData");
      }
      // ignore: empty_catches
    } catch (e) {}
  });

  // connect to RECONN SERVER
  for (int i = 0; i < 5; i++) {
    socket.send(
      [0],
      Endpoint.unicast(
        InternetAddress(args.isNotEmpty ? args[0] : "102.158.140.104"),
        port: Port(args.length > 1 ? int.parse(args[1]) : 55001),
      ),
    );
  }
  Timer.periodic(Duration(seconds: 10), (t) {
    socket.send(
      [0],
      Endpoint.unicast(
        InternetAddress(args.isNotEmpty ? args[0] : "102.158.140.104"),
        port: Port(args.length > 1 ? int.parse(args[1]) : 55001),
      ),
    );
  });

  stdin.listen((event) {
    var data = {
      "type": "DATA",
      "data": String.fromCharCodes(event),
    };
    sendToAllPeers(peers, socket, jsonEncode(data).codeUnits);
  });
}

connectAllPeers(Map<String, int> peers, UDP socket) {
  peers.forEach((ip, port) {
    socket.send(
      [0],
      Endpoint.unicast(
        InternetAddress(ip),
        port: Port(port),
      ),
    );
  });
}

sendToAllPeers(Map<String, int> peers, UDP socket, List<int> data) {
  peers.forEach((ip, port) {
    socket.send(
      data,
      Endpoint.unicast(
        InternetAddress(ip),
        port: Port(port),
      ),
    );
  });
}
