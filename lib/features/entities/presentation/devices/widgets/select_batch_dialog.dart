import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../../injector.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../../data/models/models.dart';
import '../../assets/cubits/cubits.dart';
import '../../assets/widgets/widgets.dart';

class SelectBatchDialog extends StatefulWidget {
  const SelectBatchDialog({super.key});

  @override
  State<SelectBatchDialog> createState() => _SelectBatchDialogState();
}

class _SelectBatchDialogState extends State<SelectBatchDialog> {
  final PagingController<int, EntitySearchModel> _pagingController =
  PagingController(firstPageKey: 0);

  EntityModel? _currentEstablishment;
  EntitySearchModel? _selectedBatch;
  String? _selectedBatchName;

  String _search = '';

  @override
  void initState() {
    _currentEstablishment = context
        .read<AppStateCubit>()
        .currentEstablishment;
    _pagingController.addPageRequestListener((pageKey) {
      context.read<ListAssetsCubit>().getPagedAssets(
          pageKey, kBatchTypeKey, _currentEstablishment!.id.id,
          search: _search);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 50, 16.0, 16.0),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text(
                      'selectBatch',
                      style: TextStyle(
                          color: kSecondaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ).tr(),
                    CustomTextField(
                      label: '',
                      hint: 'search'.tr(),
                      onSave: (value) {},
                      onChange: (value) {
                        Debouncer deb = Debouncer(milliseconds: 500);
                        deb.run(() {
                          _search = value;
                          _pagingController.refresh();
                        });
                      },
                    ),
                    SizedBox(
                      height: 300,
                      child: BlocBuilder<ListAssetsCubit, ListAssetsState>(
                        builder: (context, state) {
                          if (state is ListAssetsNewPage) {
                            _pagingController.value = PagingState(
                              nextPageKey: state.pageKey,
                              error: state.error,
                              itemList: state.items,
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () =>
                                Future.sync(() {
                                  _pagingController.refresh();
                                }),
                            child: PagedListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              pagingController: _pagingController,
                              separatorBuilder: (context, index) =>
                              const Divider(
                                height: 20,
                              ),
                              builderDelegate: PagedChildBuilderDelegate<
                                  EntitySearchModel>(
                                  itemBuilder: (context, asset, index) {
                                    if (_selectedBatchName ==
                                        asset.latest.name) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((timeStamp) {
                                        setState(() {
                                          _selectedBatch = asset;
                                        });
                                      });
                                    }
                                    return ListTile(
                                      onTap: () {
                                        setState(() {
                                          _selectedBatch = asset;
                                        });
                                      },
                                      title: Text(
                                        asset.latest.label,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      selected: _selectedBatch == asset,
                                      selectedColor: kAlternate,
                                    );
                                  },
                                  firstPageErrorIndicatorBuilder: (context) =>
                                      FirstPageErrorWidget(
                                        message:
                                        _pagingController.error.toString(),
                                        onRetry: () {
                                          _pagingController.refresh();
                                        },
                                      ),
                                  newPageErrorIndicatorBuilder: (context) =>
                                      NewPageErrorWidget(
                                        message:
                                        _pagingController.error.toString(),
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
                                    height: 200,
                                  )),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 120,
                          child: CustomElevatedButton(
                            borderRadius: 10,
                            onPressed: _selectedBatch == null
                                ? null
                                : () async {
                              Navigator.pop(context);
                              await context.pushNamed(
                                  kAddEarTagByBatchPageRoute,
                                  extra: _selectedBatch!);
                            },
                            child: const Text('select').tr(),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 120,
                          child: CustomElevatedButton(
                              borderRadius: 10,
                              backgroundColor: kSecondaryColor,
                              child: const Text('addBatch').tr(),
                              onPressed: () async {
                                EntityModel? result =
                                await showDialog<EntityModel?>(
                                    context: context,
                                    builder: (context) =>
                                        DialogContainer(
                                            child: MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                  create: (context) =>
                                                      injector<AssetsCubit>(),
                                                ),
                                                BlocProvider(
                                                  create: (context) =>
                                                      injector<DropdownCubit>(),
                                                ),
                                              ],
                                              child: const EditAssetContainer(
                                                entityType: kBatchTypeKey,
                                              ),
                                            )));
                                if (result != null && mounted) {
                                  _pagingController.refresh();
                                  _selectedBatchName = result.name;
                                }
                              }),
                        )
                      ],
                    )
                  ]),
                ),
                Positioned(
                    top: 16,
                    right: 16,
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircleButton(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Ionicons.close_outline,
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
    );
  }
}
