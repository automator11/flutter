import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/resources/constants.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../../data/models/models.dart';
import '../../../../data/params/params.dart';
import '../../../../data/repositories/entities_repository.dart';

part 'assets_state.dart';

class AssetsCubit extends Cubit<AssetsState> {
  final EntitiesRepository _assetsRepository;

  AssetsCubit(this._assetsRepository) : super(AssetsInitial());

  void createAsset(AssetCreateParams params, {String? parentId}) async {
    emit(const AssetsLoading());
    late DataState response;
    bool create = true;
    if (params.type == kPaddockTypeKey) {
      create = false;
      response =
          await _assetsRepository.getEstablishmentAvailableArea(parentId!);
      if (response is DataSuccess) {
        TelemetryResponseModel responseModel =
            TelemetryResponseModel.fromJson({'data': response.data});
        double availableArea = responseModel.data.first.value.toDouble();
        create = availableArea >= params.additionalInfo['totalArea'];
        if (!create) {
          emit(AssetsFail(
            message: 'unavailableEnoughArea'.tr(),
          ));
        }
      }
    }
    if (create) {
      response = await _assetsRepository.createAsset(params);
      if (response is DataSuccess) {
        emit(AssetsSuccess(asset: EntityModel.fromJson(response.data)));
        return;
      }
    }
    if (response is DataError) {
      String errorMessage = 'unknownError';
      if (response.error is UnauthorizedException) {
        errorMessage = 'sessionExpired';
      } else if (response.error is DioException) {
        errorMessage =
            ErrorHandler(dioException: (response.error as DioException))
                .errorMessage;
      }
      emit(AssetsFail(
        message: errorMessage,
      ));
    }
  }

  void updateAsset(AssetUpdateParams params, {String? parentId}) async {
    emit(const AssetsLoading());
    late DataState response;
    bool update = true;
    if (params.type == kPaddockTypeKey) {
      update = false;
      response =
          await _assetsRepository.getEstablishmentAvailableArea(parentId!);
      if (response is DataSuccess) {
        TelemetryResponseModel responseModel =
            TelemetryResponseModel.fromJson({'data': response.data});
        double availableArea = responseModel.data.first.value;
        double realArea = availableArea + params.additionalInfo['beforeArea'];
        update = realArea >= params.additionalInfo['totalArea'];
        if (!update) {
          emit(AssetsFail(
            message: 'unavailableEnoughArea'.tr(),
          ));
        }
      }
    }
    if (update) {
      final response = await _assetsRepository.updateAsset(params);
      if (response is DataSuccess) {
        emit(const AssetsSuccess());
        return;
      }
    }
    if (response is DataError) {
      String errorMessage = 'unknownError';
      if (response.error is UnauthorizedException) {
        errorMessage = 'sessionExpired';
      } else if (response.error is DioException) {
        errorMessage =
            ErrorHandler(dioException: (response.error as DioException))
                .errorMessage;
      }
      emit(AssetsFail(
        message: errorMessage,
      ));
    }
  }

  void validateBatch(FindBatchRelatedRotationsParams params) async {
    if (params.currentBatchId == params.batchId) {
      emit(BatchValidationSuccess());
      return;
    }
    emit(AssetsLoading(message: 'validatingBatch'.tr()));
    final response =
        await _assetsRepository.findBatchesRelatedRotationsByDate(params);
    if (response is DataSuccess) {
      bool isValid = true;
      EntitiesSearchResponseModel responseModel =
          EntitiesSearchResponseModel.fromJson(response.data);
      for (EntitySearchModel rotation in responseModel.data) {
        if (rotation.latest.additionalInfo?['lotName'] == params.batchName) {
          DateTime startDate = DateTime.fromMillisecondsSinceEpoch(
                  rotation.latest.additionalInfo!['startDate'],
                  isUtc: true)
              .toLocal();
          DateTime endDate = DateTime.fromMillisecondsSinceEpoch(
                  rotation.latest.additionalInfo!['endDate'],
                  isUtc: true)
              .toLocal();
          if (params.startDate.isBefore(startDate) &&
              params.endDate.isAfter(startDate)) {
            isValid = false;
            break;
          }
          if (params.startDate.isBefore(endDate) &&
              params.endDate.isAfter(endDate)) {
            isValid = false;
            break;
          }
          if (startDate.isAtSameMomentAs(params.startDate) ||
              endDate.isAtSameMomentAs(params.endDate)) {
            isValid = false;
            break;
          }
        }
      }
      if (isValid) {
        emit(BatchValidationSuccess());
      } else {
        emit(AssetsFail(
          message: 'selectedBatchValidationFailed'.tr(),
        ));
      }
      return;
    }
    if (response is DataError) {
      String errorMessage = 'unknownError';
      if (response.error is UnauthorizedException) {
        errorMessage = 'sessionExpired';
      } else if (response.error is DioException) {
        errorMessage =
            ErrorHandler(dioException: (response.error as DioException))
                .errorMessage;
      }
      emit(AssetsFail(
        message: errorMessage,
      ));
    }
  }

  void validateAnimal(String animalName) async {
    emit(AssetsLoading(message: 'validatingAnimal'.tr()));
    final response = await _assetsRepository.searchAssetByName(animalName);
    if (response is DataSuccess) {
      EntitiesSearchResponseModel responseModel =
          EntitiesSearchResponseModel.fromJson(response.data);
      if (responseModel.data.isEmpty) {
        emit(AnimalValidationSuccess());
      } else {
        emit(AnimalValidationFail(
            message: 'animalAlreadyHasEarTagAttached'.tr(),
            animal: responseModel.data.first));
      }
      return;
    }
    if (response is DataError) {
      String errorMessage = 'unknownError';
      if (response.error is UnauthorizedException) {
        errorMessage = 'sessionExpired';
      } else if (response.error is DioException) {
        errorMessage =
            ErrorHandler(dioException: (response.error as DioException))
                .errorMessage;
      }
      emit(AssetsFail(
        message: errorMessage,
      ));
    }
  }

  void setAssetSuccess(EntityModel asset) {
    emit(AssetsInitial());
    Future.delayed(const Duration(milliseconds: 100));
    emit(AssetsSuccess(asset: asset));
  }
}
