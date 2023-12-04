import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../config/themes/colors.dart';
import '../../../../core/exceptions/error_handler.dart';
import '../../../../core/exceptions/exception.dart';
import '../../../../core/utils/data_state.dart';
import '../../../main_screen/presentation/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/params/params.dart';
import '../../data/repositories/entities_repository.dart';
import 'cubits/cubits.dart';

class DevicesDataSource extends AsyncDataTableSource {
  List<EntitySearchModel> devices = [];
  final List<String> columnsNames;
  final BuildContext context;
  final String? search;
  final String parentId;
  final String type;
  final EntitiesRepository devicesRepository;
  bool lastPage = false;

  DevicesDataSource({
    required this.context,
    required this.columnsNames,
    this.search,
    required this.parentId,
    required this.type,
    required this.devicesRepository,
  });

  void updateDataSource(List<EntitySearchModel> devices) {
    this.devices = devices;
    notifyListeners();
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => devices.length;

  @override
  int get selectedRowCount => 0;

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    List<EntitySearchModel> items = [];
    if (startIndex + count < devices.length) {
      items = devices.sublist(startIndex, startIndex + count);
    } else {
      final page = startIndex ~/ count;
      SearchEntityParams params = SearchEntityParams(
          search: search,
          page: page,
          pageSize: count,
          types: [type],
          parentId: parentId);
      final response = await devicesRepository.getPagedDevicesByParent(params);
      if (response is DataError) {
        String errorMessage = 'unknownError';
        if (response.error is UnauthorizedException) {
          errorMessage = 'sessionExpired';
        } else if (response.error is DioException) {
          errorMessage =
              ErrorHandler(dioException: (response.error as DioException))
                  .errorMessage;
        }
        throw errorMessage;
      }
      if (response is DataSuccess) {
        EntitiesSearchResponseModel entitiesResponseModel =
            EntitiesSearchResponseModel.fromJson(response.data);
        final newItems = entitiesResponseModel.data;
        final totalCount = entitiesResponseModel.totalElements;
        lastPage = devices.length == totalCount!;
        devices.addAll(newItems);
        items = newItems;
      }
      return AsyncRowsResponse(
          devices.length,
          items
              .map((item) => DataRow2(cells: [
                    DataCell(Text(item.latest.label)),
                    ...columnsNames
                        .map((label) => DataCell(Text(
                            item.latest.additionalInfo?[label].toString() ??
                                '')))
                        ,
                    DataCell(Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircleButton(
                            onTap: () async {
                              // TODO: open edit page in a dialog
                              // bool result = await context.pushNamed<bool>(
                              //     kMapEditAssetPageRoute,
                              //     extra: item.toEntityModel()) ??
                              //     false;

                              // if (result && mounted) {
                              //   _getAssets();
                              // }
                            },
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
                        const SizedBox(
                          width: 10,
                        ),
                        CircleButton(
                            onTap: () async {
                              bool result = await MyDialogs.showQuestionDialog(
                                    context: context,
                                    title: 'delete'.tr(args: [
                                      item.latest.type ?? '',
                                      item.latest.label
                                    ]),
                                    message: 'deleteMessage'.tr(args: [
                                      item.latest.type ?? '',
                                      item.latest.label
                                    ]),
                                  ) ??
                                  false;
                              if (result && context.mounted) {
                                context
                                    .read<DevicesCubit>()
                                    .removeDevice(item.entityId.id);
                              }
                            },
                            backgroundColor: kSecondaryColor,
                            elevation: 0,
                            icon: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Ionicons.trash_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ))
                      ],
                    ))
                  ]))
              .toList());
    }
    return AsyncRowsResponse(0, []);
  }
}
