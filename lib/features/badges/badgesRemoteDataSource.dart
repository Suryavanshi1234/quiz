import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/features/badges/badgesExecption.dart';
import 'package:flutterquiz/utils/constants/api_body_parameter_labels.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:http/http.dart' as http;

class BadgesRemoteDataSource {
  //response of this will be map of badges
  /*
      "message" : { 
          //badge type key
          "badge_type" :
            //badge data
           {
            "type" : "",
            "id" : "",
            ...
          }
        }
       */
  Future<Map<String, dynamic>> getBadges({required String userId}) async {
    try {
      //body of post request
      final body = {accessValueKey: accessValue, userIdKey: userId};
      print(getUserBadgesUrl);
      final response = await http.post(Uri.parse(getUserBadgesUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw BadgesException(errorMessageCode: responseJson['message']);
      }
      return Map.from(responseJson['message']);
    } on SocketException catch (_) {
      throw BadgesException(errorMessageCode: noInternetCode);
    } on BadgesException catch (e) {
      throw BadgesException(errorMessageCode: e.toString());
    } catch (e) {
      throw BadgesException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<void> setBadges(
      {required String userId, required String badgeType}) async {
    try {
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        typeKey: badgeType
      };

      final response = await http.post(Uri.parse(setUserBadgesUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw BadgesException(errorMessageCode: responseJson['message']);
      }
    } on SocketException catch (_) {
      throw BadgesException(errorMessageCode: noInternetCode);
    } on BadgesException catch (e) {
      throw BadgesException(errorMessageCode: e.toString());
    } catch (e) {
      throw BadgesException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
