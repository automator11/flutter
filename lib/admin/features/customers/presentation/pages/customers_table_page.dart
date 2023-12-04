import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';
import 'package:trackeano_web_app/admin/features/customers/presentation/widgets/add_customer_content_widget.dart';
import 'package:trackeano_web_app/config/routes/routes.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../../../../features/entities/data/models/models.dart';
import '../../../../../features/entities/data/params/params.dart';
import '../../../../../features/main_screen/presentation/widgets/widgets.dart';
import '../../../../../injector.dart';
import '../../../main/widgets/widgets.dart';
import '../cubits/customers_cubit/customers_cubit.dart';
import '../cubits/customers_list_cubit/customers_list_cubit.dart';

class CustomersTablePage extends StatefulWidget {
  const CustomersTablePage({super.key});

  @override
  State<CustomersTablePage> createState() => _CustomersTablePageState();
}

class _CustomersTablePageState extends State<CustomersTablePage> {
  final PagingController<int, CustomerModel> _pagingController =
      PagingController(firstPageKey: 0);

  Debouncer deb = Debouncer(milliseconds: 500);

  final int _rowsPerPage = 50;

  String _search = "";

  int? nextPage;
  int pageSize = 50;
  int total = 0;

  bool _isLoading = false;

  void _getPage(int page) {
    SearchEntityParams params =
        SearchEntityParams(page: page, pageSize: _rowsPerPage, search: _search);
    context.read<CustomersListCubit>().getPagedCustomers(params);
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
    return BlocListener<CustomersCubit, CustomersState>(
      listener: (context, state) {
        if (_isLoading) {
          _isLoading = false;
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (state is CustomersLoading) {
          _isLoading = true;
          MyDialogs.showLoadingDialog(
              context, 'loading'.tr(args: ['customer'.tr()]));
        }
        if (state is CustomersFail) {
          MyDialogs.showErrorDialog(context, state.message);
        }
        if (state is CustomersSuccess) {
          if (state.isDeleted) {
            MyDialogs.showSuccessDialog(context, 'deleteCustomerSuccess'.tr());
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
                            message: 'add'.tr(),
                            child: CustomElevatedButton(
                                padding: EdgeInsets.zero,
                                backgroundColor: kSecondaryColor,
                                onPressed: () async {
                                  showDialog<bool?>(
                                      context: context,
                                      builder: (context) => DialogContainer(
                                              child: BlocProvider(
                                            create: (context) =>
                                                injector<CustomersCubit>(),
                                            child:
                                                const AddCustomerContentWidget(),
                                          ))).then((value) {
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
              BlocBuilder<CustomersListCubit, CustomersListState>(
                  builder: (context, state) {
                if (state is CustomersListStateNewPage) {
                  _pagingController.value = PagingState(
                    nextPageKey: state.pageKey,
                    error: state.error,
                    itemList: state.items,
                  );
                  total = state.total!;
                }
                return AdminTableWidget<CustomerModel>(
                  pagingController: _pagingController,
                  entityInfo: _getColumnsLabel(),
                  tableWidth: tableWidth,
                  itemsCount: total,
                  maxHeight: tableHeight,
                  details: (customer) {},
                  manageUsers: (customer) {
                    context.goNamed(kAdminCustomersUsersPageRoute,
                        queryParameters: {'customerId': customer.id.id});
                  },
                  onEdit: (customer) async {
                    showDialog<bool?>(
                        context: context,
                        builder: (context) => DialogContainer(
                                child: BlocProvider(
                              create: (context) => injector<CustomersCubit>(),
                              child: AddCustomerContentWidget(
                                customer: customer,
                              ),
                            ))).then((value) {
                      if (value ?? false) {
                        _pagingController.refresh();
                      }
                    });
                  },
                  onDelete: (customer) async {
                    bool result = await MyDialogs.showQuestionDialog(
                          context: context,
                          title: 'delete'
                              .tr(args: ['customer'.tr(), customer.title]),
                          message: 'deleteMessage'
                              .tr(args: ['customer'.tr(), customer.title]),
                        ) ??
                        false;
                    if (result && mounted) {
                      context
                          .read<CustomersCubit>()
                          .deleteCustomer(customer.id.id);
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
    return ['title', 'email', 'phone', 'state', 'country'];
  }
}
