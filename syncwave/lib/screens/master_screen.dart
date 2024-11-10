import 'package:flutter/material.dart';
// import 'package:wifi_iot/wifi_iot.dart';
// import '../core/hotspot_helper.dart';
// import 'dart:developer';
// import 'package:network_info_plus/network_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:logging/logging.dart';
import 'audio_file_picker.dart';
// import '../helpers/audio_sender.dart';
import '../helpers/server.dart';
// import 'package:get_ip_address/get_ip_address.dart';

class MasterPage extends StatefulWidget {
  @override
  _MasterPageState createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  IO.Socket? socket;
  // late Logger _log;
  late ServerSocket serverSocket;
  String message = "Waiting for       client connections...";
  late RawDatagramSocket udpSocket;
  String? ip;
  late String brodcastIp;

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

    // Listen to audio player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    // Listen to audio duration changes
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
      });
    });

    // Listen to audio position changes
    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _position = position;
      });
    });

    // _initializeSocket();
  }

  HttpServer? _server;
  final List<WebSocketChannel> _clients = [];

  Future<void> _startServer() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 4040);
    print(
        'Server started on ws://${_server!.address.address}:${_server!.port}');
    _server!.listen((HttpRequest request) {
      if (request.uri.path == '/ws') {
        WebSocketTransformer.upgrade(request).then((webSocket) {
          final channel = IOWebSocketChannel(webSocket);
          _clients.add(channel);
          channel.stream.listen((_) {}, onDone: () {
            _clients.remove(channel);
          });
        });
      }
    });
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Timer? _loadingTimer;
  bool _isLoading = false;

  // final String _audioPath =
  //     'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
  final String _audioPath = 'assets/sample.mp3';

  // @override
  // void initState() {
  //   super.initState();

  // }

  @override
  void dispose() {
    _audioPlayer.dispose();

    udpSocket.close();
    super.dispose();
  }

  // Open the dialog box
  void _openAudioPlayerDialog() async {
    setState(() {
      _isLoading = true;
    });

    // Show a loading animation for 10 seconds
    _loadingTimer = Timer(const Duration(seconds: 10), () async {
      print(" Timer COmplete");
      setState(() {
        _isLoading = false;
      });
      await _audioPlayer.setSourceUrl(_audioPath);
      _audioPlayer.play(_audioPath as Source);
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 200,
            child: _isLoading ? _buildLoadingView() : _buildAudioPlayerView(),
          ),
        );
      },
    ).then((_) {
      _loadingTimer?.cancel();
      _audioPlayer.stop();
    });
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildAudioPlayerView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isPlaying ? "Playing Audio" : "Paused",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Slider(
          min: 0,
          max: _duration.inSeconds.toDouble(),
          value: _position.inSeconds.toDouble(),
          onChanged: (value) async {
            final position = Duration(seconds: value.toInt());
            await _audioPlayer.seek(position);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_position)),
              Text(_formatDuration(_duration)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            size: 50,
            color: Colors.blue,
          ),
          onPressed: () async {
            if (_isPlaying) {
              await _audioPlayer.pause();
              _isPlaying = false;
            } else {
              _isPlaying = true;
              await _audioPlayer.play(_audioPath as Source);
            }
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
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

  Future<void> _showFilePicker() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick an Audio File'),
        content: AudioFilePicker(
          onFileSelected: (filePath) async {
            Navigator.of(context).pop();

            udpSocket =
                await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

            udpSocket.broadcastEnabled = true;
            // Timer.periodic(const Duration(seconds: 1), (timer) {
            // print("Broadcasting IP: ${ip!.codeUnits}");
            var resp = udpSocket.send(
                ip!.codeUnits, InternetAddress(brodcastIp), 4446);
            print("Play : $resp");
            _openAudioPlayerDialog();
            // });
            // var broadcaster = AudioBroadcaster(
            //     filePath: filePath!,
            //     broadcastAddress: brodcastIp,
            //     port: 4445,
            //     serverSocket);
            // broadcaster.broadcastAudioFile();
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
    // print("Broadcasting IP...");
    ip = await _getPrivateIPv4();
    // serverSocket = await createServer();
    print("IP: $ip");
    List<String> segments = ip!.split('.');
    segments[3] = '255';
    brodcastIp = segments.join('.');

    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

    udpSocket.broadcastEnabled = true;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      // print("Broadcasting IP: ${ip!.codeUnits}");
      var resp =
          udpSocket.send(ip!.codeUnits, InternetAddress(brodcastIp), 4444);
      // print(resp);
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

  // @override
  // void dispose() {
  //   udpSocket.close();
  //   super.dispose();
  // }

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
