// import 'dart:js_interop';
import 'package:logging/logging.dart';
// import 'package:flutter/material.dart';
// import 'package:network_info_plus/network_info_plus.dart';
import 'package:wifi_iot/wifi_iot.dart';

Future<void> createHotspot() async {
  final log = Logger('HotspotHelper');
  log.info("Creating Hotspot...");
  bool hotspotEnabled = await WiFiForIoTPlugin.isWiFiAPEnabled();
  if (!hotspotEnabled) {
    await WiFiForIoTPlugin.setWiFiAPEnabled(true);
    await WiFiForIoTPlugin.setWiFiAPSSID("MasterDevice");
    await WiFiForIoTPlugin.setWiFiAPPreSharedKey("12345678");
  }
  var ssid = await WiFiForIoTPlugin.getSSID();
  var password = await WiFiForIoTPlugin.getWiFiAPPreSharedKey();
  log.info("Hotspot Created: SSID: $ssid, Password: $password");
}
