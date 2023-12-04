import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/utils/utils.dart';
import '../../../../../injector.dart';
import '../../../data/models/models.dart';
import '../../assets/cubits/cubits.dart';
import '../cubits/cubits.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

class AddEarTagByBatchPage extends StatefulWidget {
  final EntitySearchModel batch;

  const AddEarTagByBatchPage({super.key, required this.batch});

  @override
  State<AddEarTagByBatchPage> createState() => _AddEarTagByBatchPageState();
}

class _AddEarTagByBatchPageState extends State<AddEarTagByBatchPage> {
  final PagingController<int, EntitySearchModel> _pagingController =
      PagingController(firstPageKey: 0);

  Map<String, dynamic>? info = {};

  @override
  void initState() {
    info = widget.batch.latest.additionalInfo;
    _pagingController.addPageRequestListener((pageKey) {
      context.read<DevicesCubit>().getPagedDevicesByParent(
          pageKey, '', kEarTagType, widget.batch.entityId.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: kPrimaryBackground,
      elevation: 5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 40),
                sliver: SliverAppBar(
                  elevation: 0.0,
                  backgroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  pinned: true,
                  centerTitle: true,
                  title: SizedBox(
                    width: MediaQuery.of(context).size.width - (2 * 84) - 16,
                    child: const Text(
                      'addEarTagsByBatch',
                      style: TextStyle(
                          color: kSecondaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ).tr(),
                  ),
                  bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(164),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0.0),
                        child: Column(
                          children: [
                            Card(
                              margin: EdgeInsets.zero,
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Column(
                                  children: [
                                    Row(children: [
                                      SizedBox(
                                        height: 50,
                                        width: 60,
                                        child:
                                            Utils.getDeviceIcon(kBatchTypeKey),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text('${'batch'.tr()}: ',
                                                    style: const TextStyle(
                                                        color: kSecondaryText,
                                                        fontSize: 12)),
                                                Expanded(
                                                    child: Text(
                                                  widget.batch.latest.label,
                                                  style: const TextStyle(
                                                      color: kSecondaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                  textAlign: TextAlign.right,
                                                ))
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text('${'type'.tr()}: ',
                                                    style: const TextStyle(
                                                        color: kSecondaryText,
                                                        fontSize: 12)),
                                                Expanded(
                                                  child: Text(
                                                    info?['lotType'] ?? '',
                                                    style: const TextStyle(
                                                        color: kSecondaryColor,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('${'category'.tr()}: ',
                                                    style: const TextStyle(
                                                        color: kSecondaryText,
                                                        fontSize: 12)),
                                                Expanded(
                                                  child: Text(
                                                      info?['lotCategory'] ??
                                                          '',
                                                      style: const TextStyle(
                                                          color:
                                                              kSecondaryColor,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                      textAlign:
                                                          TextAlign.right),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text('${'birthday'.tr()}: ',
                                                    style: const TextStyle(
                                                        color: kSecondaryText,
                                                        fontSize: 12)),
                                                Expanded(
                                                  child: Text(
                                                    info?['birthday']
                                                            ?.toString() ??
                                                        '',
                                                    style: const TextStyle(
                                                        color: kSecondaryColor,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('${'race'.tr()}: ',
                                                    style: const TextStyle(
                                                        color: kSecondaryText,
                                                        fontSize: 12)),
                                                Expanded(
                                                  child: Text(
                                                      info?['lotRace'] ?? '',
                                                      style: const TextStyle(
                                                          color:
                                                              kSecondaryColor,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                      textAlign:
                                                          TextAlign.right),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ]),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: SizedBox(
                                        width: 180,
                                        height: 30,
                                        child: CustomElevatedButton(
                                            onPressed: () => _addDevice(),
                                            borderRadius: 10,
                                            backgroundColor: kSecondaryColor,
                                            child: const Text(
                                              'addEarTag',
                                              textAlign: TextAlign.center,
                                            ).tr()),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      )),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 10),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: BlocListener<AppStateCubit, AppState>(
                  listener: (context, state) {
                    if (state is AppStateDeviceClaimed) {
                      _pagingController.refresh();
                    }
                  },
                  child: BlocBuilder<DevicesCubit, DevicesState>(
                    builder: (context, state) {
                      if (state is DevicesNewPage) {
                        _pagingController.value = PagingState(
                          nextPageKey: state.pageKey,
                          error: state.error,
                          itemList: state.searchDevices,
                        );
                      }
                      return PagedSliverList(
                        pagingController: _pagingController,
                        builderDelegate: PagedChildBuilderDelegate<
                                EntitySearchModel>(
                            itemBuilder: (context, device, index) =>
                                MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (context) =>
                                          injector<DeviceTelemetryCubit>(),
                                    ),
                                    BlocProvider(
                                      create: (context) =>
                                          injector<DeviceLastTelemetryCubit>(),
                                    ),
                                  ],
                                  child: DeviceListTile(
                                    searchDevice: device,
                                  ),
                                ),
                            firstPageErrorIndicatorBuilder: (context) =>
                                FirstPageErrorWidget(
                                  message: _pagingController.error.toString(),
                                  onRetry: () {
                                    _pagingController.refresh();
                                  },
                                ),
                            newPageErrorIndicatorBuilder: (context) =>
                                NewPageErrorWidget(
                                  message: _pagingController.error.toString(),
                                  onRetry: () {
                                    _pagingController.refresh();
                                  },
                                ),
                            noItemsFoundIndicatorBuilder: (context) =>
                                NoItemsFoundWidget(
                                  onRefresh: () {
                                    _pagingController.refresh();
                                  },
                                ),
                            noMoreItemsIndicatorBuilder: (context) =>
                                const SizedBox(
                                  height: 20,
                                )),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
          Positioned(
              top: 8,
              right: 8,
              child: SizedBox(
                height: 25,
                width: 25,
                child: CircleButton(
                  onTap: () {
                    context.goNamed(kMapPageRoute);
                  },
                  icon: const Icon(
                    Ionicons.close_outline,
                    color: kIconLightColor,
                    size: 18,
                  ),
                ),
              )),
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
    );
  }

  void _addDevice() async {
    bool result = await showDialog<bool?>(
            context: context,
            builder: (context) => DialogContainer(
                    child: MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (context) => injector<DevicesCubit>()),
                    BlocProvider(
                        create: (context) => injector<DropdownCubit>()),
                    BlocProvider(create: (context) => injector<AssetsCubit>()),
                  ],
                  child: ClaimEarTagPage(
                    batchInfo: widget.batch,
                  ),
                ))) ??
        false;
    if (mounted && result) {
      _pagingController.refresh();
    }
  }
}
