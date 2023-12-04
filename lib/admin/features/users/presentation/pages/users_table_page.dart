import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../../../../features/entities/data/models/models.dart';
import '../../../../../features/entities/data/params/params.dart';
import '../../../../../features/entities/presentation/assets/cubits/cubits.dart';
import '../../../../../features/main_screen/presentation/widgets/widgets.dart';
import '../../../../../features/user/data/models/models.dart';
import '../../../../../injector.dart';
import '../../../main/widgets/widgets.dart';
import '../cubits/users_cubit/users_cubit.dart';
import '../cubits/users_list_cubit/users_list_cubit.dart';
import '../widgets/widgets.dart';

class UsersTablePage extends StatefulWidget {
  const UsersTablePage({super.key});

  @override
  State<UsersTablePage> createState() => _UsersTablePageState();
}

class _UsersTablePageState extends State<UsersTablePage> {
  final PagingController<int, UserModel> _pagingController =
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
    context.read<UsersListCubit>().getPagedUsers(params);
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
    return BlocListener<UsersCubit, UsersState>(
      listener: (context, state) {
        if (_isLoading) {
          _isLoading = false;
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (state is UsersLoading) {
          _isLoading = true;
          MyDialogs.showLoadingDialog(
              context, 'loading'.tr(args: ['user'.tr()]));
        }
        if (state is UsersFail) {
          MyDialogs.showErrorDialog(context, state.message);
        }
        if (state is UsersSuccess) {
          if (state.isDeleted) {
            MyDialogs.showSuccessDialog(context, 'deleteUserSuccess'.tr());
          }
          _pagingController.refresh();
        }
        if (state is UsersActivationLinkSuccess) {
          showDialog(
              context: context,
              builder: (context) => DialogContainer(
                  width: 500,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'activationLink',
                          style: TextStyle(
                              color: kSecondaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ).tr(),
                        const SizedBox(
                          height: 10,
                        ),
                        Align(
                            alignment: Alignment.topLeft,
                            child: const Text('activationLinkMessage').tr()),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                                child: Text(
                              state.link,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            )),
                            const SizedBox(
                              width: 10,
                            ),
                            Tooltip(
                              message: 'copyActivationLink'.tr(),
                              child: IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: state.link));
                                },
                                icon: const Icon(
                                  Ionicons.copy_outline,
                                  color: kPrimaryText,
                                  size: 20,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: 120,
                          child: CustomElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              borderRadius: 10,
                              child: const Text('accept').tr()),
                        )
                      ],
                    ),
                  )));
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
                          child: Tooltip(
                            message: 'add'.tr(),
                            child: CustomElevatedButton(
                                padding: EdgeInsets.zero,
                                backgroundColor: kSecondaryColor,
                                onPressed: () async {
                                  showDialog<UserModel?>(
                                      context: context,
                                      builder: (context) => DialogContainer(
                                            child: MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                    create: (context) =>
                                                        injector<UsersCubit>()),
                                                BlocProvider(
                                                    create: (context) =>
                                                        injector<
                                                            DropdownCubit>()),
                                              ],
                                              child:
                                                  const AddUserContentWidget(),
                                            ),
                                          )).then((value) {
                                    if (value != null) {
                                      _pagingController.refresh();
                                      context.read<UsersCubit>().getActivationLink(value.id.id);
                                    }
                                  });
                                },
                                child: const Icon(
                                  Ionicons.add_outline,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
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
              BlocBuilder<UsersListCubit, UsersListState>(
                  builder: (context, state) {
                if (state is UsersListStateNewPage) {
                  _pagingController.value = PagingState(
                    nextPageKey: state.pageKey,
                    error: state.error,
                    itemList: state.items,
                  );
                  total = state.total!;
                }
                return AdminTableWidget<UserModel>(
                  pagingController: _pagingController,
                  entityInfo: _getColumnsLabel(),
                  tableWidth: tableWidth,
                  itemsCount: total,
                  maxHeight: tableHeight,
                  activationLink: (user) {
                    context.read<UsersCubit>().getActivationLink(user.id.id);
                  },
                  onEdit: (user) async {
                    showDialog<bool?>(
                        context: context,
                        builder: (context) => DialogContainer(
                                child: MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (context) => injector<UsersCubit>(),
                                ),
                                BlocProvider(
                                    create: (context) =>
                                        injector<DropdownCubit>()),
                              ],
                              child: AddUserContentWidget(
                                user: user,
                              ),
                            ))).then((value) {
                      if (value ?? false) {
                        _pagingController.refresh();
                      }
                    });
                  },
                  onDelete: (user) async {
                    bool result = await MyDialogs.showQuestionDialog(
                          context: context,
                          title: 'delete'.tr(args: ['user'.tr(), user.email]),
                          message: 'deleteMessage'
                              .tr(args: ['user'.tr(), user.email]),
                        ) ??
                        false;
                    if (result && mounted) {
                      context.read<UsersCubit>().deleteUser(user.id.id);
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

  List<String> _getColumnsLabel() {
    return ['firstName', 'lastName', 'email', 'authority'];
  }
}
