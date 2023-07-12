import 'package:flutter/foundation.dart' show kIsWeb;

Future<String> buildPath(String route) async {
  const app_name = 'cop4331-20-fcdfeeaee1d5';
  const isProduction = bool.fromEnvironment('dart.vm.product');

  if (isProduction) {
    return 'https://$app_name.herokuapp.com/$route';
  } else if (kIsWeb) {
    // Running on web platform
    return 'http://localhost:5000/$route';
  } else {
    // Running on mobile platform
    return 'http://11.23.86.195:5000/$route'; // TODO: remove personal IP
  }
}
