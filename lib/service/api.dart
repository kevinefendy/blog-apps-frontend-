import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:5000';
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:5000';
  } else {
    return 'http://localhost:5000'; // iOS Simulator atau Desktop
  }
}