import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../config/themes/colors.dart';
import '../../../../features/entities/data/models/models.dart';
import '../../../../features/entities/presentation/common_widgets/widgets.dart';
import '../../../../features/main_screen/presentation/widgets/widgets.dart';
import '../../../../features/user/data/models/models.dart';

class AdminTableWidget<T> extends StatelessWidget {
  final List<String> entityInfo;
  final List<String> entityTelemetry;
  final double tableWidth;
  final PagingController<int, T> pagingController;
  final int itemsCount;
  final double maxHeight;
  final bool isDevice;
  final Function(T)? onEdit;
  final Function(T)? onDelete;
  final Function(T)? details;
  final Function(T)? manageUsers;
  final Function(T)? activationLink;

  const AdminTableWidget(
      {super.key,
      required this.entityInfo,
      this.entityTelemetry = const [],
      required this.tableWidth,
      required this.pagingController,
      required this.itemsCount,
      required this.maxHeight,
      this.isDevice = false,
      this.onEdit,
      this.onDelete,
      this.details,
      this.manageUsers,
      this.activationLink});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
          border: const Border.fromBorderSide(
              BorderSide(color: kInputDefaultBorderColor)),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TableRowWidget(
              rowBackgroundColor: kSecondaryColor,
              rowBorderRadius: BorderRadius.circular(10),
              cells: [
                ...entityInfo.map((label) => Container(
                    constraints: const BoxConstraints.expand(width: 100),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        border: Border(
                      left: BorderSide(color: Colors.white),
                    )),
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ).tr())),
                if (isDevice) ...[
                  Container(
                      constraints: const BoxConstraints.expand(width: 100),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          border: Border(
                        left: BorderSide(color: Colors.white),
                      )),
                      child: const Text(
                        'lastReport',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ).tr())
                ],
                ...entityTelemetry.map((label) => Container(
                    constraints: const BoxConstraints.expand(width: 100),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        border: Border(
                      left: BorderSide(color: Colors.white),
                    )),
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ).tr())),
                Container(
                    constraints: const BoxConstraints.expand(width: 150),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        border: Border(
                      left: BorderSide(color: Colors.white),
                    )),
                    child: const Text(
                      'action',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ).tr()),
              ]),
          Container(
            constraints:
                BoxConstraints(maxWidth: tableWidth, maxHeight: maxHeight - 45),
            child: RefreshIndicator(
              onRefresh: () => Future.sync(() {
                pagingController.refresh();
              }),
              child: PagedListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<T>(
                    itemBuilder: (context, item, index) => TableRowWidget(
                          rowBorderSide: index == itemsCount - 1
                              ? null
                              : const Border(
                                  bottom: BorderSide(
                                      color: kInputDefaultBorderColor)),
                          cells: [
                            ...entityInfo.map((label) {
                              String value = "";
                              if (item is CustomerModel) {
                                value = item.getFieldValueAsString(label);
                              } else if (item is UserModel) {
                                value = item.getFieldValueAsString(label);
                              } else if(item is EntityModel){
                                value = item.getFieldValueAsString(label);
                              }
                              return SizedBox(
                                width: 100,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }),
                            SizedBox(
                              width: 200,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (activationLink != null)
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(right: 10.0),
                                      child: Tooltip(
                                        message: 'showActivationLink'.tr(),
                                        child: CircleButton(
                                            onTap: () => activationLink!(item),
                                            backgroundColor: kPrimaryColor,
                                            elevation: 0,
                                            icon: const Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(
                                                Ionicons.open_outline,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            )),
                                      ),
                                    ),
                                  if (manageUsers != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: Tooltip(
                                        message: 'manageUsers'.tr(),
                                        child: CircleButton(
                                            onTap: () => manageUsers!(item),
                                            backgroundColor: kPrimaryColor,
                                            elevation: 0,
                                            icon: const Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(
                                                Ionicons.person_outline,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            )),
                                      ),
                                    ),
                                  if (details != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: Tooltip(
                                        message: 'manage'.tr(),
                                        child: CircleButton(
                                            onTap: () => details!(item),
                                            backgroundColor: kPrimaryColor,
                                            elevation: 0,
                                            icon: const Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(
                                                Ionicons.stats_chart_outline,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            )),
                                      ),
                                    ),
                                  if (onEdit != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: Tooltip(
                                        message: 'edit'.tr(),
                                        child: CircleButton(
                                            onTap: () => onEdit!(item),
                                            backgroundColor: kPrimaryColor,
                                            elevation: 0,
                                            icon: const Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(
                                                Ionicons.pencil_outline,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            )),
                                      ),
                                    ),
                                  if (onDelete != null)
                                    Tooltip(
                                      message: 'delete'.tr(),
                                      child: CircleButton(
                                          onTap: () => onDelete!(item),
                                          backgroundColor: kPrimaryColor,
                                          elevation: 0,
                                          icon: const Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Icon(
                                              Ionicons.trash_outline,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          )),
                                    )
                                ],
                              ),
                            )
                          ],
                        ),
                    firstPageErrorIndicatorBuilder: (context) =>
                        FirstPageErrorWidget(
                          message: pagingController.error.toString(),
                          onRetry: () {
                            pagingController.refresh();
                          },
                        ),
                    newPageErrorIndicatorBuilder: (context) =>
                        NewPageErrorWidget(
                          message: pagingController.error.toString(),
                          onRetry: () {
                            pagingController.refresh();
                          },
                        ),
                    noItemsFoundIndicatorBuilder: (context) =>
                        NoItemsFoundWidget(
                          onRefresh: () {
                            pagingController.refresh();
                          },
                        ),
                    noMoreItemsIndicatorBuilder: (context) => const SizedBox(
                          height: 4,
                        )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
