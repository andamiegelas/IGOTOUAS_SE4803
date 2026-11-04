import 'dart:io';

class ApiConstants {
  // Gunakan 10.0.2.2 untuk Android Emulator, 127.0.0.1 untuk Desktop/Web, atau IP LAN (192.168.1.11) untuk HP fisik
  static String defaultHost = Platform.isAndroid ? '10.0.2.2:5000' : '127.0.0.1:5000';
  
  static String get baseUrl => 'http://$defaultHost/api';
  static String get uploadUrl => 'http://$defaultHost';

  static void setCustomHost(String host) {
    defaultHost = host;
  }
}

