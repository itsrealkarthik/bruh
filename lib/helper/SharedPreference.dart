import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  late final SharedPreferences _sharedPrefs;

  static final SharedPrefs _instance = SharedPrefs._internal();

  factory SharedPrefs() => _instance;

  SharedPrefs._internal();

  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  Future<void> clear() async {
    await _sharedPrefs.clear();
  }

  String get uid => _sharedPrefs.getString('uid') ?? "";
  String get name => _sharedPrefs.getString('name') ?? "";
  String get profile => _sharedPrefs.getString('profile') ?? "";
  String get registernumber => _sharedPrefs.getString('registernumber') ?? "";
  String get gender => _sharedPrefs.getString('gender') ?? "";
  String get nativestate => _sharedPrefs.getString('nativestate') ?? "";
  String get hosteller => _sharedPrefs.getString('hosteller') ?? "";
  List<String> get classes => _sharedPrefs.getStringList('classes') ?? [];

  set uid(String value) {
    _sharedPrefs.setString('uid', value);
  }

  set name(String value) {
    _sharedPrefs.setString('name', value);
  }

  set profile(String value) {
    _sharedPrefs.setString('profile', value);
  }

  set registernumber(String value) {
    _sharedPrefs.setString('registernumber', value);
  }

  set gender(String value) {
    _sharedPrefs.setString('gender', value);
  }

  set nativestate(String value) {
    _sharedPrefs.setString('nativestate', value);
  }

  set hosteller(String value) {
    _sharedPrefs.setString('hosteller', value);
  }

  set classes(List<String> value) {
    _sharedPrefs.setStringList('classes', value);
  }
}
