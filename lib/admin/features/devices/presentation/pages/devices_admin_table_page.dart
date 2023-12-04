import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../../../../features/entities/data/models/models.dart';
import '../../../../../features/entities/data/params/params.dart';
import '../../../../../features/entities/presentation/assets/cubits/cubits.dart';
import '../../../../../features/entities/presentation/devices/cubits/cubits.dart';
import '../../../../../features/main_screen/presentation/widgets/widgets.dart';
import '../../../main/widgets/widgets.dart';
import '../cubits/devices_list_cubit/devices_list_cubit.dart';

class DevicesAdminTablePage extends StatefulWidget {
  const DevicesAdminTablePage({super.key});

  @override
  State<DevicesAdminTablePage> createState() => _DevicesAdminTablePageState();
}

class _DevicesAdminTablePageState extends State<DevicesAdminTablePage> {
  final PagingController<int, EntityModel> _pagingController =
  PagingController(firstPageKey: 0);

  CustomerModel? _customer;

  DropdownSelectedState _customerState =
  const DropdownSelectedState(isLoading: false, error: false, items: []);

  Debouncer deb = Debouncer(milliseconds: 500);

  final int _rowsPerPage = 50;

  String _search = "";

  int? nextPage;
  int pageSize = 50;
  int total = 0;

  bool _isLoading = false;

  void _getPage(int page) {
    SearchEntityParams params = SearchEntityParams(
        page: page,
        pageSize: _rowsPerPage,
        search: _search,
        parentId: _customer?.id.id);
    context.read<DevicesListCubit>().getPagedDevices(params);
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _getPage(pageKey);
    });
    DropdownCubit cubit = context.read<DropdownCubit>();
    cubit.getCustomers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
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
                        // SizedBox(
                        //   width: headerHeight,
                        //   height: headerHeight,
                        //   child: Tooltip(
                        //     message: 'add'.tr(),
                        //     child: CustomElevatedButton(
                        //         padding: EdgeInsets.zero,
                        //         backgroundColor: kSecondaryColor,
                        //         onPressed: () async {
                        //           showDialog<UserModel?>(
                        //               context: context,
                        //               builder: (context) => DialogContainer(
                        //                 child: MultiBlocProvider(
                        //                   providers: [
                        //                     BlocProvider(
                        //                         create: (context) =>
                        //                             injector<UsersCubit>()),
                        //                     BlocProvider(
                        //                         create: (context) =>
                        //                             injector<
                        //                                 DropdownCubit>()),
                        //                   ],
                        //                   child:
                        //                   const AddUserContentWidget(),
                        //                 ),
                        //               )).then((value) {
                        //             if (value != null) {
                        //               _pagingController.refresh();
                        //               context.read<UsersCubit>().getActivationLink(value.id.id);
                        //             }
                        //           });
                        //         },
                        //         child: const Icon(
                        //           Ionicons.add_outline,
                        //           color: Colors.white,
                        //         )),
                        //   ),
                        // ),
                        // const SizedBox(
                        //   width: 10,
                        // ),
                        SizedBox(
                          width: headerHeight,
                          height: headerHeight,
                          child: Tooltip(
                            message: 'refresh'.tr(),
                            child: CustomElevatedButton(
                                padding: EdgeInsets.zero,
                                backgroundColor: kSecondaryColor,
                                onPressed: () => _pagingController.refresh(),
                                child: const Icon(
                                  Ionicons.refresh_outline,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 150,
                          height: headerHeight,
                          child: BlocSelector<DropdownCubit, DropdownState,
                              DropdownSelectedState>(
                            selector: (state) {
                              if (state.groupType == 'Customer') {
                                bool isLoading = state is DropdownLoading;
                                bool hasError = state is DropdownFail;
                                List<CustomerModel> customers = [
                                  CustomerModel(
                                      createdTime: 0,
                                      id: const EntityId(
                                          id: '', entityType: ''),
                                      name: '',
                                      title: 'all'.tr())
                                ];
                                if (state is DropdownSuccess) {
                                  customers.addAll(state.customersItems!);
                                }
                                if (state is DropdownFail) {
                                  customers = [];
                                }
                                _customerState = DropdownSelectedState(
                                    isLoading: isLoading,
                                    error: hasError,
                                    items: customers);
                                return _customerState;
                              }
                              return _customerState;
                            },
                            builder: (context, state) {
                              return CustomDropDown<CustomerModel>(
                                allowNullValue: true,
                                initialValue: _customer,
                                items: state.items as List<CustomerModel>,
                                hint: 'customer'.tr(),
                                isLoading: state.isLoading,
                                hasError: state.error,
                                onRefresh: () => context
                                    .read<DropdownCubit>()
                                    .getCustomers(),
                                onChange: (value) {
                                  _customer =
                                  value!.title != 'all'.tr() ? value : null;
                                  _pagingController.refresh();
                                },
                                onSave: (value) {},
                                validator: (value) {
                                  return null;
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 200,
                          height: headerHeight,
                          child: TextField(
                            onChanged: (value) {
                              deb.run(() {
                                _search = value;
                                _pagingController.refresh();
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
                  ],
                ),
              ),
              BlocBuilder<DevicesListCubit, DevicesListState>(
                  builder: (context, state) {
                    if (state is DevicesListNewPage) {
                      _pagingController.value = PagingState(
                        nextPageKey: state.pageKey,
                        error: state.error,
                        itemList: state.items,
                      );
                      total = state.total!;
                    }
                    return AdminTableWidget<EntityModel>(
                      pagingController: _pagingController,
                      entityInfo: _getColumnsLabel(),
                      tableWidth: tableWidth,
                      itemsCount: total,
                      maxHeight: tableHeight,
                      details: (device){},
                      onEdit: (device) async {
                        // showDialog<bool?>(
                        //     context: context,
                        //     builder: (context) => DialogContainer(
                        //         child: MultiBlocProvider(
                        //           providers: [
                        //             BlocProvider(
                        //               create: (context) => injector<UsersCubit>(),
                        //             ),
                        //             BlocProvider(
                        //                 create: (context) =>
                        //                     injector<DropdownCubit>()),
                        //           ],
                        //           child: AddUserContentWidget(
                        //             user: user,
                        //           ),
                        //         ))).then((value) {
                        //   if (value ?? false) {
                        //     _pagingController.refresh();
                        //   }
                        // });
                      },
                      onDelete: (device) async {
                        bool result = await MyDialogs.showQuestionDialog(
                          context: context,
                          title: 'delete'.tr(args: [
                            device.type ?? '',
                            device.label ?? ''
                          ]),
                          message: 'deleteMessage'.tr(args: [
                            device.type ?? '',
                            device.label ?? ''
                          ]),
                        ) ??
                            false;
                        if (result && context.mounted) {
                          context
                              .read<DevicesCubit>()
                              .removeDevice(device.id.id);
                        }
                      },
                    );
                  })
            ],
          ),
        );
      });
  }

  List<String> _getColumnsLabel() {
    return ['name', 'label', 'type'];
  }
}
