import 'dart:io';
import 'dart:typed_data';
// import 'package:udp/udp.dart';

class AudioBroadcaster {
  final String filePath;
  final String broadcastAddress;
  final int port;
  final int chunkSize;

  AudioBroadcaster({
    required this.filePath,
    this.broadcastAddress = '255.255.255.255',
    this.port = 4445,
    this.chunkSize = 1024,
  });

  /// Read and send audio file chunks via UDP
  Future<void> broadcastAudioFile() async {
    final file = File(filePath);

    // Check if the file exists
    if (!await file.exists()) {
      print("File not found!");
      return;
    }

    // Create a UDP sender for broadcasting
    // final sender = await UDP.bind(Endpoint.any(port: Port(port)));
    var udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

    udpSocket.broadcastEnabled = true;
    // Timer.periodic(const Duration(seconds: 1), (timer) {
    //   print("Broadcasting IP: ${ip!.codeUnits}");
      
    // });
  
    // Read the file as bytes
    final fileBytes = await file.readAsBytes();
    final totalChunks = (fileBytes.length / chunkSize).ceil();
    print("Total Chunks: $totalChunks");

    for (int i = 0; i < totalChunks; i++) {
      int start = i * chunkSize;
      int end = start + chunkSize;
      end = end > fileBytes.length ? fileBytes.length : end;
      Uint8List chunk = Uint8List.fromList(fileBytes.sublist(start, end));
      var resp =
          udpSocket.send(chunk, InternetAddress(broadcastAddress), 4445);
      print(resp);
      print("Sent chunk $resp ==  ${i + 1} / $totalChunks");

      // Add a small delay to prevent congestion
      await Future.delayed(Duration(milliseconds: 10));
    }

    print("Broadcast completed.");
    // sender.close();
  }
}
