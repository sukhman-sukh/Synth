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
              Navigator.pushNamed(context, NavigationHelper.home);
            },
          ),
        ],
      ),
      // body: Padding(
      // padding: const EdgeInsets.all(16.0),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 0.5 Above Middle Row
          const Spacer(flex: 1),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sync Button Pressed'),
                  action: SnackBarAction(
                    label: 'Go Back',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
            child: const Text('Sync Now'),
          ),

          // Middle Row Spacer
          // const Spacer(flex: 1),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, NavigationHelper.masterScreen);
                  },
                  child: const Text('Master Screen'),
                ),
                const SizedBox(width: 15), // Padding between buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, NavigationHelper.clientScreen);
                  },
                  child: const Text('Slave Screen'),
                ),
              ],
            ),
          ),

          // Final Spacer to balance layout
          const Spacer(flex: 2),
        ],
      ),
      // ),
    );
  }
}
