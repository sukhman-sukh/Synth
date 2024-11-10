import 'package:flutter/material.dart';
import 'package:device_scan_animation/device_scan_animation.dart';
// import 'package:flutter_wifi_connect/flutter_wifi_connect.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:wifi_iot/wifi_iot.dart';
import '../helpers/audio_reciever.dart';

class ClientPage extends StatefulWidget {
  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  late Logger log;
  IO.Socket? socket;
  String message = "Searching for Master...";

  @override
  void initState() {
    super.initState();
    log = Logger('ClientPage');
    // _connectToMaster();
    _discoverMasterIp();
  }

  Future<void> _connectToMaster() async {
    print("Connecting to Master...");
    bool enabled = await WiFiForIoTPlugin.isEnabled();
    if (!enabled) {
      await WiFiForIoTPlugin.setEnabled(true);
    }
    bool connected = await WiFiForIoTPlugin.findAndConnect("MasterDevice",
        withInternet: false, password: "12345678");

    print(connected);

    if (connected) {
      _discoverMasterIp();
    } else {
      setState(() {
        message = "Failed to connect to Master!";
      });
    }
  }

// Future<void> _discoverMasterIp() async {
//   RawDatagramSocket.bind(InternetAddress.anyIPv4, 4445).then((udpSocket) {
//     udpSocket.listen((RawSocketEvent event) {
//       if (event == RawSocketEvent.read) {
//         Datagram? datagram = udpSocket.receive();
//         if (datagram != null) {
//           String masterIp = String.fromCharCodes(datagram.data);
//           setState(() {
//             message = "Master IP discovered: $masterIp";
//           });
//           _initializeSocket(masterIp);
//         }
//       }
//     });
//   });
// }

  Future<void> _discoverMasterIp() async {
    RawDatagramSocket _socket;
    int count = 0;
    // Future<void> _startListening() async {
    try {
      // Bind to the socket on the specified port
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4444);
      // _socket.broadcastEnabled = true;
      print("Started listening for UDP messages on port 4444");
      // Listen for incoming datagrams
      _socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket.receive();
          // print(datagram);
          if (datagram != null) {
            // Convert the message from bytes to a string
            final masterIp = String.fromCharCodes(datagram.data);
            if (count == 0) {
              _initializeSocket(masterIp);
              count++;
            }
            setState(() {
              message = "Master IP discovered: $masterIp";
            });
          }
        }
      });
    } catch (e) {
      setState(() {
        message = 'Error: $e';
      });
    }
    // }
  }

  void _initializeSocket(String masterIp) {
    final receiver = AudioReceiver(port: 4445);
    receiver.listenForAudioChunks();

    print("master ip : $masterIp");
    socket = IO.io('http://$masterIp:3000',
        IO.OptionBuilder().setTransports(['websocket']).build());
    socket?.connect();
    socket?.onConnect((_) {
      setState(() {
        message = "Connected to Master!";
      });
      socket?.emit('clientMessage', "Hello from Client!");
    });

    socket?.on('masterMessage', (data) {
      setState(() {
        message = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Client Device")),
      body: Column(children: [
        DeviceScanWidget(),
        Center(child: Text(message)),
      ]),
    );
  }
}
