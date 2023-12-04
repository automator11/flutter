import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../../../features/entities/data/models/models.dart';
import '../../../../features/entities/data/params/params.dart';
import '../../../../features/main_screen/presentation/cubit/cubits.dart';
import '../../../../features/main_screen/presentation/widgets/widgets.dart';
import '../../../../features/user/data/models/models.dart';
import '../../customers/presentation/cubits/customers_list_cubit/customers_list_cubit.dart';

class SelectCustomerDialog extends StatefulWidget {
  const SelectCustomerDialog({super.key});

  @override
  State<SelectCustomerDialog> createState() => _SelectCustomerDialogState();
}

class _SelectCustomerDialogState extends State<SelectCustomerDialog> {
  final PagingController<int, CustomerModel> _pagingController =
      PagingController(firstPageKey: 0);
  UserModel? selectedCustomer;
  UserModel? _user;

  Debouncer deb = Debouncer(milliseconds: 500);

  List<CustomerModel> customers = [];

  String _search = '';

  @override
  void initState() {
    _user = context.read<AuthCubit>().user;
    _pagingController.addPageRequestListener((pageKey) {
      context.read<CustomersListCubit>().getPagedCustomers(SearchEntityParams(
          parentId: _user!.id.id, search: _search, pageSize: 50, page: 0));
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
                      'selectEstablishment',
                      style: TextStyle(
                          color: kSecondaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ).tr(),
                    CustomTextField(
                      label: '',
                      hint: 'search'.tr(),
                      onSave: (value) {},
                      onChange: (value) {
                        deb.run(() {
                          _search = value;
                          _pagingController.refresh();
                        });
                      },
                    ),
                    SizedBox(
                      height: 300,
                      child:
                          BlocBuilder<CustomersListCubit, CustomersListState>(
                        builder: (context, state) {
                          if (state is CustomersListStateNewPage) {
                            _pagingController.value = PagingState(
                              nextPageKey: state.pageKey,
                              error: state.error,
                              itemList: state.items,
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () => Future.sync(() {
                              _pagingController.refresh();
                            }),
                            child: PagedListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              pagingController: _pagingController,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                height: 4,
                              ),
                              builderDelegate: PagedChildBuilderDelegate<
                                      CustomerModel>(
                                  itemBuilder: (context, customer, index) {
                                    return ListTile(
                                      dense: true,
                                      onTap: () {},
                                      title: Text(
                                        customer.title,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      selected: selectedCustomer == customer,
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 130,
                          child: CustomElevatedButton(
                            borderRadius: 10,
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('cancel').tr(),
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
                              child: const Text('add').tr(),
                              onPressed: () async {}),
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
                          Ionicons.close,
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
