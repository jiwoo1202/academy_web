import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_ip_address/get_ip_address.dart';

import '../provider/user_state.dart';

Future<void> loginLogCheck(String id, String nickName) async {
  final us = Get.put(UserState());
  try {
    await getPublicIP();
    FirebaseFirestore.instance.collection('log').add({
      'ID': id,
      'ip': us.usipAddress.value,
      'ipType': '',
      'interface': '',
      'time': '${DateTime.now()}',
      'deviceId': '',
      'nickName': nickName,
      'temp1': '',
      'temp2': '',
      'temp3': '',
      'isApp': 'false'
    });

  } catch (e) {
    print(e);
  }
}

Future<String?> getLocalIpAddress() async {
  final us = Get.put(UserState());
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
  );
  try {
    NetworkInterface vpnInterface =
        interfaces.firstWhere((element) => element.name == "tun0");

    us.usinterface.value = vpnInterface.name;
    us.usipAddress.value = vpnInterface.addresses.first.address;
    us.usipType.value = vpnInterface.addresses.first.type.name;

    return vpnInterface.addresses.first.address;
  } on StateError {
    // Try wlan connection next
    try {
      NetworkInterface interface =
          interfaces.firstWhere((element) => element.name == "wlan0");

      us.usinterface.value = interface.name;
      us.usipAddress.value = interface.addresses.first.address;
      us.usipType.value = interface.addresses.first.type.name;

      return interface.addresses.first.address;
    } catch (ex) {
      // Try any other connection next
      try {
        NetworkInterface interface = interfaces.firstWhere(
            (element) => !(element.name == "tun0" || element.name == "wlan0"));

        us.usinterface.value = interface.name;
        us.usipType.value = interface.addresses.first.type.name;
        return interface.addresses.first.address;
      } catch (ex) {
        return null;
      }
    }
  }
}

Future<String?> getPublicIP() async {
  final us = Get.put(UserState());
  try {
    /// Initialize Ip Address
    var ipAddress = IpAddress(type: RequestType.json);

    /// Get the IpAddress based on requestType.
    dynamic data = await ipAddress.getIpAddress();
    us.usipAddress.value = data['ip'];

  } on IpAddressException catch (exception) {
    /// Handle the exception.

    print(exception.message);
  }
}
