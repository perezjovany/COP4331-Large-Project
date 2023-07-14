import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

var port = Platform.environment['PORT'];

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
    return 'http://11.22.11.68:5000/$route'; // TODO: remove personal IP
  }
}
