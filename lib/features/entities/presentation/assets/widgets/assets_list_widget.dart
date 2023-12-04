import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/resources/constants.dart';
import '../../../data/models/models.dart';
import '../cubits/cubits.dart';
import 'widgets.dart';

class AssetsListWidget extends StatefulWidget {
  final String type;

  const AssetsListWidget({super.key, required this.type});

  @override
  State<AssetsListWidget> createState() => _AssetsListWidgetState();
}

class _AssetsListWidgetState extends State<AssetsListWidget> {
  EntityModel? currentEstablishment;

  bool _isLoading = false;

  DateTime? _dateFilter;

  late String assetType;

  void _getAssets() => context.read<ListAssetsCubit>().getAssets(
        assetType,
        currentEstablishment!.id.id,
        dateFilter: _dateFilter?.millisecondsSinceEpoch,
      );

  @override
  void initState() {
    currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    assetType = widget.type;
    _getAssets();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AssetsListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    assetType = widget.type;
    _getAssets();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.type == kRotationTypeKey)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: TableCalendar(
                firstDay: now.copyWith(month: 1, day: 1),
                lastDay: now.copyWith(month: 12, day: 31),
                focusedDay: _dateFilter ?? now,
                calendarFormat: CalendarFormat.week,
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(selectedDay, _dateFilter)) {
                    setState(() {
                      _dateFilter = selectedDay;
                    });
                  } else {
                    setState(() {
                      _dateFilter = null;
                    });
                  }
                  _getAssets();
                },
                selectedDayPredicate: (day) => isSameDay(_dateFilter, day),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  leftChevronIcon: Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                            BorderSide(color: kInputDefaultBorderColor))),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Ionicons.chevron_back_outline,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                  rightChevronIcon: Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                            BorderSide(color: kInputDefaultBorderColor))),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Ionicons.chevron_forward_outline,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
                calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                        color: kPrimaryColor, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                        color: kSecondaryColor, shape: BoxShape.circle)),
                onHeaderTapped: (date) {
                  showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().copyWith(month: 1, day: 1),
                      lastDate: DateTime.now().copyWith(month: 12, day: 31),
                      initialDatePickerMode: DatePickerMode.year);
                },
              ),
            ),
          ),
        BlocListener<AppStateCubit, AppState>(
          listener: (context, state) {
            if (state is AppStateAssetCreated && state.type == widget.type) {
              _getAssets();
            }
          },
          child: BlocConsumer<ListAssetsCubit, ListAssetsState>(
            listener: (context, state) {
              if (_isLoading) {
                _isLoading = false;
                Navigator.of(context, rootNavigator: true).pop();
              }
              if (state is ListAssetsDeleteLoading) {
                _isLoading = true;
                MyDialogs.showLoadingDialog(
                    context, 'loading'.tr(args: [widget.type]));
              }
              if (state is ListAssetsSuccess) {
                MyDialogs.showSuccessDialog(
                    context, 'deleteAssetSuccess'.tr(args: [widget.type]));
                _getAssets();
              }
              if (state is ListAssetsFail) {
                MyDialogs.showErrorDialog(context, state.message);
              }
            },
            builder: (context, state) {
              if (state is ListAssetsLoading) {
                return const SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: kPrimaryColor,
                    ),
                  ),
                );
              }
              List<EntitySearchModel> items = [];
              if (state is ListAssetsNewPage) {
                items = state.items;
              }
              return Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: RefreshIndicator(
                    onRefresh: () => Future.sync(() {
                      _getAssets();
                    }),
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final asset = items[index];
                          final child = AssetListTile(
                            asset: asset,
                            onEdit: () async {
                              bool result = await context.pushNamed<bool>(
                                      kMapEditAssetPageRoute,
                                      extra: asset.toEntityModel()) ??
                                  false;

                              if (result && mounted) {
                                _getAssets();
                              }
                            },
                            onDelete: () async {
                              bool result = await MyDialogs.showQuestionDialog(
                                    context: context,
                                    title: 'delete'.tr(args: [
                                      asset.latest.type ?? '',
                                      asset.latest.label
                                    ]),
                                    message: 'deleteMessage'.tr(args: [
                                      asset.latest.type ?? '',
                                      asset.latest.label
                                    ]),
                                  ) ??
                                  false;
                              if (result && mounted) {
                                context
                                    .read<ListAssetsCubit>()
                                    .deleteAsset(asset.entityId.id);
                              }
                            },
                          );
                          return index == items.length - 1
                              ? const SizedBox(
                                  height: 20,
                                )
                              : child;
                        }),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
