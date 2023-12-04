import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/utils/utils.dart';
import '../../../data/models/models.dart';
import '../cubits/cubits.dart';
import 'widgets.dart';

class WaterLevelDetailsWidget extends StatefulWidget {
  final EntityModel device;
  final Map<String, dynamic> telemetry;
  final bool telemetryLoading;

  const WaterLevelDetailsWidget(
      {super.key,
      required this.device,
      required this.telemetry,
      this.telemetryLoading = false});

  @override
  State<WaterLevelDetailsWidget> createState() =>
      _WaterLevelDetailsWidgetState();
}

class _WaterLevelDetailsWidgetState extends State<WaterLevelDetailsWidget> {
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _keys = ['level'];

  DateTime? start;
  DateTime? end;

  String _selectedValue = 'lastMonth';

  TimeseriesResponseModel? _levelData;
  double? _minTs;
  double? _maxTs;
  double? _maxLevel;
  double? _minLevel;
  double? _minY;

  String _currentLevel = '';

  final List<Color> _gradientColors = [
    Colors.white,
    const Color(0xFFF17830).withOpacity(0.5),
  ];

  void _initValues() {
    _currentLevel = 'noDataReceived'.tr();
    if (widget.telemetry.containsKey('level')) {
      _currentLevel =
          '${(widget.telemetry['level'] as List).first['value']} cm';
    }
    if (widget.device.additionalInfo?.containsKey('maxLevel') ?? false) {
      _maxLevel = double.tryParse(widget.device.additionalInfo!['maxLevel']?.toString() ?? '');
    }
    if (widget.device.additionalInfo?.containsKey('minLevel') ?? false) {
      _minLevel = double.tryParse(widget.device.additionalInfo!['minLevel']?.toString() ?? '');
    }
  }

  @override
  void initState() {
    _initValues();
    _processInterval('lastMonth');
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WaterLevelDetailsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _initValues();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 150, minWidth: 100),
              child: Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(_maxLevel?.toStringAsFixed(2) ?? '',
                          style: const TextStyle(
                              color: kPrimaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                    const Text('ability',
                            style:
                                TextStyle(color: kPrimaryColor, fontSize: 10))
                        .tr()
                  ]),
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 160, minWidth: 100),
              child: Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(_currentLevel,
                          style: const TextStyle(
                              color: kPrimaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                    const Text('currentLevel',
                            style:
                                TextStyle(color: kPrimaryColor, fontSize: 10))
                        .tr()
                  ]),
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: const Border.fromBorderSide(
                  BorderSide(color: kInputDefaultBorderColor))),
          child: Row(
            children: [
              Expanded(
                child: const Text('initLevel',
                        style: TextStyle(color: kSecondaryText, fontSize: 11))
                    .tr(),
              ),
              Text('${widget.device.additionalInfo?['initLevel'] ?? ''} cm',
                  style: const TextStyle(
                      color: kSecondaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700))
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: const Border.fromBorderSide(
                  BorderSide(color: kInputDefaultBorderColor))),
          child: Row(
            children: [
              Expanded(
                child: const Text('minLevel',
                        style: TextStyle(color: kSecondaryText, fontSize: 11))
                    .tr(),
              ),
              Text('${widget.device.additionalInfo?['minLevel'] ?? ''} cm',
                  style: const TextStyle(
                      color: kSecondaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700))
            ],
          ),
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
                      await context.pushNamed(kMapConfigureDevicesPageRoute,
                              extra: widget.device) ??
                          false;
                    }))),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: const Text(
            'history',
            style: TextStyle(
                color: kSecondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ).tr(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: BlocConsumer<DeviceTelemetryCubit, DeviceTelemetryState>(
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
                  _levelData = data['level'];
                  _minTs = _levelData!.values.last.ts.toDouble() - 3600000;
                  _maxTs = _levelData!.values.first.ts.toDouble() + 3600000;
                  _maxLevel ??= 0.0;
                  _minY ??= 0.0;
                  for (var level in _levelData!.values) {
                    double levelValue = double.parse(level.value!.toString());
                    if (_maxLevel! < levelValue) {
                      _maxLevel = levelValue + 10;
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
                  const SizedBox(height: 10,),
                  if (_selectedValue == 'custom')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
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
                        padding: const EdgeInsets.symmetric(horizontal: 24),
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
                              border: const Border.fromBorderSide(BorderSide(
                                  color: Colors.black12, width: 1.0))),
                          lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                maxContentWidth: 220,
                                getTooltipItems: (touchedSpots) =>
                                    touchedSpots.map((barSpot) {
                                  DateTime date =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          barSpot.x.toInt());
                                  String variableName = 'level'.tr();
                                  String type = 'cm';
                                  return LineTooltipItem(
                                    '${DateFormat.yMd().add_jm().format(date)}\n\n',
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
                                          getDotPainter: (spot, percent,
                                                  barData, index) =>
                                              FlDotCirclePainter(
                                                  radius: 6,
                                                  color: kPrimaryColor,
                                                  strokeColor: kSecondaryColor))))
                                  .toList()),
                          extraLinesData: _minLevel != null
                              ? ExtraLinesData(
                                  horizontalLines: [
                                    HorizontalLine(
                                      label: HorizontalLineLabel(show: true),
                                      y: _minLevel!,
                                      color: Colors.red,
                                      strokeWidth: 2,
                                      dashArray: [20, 10],
                                    ),
                                  ],
                                )
                              : const ExtraLinesData(),
                          lineBarsData: [
                            LineChartBarData(
                                spots: _levelData!.values.map((value) {
                                  return FlSpot(value.ts.toDouble(),
                                      double.parse(value.value.toString()));
                                }).toList(),
                                color: const Color(0xFFF17830),
                                isCurved: true,
                                isStrokeCapRound: true,
                                barWidth: 3,
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                      colors: _gradientColors
                                          .map(
                                              (color) => color.withOpacity(0.3))
                                          .toList(),
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter),
                                ),
                                dotData: const FlDotData(
                                  show: false,
                                  // getDotPainter:
                                  //     (spot, percent, barData, index) =>
                                  //         FlDotCirclePainter(
                                  //             radius: 8,
                                  //             color: Colors.transparent,
                                  //             strokeColor: Colors.red)
                                )),
                          ],
                          minX: _minTs,
                          maxX: _maxTs,
                          minY: _minY,
                          maxY: _maxLevel,
                          titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                axisNameSize: 16,
                                axisNameWidget: Text(
                                  '${'level'.tr()} (cm)',
                                  style: const TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12),
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      reservedSize: 20,
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
