import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/utils/utils.dart';
import '../../../data/models/models.dart';
import '../cubits/cubits.dart';
import 'widgets.dart';

class TempHumDetailsWidget extends StatefulWidget {
  final EntityModel device;
  final Map<String, dynamic> telemetry;
  final bool telemetryLoading;

  const TempHumDetailsWidget(
      {super.key,
      required this.device,
      required this.telemetry,
      this.telemetryLoading = false});

  @override
  State<TempHumDetailsWidget> createState() => _TempHumDetailsWidgetState();
}

class _TempHumDetailsWidgetState extends State<TempHumDetailsWidget> {
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  List<AlertModel> _alerts = [];
  late EntityModel _device;

  final _keys = ['temperature', 'humidity'];

  DateTime? start;
  DateTime? end;

  String _selectedValue = 'lastMonth';

  TimeseriesResponseModel? _temperatureData;
  TimeseriesResponseModel? _humidityData;
  double? _minTs;
  double? _maxTs;
  double? _maxY;
  double? _minY;

  String temperature = '--';
  String humidity = '--';

  void _initValues() {
    if (widget.telemetry.containsKey('temperature')) {
      temperature =
          '${(double.tryParse((widget.telemetry['temperature'] as List).first['value'].toString()))?.toStringAsFixed(2) ?? '--'}°';
    }
    if (widget.telemetry.containsKey('humidity')) {
      humidity =
          '${(double.tryParse((widget.telemetry['humidity'] as List).first['value'].toString()))?.toStringAsFixed(2) ?? '--'}%';
    }
  }

  @override
  void initState() {
    _device = widget.device;
    _alerts =
        AlertsResponseModel.fromJson(widget.device.additionalInfo ?? {}).alerts;
    _processInterval('lastMonth');
    _initValues();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TempHumDetailsWidget oldWidget) {
    if (widget != oldWidget) {
      _device = widget.device;
      _alerts = AlertsResponseModel.fromJson(widget.device.additionalInfo ?? {})
          .alerts;
      _initValues();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  constraints:
                      const BoxConstraints(maxWidth: 150, minWidth: 100),
                  child: Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(temperature,
                              style: const TextStyle(
                                  color: kPrimaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const Text('temperature',
                                style: TextStyle(
                                    color: kPrimaryColor, fontSize: 10))
                            .tr()
                      ]),
                    ),
                  ),
                ),
                Container(
                  constraints:
                      const BoxConstraints(maxWidth: 160, minWidth: 100),
                  child: Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(humidity,
                              style: const TextStyle(
                                  color: kPrimaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const Text('humidity',
                                style: TextStyle(
                                    color: kPrimaryColor, fontSize: 10))
                            .tr()
                      ]),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'alerts',
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
            height: 10,
          ),
          itemCount: _alerts.length,
          itemBuilder: (BuildContext context, int index) {
            return AlertTileWidget(alert: _alerts[index]);
          },
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
                      style: TextStyle(fontSize: 14),
                    ).tr(),
                    onPressed: () async {
                      await context.pushNamed<bool>(
                              kMapConfigureDevicesPageRoute,
                              extra: _device) ??
                          false;
                    }))),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'history',
          style: TextStyle(
              color: kSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ).tr(),
        const SizedBox(
          height: 10,
        ),
        BlocConsumer<DeviceTelemetryCubit, DeviceTelemetryState>(
          listener: (context, state) {
            if (state is DeviceTelemetryFail) {
              MyDialogs.showErrorDialog(context, state.message);
            }
          },
          builder: (context, state) {
            bool noData = true;
            if (state is DeviceTelemetrySuccess) {
              final data = state.telemetry;
              if (data.isNotEmpty) {
                noData = false;
                _temperatureData = data['temperature'];
                _humidityData = data['humidity'];
                _minTs = _temperatureData!.values.last.ts.toDouble() - 3600000;
                _maxTs = _temperatureData!.values.first.ts.toDouble() + 3600000;
                _maxY ??= 0.0;
                _minY ??= 0.0;
                for (var level in _temperatureData!.values) {
                  double levelValue = double.parse(level.value!.toString());
                  if (_maxY! < levelValue) {
                    _maxY = levelValue + 10;
                  }
                  if (_minY! > levelValue) {
                    _minY = levelValue - 10;
                  }
                }
                for (var level in _humidityData!.values) {
                  double levelValue = double.parse(level.value!.toString());
                  if (_maxY! < levelValue) {
                    _maxY = levelValue + 10;
                  }
                  if (_minY! > levelValue) {
                    _minY = levelValue - 10;
                  }
                }
              }
            }
            return Column(
              children: [
                CustomDropDown(
                  initialValue: _selectedValue,
                  items: const [
                    'lastHalfHour',
                    'lastHour',
                    'lastDay',
                    'lastWeek',
                    'lastMonth',
                    'custom'
                  ],
                  hint: '',
                  label: 'timeseriesInterval'.tr(),
                  validator: (value) {
                    return null;
                  },
                  onChange: (value) {
                    if (value != null) {
                      _selectedValue = value;
                      _processInterval(value);
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                if (_selectedValue == 'custom')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CustomTextField(
                        controller: _startController,
                        label: 'start'.tr(),
                        onSave: (value) {}),
                  ),
                if (_selectedValue == 'custom')
                  CustomTextField(
                      controller: _endController,
                      label: 'end'.tr(),
                      onSave: (value) {}),
                const SizedBox(
                  height: 20,
                ),
                if (noData)
                  SizedBox(
                    height: 400,
                    width: 350,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: FirstPageErrorWidget(
                        message: 'noDataAvailable'.tr(),
                        onRetry: () {
                          _processInterval(_selectedValue);
                        },
                      ),
                    ),
                  ),
                if (!noData)
                  SizedBox(
                    height: 400,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(
                            show: true,
                            border: const Border.fromBorderSide(
                                BorderSide(color: Colors.black12, width: 1.0))),
                        lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              maxContentWidth: 220,
                              getTooltipItems: (touchedSpots) =>
                                  touchedSpots.map((barSpot) {
                                DateTime date =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        barSpot.x.toInt());
                                String variableName = barSpot.barIndex == 0
                                    ? 'temperature'.tr()
                                    : 'humidity'.tr();
                                String type =
                                    barSpot.barIndex == 0 ? '°C' : '%';
                                return LineTooltipItem(
                                  barSpot.barIndex == 1
                                      ? '${DateFormat.yMd().add_jm().format(date)}\n\n'
                                      : '',
                                  const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 11),
                                  children: [
                                    TextSpan(
                                        text: '$variableName: ',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                            fontSize: 11)),
                                    TextSpan(
                                      text: '${barSpot.y.toString()} $type',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontSize: 11),
                                    ),
                                  ],
                                  textAlign: TextAlign.left,
                                );
                              }).toList(),
                            ),
                            getTouchedSpotIndicator: (data, points) => points
                                .map((e) => TouchedSpotIndicatorData(
                                    const FlLine(color: kSecondaryColor),
                                    FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData,
                                                index) =>
                                            FlDotCirclePainter(
                                                radius: 6,
                                                color: kPrimaryColor,
                                                strokeColor: kSecondaryColor))))
                                .toList()),
                        lineBarsData: [
                          LineChartBarData(
                              spots: _temperatureData!.values.map((value) {
                                return FlSpot(value.ts.toDouble(),
                                    double.parse(value.value.toString()));
                              }).toList(),
                              color: Colors.red,
                              isCurved: true,
                              isStrokeCapRound: true,
                              barWidth: 3,
                              belowBarData: BarAreaData(show: false),
                              dotData: const FlDotData(
                                show: false,
                                // getDotPainter:
                                //     (spot, percent, barData, index) =>
                                //         FlDotCirclePainter(
                                //             radius: 8,
                                //             color: Colors.transparent,
                                //             strokeColor: Colors.red)
                              )),
                          LineChartBarData(
                              spots: _humidityData!.values
                                  .map((value) => FlSpot(value.ts.toDouble(),
                                      double.parse(value.value.toString())))
                                  .toList(),
                              color: Colors.blue,
                              isCurved: true,
                              isStrokeCapRound: true,
                              barWidth: 5,
                              belowBarData: BarAreaData(show: false),
                              dotData: const FlDotData(
                                show: false,
                                // getDotPainter:
                                //     (spot, percent, barData, index) =>
                                //         FlDotCirclePainter(
                                //             radius: 8,
                                //             color: Colors.transparent,
                                //             strokeColor: Colors.blue)
                              )),
                        ],
                        minX: _minTs,
                        maxX: _maxTs,
                        minY: _minY,
                        maxY: _maxY,
                        titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              axisNameSize: 30,
                              axisNameWidget: Text(
                                '${'temperature'.tr()} (°C)',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12),
                              ),
                              // sideTitles: SideTitles(
                              //     showTitles: true,
                              //     reservedSize: 40,
                              //     getTitlesWidget: leftTitleWidgets)
                            ),
                            rightTitles: AxisTitles(
                              axisNameSize: 30,
                              axisNameWidget: Text(
                                '${'humidity'.tr()} (%)',
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12),
                              ),
                              // sideTitles: SideTitles(
                              //     reservedSize: 40,
                              //     getTitlesWidget: rightTitleWidgets,
                              //     showTitles: true)
                            ),
                            bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    reservedSize: 60,
                                    getTitlesWidget: bottomTitleWidgets,
                                    showTitles: true)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false))),
                      ),
                      duration: const Duration(milliseconds: 300), // Optional
                      curve: Curves.linear, // Optional
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void _processInterval(String interval) async {
    DateTime now = DateTime.now();
    start = null;
    end = null;
    switch (interval) {
      case 'lastHalfHour':
        start = now.subtract(const Duration(minutes: 30));
        end = now;
        break;
      case 'lastDay':
        start = now.subtract(const Duration(hours: 24));
        end = now;
        break;
      case 'lastWeek':
        start = now.subtract(const Duration(days: 7));
        end = now;
        break;
      case 'lastMonth':
        start = now.subtract(const Duration(days: 30));
        end = now;
        break;
      case 'custom':
        Map<String, DateTime?>? result = await showDialog(
            context: context,
            builder: (context) => const SelectTimeIntervalDialog());
        if (result == null) {
          return;
        }
        start = result['startDate']!;
        _startController.text = Utils.getLongDate(start!);
        end = result['endDate']!;
        _endController.text = Utils.getLongDate(end!);
        break;
      default:
        start = now.subtract(const Duration(minutes: 60));
        end = now;
        break;
    }
    if (mounted && start != null && end != null) {
      context.read<DeviceTelemetryCubit>().getDeviceTelemetry(
          widget.device.id.id,
          start!.millisecondsSinceEpoch,
          end!.millisecondsSinceEpoch,
          _keys);
    }
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Text(
        value.toString(),
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    return Text(value.toString(), style: style, textAlign: TextAlign.right);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    if (value != _minTs && value != _maxTs) {
      return Container();
    }
    const style = TextStyle(color: Colors.black, fontSize: 10);
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    String dateStr = DateFormat.MMMd().format(date);
    String timeStr = DateFormat.jm().format(date);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('$dateStr\n$timeStr', style: style),
    );
  }
}
