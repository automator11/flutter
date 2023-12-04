import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

import '../../../../config/routes/routes.dart';
import '../../../../config/themes/colors.dart';
import '../../../../core/resources/constants.dart';
import '../../../../injector.dart';
import '../../../entities/data/models/models.dart';
import '../../../entities/presentation/assets/cubits/cubits.dart';
import '../../../entities/presentation/assets/widgets/widgets.dart';
import '../../../entities/presentation/devices/cubits/cubits.dart';
import '../../../main_screen/presentation/cubit/cubits.dart';
import '../../../main_screen/presentation/widgets/widgets.dart';
import '../cubits/map_filter_cubit/map_filter_cubit.dart';
import '../widgets/widgets.dart';

class MapViewPage extends StatefulWidget {
  final Widget child;
  final EntityModel? selectedEntity;

  const MapViewPage({super.key, required this.child, this.selectedEntity});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  final Completer<GoogleMapController> _controller = Completer();

  CameraPosition? kInitialPosition;

  final Set<Polygon> _polygon = HashSet<Polygon>();
  final Set<Marker> _markers = HashSet<Marker>();
  final Set<Circle> _circles = HashSet<Circle>();
  final Set<Polyline> _polylines = HashSet<Polyline>();

  late Future _initializePosition;

  final List<LatLng> _polygonsPoints = <LatLng>[];

  EntityModel? _currentEstablishment;

  final List<String> _types = [
    kGatewayTypeKey,
    kPaddockTypeKey,
    kWaterFontTypeKey,
    kShadowTypeKey,
    kWaterLevelType,
    kTempAndHumidityType,
    kControllerType,
    kEarTagType
  ];

  final List<String> _selectedAssetTypes = [];
  final List<String> _selectedDeviceTypes = [];

  List<EntityModel> _items = [];

  EntityModel? _selectedItem;

  bool _isLoading = false;
  bool _isDeleting = false;

  Future _setMainHouse() async {
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

  Future _clearPositions() async {
    _markers.clear();
    _circles.clear();
    _polylines.clear();
    _polygon.clear();
    _polygonsPoints.clear();
    await _setMainHouse();
  }

  Future _processLocationsJson({bool clearAll = true}) async {
    if (clearAll) {
      await _clearPositions();
    }
    for (var item in _items) {
      switch (item.type) {
        case kEstablishmentTypeKey:
          // draw main house position
          double? latitude =
              item.additionalInfo?['mainHousePosition']?['marker']?['latitude'];
          double? longitude = item.additionalInfo?['mainHousePosition']
              ?['marker']?['longitude'];
          if (latitude != null && longitude != null) {
            LatLng position = LatLng(latitude, longitude);
            await _setMarker(position, item.id.id, item.type!);
          }
          //draw establishment area
          List<LatLng> polygonPoints =
              (item.additionalInfo?['position']?['polygon'] ?? [])
                  .map<LatLng>((point) {
            return LatLng(point['latitude'], point['longitude']);
          }).toList();
          _setPolygon(polygonPoints, item.id.id);
          break;
        case kGatewayTypeKey:
        case kWaterLevelType:
        case kTempAndHumidityType:
        case kControllerType:
          double? latitude =
              item.additionalInfo?['position']?['marker']?['latitude'];
          double? longitude =
              item.additionalInfo?['position']?['marker']?['longitude'];
          if (latitude != null && longitude != null) {
            LatLng position = LatLng(latitude, longitude);
            await _setMarker(position, item.id.id, item.type!);
          }
          break;
        case kPaddockTypeKey:
          List<LatLng> polygonPoints =
              (item.additionalInfo?['position']?['polygon'] ?? [])
                  .map<LatLng>((point) {
            return LatLng(point['latitude'], point['longitude']);
          }).toList();
          _setPolygon(polygonPoints, item.id.id,
              fillColor: Colors.green.withOpacity(0.5),
              strokeColor: Colors.green);
          break;
        case kWaterFontTypeKey:
        case kShadowTypeKey:
          final fillColor = item.type == kWaterFontTypeKey
              ? Colors.blue.withOpacity(0.5)
              : Colors.grey.withOpacity(0.5);
          final strokeColor =
              item.type == kWaterFontTypeKey ? Colors.blue : Colors.grey;
          String type = (item.additionalInfo?['position'] as Map).keys.first;
          switch (type) {
            case 'marker':
              double? latitude =
                  item.additionalInfo?['position']?['marker']?['latitude'];
              double? longitude =
                  item.additionalInfo?['position']?['marker']?['longitude'];
              if (latitude != null && longitude != null) {
                LatLng position = LatLng(latitude, longitude);
                await _setMarker(position, item.id.id, item.type!);
              }
              break;
            case 'polygon':
              List<LatLng> polygonPoints =
                  (item.additionalInfo?['position']?['polygon'] as List)
                      .map<LatLng>((point) {
                return LatLng(point['latitude'], point['longitude']);
              }).toList();
              _setPolygon(polygonPoints, item.id.id,
                  fillColor: fillColor, strokeColor: strokeColor);
              break;
            case 'circle':
              LatLng position = LatLng(
                  item.additionalInfo?['position']?['circle']['latitude'],
                  item.additionalInfo?['position']?['circle']['longitude']);
              double radius =
                  item.additionalInfo?['position']?['circle']['radius'];
              _setCircle(position, radius, item.id.id,
                  fillColor: fillColor, strokeColor: strokeColor);
              break;
            case 'polyline':
              List<LatLng> polygonPoints =
                  (item.additionalInfo?['position']?['polyline'] as List)
                      .map<LatLng>((point) {
                return LatLng(point['latitude'], point['longitude']);
              }).toList();
              _setPolyline(polygonPoints, item.id.id, color: strokeColor);
              break;
            default:
              break;
          }
          break;
        case kEarTagType:
          TelemetryModel? latitudeTimeSerie;
          TelemetryModel? longitudeTimeSerie;
          try {
            latitudeTimeSerie = item.latestValues
                ?.firstWhere((element) => element.key == 'latitude');
            longitudeTimeSerie = item.latestValues
                ?.firstWhere((element) => element.key == 'longitude');
          } catch (e) {
            latitudeTimeSerie = null;
            longitudeTimeSerie = null;
          }

          if (latitudeTimeSerie != null && longitudeTimeSerie != null) {
            double latitude = double.parse(latitudeTimeSerie.value);
            double longitude = double.parse(longitudeTimeSerie.value);
            LatLng position = LatLng(latitude, longitude);
            await _setMarker(position, item.id.id, item.type!);
          }
          break;
        default:
          break;
      }
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
        for (EntityModel asset in _items) {
          if (asset.id.id == markerId) {
            setState(() {
              _selectedItem = asset;
            });
            return;
          }
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
        onTap: () {
          for (EntityModel asset in _items) {
            if (asset.id.id == polygonId) {
              setState(() {
                _selectedItem = asset;
              });
              return;
            }
          }
        }));
  }

  void _setCircle(LatLng position, double radius, String circleId,
      {Color? fillColor, Color? strokeColor}) {
    _circles.add(Circle(
        circleId: CircleId('circle_$circleId'),
        center: position,
        radius: radius,
        fillColor: fillColor ?? Colors.redAccent.withOpacity(0.5),
        strokeWidth: 3,
        strokeColor: strokeColor ?? Colors.redAccent,
        consumeTapEvents: true,
        onTap: () {
          for (EntityModel asset in _items) {
            if (asset.id.id == circleId) {
              setState(() {
                _selectedItem = asset;
              });
              return;
            }
          }
        }));
  }

  void _setPolyline(List<LatLng> polyLinePoints, String polyLineId,
      {Color? color}) {
    _polylines.add(Polyline(
        polylineId: PolylineId('polyline_$polyLineId'),
        points: polyLinePoints,
        color: color ?? Colors.greenAccent,
        width: 3,
        geodesic: true,
        consumeTapEvents: true,
        onTap: () {
          for (EntityModel asset in _items) {
            if (asset.id.id == polyLineId) {
              setState(() {
                _selectedItem = asset;
              });
              return;
            }
          }
        }));
  }

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedEntity;
    _initializePosition = _initPosition();
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
          log('my position get successfully');
        }
      }
    }

    if(_selectedItem != null){
      _items = [_selectedItem!];
      await _processLocationsJson();
      LatLng? position = _getSelectedItemPosition();
      if (position != null) {
        kInitialPosition = CameraPosition(
          target: position,
          zoom: 19,
        );
        log('set selected item position');
      }
    }
    _currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    if (_currentEstablishment?.additionalInfo?['mainHousePosition'] != null) {
      double latitude = _currentEstablishment!
          .additionalInfo!['mainHousePosition']['marker']['latitude'];
      double longitude = _currentEstablishment!
          .additionalInfo!['mainHousePosition']['marker']['longitude'];
      LatLng position = LatLng(latitude, longitude);
      kInitialPosition ??= CameraPosition(
        target: position,
        zoom: 14,
      );
      log('set current establishment position if null');
      await _setMainHouse();
    } else {
      kInitialPosition ??= CameraPosition(
        target: myPosition,
        zoom: 14,
      );
    }
    log('camera position initialized to ${kInitialPosition?.target.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final childWidth = width * 0.3 > 350.0 ? 350.0 : width * 0.3;
      return FutureBuilder(
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
          log('map built');
          return MultiBlocListener(
            listeners: [
              BlocListener<AppStateCubit, AppState>(
                listener: (context, state) async {
                  log('entered to AppState listener with state value of: ${state.toString()}');
                  if (state is AppStateUpdatedCurrentEstablishment ||
                      state is AppStateRestored) {
                    _currentEstablishment = state
                            is AppStateUpdatedCurrentEstablishment
                        ? state.establishment
                        : context.read<AppStateCubit>().currentEstablishment;
                    double latitude = _currentEstablishment!
                            .additionalInfo!['mainHousePosition']['marker']
                        ['latitude'];
                    double longitude = _currentEstablishment!
                            .additionalInfo!['mainHousePosition']['marker']
                        ['longitude'];
                    LatLng position = LatLng(latitude, longitude);
                    kInitialPosition = CameraPosition(
                      target: position,
                      zoom: 14,
                    );
                    log('camera position updated to $position');
                    await _clearPositions();
                    GoogleMapController controller = await _controller.future;
                    controller.animateCamera(
                        CameraUpdate.newCameraPosition(kInitialPosition!));
                    if (_selectedAssetTypes.isNotEmpty ||
                        _selectedDeviceTypes.isNotEmpty) {
                      if (mounted) {
                        context.read<MapFilterCubit>().getEntities(
                            assets: _selectedAssetTypes,
                            devices: _selectedDeviceTypes,
                            parentId: _currentEstablishment!.id.id);
                      }
                    } else {
                      if (mounted) {
                        context.read<MapFilterCubit>().refreshMap();
                      }
                    }
                  }
                  if (state is AppStateAssetCreated ||
                      state is AppStateDeviceClaimed) {
                    if ((_selectedAssetTypes.isNotEmpty ||
                            _selectedDeviceTypes.isNotEmpty) &&
                        mounted &&
                        _currentEstablishment != null) {
                      context.read<MapFilterCubit>().getEntities(
                          assets: _selectedAssetTypes,
                          devices: _selectedDeviceTypes,
                          parentId: _currentEstablishment!.id.id);
                    }
                  }
                },
              ),
              BlocListener<DevicesCubit, DevicesState>(
                listener: (context, state) async {
                  if (_isDeleting) {
                    _isDeleting = false;
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                  if (state is DevicesLoading) {
                    _isDeleting = true;
                    MyDialogs.showLoadingDialog(
                        context,
                        'loadingDeleteAsset'
                            .tr(args: [_selectedItem?.type ?? '']));
                  }
                  if (state is DevicesSuccess) {
                    MyDialogs.showSuccessDialog(
                        context,
                        'deleteAssetSuccess'
                            .tr(args: [_selectedItem?.type ?? '']));
                    _items.remove(_selectedItem);
                    _selectedItem = null;
                    await _processLocationsJson();
                    if (mounted) {
                      context.read<MapFilterCubit>().refreshMap();
                    }
                  }
                  if (state is DevicesFail && mounted) {
                    MyDialogs.showErrorDialog(context, state.message);
                  }
                },
              ),
              BlocListener<ListAssetsCubit, ListAssetsState>(
                listener: (context, state) async {
                  if (_isDeleting) {
                    _isDeleting = false;
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                  if (state is ListAssetsLoading) {
                    _isDeleting = true;
                    MyDialogs.showLoadingDialog(
                        context,
                        'loadingDeleteAsset'
                            .tr(args: [_selectedItem?.type ?? '']));
                  }
                  if (state is ListAssetsSuccess) {
                    MyDialogs.showSuccessDialog(
                        context,
                        'deleteAssetSuccess'
                            .tr(args: [_selectedItem?.type ?? '']));
                    _items.remove(_selectedItem);
                    _selectedItem = null;
                    await _processLocationsJson();
                    if (mounted) {
                      context.read<MapFilterCubit>().refreshMap();
                    }
                  }
                  if (state is ListAssetsFail && mounted) {
                    MyDialogs.showErrorDialog(context, state.message);
                  }
                },
              )
            ],
            child: BlocConsumer<MapFilterCubit, MapFilterState>(
              listener: (context, state) async {
                if (_isLoading) {
                  Navigator.of(context, rootNavigator: true).pop();
                  _isLoading = false;
                }
                if (state is MapFilterLoading) {
                  _isLoading = true;
                  MyDialogs.showLoadingDialog(
                      context, 'gettingAssetsData'.tr());
                  return;
                }
                if (state is MapFilterFail) {
                  MyDialogs.showErrorDialog(context, state.message);
                  return;
                }
                if (state is MapFilterSuccess) {
                  _items = state.items;
                  await _processLocationsJson();
                  await _setMainHouse();
                  if (mounted) {
                    context.read<MapFilterCubit>().refreshMap();
                  }
                  return;
                }
                if (state is MapFilterItemSelected) {
                  final value = state.item;
                  if (!_items.contains(value)) {
                    _items.add(value);
                  }
                  await _processLocationsJson();
                  setState(() {
                    _selectedItem = value;
                  });
                  LatLng? position = _getSelectedItemPosition();
                  if (position != null) {
                    final cameraPosition = CameraPosition(
                      target: position,
                      zoom: 19,
                    );
                    GoogleMapController controller = await _controller.future;
                    controller.animateCamera(
                        CameraUpdate.newCameraPosition(cameraPosition));
                  }
                }
              },
              buildWhen: (previous, current) =>
                  current is MapFilterSuccess || current is MapFilterInitial,
              builder: (context, state) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    GoogleMap(
                      mapType: MapType.hybrid,
                      initialCameraPosition: kInitialPosition!,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                      markers: _markers,
                      polygons: _polygon,
                      circles: _circles,
                      polylines: _polylines,
                      onTap: (position) {},
                    ),
                   Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: SizedBox(
                                width: childWidth,
                                child: widget.child),
                          )),

                    Positioned(
                      top: 24,
                      left: childWidth + 48,
                      child: PointerInterceptor(
                        child: SizedBox(
                          height: 80,
                          width: width - childWidth - 48,
                          child: Wrap(
                            runSpacing: 10,
                            spacing: 10,
                            children: _types
                                .map(
                                  (e) => Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 250),
                                    child: ChoiceChip(
                                      backgroundColor: Colors.white,
                                      selectedColor: kPrimaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      label: Text(
                                        e,
                                        style: TextStyle(
                                            color: _selectedAssetTypes
                                                        .contains(e) ||
                                                    _selectedDeviceTypes
                                                        .contains(e)
                                                ? Colors.white
                                                : kSecondaryColor,
                                            fontSize: 12),
                                      ).tr(),
                                      selected:
                                          _selectedAssetTypes.contains(e) ||
                                              _selectedDeviceTypes.contains(e),
                                      onSelected: (value) async {
                                        bool process = true;
                                        if (_currentEstablishment == null) {
                                          process = await showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      BlocProvider(
                                                        create: (context) =>
                                                            injector<
                                                                EstablishmentsCubit>(),
                                                        child:
                                                            const SelectEstablishmentDialog(),
                                                      )) ??
                                              false;
                                        }
                                        if (process && mounted) {
                                          if (value) {
                                            _addSelectedType(e);
                                            context
                                                .read<MapFilterCubit>()
                                                .getEntities(
                                                    parentId:
                                                        _currentEstablishment!
                                                            .id.id,
                                                    assets: _selectedAssetTypes,
                                                    devices:
                                                        _selectedDeviceTypes);
                                          } else {
                                            List<EntityModel> newItems = [];
                                            for (var a in _items) {
                                              if (a.type != e) {
                                                newItems.add(a);
                                              }
                                            }
                                            _items = newItems;
                                            await _processLocationsJson();
                                            await _setMainHouse();
                                            _removeSelectedType(e);
                                            if (mounted) {
                                              context
                                                  .read<MapFilterCubit>()
                                                  .refreshMap();
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedItem != null)
                      Positioned(
                          bottom: 20,
                          right: 56,
                          child: BlocProvider(
                            create: (context) =>
                                injector<DeviceLastTelemetryCubit>(),
                            child: AssetMapDetailsWidget(
                              asset: _selectedItem!,
                              onClose: () {
                                setState(() {
                                  _selectedItem = null;
                                });
                              },
                              onEdit: () async {
                                bool result = false;
                                if (_selectedItem?.id.entityType == 'DEVICE') {
                                  result = await context.pushNamed<bool>(
                                          kDeviceDetailsPageRoute,
                                          extra: _selectedItem) ??
                                      false;
                                } else {
                                  switch (_selectedItem!.type) {
                                    case kGatewayTypeKey:
                                      result = await context.pushNamed<bool>(
                                              kEditGatewayPageRoute,
                                              extra: _selectedItem) ??
                                          false;
                                      break;
                                    case kPaddockTypeKey:
                                      result = await context.pushNamed<bool>(
                                              kEditPaddockPageRoute,
                                              extra: _selectedItem) ??
                                          false;
                                      break;
                                    case kWaterFontTypeKey:
                                      result = await context.pushNamed<bool>(
                                              kEditWaterFontPageRoute,
                                              extra: _selectedItem) ??
                                          false;
                                      break;
                                    case kShadowTypeKey:
                                      result = await context.pushNamed<bool>(
                                              kEditShadowPageRoute,
                                              extra: _selectedItem) ??
                                          false;
                                      break;
                                    case kBatchTypeKey:
                                      result = await context.pushNamed<bool>(
                                              kEditBatchPageRoute,
                                              extra: _selectedItem) ??
                                          false;
                                      break;
                                    case kAnimalTypeKey:
                                      result = await context.pushNamed<bool>(
                                              kEditAnimalPageRoute,
                                              extra: _selectedItem) ??
                                          false;
                                      break;
                                    case kRotationTypeKey:
                                      result = await context.pushNamed<bool>(
                                              kEditRotationPageRoute,
                                              extra: _selectedItem) ??
                                          false;
                                      break;
                                    default:
                                      break;
                                  }
                                }
                                if (result && mounted) {
                                  context.read<MapFilterCubit>().getEntities(
                                      parentId: _currentEstablishment!.id.id,
                                      assets: _selectedAssetTypes,
                                      devices: _selectedDeviceTypes);
                                }
                              },
                              onDelete: () async {
                                if (_selectedItem?.id.entityType == 'DEVICE') {
                                  bool result =
                                      await MyDialogs.showQuestionDialog(
                                            context: context,
                                            title: 'removeDevice'.tr(args: [
                                              _selectedItem?.type?.tr() ?? ''
                                            ]),
                                            message: 'removeDeviceMessage'
                                                .tr(namedArgs: {
                                              "deviceType":
                                                  _selectedItem?.type?.tr() ??
                                                      '',
                                              "deviceName":
                                                  _selectedItem?.label ?? ''
                                            }),
                                          ) ??
                                          false;
                                  if (result && mounted) {
                                    context
                                        .read<DevicesCubit>()
                                        .removeDevice(_selectedItem!.name);
                                  }
                                } else {
                                  bool result =
                                      await MyDialogs.showQuestionDialog(
                                            context: context,
                                            title: 'delete'.tr(args: [
                                              _selectedItem?.type ?? '',
                                              _selectedItem?.label ?? ''
                                            ]),
                                            message: 'deleteMessage'.tr(args: [
                                              _selectedItem?.type ?? '',
                                              _selectedItem?.label ?? ''
                                            ]),
                                          ) ??
                                          false;
                                  if (result && mounted) {
                                    context
                                        .read<ListAssetsCubit>()
                                        .deleteAsset(_selectedItem!.id.id);
                                  }
                                }
                              },
                            ),
                          )),
                  ],
                );
              },
            ),
          );
        },
      );
    });
  }

  void _addSelectedType(String type) {
    if (type == kGatewayTypeKey ||
        type == kPaddockTypeKey ||
        type == kWaterFontTypeKey ||
        type == kShadowTypeKey) {
      _selectedAssetTypes.add(type);
    } else {
      _selectedDeviceTypes.add(type);
    }
  }

  void _removeSelectedType(String type) {
    _selectedAssetTypes.remove(type);
    _selectedDeviceTypes.remove(type);
  }

  LatLng? _getSelectedItemPosition() {
    switch (_selectedItem?.type) {
      case kEstablishmentTypeKey:
      case kGatewayTypeKey:
      case kWaterLevelType:
      case kTempAndHumidityType:
      case kControllerType:
        double latitude =
            _selectedItem!.additionalInfo?['position']?['marker']?['latitude'];
        double longitude =
            _selectedItem!.additionalInfo?['position']?['marker']?['longitude'];
        return LatLng(latitude, longitude);
      case kPaddockTypeKey:
        List<LatLng> polygonPoints =
            (_selectedItem!.additionalInfo?['position']?['polygon'] ?? [])
                .map<LatLng>((point) {
          return LatLng(point['latitude'], point['longitude']);
        }).toList();
        return polygonPoints.first;
      case kWaterFontTypeKey:
      case kShadowTypeKey:
        String type =
            (_selectedItem!.additionalInfo?['position'] as Map).keys.first;
        switch (type) {
          case 'marker':
            double latitude = _selectedItem!.additionalInfo?['position']
                ?['marker']?['latitude'];
            double longitude = _selectedItem!.additionalInfo?['position']
                ?['marker']?['longitude'];
            return LatLng(latitude, longitude);
          case 'polygon':
            List<LatLng> polygonPoints =
                (_selectedItem!.additionalInfo?['position']?['polygon'] as List)
                    .map<LatLng>((point) {
              return LatLng(point['latitude'], point['longitude']);
            }).toList();
            return polygonPoints.first;
          case 'circle':
            return LatLng(
                _selectedItem!.additionalInfo?['position']?['circle']
                    ['latitude'],
                _selectedItem!.additionalInfo?['position']?['circle']
                    ['longitude']);
          case 'polyline':
            List<LatLng> polygonPoints = (_selectedItem!
                    .additionalInfo?['position']?['polyline'] as List)
                .map<LatLng>((point) {
              return LatLng(point['latitude'], point['longitude']);
            }).toList();
            return polygonPoints.first;
          default:
            return null;
        }
      default:
        return null;
    }
  }
}
