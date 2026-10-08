import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  final SharedPreferences _p;
  Settings(this._p);
  String get baseUrl =>
      _p.getString('baseUrl') ?? 'https://xraymodel.temboafrica.org';
  String get apiKey => _p.getString('apiKey') ?? '';
  String get facilityId => _p.getString('facilityId') ?? 'FAC-001';
  Future<void> save(String url, String key, String facility) async {
    await _p.setString('baseUrl', url.trim());
    await _p.setString('apiKey', key.trim());
    await _p.setString('facilityId', facility.trim());
  }
}
