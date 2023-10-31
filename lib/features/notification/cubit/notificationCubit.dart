import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/notification/notificationException.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/api_body_parameter_labels.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:http/http.dart' as http;

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationProgress extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final List notificationList;
  final int totalData;
  final bool hasMore;

  NotificationSuccess(this.notificationList, this.totalData, this.hasMore);
}

class NotificationFailure extends NotificationState {
  final String errorMessageCode;

  NotificationFailure(this.errorMessageCode);
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  Future<Map<String, dynamic>> _fetchData({
    required String limit,
    String? offset,
  }) async {
    try {
      final body = {
        accessValueKey: accessValue,
        limitKey: limit,
        offsetKey: offset ?? "",
      };

      if (offset == null) {
        body.remove(offset);
      }

      final response = await http.post(
        Uri.parse(getNotificationUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw NotificationException(errorMessageCode: responseJson['message']);
      }

      return Map.from(responseJson);
    } on SocketException catch (_) {
      throw NotificationException(errorMessageCode: noInternetCode);
    } on NotificationException catch (e) {
      throw NotificationException(errorMessageCode: e.toString());
    } catch (e) {
      throw NotificationException(
        errorMessageKey: e.toString(),
        errorMessageCode: '',
      );
    }
  }

  void fetchNotifications(String limit) {
    emit(NotificationProgress());

    _fetchData(limit: limit).then((v) {
      final usersDetails = v['data'] as List;
      final total = int.parse(v['total'].toString());

      emit(NotificationSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(NotificationFailure(defaultErrorMessageCode));
    });
  }

  void fetchMoreNotifications(String limit) {
    _fetchData(
            limit: limit,
            offset: (state as NotificationSuccess)
                .notificationList
                .length
                .toString())
        .then((value) {
      //
      final oldState = (state as NotificationSuccess);
      final usersDetails = value['data'] as List;
      final updatedUserDetails = List.from(oldState.notificationList);
      updatedUserDetails.addAll(usersDetails);
      emit(NotificationSuccess(updatedUserDetails, oldState.totalData,
          oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(NotificationFailure(defaultErrorMessageCode));
    });
  }

  bool get hasMore => state is NotificationSuccess
      ? (state as NotificationSuccess).hasMore
      : false;
}
