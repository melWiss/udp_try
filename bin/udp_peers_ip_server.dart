import 'dart:convert';
import 'dart:io';
import 'package:udp/udp.dart';

void main(List<String> args) async {
  var p1 = args.isNotEmpty ? Port(int.parse(args[0])) : Port(55001);
  var endp1 = Endpoint.unicast(InternetAddress("0.0.0.0"), port: p1);
  var socket = await UDP.bind(endp1);
  print(
      "Starting RECON-SERVER://${endp1.address!.address}:${endp1.port!.value}");

  Map<String, int> ips = {};

  socket.asStream().listen(
    (event) async {
      print("REQUEST ${event!.address.address}:${event.port} ");
      if (ips.containsKey(event.address.address)) {
        if (ips[event.address.address] != event.port) {
          ips[event.address.address] = event.port;
          //notify all peers
          notifyAllPeers(ips, socket);
          print(ips);
        }
      } else {
        ips.addAll({event.address.address: event.port});
        //notify all peers
        notifyAllPeers(ips, socket);
        print(ips);
      }
      // notifyAllPeers(ips, socket);
    },
    onDone: () => print("done"),
    onError: (e) => print("error"),
  );
}

notifyAllPeers(Map<String, int> ips, UDP socket) {
  var data = {
    "type": "CONNECTIONS",
    "data": ips,
  };
  var response = jsonEncode(data).codeUnits;
  ips.forEach((key, value) async {
    socket.send(
      response,
      Endpoint.unicast(
        InternetAddress(key),
        port: Port(value),
      ),
    );
  });
}
