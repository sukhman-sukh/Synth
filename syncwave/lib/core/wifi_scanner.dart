import 'package:flutter/material.dart';
import 'package:wifi_flutter/wifi_flutter.dart';

  Future<Iterable<WifiNetwork>> scanWifiNetworks() async {
  Iterable<WifiNetwork> networks = [];
  await WifiFlutter.promptPermissions();
  try {
    networks = await WifiFlutter.wifiNetworks;
  } catch (e) {
    print('Error retrieving Wi-Fi networks: $e');
  }

  return networks;
}
