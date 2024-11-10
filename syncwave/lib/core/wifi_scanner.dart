// import 'dart:io';

// /// Scans for devices connected to the hotspot network.
// Future<List<Map<String, String>>> getConnectedDevices(String subnet) async {
//   List<Map<String, String>> devices = [];

//   for (int i = 2; i < 255; i++) {
//     String ip = "$subnet.$i";
//     try {
//       final result = await InternetAddress.lookup(ip);
//       if (result.isNotEmpty) {
//         devices.add({"ip": ip, "ssid": "Device $i"});
//         print('Device found: IP - $ip');
//       }
//     } catch (e) {
//       continue;
//     }
//   }
//   return devices;
// }


// Future<void> scanDevices(BuildContext context) async {
//   final info = NetworkInfo();

//   // Get the IP address of the hotspot
//   String? ipAddress = await info.getWifiIP();
//   if (ipAddress == null) {
//     print("Unable to detect hotspot. Please ensure it is enabled.");
//     return;
//   }

//   // Assume default Android hotspot subnet (change if needed)
//   String subnet = ipAddress.substring(0, ipAddress.lastIndexOf('.'));

//   // Fetch connected devices
//   List<Map<String, String>> connectedDevices =
//       await getConnectedDevices(subnet);

//   // Display hotspot and device info
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Connected Devices'),
//         content: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text("Hotspot IP: $ipAddress"),
//             const SizedBox(height: 10),
//             Text("Devices:"),
//             ...connectedDevices.map((device) {
//               return Text("IP: ${device['ip']}, SSID: ${device['ssid']}");
//             }).toList(),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       );
//     },
//   );
// }
