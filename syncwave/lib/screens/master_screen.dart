import 'package:flutter/material.dart';
// import 'package:wifi_iot/wifi_iot.dart';
// import '../core/hotspot_helper.dart';
// import 'dart:developer';
// import 'package:network_info_plus/network_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';
import 'dart:async';
// import 'package:logging/logging.dart';
import 'audio_file_picker.dart';
// import 'package:get_ip_address/get_ip_address.dart';

class MasterPage extends StatefulWidget {
  @override
  _MasterPageState createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  IO.Socket? socket;
  // late Logger _log;
  String message = "Waiting for       client connections...";
  late RawDatagramSocket udpSocket;
  String? ip;
  @override
  void initState() {
    // _log = Logger('MasterPage');
    // log("starting nowwwww1");
    print("starting nowwwww2");
    super.initState();
    // _createHotspot();
    // createHotspot();
    // _log.warning("starting nowwwww3");
    _startBroadcastingIp();
    _initializeSocket();
  }

  // Future<void> _createHotspot() async {
  //   bool hotspotEnabled = await WiFiForIoTPlugin.isWiFiAPEnabled();
  //   if (!hotspotEnabled) {
  //     await WiFiForIoTPlugin.setWiFiAPEnabled(true);
  //     await WiFiForIoTPlugin.setWiFiAPSSID("MasterDevice");
  //     await WiFiForIoTPlugin.setWiFiAPPassword("12345678");
  //   }
  //   print("Hotspot Created: SSID: MasterDevice");
  // }

  String? selectedFilePath;

  void _showFilePicker() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick an Audio File'),
        content: AudioFilePicker(
          onFileSelected: (filePath) {
            Navigator.of(context).pop(); // Close the dialog
            setState(() {
              selectedFilePath = filePath;
              message = filePath!;
            });
          },
        ),
      ),
    );
  }

  Future<String?> _getPrivateIPv4() async {
    // try {

    // var ipAddress = IpAddress(type: RequestType.json);

    // dynamic data = await ipAddress.getIpAddress();
    // var ipv4 = data.toString();
    // print(ipv4);

    // } on IpAddressException catch (exception) {
    //   print(exception.message);
    // }
    var ipv4 = "as";
    var list = await NetworkInterface.list(
        includeLoopback: true, type: InternetAddressType.IPv4);
    print(list);
    for (var i = 0; i < list.length; i++) {
      if (list[i].name == "wlan2") {
        print(list[i].name);

        ipv4 = (list[i].addresses[0].address);
        print(ipv4);
        // return list[i].addresses[0].address;
      }
    }

    // final info = NetworkInfo();
    // String? ipv4 = "nullIp";
    // ipv4 = await info.getWifiIP();
    // ipv4 ??= 'Unable to fetch IP';
    return ipv4;
  }

  Future<void> _startBroadcastingIp() async {
    print("Broadcasting IP...");
    ip = await _getPrivateIPv4();
    print("IP: $ip");
    List<String> segments = ip!.split('.');
    segments[3] = '255';
    String brodcastIp = segments.join('.');

    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

    udpSocket.broadcastEnabled = true;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      print("Broadcasting IP: ${ip!.codeUnits}");
      var resp =
          udpSocket.send(ip!.codeUnits, InternetAddress(brodcastIp), 4444);
      print(resp);
    });
  }

  void _initializeSocket() {
    socket = IO.io('http://$ip:3000',
        IO.OptionBuilder().setTransports(['websocket']).build());
    print("Socket Initialized");

    socket?.onConnect((_) {
      setState(() {
        message = "Client Connected!";
      });
      socket?.emit('masterMessage', "Hello from Master!");
    });

    socket?.on('clientMessage', (data) {
      setState(() {
        message = data;
      });
    });
  }

  @override
  void dispose() {
    udpSocket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Master Device")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
            ElevatedButton(
              onPressed: _showFilePicker,
              child: const Text('Open Audio Picker'),
            ),
            const SizedBox(height: 20),
            if (selectedFilePath != null)
              Text(
                'Selected File: $selectedFilePath',
                textAlign: TextAlign.center,
              )
            else
              const Text('No file selected'),
          ],
        ),
      ),
    );
    // );
  }
}
