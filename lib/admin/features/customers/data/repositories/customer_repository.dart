import 'package:trackeano_web_app/admin/features/customers/data/params/create_customer_params.dart';

import '../../../../../core/utils/data_state.dart';
import '../../../../../features/entities/data/params/params.dart';
import '../data_sources/customer_remote_data_source.dart';

typedef _ApiCallFunction = Future<dynamic> Function();

class CustomerRepository {
  final CustomerRemoteDataSource _apiService;

  const CustomerRepository(this._apiService);

  Future<DataState> _apiCall(_ApiCallFunction apiCallFunction) async {
    try {
      final json = await apiCallFunction();
      return DataSuccess(json);
    } on Exception catch (error) {
      return DataError(error);
    }
  }

  Future<DataState> getPagedCustomers(SearchEntityParams params) async {
    return _apiCall(() => _apiService.getPagedCustomers(params));
  }

  Future<DataState> getCustomer(String customerId) async {
    return _apiCall(() => _apiService.getCustomer(customerId));
  }

  Future<DataState> createCustomer(CreateCustomerParams params) async {
    return _apiCall(() => _apiService.createCustomer(params));
  }

  Future<DataState> deleteCustomer(String customerId) async {
    return _apiCall(() => _apiService.deleteCustomer(customerId));
  }
}
