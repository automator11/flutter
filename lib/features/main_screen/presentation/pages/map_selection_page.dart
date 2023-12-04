import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'dart:async';
import 'dart:collection';

import '../../../../config/themes/colors.dart';
import '../../../../core/resources/constants.dart';
import '../../../../core/resources/enums.dart';
import '../../../entities/data/models/models.dart';
import '../../../map/presentation/cubits/map_filter_cubit/map_filter_cubit.dart';
import '../../../map/presentation/widgets/widgets.dart';
import '../cubit/cubits.dart';
import '../widgets/widgets.dart';

enum SelectionType { marker, polygon, circle, polyline }

class MapSelectionPage extends StatefulWidget {
  final LocationType locationType;
  final String? assetType;
  final Map<String, dynamic> initialPosition;

  const MapSelectionPage(
      {super.key,
      required this.locationType,
      this.assetType,
      required this.initialPosition});

  @override
  State<MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final _circleRadiusController = TextEditingController();

  late CameraPosition _kInitialPosition;

  final Set<Polygon> _polygon = HashSet<Polygon>();
  final Set<Marker> _markers = HashSet<Marker>();
  final Set<Circle> _circles = HashSet<Circle>();
  final Set<Polyline> _polylines = HashSet<Polyline>();

  late Future _initializePosition;

  final Map<String, LatLng> _polygonsPoints = {};

  int _markersCounter = 1;

  LatLng? singlePosition;

  double _circleRadius = 20.0;
  LatLng? _circleCenter;

  SelectionType _selectionType = SelectionType.marker;

  Map<String, dynamic> position = {};

  EntityModel? _currentEstablishment;

  bool _isLoading = false;
  bool _positionSelected = false;

  List<EntityModel> _items = [];

  Color? _fillColor;
  Color? _strokeColor;

  void _cleanEverything() {
    _markers.clear();
    _markersCounter = 1;
    _polygonsPoints.clear();
    _polygon.clear();
    _polylines.clear();
    _circles.clear();
    _circleRadius = 20.0;
  }

  void _setMarker(LatLng position, String markerId) {
    singlePosition = position;
    _markers.add(Marker(
        markerId: MarkerId(markerId),
        position: position,
        draggable: true,
        onDrag: (newPosition) async {
          switch (_selectionType) {
            case SelectionType.marker:
              singlePosition = newPosition;
              break;
            case SelectionType.circle:
              singlePosition = newPosition;
              _circleCenter = newPosition;
              _circles.clear();
              _setCircle(newPosition);
              break;
            case SelectionType.polygon:
              _polygonsPoints[markerId] = newPosition;
              _polygon.clear();
              _setPolygon();
              break;
            case SelectionType.polyline:
              _polygonsPoints[markerId] = newPosition;
              _polylines.clear();
              _setPolyline();
              break;
            default:
              break;
          }
          if (mounted) {
            context.read<MapFilterCubit>().refreshMap();
          }
        }));
  }

  void _setPolygon() {
    _polygon.add(Polygon(
      polygonId: const PolygonId('polygon_1'),
      points: _polygonsPoints.values.toList(),
      fillColor: _fillColor ?? Colors.green.withOpacity(0.5),
      strokeColor: _strokeColor ?? Colors.green,
      geodesic: true,
      strokeWidth: 3,
    ));
  }

  void _setCircle(LatLng position) {
    singlePosition = position;
    _circles.add(Circle(
        circleId: const CircleId('circle_1'),
        center: position,
        radius: _circleRadius,
        fillColor: _fillColor ?? Colors.redAccent.withOpacity(0.5),
        strokeWidth: 3,
        strokeColor: _strokeColor ?? Colors.redAccent));
  }

  void _setPolyline() {
    _polylines.add(Polyline(
      polylineId: const PolylineId('polyline_1'),
      points: _polygonsPoints.values.toList(),
      color: _strokeColor ?? Colors.greenAccent,
      width: 3,
      geodesic: true,
    ));
  }

  @override
  void initState() {
    _currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    if (widget.assetType != null && _currentEstablishment != null) {
      context.read<MapFilterCubit>().getEntities(
          parentId: _currentEstablishment!.id.id,
          assets: [widget.assetType!],
          devices: []);
    }
    if (widget.locationType == LocationType.polygon) {
      _selectionType = SelectionType.polygon;
    }
    _initializePosition = _initPosition();

    super.initState();
  }

  Future<void> _initPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    LatLng myPosition = const LatLng(-30.405959, -56.468364);

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition();
          myPosition = LatLng(position.latitude, position.longitude);
        }
      }
    }

    LatLng? initialPosition;
    if (widget.initialPosition.isNotEmpty) {
      String type = widget.initialPosition.keys.first;
      if (type == 'marker') {
        _selectionType = SelectionType.marker;
        double latitude = widget.initialPosition['marker']?['latitude'];
        double longitude = widget.initialPosition['marker']?['longitude'];
        initialPosition = LatLng(latitude, longitude);
        _processPosition(initialPosition);
      }
      if (type == 'circle') {
        _selectionType = SelectionType.circle;
        _circleRadius = widget.initialPosition['circle']?['radius'];
        _circleRadiusController.text = _circleRadius.toStringAsFixed(2);
        double latitude = widget.initialPosition['circle']?['latitude'];
        double longitude = widget.initialPosition['circle']?['longitude'];
        initialPosition = LatLng(latitude, longitude);
        _circleCenter = initialPosition;
        _processPosition(initialPosition);
        _positionSelected = true;
      }
      if (type == 'polygon') {
        _selectionType = SelectionType.polygon;
        for (var point in (widget.initialPosition['polygon'] as List)) {
          _processPosition(LatLng(point['latitude'], point['longitude']));
        }
        double latitude =
            (widget.initialPosition['polygon'] as List).first['latitude'];
        double longitude =
            (widget.initialPosition['polygon'] as List).first['longitude'];
        initialPosition = LatLng(latitude, longitude);
      }
      if (type == 'polyline') {
        _selectionType = SelectionType.polyline;
        for (var point in (widget.initialPosition['polyline'] as List)) {
          _processPosition(LatLng(point['latitude'], point['longitude']));
        }
        double latitude =
            (widget.initialPosition['polyline'] as List).first['latitude'];
        double longitude =
            (widget.initialPosition['polyline'] as List).first['longitude'];
        initialPosition = LatLng(latitude, longitude);
      }
    }
    if (_currentEstablishment?.additionalInfo?['mainHousePosition'] != null) {
      double latitude = _currentEstablishment!
          .additionalInfo!['mainHousePosition']['marker']['latitude'];
      double longitude = _currentEstablishment!
          .additionalInfo!['mainHousePosition']['marker']['longitude'];
      initialPosition ??= LatLng(latitude, longitude);

      _markers.add(Marker(
        markerId: MarkerId('marker_${_currentEstablishment!.id.id}'),
        position: LatLng(latitude, longitude),
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
    _kInitialPosition = CameraPosition(
      target:
          initialPosition ?? myPosition,
      zoom: 19,
    );
  }

  Future _processLocationsJson() async {
    for (var item in _items) {
      switch (item.type) {
        case kEstablishmentTypeKey:
        case kGatewayTypeKey:
        case kWaterLevelType:
        case kTempAndHumidityType:
        case kControllerType:
          double latitude =
              item.additionalInfo?['position']?['marker']?['latitude'];
          double longitude =
              item.additionalInfo?['position']?['marker']?['longitude'];
          LatLng position = LatLng(latitude, longitude);
          _markers.add(Marker(
            markerId: MarkerId('marker_${item.id.id}'),
            position: position,
            icon: await AssetMapIndicator(assetType: item.type)
                .toBitmapDescriptor(
                    logicalSize: const Size(150, 150),
                    imageSize: const Size(150, 150)),
          ));
          break;
        case kPaddockTypeKey:
          _fillColor = Colors.green.withOpacity(0.5);
          _strokeColor = Colors.green;
          List<LatLng> polygonPoints =
              (item.additionalInfo?['position']?['polygon'] ?? [])
                  .map<LatLng>((point) {
            return LatLng(point['latitude'], point['longitude']);
          }).toList();
          _polygon.add(Polygon(
            polygonId: PolygonId('polygon_${item.id.id}'),
            points: polygonPoints,
            fillColor: Colors.black.withOpacity(0.5),
            strokeColor: Colors.white,
            geodesic: true,
            strokeWidth: 3,
          ));
          break;
        case kWaterFontTypeKey:
        case kShadowTypeKey:
          _fillColor = item.type == kWaterFontTypeKey
              ? Colors.blue.withOpacity(0.5)
              : Colors.grey.withOpacity(0.5);
          _strokeColor =
              item.type == kWaterFontTypeKey ? Colors.blue : Colors.grey;
          String type = (item.additionalInfo?['position'] as Map).keys.first;
          switch (type) {
            case 'marker':
              double latitude =
                  item.additionalInfo?['position']?['marker']?['latitude'];
              double longitude =
                  item.additionalInfo?['position']?['marker']?['longitude'];
              LatLng position = LatLng(latitude, longitude);
              _markers.add(Marker(
                markerId: MarkerId('marker_${item.id.id}'),
                position: position,
                icon: await AssetMapIndicator(assetType: item.type)
                    .toBitmapDescriptor(
                        logicalSize: const Size(150, 150),
                        imageSize: const Size(150, 150)),
              ));
              break;
            case 'polygon':
              List<LatLng> polygonPoints =
                  (item.additionalInfo?['position']?['polygon'] as List)
                      .map<LatLng>((point) {
                return LatLng(point['latitude'], point['longitude']);
              }).toList();
              _polygon.add(Polygon(
                polygonId: PolygonId('polygon_${item.id.id}'),
                points: polygonPoints,
                fillColor: Colors.black.withOpacity(0.5),
                strokeColor: Colors.white,
                geodesic: true,
                strokeWidth: 3,
              ));
              break;
            case 'circle':
              LatLng position = LatLng(
                  item.additionalInfo?['position']?['circle']['latitude'],
                  item.additionalInfo?['position']?['circle']['longitude']);
              double radius =
                  item.additionalInfo?['position']?['circle']['radius'];
              _circles.add(Circle(
                circleId: CircleId('circle_${item.id.id}'),
                center: position,
                radius: radius,
                fillColor: Colors.black.withOpacity(0.5),
                strokeWidth: 3,
                strokeColor: Colors.white,
              ));
              break;
            case 'polyline':
              List<LatLng> polygonPoints =
                  (item.additionalInfo?['position']?['polyline'] as List)
                      .map<LatLng>((point) {
                return LatLng(point['latitude'], point['longitude']);
              }).toList();
              _polylines.add(Polyline(
                polylineId: PolylineId('polyline_${item.id.id}'),
                points: polygonPoints,
                color: Colors.white,
                width: 3,
                geodesic: true,
              ));
              break;
            default:
              break;
          }
          break;
        default:
          break;
      }
    }
  }

  void _processPosition(LatLng position) {
    switch (_selectionType) {
      case SelectionType.marker:
        _markers.removeWhere((element) =>
            element.markerId.value != 'marker_${_currentEstablishment?.id.id}');
        _setMarker(position, 'marker_$_markersCounter');
        break;
      case SelectionType.polygon:
        _polygonsPoints.addAll({'marker_$_markersCounter': position});
        _setMarker(position, 'marker_$_markersCounter');
        _markersCounter++;
        if (_polygonsPoints.length > 2) {
          _polygon.clear();
          _setPolygon();
        }
        break;
      case SelectionType.circle:
        _circleCenter = position;
        _markers.clear();
        _setMarker(position, 'marker_$_markersCounter');
        _circles.clear();
        _setCircle(position);
        break;
      case SelectionType.polyline:
        _polygonsPoints.addAll({'marker_$_markersCounter': position});
        _setMarker(position, 'marker_$_markersCounter');
        _markersCounter++;
        if (_polygonsPoints.length > 1) {
          _polylines.clear();
          _setPolyline();
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              return FirstPageErrorWidget(
                message: 'errorLoadingMap'.tr(),
                onRetry: () => setState(() {
                  _initializePosition = _initPosition();
                }),
              );
            }
            log('map built');
            return BlocConsumer<MapFilterCubit, MapFilterState>(
              listener: (context, state) async {
                log('listener: ${state.toString()}');
                if (_isLoading) {
                  Navigator.of(context, rootNavigator: true).pop();
                  _isLoading = false;
                }
                if (state is MapFilterLoading) {
                  _isLoading = true;
                  MyDialogs.showLoadingDialog(
                      context, 'gettingAssetsData'.tr());
                }
                if (state is MapFilterFail) {
                  MyDialogs.showErrorDialog(context, state.message);
                }
                if (state is MapFilterSuccess) {
                  log('items: ${state.items.toString()}');
                  _items = state.items;
                  await _processLocationsJson();
                  if (mounted) {
                    context.read<MapFilterCubit>().refreshMap();
                  }
                }
              },
              buildWhen: (previous, current) =>
                  current is MapFilterSuccess || current is MapFilterInitial,
              builder: (context, state) {
                return Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.hybrid,
                      initialCameraPosition: _kInitialPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: _markers,
                      polygons: _polygon,
                      circles: _circles,
                      polylines: _polylines,
                      onTap: (position) {
                        _processPosition(position);
                        context.read<MapFilterCubit>().refreshMap();
                      },
                    ),
                    if (widget.locationType == LocationType.custom)
                      Positioned(
                        bottom: 80,
                        left: 24,
                        child: PointerInterceptor(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  height: 35,
                                  width: 250,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: DropdownButton<SelectionType>(
                                    underline: Container(),
                                    isExpanded: true,
                                    items: [
                                      DropdownMenuItem(
                                        value: SelectionType.marker,
                                        child: const Text('marker').tr(),
                                      ),
                                      DropdownMenuItem(
                                        value: SelectionType.polygon,
                                        child: const Text('polygon').tr(),
                                      ),
                                      DropdownMenuItem(
                                        value: SelectionType.circle,
                                        child: const Text('circle').tr(),
                                      ),
                                      DropdownMenuItem(
                                        value: SelectionType.polyline,
                                        child: const Text('polyline').tr(),
                                      )
                                    ],
                                    value: _selectionType,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectionType = value!;
                                        _cleanEverything();
                                      });
                                    },
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              if (_selectionType == SelectionType.circle)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: SizedBox(
                                    width: 250,
                                    height: 35,
                                    child: TextField(
                                      controller: _circleRadiusController,
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText:
                                              '${'setCircleRadius'.tr()} (m)',
                                          hintStyle:
                                              const TextStyle(fontSize: 12)),
                                      onChanged: (value) {
                                        _circleRadius =
                                            double.tryParse(value) ?? 20.0;
                                        if (_circleCenter == null) {
                                          MyDialogs.showErrorDialog(context,
                                              'provideCircleCenter'.tr());
                                          return;
                                        }
                                        setState(() {
                                          _setCircle(_circleCenter!);
                                          _positionSelected = true;
                                        });
                                      },
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    if (_selectionType != SelectionType.circle)
                      Positioned(
                        bottom: 48,
                        left: 154,
                        child: PointerInterceptor(
                          child: Column(
                            children: [
                              Visibility(
                                visible:
                                    _selectionType == SelectionType.polygon,
                                child: SizedBox(
                                  width: 120,
                                  height: 35,
                                  child: CustomElevatedButton(
                                    backgroundColor: kSecondaryColor,
                                    borderRadius: 8,
                                    onPressed: () {
                                      if (_polygonsPoints.length < 3) {
                                        MyDialogs.showErrorDialog(
                                            context, 'invalidPolygon'.tr());
                                        return;
                                      }
                                      setState(() {
                                        _setPolygon();
                                        _positionSelected = true;
                                      });
                                    },
                                    child: const Text(
                                      'validatePolygon',
                                      style: TextStyle(fontSize: 12),
                                    ).tr(),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible:
                                    _selectionType == SelectionType.polyline,
                                child: SizedBox(
                                  width: 120,
                                  height: 35,
                                  child: CustomElevatedButton(
                                    borderRadius: 8,
                                    backgroundColor: kSecondaryColor,
                                    onPressed: () {
                                      if (_polygonsPoints.length < 2) {
                                        MyDialogs.showErrorDialog(
                                            context, 'invalidPolyline'.tr());
                                        return;
                                      }
                                      setState(() {
                                        _setPolyline();
                                        _positionSelected = true;
                                      });
                                    },
                                    child: const Text(
                                      'validatePolyline',
                                      style: TextStyle(fontSize: 12),
                                    ).tr(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                        bottom: 48,
                        left: 24,
                        child: PointerInterceptor(
                          child: SizedBox(
                            width: 120,
                            height: 35,
                            child: CustomElevatedButton(
                              borderRadius: 8,
                              onPressed: !_validateSelection()
                                  ? null
                                  : () async {
                                      if (_polygonsPoints.isNotEmpty) {
                                        String key = _selectionType ==
                                                SelectionType.polygon
                                            ? 'polygon'
                                            : 'polyline';
                                        position = {key: []};
                                        for (var i in _polygonsPoints.values) {
                                          position[key].add({
                                            "latitude": i.latitude,
                                            "longitude": i.longitude
                                          });
                                        }
                                      } else if (singlePosition != null) {
                                        if (_selectionType ==
                                            SelectionType.marker) {
                                          position = {
                                            "marker": {
                                              "latitude":
                                                  singlePosition?.latitude,
                                              "longitude":
                                                  singlePosition?.longitude
                                            }
                                          };
                                        } else {
                                          position = {
                                            "circle": {
                                              "latitude":
                                                  singlePosition?.latitude,
                                              "longitude":
                                                  singlePosition?.longitude,
                                              "radius": _circleRadius
                                            }
                                          };
                                        }
                                      }
                                      context.pop(position);
                                    },
                              child: const Text(
                                'select',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ).tr(),
                            ),
                          ),
                        )),
                    Positioned(
                        top: 24,
                        left: 24,
                        child: PointerInterceptor(
                          child: CircleButton(
                            onTap: () {
                              context.pop();
                            },
                            icon: const Icon(
                              Ionicons.chevron_back_outline,
                              color: kSecondaryColor,
                              size: 40,
                            ),
                          ),
                        ))
                  ],
                );
              },
            );
          }),
    );
  }

  bool _validateSelection() {
    if (_selectionType == SelectionType.polygon && _polygonsPoints.isEmpty) {
      return false;
    }
    if (_selectionType == SelectionType.circle &&
        _circles.isEmpty &&
        !_positionSelected) {
      return false;
    }
    int markersLength =
        _currentEstablishment?.additionalInfo?['mainHousePosition'] != null
            ? _markers.length - 1
            : _markers.length;

    if (_selectionType == SelectionType.marker && markersLength == 0) {
      return false;
    }
    if (_selectionType == SelectionType.polyline &&
        _polygonsPoints.isEmpty &&
        !_positionSelected) {
      return false;
    }
    if (!_positionSelected && _selectionType != SelectionType.marker) {
      return false;
    }
    return true;
  }
}
