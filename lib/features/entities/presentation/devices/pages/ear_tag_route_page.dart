import 'dart:async';
import 'dart:collection';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/utils/utils.dart';
import '../../../../../injector.dart';
import '../../../../map/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../cubits/cubits.dart';
import '../widgets/widgets.dart';

class EarTagRoutePage extends StatefulWidget {
  final EntityModel device;

  const EarTagRoutePage({super.key, required this.device});

  @override
  State<EarTagRoutePage> createState() => _EarTagRoutePageState();
}

class _EarTagRoutePageState extends State<EarTagRoutePage> {
  final Completer<GoogleMapController> _controller = Completer();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  late CameraPosition _kGoogle;

  final Set<Polygon> _polygon = HashSet<Polygon>();
  final Set<Marker> _markers = HashSet<Marker>();
  final Set<Polyline> _polylines = HashSet<Polyline>();

  final _keys = ['latitude', 'longitude'];

  late Future _initializePosition;

  EntityModel? _currentEstablishment;

  DateTime? start;
  DateTime? end;

  bool _isLoading = false;
  bool _showInfo = false;

  TelemetryModel? lastValue;

  String _selectedValue = 'lastDay';

  Future _setMainHouseMarker() async {
    if (_currentEstablishment?.additionalInfo?['mainHousePosition'] != null) {
      double latitude = _currentEstablishment!
          .additionalInfo!['mainHousePosition']['marker']['latitude'];
      double longitude = _currentEstablishment!
          .additionalInfo!['mainHousePosition']['marker']['longitude'];
      LatLng position = LatLng(latitude, longitude);
      await _setMarker(position, 'mainHouse', kEstablishmentTypeKey);
    }

    if (_currentEstablishment?.additionalInfo?['position'] != null) {
//draw establishment area
      List<LatLng> polygonPoints =
          (_currentEstablishment!.additionalInfo?['position']?['polygon'] ?? [])
              .map<LatLng>((point) {
        return LatLng(point['latitude'], point['longitude']);
      }).toList();
      _setPolygon(polygonPoints, _currentEstablishment!.id.id,
          fillColor: Colors.black.withOpacity(0.3), strokeColor: Colors.white);
    }
  }

  Future _processLocationsJson(Map<String, dynamic> timeseries) async {
    _markers.clear();
    _polylines.clear();
    TimeseriesResponseModel? latitudeTimeSerie = timeseries['latitude'];
    TimeseriesResponseModel? longitudeTimeSerie = timeseries['longitude'];
    int totalPoints = latitudeTimeSerie?.values.length ?? 0;

    if (latitudeTimeSerie != null && longitudeTimeSerie != null) {
      List<LatLng> polylinePoints = [];
      for (var i = 0; i < totalPoints; i++) {
        double latitude = double.parse(latitudeTimeSerie.values[i].value);
        double longitude = double.parse(longitudeTimeSerie.values[i].value);
        LatLng position = LatLng(latitude, longitude);
        polylinePoints.add(position);
      }
      _setPolyline(polylinePoints, widget.device.id.id);
      LatLng lastPoint = LatLng(double.parse(latitudeTimeSerie.values[0].value),
          double.parse(longitudeTimeSerie.values[0].value));
      await _setMarker(lastPoint, widget.device.id.id, widget.device.type!);
      GoogleMapController mapController = await _controller.future;
      mapController.animateCamera(CameraUpdate.newLatLng(lastPoint));
    }
  }

  Future _setMarker(LatLng position, markerId, String assetType,
      {String? animalCategory}) async {
    _markers.add(Marker(
      markerId: MarkerId('marker_$markerId'),
      position: position,
      icon: await AssetMapIndicator(
        assetType: assetType,
        animalCategory: animalCategory,
      ).toBitmapDescriptor(
          logicalSize: const Size(150, 150), imageSize: const Size(150, 150)),
      onTap: () {
        if (!_showInfo) {
          setState(() {
            _showInfo = true;
          });
        }
      },
    ));
  }

  void _setPolygon(List<LatLng> polygonPoints, String polygonId,
      {Color? fillColor, Color? strokeColor}) {
    _polygon.add(Polygon(
      polygonId: PolygonId('polygon_$polygonId'),
      points: polygonPoints,
      fillColor: fillColor ?? Colors.green.withOpacity(0.5),
      strokeColor: strokeColor ?? Colors.green,
      geodesic: true,
      strokeWidth: 3,
      consumeTapEvents: true,
    ));
  }

  void _setPolyline(List<LatLng> polyLinePoints, String polyLineId) {
    _polylines.add(Polyline(
        polylineId: PolylineId('polyline_$polyLineId'),
        points: polyLinePoints,
        color: Colors.greenAccent,
        width: 3,
        geodesic: true,
        consumeTapEvents: true,
        onTap: () {}));
  }

  @override
  void initState() {
    super.initState();
    _currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    _processInterval('lastDay');
    _initializePosition = _initPosition();
  }

  Future<void> _initPosition() async {
    // bool serviceEnabled;
    // LocationPermission permission;

    // Test if location services are enabled.
    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   // Location services are not enabled don't continue
    //   // accessing the position and request users of the
    //   // App to enable the location services.
    //   return;
    // }
    //
    // permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    //   if (permission == LocationPermission.denied) {
    //     // Permissions are denied, next time you could try
    //     // requesting permissions again (this is also where
    //     // Android's shouldShowRequestPermissionRationale
    //     // returned true. According to Android guidelines
    //     // your App should show an explanatory UI now.
    //     return;
    //   }
    // }
    //
    // if (permission == LocationPermission.deniedForever) {
    //   // Permissions are denied forever, handle appropriately.
    //   return;
    // }

    late LatLng myPosition;
    //TODO: Uncomment this for production
    // try {
    //   final currentPosition = await Geolocator.getCurrentPosition();
    //   myPosition = LatLng(currentPosition.latitude, currentPosition.longitude);
    // } catch (e) {
    //   log('Geolocation error: ${e.toString()}');
    myPosition = const LatLng(37.42796133580664, -122.085749655962);
    // }

    LatLng? initialPosition;
    if (_currentEstablishment?.additionalInfo?['mainHousePosition'] != null) {
      double latitude = _currentEstablishment!
          .additionalInfo!['mainHousePosition']['marker']['latitude'];
      double longitude = _currentEstablishment!
          .additionalInfo!['mainHousePosition']['marker']['longitude'];
      initialPosition = LatLng(latitude, longitude);

      _markers.add(Marker(
        markerId: MarkerId('marker_${_currentEstablishment!.id.id}'),
        position: initialPosition,
        icon: await const AssetMapIndicator(assetType: kEstablishmentTypeKey)
            .toBitmapDescriptor(
                logicalSize: const Size(150, 150),
                imageSize: const Size(150, 150)),
      ));
      //draw establishment area
      List<LatLng> polygonPoints =
          (_currentEstablishment!.additionalInfo?['position']?['polygon'] ?? [])
              .map<LatLng>((point) {
        return LatLng(point['latitude'], point['longitude']);
      }).toList();
      _polygon.add(Polygon(
        polygonId: const PolygonId('establishment_polygon'),
        points: polygonPoints,
        fillColor: Colors.black.withOpacity(0.3),
        strokeColor: Colors.white,
        geodesic: true,
        strokeWidth: 3,
      ));
    }
    _kGoogle = CameraPosition(
      target:
          initialPosition ?? LatLng(myPosition.latitude, myPosition.longitude),
      zoom: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).viewPadding;
    return Scaffold(
      body: FutureBuilder(
        future: _initializePosition,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: const Text('errorInitializingLocationsServices').tr(),
            );
          }
          return BlocConsumer<DeviceTelemetryCubit, DeviceTelemetryState>(
            listener: (context, state) async {
              if (_isLoading) {
                Navigator.of(context, rootNavigator: true).pop();
                _isLoading = false;
              }
              if (state is DeviceTelemetryLoading) {
                _isLoading = true;
                MyDialogs.showLoadingDialog(context, 'gettingData'.tr());
              }
              if (state is DeviceTelemetryFail) {
                MyDialogs.showErrorDialog(context, state.message);
              }
              if (state is DeviceTelemetrySuccess) {
                if (state.telemetry.isEmpty) {
                  MyDialogs.showSuccessDialog(context, 'noDataAvailable'.tr());
                } else {
                  await _processLocationsJson(state.telemetry);
                  await _setMainHouseMarker();

                  if (mounted) {
                    context.read<DeviceTelemetryCubit>().refreshMap();
                  }
                }
              }
            },
            buildWhen: (previous, current) =>
                current is DeviceTelemetrySuccess ||
                current is DeviceTelemetryInitial,
            builder: (context, state) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  GoogleMap(
                    mapType: MapType.hybrid,
                    initialCameraPosition: _kGoogle,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    markers: _markers,
                    polygons: _polygon,
                    polylines: _polylines,
                    onTap: (position) {},
                  ),
                  Positioned(
                    top: 24,
                    left: 24,
                    bottom: 24,
                    child: PointerInterceptor(
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 60.0, bottom: 20),
                                  child: const Text(
                                    'selectTrackingInterval',
                                    style: TextStyle(
                                        color: kPrimaryText,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ).tr(),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                CustomDropDown(
                                  initialValue: _selectedValue,
                                  items: const [
                                    'lastHalfHour',
                                    'lastHour',
                                    'lastDay',
                                    'lastWeek',
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
                                      onSave: (value) {})
                              ],
                            ),
                            Positioned(
                                top: 8,
                                left: 8,
                                child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircleButton(
                                    onTap: () {
                                      context.pop();
                                    },
                                    icon: const Icon(
                                      Ionicons.chevron_back_outline,
                                      color: kIconLightColor,
                                      size: 18,
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_showInfo)
                    Positioned(
                        bottom: 20,
                        right: 56,
                        child: BlocProvider(
                          create: (context) => injector<DeviceTelemetryCubit>(),
                          child: AssetMapDetailsWidget(
                            asset: widget.device,
                            onClose: () {
                              setState(() {
                                _showInfo = false;
                              });
                            },
                          ),
                        )),
                ],
              );
            },
          );
        },
      ),
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
}
