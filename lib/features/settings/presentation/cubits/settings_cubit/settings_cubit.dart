import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../../core/exceptions/error_handler.dart';
import '../../../../../core/utils/data_state.dart';
import '../../../../entities/data/models/models.dart';
import '../../../../user/data/repositories/repositories.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final FirebaseMessaging _messaging;
  final UserRepository _userRepository;
  SettingsCubit(this._messaging, this._userRepository)
      : super(SettingsInitial());

  void subscribeNotifications(String customerId) async {
    emit(SettingsLoading());
    DataState data = await _userRepository.getCustomer(customerId);
    if (data is DataSuccess) {
      CustomerModel customer = CustomerModel.fromJson(data.data);
      String? topic = customer.title;
      if (topic.isEmpty) {
        emit(const SettingsFail('notificationsTopicInvalid'));
        return;
      }
      try {
        topic = topic.replaceAll(' ', '_');
        await _messaging.subscribeToTopic(topic);
        log('Subscribed to $topic topic.');
      } catch (e) {
        log('Fail to subscribe to $topic topic. ${e.toString()}');
        emit(SettingsFail('failToSubscribeToTopic'.tr(args: [topic!])));
        return;
      }
      emit(const SettingsSuccess());
      return;
    }
    if (data is DataError) {
      if (data.error is DioException) {
        final String errorStr =
            ErrorHandler(dioException: (data.error as DioException))
                .errorMessage;
        emit(SettingsFail(errorStr));
        return;
      }
      emit(const SettingsFail('unknownError'));
    }
  }

  void unsubscribeNotifications(String customerId) async {
    emit(SettingsLoading());
    DataState data = await _userRepository.getCustomer(customerId);
    if (data is DataSuccess) {
      CustomerModel customer = CustomerModel.fromJson(data.data);
      String? topic = customer.title;
      if (topic.isEmpty) {
        emit(const SettingsFail('notificationsTopicInvalid'));
        return;
      }
      try {
        topic = topic.replaceAll(' ', '_');
        await _messaging.unsubscribeFromTopic(topic);
        log('Unsubscribed from $topic topic.');
      } catch (e) {
        log('Fail to unsubscribe from $topic topic. ${e.toString()}');
        emit(SettingsFail('failToUnsubscribeToTopic'.tr(args: [topic!])));
        return;
      }
      emit(const SettingsSuccess());
      return;
    }
    if (data is DataError) {
      if (data.error is DioException) {
        final String errorStr =
            ErrorHandler(dioException: (data.error as DioException))
                .errorMessage;
        emit(SettingsFail(errorStr));
        return;
      }
      emit(const SettingsFail('unknownError'));
    }
  }
}
