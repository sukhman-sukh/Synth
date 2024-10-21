import 'package:flutter/material.dart';
import 'package:syncwave/helpers/navigation_helper.dart';
import '../widgets/widgets.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

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
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Sync Now'),
      ),
    );
  }
}
