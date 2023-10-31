import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileManagementLocalDataSource {
  String getName() {
    return Hive.box(userDetailsBox).get(nameBoxKey, defaultValue: "");
  }

  String getUserUID() {
    return Hive.box(userDetailsBox).get(userUIdBoxKey, defaultValue: "");
  }

  String getEmail() {
    return Hive.box(userDetailsBox).get(emailBoxKey, defaultValue: "");
  }

  String getMobileNumber() {
    return Hive.box(userDetailsBox).get(mobileNumberBoxKey, defaultValue: "");
  }

  String getRank() {
    return Hive.box(userDetailsBox).get(rankBoxKey, defaultValue: "");
  }

  String getCoins() {
    return Hive.box(userDetailsBox).get(coinsBoxKey, defaultValue: "");
  }

  String getScore() {
    return Hive.box(userDetailsBox).get(scoreBoxKey, defaultValue: "");
  }

  String getProfileUrl() {
    return Hive.box(userDetailsBox).get(profileUrlBoxKey, defaultValue: "");
  }

  String getFirebaseId() {
    return Hive.box(userDetailsBox).get(firebaseIdBoxKey, defaultValue: "");
  }

  String getStatus() {
    return Hive.box(userDetailsBox).get(statusBoxKey, defaultValue: "1");
  }

  String getReferCode() {
    return Hive.box(userDetailsBox).get(referCodeBoxKey, defaultValue: "");
  }

  String getFCMToken() {
    return Hive.box(userDetailsBox).get(fcmTokenBoxKey, defaultValue: "");
  }

  //

  Future<void> setEmail(String email) async {
    Hive.box(userDetailsBox).put(emailBoxKey, email);
  }

  Future<void> setUserUId(String userId) async {
    Hive.box(userDetailsBox).put(userUIdBoxKey, userId);
  }

  Future<void> setName(String name) async {
    Hive.box(userDetailsBox).put(nameBoxKey, name);
  }

  Future<void> serProfileUrl(String profileUrl) async {
    Hive.box(userDetailsBox).put(profileUrlBoxKey, profileUrl);
  }

  Future<void> setRank(String rank) async {
    Hive.box(userDetailsBox).put(rankBoxKey, rank);
  }

  Future<void> setCoins(String coins) async {
    Hive.box(userDetailsBox).put(coinsBoxKey, coins);
  }

  Future<void> setMobileNumber(String mobileNumber) async {
    Hive.box(userDetailsBox).put(mobileNumberBoxKey, mobileNumber);
  }

  Future<void> setScore(String score) async {
    Hive.box(userDetailsBox).put(scoreBoxKey, score);
  }

  Future<void> setStatus(String status) async {
    Hive.box(userDetailsBox).put(statusBoxKey, status);
  }

  Future<void> setFirebaseId(String firebaseId) async {
    Hive.box(userDetailsBox).put(firebaseIdBoxKey, firebaseId);
  }

  Future<void> setReferCode(String referCode) async {
    Hive.box(userDetailsBox).put(referCodeBoxKey, referCode);
  }

  Future<void> setFCMToken(String fcmToken) async {
    Hive.box(userDetailsBox).put(fcmTokenBoxKey, fcmToken);
  }

  static Future<void> updateReversedCoins(int coins) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("reversedCoins", coins);
  }

  static Future<int> getUpdateReversedCoins() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.reload();
      return sharedPreferences.getInt("reversedCoins") ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
