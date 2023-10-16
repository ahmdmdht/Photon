import 'package:flutterquiz/utils/apiBodyParameterLabels.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:hive/hive.dart';

//AuthLocalDataSource will communicate with local database (hive)
class AuthLocalDataSource {
  static String getJwtToken() {
    return Hive.box(authBox).get(jwtTokenKey, defaultValue: "");
  }

  static Future<void> setJwtToken(String jwtToken) async {
    await Hive.box(authBox).put(jwtTokenKey, jwtToken);
  }

  static bool checkIsAuth() {
    return Hive.box(authBox).get(isLoginKey, defaultValue: false);
  }

  static String getAuthType() {
    return Hive.box(authBox).get(authTypeKey, defaultValue: "");
  }

  static String getGrade() {
    return Hive.box(authBox).get(gradeKey, defaultValue: "");
  }


  Future<void> setGrade(String? grade) async {
    Hive.box(authBox).put(gradeKey, grade);
  }
  static String getUserFirebaseId() {
    return Hive.box(authBox).get(firebaseIdBoxKey, defaultValue: "");
  }

  Future<void> setUserFirebaseId(String? userId) async {
    Hive.box(authBox).put(firebaseIdBoxKey, userId);
  }

  Future<void> setAuthType(String? authType) async {
    Hive.box(authBox).put(authTypeKey, authType);
  }

  Future<void> changeAuthStatus(bool? authStatus) async {
    Hive.box(authBox).put(isLoginKey, authStatus);
  }
}
