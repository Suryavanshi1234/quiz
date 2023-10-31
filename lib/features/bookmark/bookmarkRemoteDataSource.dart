import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutterquiz/features/bookmark/bookmarkException.dart';
import 'package:flutterquiz/utils/constants/api_body_parameter_labels.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';

import 'package:http/http.dart' as http;

class BookmarkRemoteDataSource {
  Future<List<dynamic>> getBookmark(String userId, String type) async {
    try {
      //type is 1 - Quiz zone 3- Guess the word 4 - Audio question
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        typeKey: type
      };

      final response = await http.post(
        Uri.parse(getBookmarkUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body);

      log(name: 'Bookmarks', responseJson.toString());

      if (responseJson['error']) {
        throw BookmarkException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw BookmarkException(errorMessageCode: noInternetCode);
    } on BookmarkException catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    } catch (e) {
      throw BookmarkException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<dynamic> updateBookmark(
    String userId,
    String questionId,
    String status,
    String type,
  ) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        statusKey: status,
        questionIdKey: questionId,
        typeKey: type, //1 - Quiz zone 3 - Guess the word 4 - Audio quesitons
      };
      final response = await http.post(
        Uri.parse(updateBookmarkUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
      final responseJson = jsonDecode(response.body);

      log(name: 'Update Bookmark', responseJson.toString());

      if (responseJson['error']) {
        throw BookmarkException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw BookmarkException(errorMessageCode: noInternetCode);
    } on BookmarkException catch (e) {
      throw BookmarkException(errorMessageCode: e.toString());
    } catch (e) {
      throw BookmarkException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}
