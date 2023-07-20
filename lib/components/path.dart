import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

var port = Platform.environment['PORT'];
var address = const String.fromEnvironment('address');

Future<String> buildPath(String route) async {
  const appName = 'cop4331-20-fcdfeeaee1d5';
  const isProduction = bool.fromEnvironment('dart.vm.product');

  if (isProduction) {
    return 'https://$appName.herokuapp.com/$route';
  } else if (kIsWeb) {
    // Running on web platform
    return 'http://localhost:5000/$route';
  } else {
    // Running on mobile platform
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/$route';
    } else if (address.isNotEmpty) {
      return 'http://$address:5000/$route';
    } else {
      return 'http://localhost:5000/$route';
    }
  }
}
