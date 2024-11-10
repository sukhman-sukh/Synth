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
    _socket.listen((RawSocketEvent event) async {
      if (event == RawSocketEvent.read) {
        final datagram = _socket.receive();
        if (Uint8List.fromList(datagram!.data)
                .sublist(Uint8List.fromList(datagram.data).length - 2) ==
            "##".codeUnits) {
          print("Audio file received");
          await saveReceivedChunks(receivedChunks);
          _socket.close();
        }
        if (datagram != null) {
          receivedChunks.add(Uint8List.fromList(datagram.data));
          Uint8List lastThreeChunks = receivedChunks[receivedChunks.length-1].sublist(receivedChunks.length - 3);
          print(event);
          List<int> lastChunk = [35,35];
          if(receivedChunks.sublist(receivedChunks.length - 3) == [35, 35]) {
            print("Audio file received2");
            await saveReceivedChunks(receivedChunks);
            _socket.close();
          }
          print("Received chunk: ${receivedChunks.length}");
        }
      }
    });
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
}
