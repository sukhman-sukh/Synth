import 'package:flutter/material.dart';
import 'package:syncwave/helpers/navigation_helper.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SyncWave'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, NavigationHelper.accountScreen);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // WifiScanner widget goes here
            Expanded(
              child: WifiNetworkListScreen(),
            ),
            // Button below WifiScanner widget
            ElevatedButton(
              onPressed: () {
                // Action to perform when the button is pressed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync Button Pressed')),
                );
              },
              child: const Text('Sync Now'),
            ),
          ],
        ),
      ),
    );
  }
}
