import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../../core/utils/utils.dart';
import '../../../../alerts/data/models/models.dart';
import '../../../../alerts/presentation/cubits/alerts_cubit.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';

class EarTagDetailsWidget extends StatefulWidget {
  final EntityModel device;
  final Map<String, dynamic> telemetry;
  final List<dynamic> attributes;
  final bool telemetryLoading;

  const EarTagDetailsWidget(
      {super.key,
      required this.device,
      required this.telemetry,
      required this.attributes,
      this.telemetryLoading = false});

  @override
  State<EarTagDetailsWidget> createState() => _EarTagDetailsWidgetState();
}

class _EarTagDetailsWidgetState extends State<EarTagDetailsWidget> {
  List<AlarmModel> _alarms = [];

  double? distance;

  void _initValues() {
    for (var attr in widget.attributes) {
      if (attr['key'] == 'distance') {
        distance = attr['value'];
      }
    }
  }

  @override
  void initState() {
    context.read<AlertsCubit>().getDeviceAlert(widget.device.id.id);
    _initValues();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant EarTagDetailsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    context.read<AlertsCubit>().getDeviceAlert(widget.device.id.id);
    _initValues();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Card(
            elevation: 3.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 40,
                        width: 50,
                        child: Utils.getDeviceIcon(widget.device.type),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text('${'totalDistance'.tr()}: ',
                                      style: const TextStyle(
                                          color: kSecondaryText, fontSize: 12)),
                                ),
                                Text('${distance?.toStringAsFixed(2) ?? '--'} m',
                                        style: const TextStyle(
                                            color: kSecondaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700))
                                    .tr()
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const Divider(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/time.png',
                            width: 20,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            widget.telemetry.isEmpty
                                ? 'noDataReceived'
                                : Utils.getTimeAgoDate(
                                    (widget.telemetry.values.first as List)
                                        .first['ts'],
                                    locale: context.locale.languageCode),
                            style: const TextStyle(
                                color: kSecondaryText, fontSize: 12),
                          ).tr(),
                        ],
                      ),
                      Center(
                          child: Container(
                              constraints: const BoxConstraints(
                                  maxWidth: 130, maxHeight: 40),
                              child: CustomElevatedButton(
                                  borderRadius: 10,
                                  backgroundColor: kSecondaryColor,
                                  child: const Text(
                                    'seeRoute',
                                    style: TextStyle(fontSize: 12),
                                  ).tr(),
                                  onPressed: () {
                                    context.pushNamed(
                                            kEarTagRoutePageRoute,
                                            extra: widget.device);
                                  }))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Card(
          elevation: 3.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: Container(
                  constraints:
                      const BoxConstraints(minHeight: 200, maxHeight: 400),
                  child: BlocBuilder<AlertsCubit, AlertsState>(
                    builder: (context, state) {
                      if (state is AlertsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (state is AlertsFail) {
                        return FirstPageErrorWidget(
                          message: state.message.tr(),
                          onRetry: () {
                            context
                                .read<AlertsCubit>()
                                .getDeviceAlert(widget.device.id.id);
                          },
                        );
                      }
                      if (state is AlertsSuccess) {
                        _alarms = state.items;
                      }
                      return _alarms.isEmpty
                          ? FirstPageErrorWidget(
                              message: 'emptyData'.tr(),
                              onRetry: () {
                                context
                                    .read<AlertsCubit>()
                                    .getDeviceAlert(widget.device.id.id);
                              },
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemExtent: 80,
                              itemCount: _alarms.length,
                              itemBuilder: (context, index) => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 15,
                                            height: 15,
                                            decoration: const BoxDecoration(
                                                color: Color(0xFFD2D3D4),
                                                shape: BoxShape.circle),
                                          ),
                                          if (index < _alarms.length - 1)
                                            Container(
                                              constraints: const BoxConstraints(
                                                  maxWidth: 4, maxHeight: 65),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFD2D3D4),
                                              ),
                                            )
                                        ]),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                              Utils.getShortDate(DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      _alarms[index].startTs)),
                                              style: const TextStyle(
                                                  color: kPrimaryText,
                                                  fontSize: 12)),
                                          Text(
                                              _alarms[index]
                                                      .details['message'] ??
                                                  '',
                                              style: const TextStyle(
                                                  color: Color(0xFFF17830),
                                                  fontSize: 10))
                                        ]),
                                  )
                                ],
                              ),
                            );
                    },
                  ))),
        ),
        const SizedBox(
          height: 20,
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
                      style: TextStyle(fontSize: 12),
                    ).tr(),
                    onPressed: () async {
                      await context.pushNamed(kMapConfigureDevicesPageRoute,
                              extra: widget.device) ??
                          false;
                    })))
      ],
    );
  }
}
