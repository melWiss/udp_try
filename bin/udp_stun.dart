import 'dart:io';
import 'package:udp/udp.dart';

void main(List<String> args) async {
  var p1 = int.parse(args[0]);
  var p2 = int.parse(args[1]);
  var ip2 = args[2];
  print("Starting Awesome Chatapp...");
  var endp1 = Endpoint.unicast(InternetAddress("0.0.0.0"), port: Port(p1));
  var endp2 = Endpoint.unicast(InternetAddress(ip2), port: Port(p2));
  var socket = await UDP.bind(endp1);

  stdout.write("PEER1: ");
  socket.asStream().listen((event) {
    print("PEER2: " + String.fromCharCodes(event!.data));
    stdout.write("PEER1: ");
  });

  stdin.listen((event) {
    socket.send(event, endp2);
    stdout.write("PEER1: ");
  });
}
