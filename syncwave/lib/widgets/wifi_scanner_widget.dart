part of 'widgets.dart';

// import 'package:flutter/widgets.dart';

// import 'widgets.dart';
// class WifiNetworkListScreen extends StatefulWidget {
//   @override
//   _WifiNetworkListScreenState createState() => _WifiNetworkListScreenState();
// // }

// class _WifiNetworkListScreenState extends StatefulWidget {
//     List<WifiNetwork> _networks = [];

//   @override
//   void initState() {
//     super.initState();
//     _scanWifiNetworks();
//   }

//   Future<void> _scanWifiNetworks() async {
//     List<WifiNetwork> networks = await scanWifiNetworks();
//     setState(() {
//       _networks = networks;
//     });
//   }

//   @override
  // Widget build(BuildContext context) {
  //     return Scaffold(
  //       body: Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             // Lottie scanning animation
  //             Lottie.asset('assets/scanning_animation.json'),
  //             // Text or indicator to show that scanning is in progress
  //             Text("Scanning for devices..."),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

// }

class WifiNetworkListScreen extends StatefulWidget {
  @override
  _WifiNetworkListScreenState createState() => _WifiNetworkListScreenState();
}

class _WifiNetworkListScreenState extends State<WifiNetworkListScreen> {
  Iterable<WifiNetwork> _networks = [];
  Duration duration = const Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    Timer.periodic(duration, (Timer timer) {
      _scanWifiNetworks();
    });    
  }

  Future<void> _scanWifiNetworks() async {
    Iterable<WifiNetwork> networks = await scanWifiNetworks();
    setState(() {
      _networks = networks;
    });
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:   [
            Lottie.asset('assets/scanning_animation.json'),
            Text("Scanning for devices..."),
          ],
        ),
      ),
    );
  }
}
