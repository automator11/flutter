import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackeano_web_app/features/main_screen/presentation/cubit/cubits.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../../features/entities/data/models/models.dart';
import '../../../../../features/main_screen/presentation/widgets/widgets.dart';
import '../../../../../features/user/data/models/models.dart';
import '../../data/params/create_customer_params.dart';
import '../cubits/customers_cubit/customers_cubit.dart';

class AddCustomerContentWidget extends StatefulWidget {
  final CustomerModel? customer;

  const AddCustomerContentWidget({super.key, this.customer});

  @override
  State<AddCustomerContentWidget> createState() =>
      _AddCustomerContentWidgetState();
}

class _AddCustomerContentWidgetState extends State<AddCustomerContentWidget> {
  final _addCustomerFormKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  final _address2Controller = TextEditingController();
  final _zipCodeController = TextEditingController();

  String _title = '';
  String _phone = '';
  String _email = '';
  String _city = '';
  String _state = '';
  String _country = '';
  String _address = '';
  String _address2 = '';
  String _zipCode = '';

  @override
  void initState() {
    if (widget.customer != null) {
      _title = widget.customer!.title;
      _titleController.text = _title;
      _phone = widget.customer!.phone!;
      _phoneController.text = _phone;
      _email = widget.customer!.email!;
      _emailController.text = _email;
      _city = widget.customer!.city!;
      _cityController.text = _city;
      _state = widget.customer!.state!;
      _stateController.text = _state;
      _country = widget.customer!.country!;
      _countryController.text = _country;
      _address = widget.customer!.address!;
      _addressController.text = _address;
      _address2 = widget.customer!.address2!;
      _address2Controller.text = _address2;
      _zipCode = widget.customer!.zip!;
      _zipCodeController.text = _zipCode;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Form(
          key: _addCustomerFormKey,
          child: Column(
            children: [
              Text(
                widget.customer != null ? 'updateCustomer' : 'createCustomer',
                style: const TextStyle(
                    color: kSecondaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ).tr(),
              const SizedBox(
                height: 30,
              ),
              CustomTextField(
                controller: _titleController,
                label: 'title'.tr(),
                onSave: (value) => _title = value,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'emptyFieldValidation'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                controller: _emailController,
                label: 'email'.tr(),
                onSave: (value) => _email = value,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'emptyFieldValidation'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                controller: _phoneController,
                label: 'phone'.tr(),
                onSave: (value) => _phone = value,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'emptyFieldValidation'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                controller: _countryController,
                label: 'country'.tr(),
                onSave: (value) => _country = value,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                controller: _stateController,
                label: 'state'.tr(),
                onSave: (value) => _state = value,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                controller: _cityController,
                label: 'city'.tr(),
                onSave: (value) => _city = value,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                controller: _addressController,
                label: 'address'.tr(),
                onSave: (value) => _address = value,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                controller: _address2Controller,
                label: 'address2'.tr(),
                onSave: (value) => _address2 = value,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                controller: _zipCodeController,
                label: 'zipCode'.tr(),
                onSave: (value) => _zipCode = value,
                validator: (value) {
                  if ((value?.isNotEmpty ?? false) && value!.length > 5) {
                    return 'invalidZipCode'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: 120,
                height: 30,
                child: BlocConsumer<CustomersCubit, CustomersState>(
                  listener: (context, state) async {
                    if (state is CustomersFail) {
                      MyDialogs.showErrorDialog(context, state.message);
                    }
                    if (state is CustomersSuccess) {
                      await MyDialogs.showSuccessDialog(
                          context,
                          widget.customer != null
                              ? 'customerUpdated'.tr()
                              : 'customerCreated'.tr());
                      if (mounted) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  builder: (context, state) {
                    return CustomElevatedButton(
                        isLoading: state is CustomersLoading,
                        onPressed: () {
                          if (_validateForm()) {
                            _addCustomerFormKey.currentState!.save();
                            UserModel? user = context.read<AuthCubit>().user;
                            if (widget.customer != null) {
                              _updateCustomer(user);
                              return;
                            }
                            _createCustomer(user);
                          }
                        },
                        borderRadius: 10,
                        child: Text(widget.customer != null ? 'update' : 'add')
                            .tr());
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _createCustomer(UserModel? user) {
    CreateCustomerParams params = CreateCustomerParams(
        ownerId: user!.ownerId.id,
        title: _title,
        email: _email,
        phone: _phone,
        state: _state,
        city: _city,
        country: _country,
        address: _address,
        address2: _address2,
        zip: _zipCode);
    context.read<CustomersCubit>().createCustomer(params);
  }

  void _updateCustomer(UserModel? user) {
    CreateCustomerParams params = CreateCustomerParams(
        id: widget.customer!.id.id,
        createdTime: widget.customer!.createdTime,
        customerId: user!.customerId!.id,
        ownerId: user.ownerId.id,
        tenantId: user.tenantId.id,
        title: _title,
        email: _email,
        phone: _phone,
        state: _state,
        city: _city,
        country: _country,
        address: _address,
        address2: _address2,
        zip: _zipCode);
    context.read<CustomersCubit>().createCustomer(params);
  }

  bool _validateForm() {
    return _addCustomerFormKey.currentState?.validate() ?? false;
  }
}
