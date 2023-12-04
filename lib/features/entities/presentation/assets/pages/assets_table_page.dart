import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';
import 'package:trackeano_web_app/config/themes/colors.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/resources/destinations.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../../common_widgets/widgets.dart';
import '../cubits/cubits.dart';

class AssetsTablePage extends StatefulWidget {
  final String type;

  const AssetsTablePage({super.key, required this.type});

  @override
  State<AssetsTablePage> createState() => _AssetsTablePageState();
}

class _AssetsTablePageState extends State<AssetsTablePage> {
  final PagingController<int, EntitySearchModel> _pagingController =
      PagingController(firstPageKey: 0);
  EntityModel? currentEstablishment;

  final int _rowsPerPage = 50;

  String? _search;

  int? nextPage;
  int pageSize = 50;
  int total = 0;

  bool _isLoading = false;

  void _getPage(int page) {
    context.read<ListAssetsCubit>().getPagedAssets(
        page, widget.type, currentEstablishment!.id.id,
        search: _search, pageSize: _rowsPerPage);
  }

  @override
  void initState() {
    currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    if (currentEstablishment != null) {
      _pagingController.addPageRequestListener((pageKey) {
        _getPage(pageKey);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppStateCubit, AppState>(
      listener: (context, state) {
        if (state is AppStateAssetCreated) {
          _pagingController.refresh();
        }
      },
      child: LayoutBuilder(builder: (context, constraints) {
        double tableWidth = constraints.maxWidth - 40;
        double headerHeight = 40;
        double tableHeight = constraints.maxHeight - headerHeight - 12;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: headerHeight,
                          height: headerHeight,
                          child: CustomElevatedButton(
                              padding: EdgeInsets.zero,
                              backgroundColor: kSecondaryColor,
                              onPressed: () {
                                context.goNamed(kMapEditAssetPageRoute,
                                    queryParameters: {
                                      'type': widget.type,
                                      'fromTable': '1'
                                    });
                              },
                              child: const Icon(
                                Ionicons.add_outline,
                                color: Colors.white,
                              )),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        SizedBox(
                          width: headerHeight,
                          height: headerHeight,
                          child: CustomElevatedButton(
                              padding: EdgeInsets.zero,
                              backgroundColor: kSecondaryColor,
                              onPressed: () {
                                context.goNamed(
                                    allDestinations
                                        .firstWhere(
                                            (element) =>
                                                element.type == widget.type,
                                            orElse: () => allDestinations.first)
                                        .path,
                                    queryParameters: {'type': widget.type});
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                    'assets/icons/return_white_icon.png'),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 200,
                      height: headerHeight,
                      child: TextField(
                        onChanged: (value) {
                          Debouncer deb = Debouncer(milliseconds: 500);
                          deb.run(() {
                            _search = value;
                            _getPage(0);
                          });
                        },
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'search'.tr(),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                              'assets/icons/search_grey.png',
                              width: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BlocConsumer<ListAssetsCubit, ListAssetsState>(
                  listener: (context, state) {
                if (_isLoading) {
                  _isLoading = false;
                  Navigator.of(context, rootNavigator: true).pop();
                }
                if (state is ListAssetsLoading) {
                  _isLoading = true;
                  MyDialogs.showLoadingDialog(
                      context, 'loadingDeleteAsset'.tr(args: [widget.type]));
                }
                if (state is ListAssetsSuccess) {
                  MyDialogs.showSuccessDialog(
                      context, 'deleteAssetSuccess'.tr(args: [widget.type]));
                  _pagingController.refresh();
                }
                if (state is ListAssetsFail) {
                  MyDialogs.showErrorDialog(context, state.message);
                }
              }, builder: (context, state) {
                if (state is ListAssetsNewPage) {
                  _pagingController.value = PagingState(
                    nextPageKey: state.pageKey,
                    error: state.error,
                    itemList: state.items,
                  );
                  total = state.total!;
                }
                return TableWidget(
                  pagingController: _pagingController,
                  entityInfo: _getAssetColumns(),
                  tableWidth: tableWidth,
                  itemsCount: total,
                  maxHeight: tableHeight,
                  details: (item) {
                    context.goNamed(kMapPageRoute, extra: item.toEntityModel());
                  },
                  onEdit: (asset) async {
                    context.goNamed(kMapEditAssetPageRoute,
                        extra: asset.toEntityModel(),
                        queryParameters: {'fromTable': '1'});
                  },
                  onDelete: (asset) async {
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
              })
            ],
          ),
        );
      }),
    );
  }

  List<String> _getAssetColumns() {
    switch (widget.type) {
      case kAnimalTypeKey:
        return ["batchName", "type", "category", "race", "birthday"];
      case kBatchTypeKey:
        return [
          "lotType",
          "lotCategory",
          "birthday",
          "lotRace",
          "totalAnimals"
        ];
      case kGatewayTypeKey:
        return ["id"];
      case kPaddockTypeKey:
        return ["totalArea", "usableArea"];
      case kRotationTypeKey:
        return [
          "parcelLabel",
          "lotLabel",
          "startDate",
          "endDate",
          "recurrence",
          "recurrenceEndTime"
        ];
      case kShadowTypeKey:
        return ["totalArea"];
      case kWaterFontTypeKey:
        return ["volume", "type"];
      default:
        return [];
    }
  }
}
