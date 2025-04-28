import 'package:shared_preferences/shared_preferences.dart';

class ApiUtils {
  static const String _defaultIp = "10.0.0.43";
  static String _currentIp = _defaultIp;
  static String baseUrl = "http://$_defaultIp:8000/api"; // Default to Laravel

  static String get currentIp => _currentIp;

  static Future<void> setIpAddress(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    _currentIp = ip;
    await prefs.setString('server_ip', ip);
    await _updateBaseUrl();
  }

  static Future<void> loadIpAddress() async {
    final prefs = await SharedPreferences.getInstance();
    _currentIp = prefs.getString('server_ip') ?? _defaultIp;
    await _updateBaseUrl();
  }

  static Future<void> setBaseUrl(String server) async {
    final prefs = await SharedPreferences.getInstance();
    await _updateBaseUrl(server: server);
    await prefs.setString('selected_server', server);
  }

  static Future<void> _updateBaseUrl({String? server}) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedServer = server ?? prefs.getString('selected_server') ?? 'laravel';
    
    if (selectedServer == 'laravel') {
      baseUrl = "http://$_currentIp:8000/api";
    } else if (selectedServer == 'nodejs') {
      baseUrl = "http://$_currentIp:3300/api";
    }
  }

  static Future<void> loadSelectedServer() async {
    await loadIpAddress();
    final prefs = await SharedPreferences.getInstance();
    final selectedServer = prefs.getString('selected_server') ?? 'laravel';
    await _updateBaseUrl(server: selectedServer);
  }
}