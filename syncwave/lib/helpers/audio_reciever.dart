import 'dart:io';
import 'dart:typed_data';

class AudioReceiver {
  final int port;

  AudioReceiver({this.port = 4445});

  /// Listen for incoming audio chunks
  Future<void> listenForAudioChunks() async {
    var _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    print("Listening on port $port");

    final List<Uint8List> receivedChunks = [];
    _socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = _socket.receive();
        if (datagram != null) {
          receivedChunks.add(Uint8List.fromList(datagram.data));
          print("Received chunk: ${receivedChunks.length}");
        }
      }
    });

    await saveReceivedChunks(receivedChunks);

  }

  /// Save received audio chunks to a file
  Future<void> saveReceivedChunks(List<Uint8List> chunks) async {
    final file = File('received_audio.wav');
    final sink = file.openWrite();

    for (final chunk in chunks) {
      sink.add(chunk);
    }

    await sink.close();
    print("Audio file saved as received_audio.wav");
  }
}
