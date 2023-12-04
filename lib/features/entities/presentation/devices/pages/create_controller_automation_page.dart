import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../widgets/widgets.dart';

class CreateControllerAutomationPage extends StatefulWidget {
  final AutomationModel? automation;

  const CreateControllerAutomationPage({super.key, this.automation});

  @override
  State<CreateControllerAutomationPage> createState() =>
      _CreateControllerAutomationPageState();
}

class _CreateControllerAutomationPageState
    extends State<CreateControllerAutomationPage> {
  String _type = 'hour';

  @override
  void initState() {
    if (widget.automation != null) {
      _type = widget.automation!.type;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - (2 * 84) - 16,
              child: Text(
                widget.automation != null
                    ? 'editAutomation'
                    : 'createAutomation',
                style: const TextStyle(
                    color: kSecondaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ).tr(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  CustomDropDown<String>(
                    initialValue: _type,
                    items: const ['hour', 'sensor'],
                    label: 'type'.tr(),
                    hint: ''.tr(),
                    onSave: (_) {},
                    onChange: (value) {
                      setState(() {
                        _type = value!;
                      });
                    },
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'emptyFieldValidation'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (_type == 'hour')
                    HourAutomationFormWidget(
                      automation: widget.automation is HourAutomationModel
                          ? widget.automation as HourAutomationModel
                          : null,
                    ),
                  if (_type == 'sensor')
                    SensorAutomationFormWidget(
                        automation: widget.automation is SensorAutomationModel
                            ? widget.automation as SensorAutomationModel
                            : null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
