import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';
import 'package:trackeano_web_app/config/routes/routes.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../../../../features/entities/data/params/params.dart';
import '../../../../../features/entities/presentation/assets/cubits/cubits.dart';
import '../../../../../features/main_screen/presentation/widgets/widgets.dart';
import '../../../../../features/user/data/models/models.dart';
import '../../../../../injector.dart';
import '../../../main/widgets/widgets.dart';
import '../../../users/presentation/cubits/users_cubit/users_cubit.dart';
import '../../../users/presentation/cubits/users_list_cubit/users_list_cubit.dart';
import '../../../users/presentation/widgets/widgets.dart';

class CustomerUsersTablePage extends StatefulWidget {
  final String customerId;

  const CustomerUsersTablePage({super.key, required this.customerId});

  @override
  State<CustomerUsersTablePage> createState() => _CustomerUsersTablePageState();
}

class _CustomerUsersTablePageState extends State<CustomerUsersTablePage> {
  final PagingController<int, UserModel> _pagingController =
      PagingController(firstPageKey: 0);

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
        parentId: widget.customerId);
    context.read<UsersListCubit>().getPagedUsers(params);
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _getPage(pageKey);
    });
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
                            message: 'back'.tr(),
                            child: CustomElevatedButton(
                                padding: EdgeInsets.zero,
                                backgroundColor: kSecondaryColor,
                                onPressed: () {
                                  context.goNamed(kAdminCustomersPageRoute);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                      'assets/icons/return_white_icon.png'),
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
                            message: 'add'.tr(),
                            child: CustomElevatedButton(
                                padding: EdgeInsets.zero,
                                backgroundColor: kSecondaryColor,
                                onPressed: () async {
                                  showDialog<bool?>(
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
                                              child: AddUserContentWidget(
                                                  customerId:
                                                      widget.customerId),
                                            ),
                                          )).then((value) {
                                    if (value ?? false) {
                                      _pagingController.refresh();
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
    return ['firstName', 'lastName', 'email'];
  }
}
