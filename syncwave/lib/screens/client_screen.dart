import 'package:flutter/material.dart';
import 'package:device_scan_animation/device_scan_animation.dart';
// import 'package:flutter_wifi_connect/flutter_wifi_connect.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:audioplayers/audioplayers.dart';
import '../helpers/audio_reciever.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:path_provider/path_provider.dart';

class ClientPage extends StatefulWidget {
  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  late Logger log;
  IO.Socket? socket;
  String message = "Searching for Master...";

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Timer? _loadingTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    log = Logger('ClientPage');
    // _connectToMaster();
    _discoverMasterIp();

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
        _getDuration();
      });
    });

    // Listen to audio position changes
    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _position = position;
      });
    });
  }

  Future<void> _connectToMaster() async {
    // print("Connecting to Master...");
    // bool enabled = await WiFiForIoTPlugin.isEnabled();
    // if (!enabled) {
    //   await WiFiForIoTPlugin.setEnabled(true);
    // }
    // bool connected = await WiFiForIoTPlugin.findAndConnect("MasterDevice",
    //     withInternet: false, password: "12345678");

    // print(connected);

    // if (connected) {
    //   _discoverMasterIp();
    // } else {
    //   setState(() {
    //     message = "Failed to connect to Master!";
    //   });
    // }
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

  String? masterIP;
  Future<void> _discoverMasterIp() async {
    _discoverstartTime();
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
            // if (count == 0) {
            //   // _initializeSocket(masterIp);
            //   count++;
            // }
            setState(() {
              message = "Master IP discovered: $masterIp";
              masterIP = masterIp;
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

  Future<void> _discoverstartTime() async {
    RawDatagramSocket _socket;
    // int count = 0;
    // Future<void> _startListening() async {
    try {
      // Bind to the socket on the specified port
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4446);
      // _socket.broadcastEnabled = true;
      print("Started listening for UDP messages on port 4446");
      // Listen for incoming datagrams
      _socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket.receive();
          // print(datagram);
          if (datagram != null) {
            // Convert the message from bytes to a string
            _openAudioPlayerDialog();
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

  /// Save received audio chunks to a file
  Future<void> saveReceivedChunks(List<Uint8List> chunks) async {
    print("Saving audio file...");
    final file = File('received_audio.wav');
    final sink = file.openWrite();

    for (final chunk in chunks) {
      sink.add(chunk);
    }

    await sink.close();
    print("Audio file saved as received_audio.wav");
  }

  final List<Uint8List> receivedChunks = [];

  void _initializeSocket(String masterIp) {
    Socket.connect(masterIp, 3000).then((Socket socket) {
      print(
          'Connected to ${socket.remoteAddress.address}:${socket.remotePort}');
      socket.listen(
        (data) async {
          print('Received from server:');
          receivedChunks.add(Uint8List.fromList(data));
          Uint8List lastThreeChunks = receivedChunks[receivedChunks.length - 1]
              .sublist(receivedChunks.length - 3);
          print(lastThreeChunks);
          List<int> lastChunk = [35, 35];
          if (lastThreeChunks == lastChunk) {
            print("Audio file received2");
            await saveReceivedChunks(receivedChunks);
            // _socket.close();
          }
        },
        onError: (error) {
          print('Error: $error');
        },
        onDone: () {
          print('Server has closed the connection');
        },
      );
      socket.write('Hello, Server!');
      socket.writeln('clientMessage Hello from Client!');
    });

    // final receiver = AudioReceiver(port: 4445);
    // receiver.listenForAudioChunks();

    // print("master ip : $masterIp");
    // socket = IO.io('http://$masterIp:3000',
    //     IO.OptionBuilder().setTransports(['websocket']).build());
    // socket?.connect();
    // socket?.onConnect((_) {
    //   setState(() {
    //     message = "Connected to Master!";
    //   });
    //   socket?.emit('clientMessage', "Hello from Client!");
    // });

    // socket?.on('masterMessage', (data) {
    //   setState(() {
    //     message = data;
    //   });
    // });
  }

  WebSocketChannel? _channel;
  String _status = 'Disconnected';

  void _connectToServer() {
    // final address = _controller.text.trim();
    _channel = IOWebSocketChannel.connect('ws://$masterIP:3000/ws');
    _status = 'Connected';
    _channel!.stream.listen((data) async {
      await _saveFile(Uint8List.fromList(data));
      setState(() {
        _status = 'File received';
      });
    }, onError: (error) {
      setState(() {
        _status = 'Error: $error';
      });
    });
  }

  Future<void> _getDuration() async {
    final duration = await _audioPlayer.getDuration();
    setState(() {
      _duration = duration!;
    });
    // _duration = duration!;
  }

  // final String _audioPath =
  //     'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
  final String _audioPath = 'assets/sample.mp3';
  Source get _source => DeviceFileSource(_audioPath);
  @override
  void dispose() {
    _audioPlayer.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  // Open the dialog box
  void _openAudioPlayerDialog() async {
    print("Button Pressed");
    setState(() {
      _isLoading = true;
      print("_isLoading: set to $_isLoading");
    });

    // await Future.delayed(const Duration(seconds: 10));
    // Show a loading animation for 10 seconds
    _loadingTimer = Timer(const Duration(seconds: 3), () async {
      setState(() {
        _isLoading = false;
        Navigator.of(context).pop();
        print("_isLoading: set to $_isLoading");

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: SizedBox(
                height: 200,
                child:
                    _isLoading ? _buildLoadingView() : _buildAudioPlayerView(),
              ),
            );
          },
        ).then((_) {
          _loadingTimer?.cancel();
          _audioPlayer.stop();
        });
      });
      await _audioPlayer.setSource(_source);
      _getDuration();
      _audioPlayer.play(_source);
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
            // await _audioPlayer.seek(position);
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
              setState(() {
                _isPlaying = false;
              });
              
            } else {
              setState(() {
                _isPlaying = true;
              });
              // _isPlaying = true;
              await _audioPlayer.play(_source);
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

  Future<void> _saveFile(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/received_file');
    await file.writeAsBytes(bytes);
    print('File saved at ${file.path}');
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Client Device")),
      body: Column(children: [
        DeviceScanWidget(),
        Center(child: Text(message)),
        ElevatedButton(
          onPressed: _openAudioPlayerDialog,
          child: const Text('Connect And Play Audio'),
        ),
      ]),
    );
  }
}
