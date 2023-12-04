import '../../params/devices_params/params.dart';

class SaveControllersAttributesParams extends SaveAttributesParams {
  final String action;
  SaveControllersAttributesParams(
      {required super.deviceId, required this.action});

  @override
  Map<String, dynamic> toJson() => {'action': action};
}
