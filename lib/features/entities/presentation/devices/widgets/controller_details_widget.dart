import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';
import 'widgets.dart';

class ControllerDetailsWidget extends StatefulWidget {
  final EntityModel device;
  final Map<String, dynamic> telemetry;
  final bool telemetryLoading;

  const ControllerDetailsWidget(
      {super.key,
      required this.device,
      required this.telemetry,
      this.telemetryLoading = false});

  @override
  State<ControllerDetailsWidget> createState() =>
      _ControllerDetailsWidgetState();
}

class _ControllerDetailsWidgetState extends State<ControllerDetailsWidget> {
  List<AutomationModel> _automations = [];
  late EntityModel _device;

  @override
  void initState() {
    _device = widget.device;
    _automations =
        AutomationsResponseModel.fromJson(widget.device.additionalInfo ?? {})
            .automations;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ControllerDetailsWidget oldWidget) {
    if (widget != oldWidget) {
      _device = widget.device;
      _automations =
          AutomationsResponseModel.fromJson(widget.device.additionalInfo ?? {})
              .automations;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'automations',
          style: TextStyle(
              color: kSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ).tr(),
        const SizedBox(
          height: 10,
        ),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const Divider(
            height: 20,
          ),
          itemCount: _automations.length,
          itemBuilder: (BuildContext context, int index) {
            if (_automations[index].type == 'hour') {
              return HourAutomationWidget(
                  automation: _automations[index] as HourAutomationModel);
            }
            if (_automations[index].type == 'sensor') {
              return SensorAutomationWidget(
                  automation: _automations[index] as SensorAutomationModel);
            }
            return Container();
          },
        ),
        const SizedBox(
          height: 40,
        ),
        Center(
            child: SizedBox(
                height: 30,
                width: 120,
                child: CustomElevatedButton(
                    backgroundColor: kSecondaryColor,
                    borderRadius: 10,
                    child: const Text(
                      'configure',
                    ).tr(),
                    onPressed: () async {
                      await context.pushNamed<bool>(
                              kMapConfigureDevicesPageRoute,
                              extra: _device) ??
                          false;
                    }))),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
