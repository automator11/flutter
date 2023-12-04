import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../main_screen/presentation/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../cubits/alerts_cubit.dart';
import 'widgets.dart';

class AlertsListWidget extends StatefulWidget {
  const AlertsListWidget({super.key});

  @override
  State<AlertsListWidget> createState() => _AlertsListWidgetState();
}

class _AlertsListWidgetState extends State<AlertsListWidget> {
  final PagingController<int, AlarmModel> _pagingController =
      PagingController(firstPageKey: 0);

  bool _isLoading = false;
  final List<String> _readAlerts = [];

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      context.read<AlertsCubit>().getPagedAlerts(pageKey);
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AlertsListWidget oldWidget) {
    _pagingController.refresh();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AlertsCubit, AlertsState>(
      listener: (context, state) {
        if (_isLoading) {
          _isLoading = false;
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (state is AlertsLoading) {
          _isLoading = true;
          MyDialogs.showLoadingDialog(context, 'loadingDeleteAlert'.tr());
        }
        if (state is AlertsDeleted) {
          MyDialogs.showSuccessDialog(context, 'deleteAlertSuccess'.tr());
          _pagingController.refresh();
        }
        if (state is AlertsFail) {
          MyDialogs.showErrorDialog(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is AlertsNewPage) {
          _pagingController.value = PagingState(
            nextPageKey: state.pageKey,
            error: state.error,
            itemList: state.items,
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: RefreshIndicator(
            onRefresh: () => Future.sync(() {
              _pagingController.refresh();
            }),
            child: PagedListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<AlarmModel>(
                  itemBuilder: (context, alert, index) {
                    if (!alert.status.contains('UNACK')) {
                      _readAlerts.add(alert.id.id);
                    }
                    return AlertListTile(
                      alert: alert,
                      read: _readAlerts.contains(alert.id.id),
                      onTap: () {
                        if (!_readAlerts.contains(alert.id.id)) {
                          setState(() {
                            _readAlerts.add(alert.id.id);
                          });
                          context
                              .read<AlertsCubit>()
                              .acknowledgeAlert(alert.id.id);
                        }
                      },
                    );
                  },
                  firstPageErrorIndicatorBuilder: (context) =>
                      FirstPageErrorWidget(
                        message: _pagingController.error.toString(),
                        onRetry: () {
                          _pagingController.refresh();
                        },
                      ),
                  newPageErrorIndicatorBuilder: (context) => NewPageErrorWidget(
                        message: _pagingController.error.toString(),
                        onRetry: () {
                          _pagingController.refresh();
                        },
                      ),
                  noItemsFoundIndicatorBuilder: (context) => NoItemsFoundWidget(
                        onRefresh: () {
                          _pagingController.refresh();
                        },
                      ),
                  noMoreItemsIndicatorBuilder: (context) => const SizedBox(
                        height: 200,
                      )),
            ),
          ),
        );
      },
    );
  }
}
