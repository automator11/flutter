import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/resources/constants.dart';
import '../../../../entities/data/models/models.dart';
import '../../../../user/data/models/models.dart';

part 'app_state_state.dart';

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit() : super(AppInitial());

  UserModel? userProfile;
  EntityModel? currentEstablishment;
  String addButtonAction = kEstablishmentTypeKey;
  String? deviceType;

  void restoreAppState(UserModel? user) async {
    if(user != null){
      userProfile = user;
      currentEstablishment = null;
      final prefs = await SharedPreferences.getInstance();
      String? jsonStr = prefs.getString(user.id.id);
      if (jsonStr != null) {
        Map<String, dynamic> json = jsonDecode(jsonStr);
        if (json.containsKey(kSelectedEstablishment)) {
          currentEstablishment =
              EntityModel.fromJson(json[kSelectedEstablishment]);
        }
      }
    }
    emit(AppStateRestored(user: user));
  }

  void updateCurrentEstablishment(
      EntityModel establishment, String userId) async {
    emit(AppStateChangingEstablishment());
    currentEstablishment = establishment;
    final prefs = await SharedPreferences.getInstance();
    final userPrefsJson = prefs.getString(userId) ?? "{}";
    final userPrefs = jsonDecode(userPrefsJson);
    userPrefs[kSelectedEstablishment] = currentEstablishment!.toJson();
    prefs.setString(userId, jsonEncode(userPrefs));
    emit(AppStateUpdatedCurrentEstablishment(
        establishment: currentEstablishment!));
  }

  void emitAssetCreated(String type) {
    emit(AppStateAssetCreated(type: type));
  }

  void emitDeviceClaimed() {
    emit(AppStateDeviceClaimed());
  }

// void clear() {
//   final prefs = await SharedPreferences.getInstance();
//   prefs.clear();
// }
}
