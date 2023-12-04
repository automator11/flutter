import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackeano_web_app/features/main_screen/presentation/cubit/auth_cubit/auth_cubit.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../features/entities/data/models/models.dart';
import '../../../../../features/entities/presentation/assets/cubits/cubits.dart';
import '../../../../../features/main_screen/presentation/widgets/widgets.dart';
import '../../../../../features/user/data/models/models.dart';
import '../../data/params/create_user_params.dart';
import '../cubits/users_cubit/users_cubit.dart';

class AddUserContentWidget extends StatefulWidget {
  final UserModel? user;
  final String? customerId;

  const AddUserContentWidget({super.key, this.user, this.customerId});

  @override
  State<AddUserContentWidget> createState() => _AddUserContentWidgetState();
}

class _AddUserContentWidgetState extends State<AddUserContentWidget> {
  final _addUserFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _authority = kCustomerRole;
  bool _sendActivationMail = false;
  bool _showCustomers = true;
  CustomerModel? _customer;

  DropdownSelectedState _customerState =
      const DropdownSelectedState(isLoading: false, error: false, items: []);

  @override
  void initState() {
    if (widget.user != null) {
      _email = widget.user!.email;
      _emailController.text = _email;
      _firstName = widget.user!.firstName;
      _firstNameController.text = _firstName;
      _lastName = widget.user!.lastName ?? '';
      _lastNameController.text = _lastName;
      _authority = widget.user?.authority ?? kCustomerRole;
    }

    DropdownCubit cubit = context.read<DropdownCubit>();
    cubit.getCustomers();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Form(
          key: _addUserFormKey,
          child: Column(
            children: [
              Text(
                widget.user != null ? 'updateUser' : 'createUser',
                style: const TextStyle(
                    color: kSecondaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ).tr(),
              const SizedBox(
                height: 30,
              ),
              CustomTextField(
                controller: _firstNameController,
                label: 'firstName'.tr(),
                onSave: (value) => _firstName = value,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'emptyFieldValidation'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextField(
                controller: _lastNameController,
                label: 'lastName'.tr(),
                onSave: (value) => _lastName = value,
              ),
              const SizedBox(
                height: 10,
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
                height: 10,
              ),
              CustomDropDown<String>(
                disabled: widget.user != null,
                initialValue: _authority,
                items: const [kTenantAdminRole, kCustomerRole],
                label: 'authority'.tr(),
                hint: '',
                onChange: (value) {
                  setState(() {
                    _showCustomers = value == kCustomerRole;
                  });
                },
                onSave: (value) => _authority = value!,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'emptyFieldValidation'.tr();
                  }
                  return null;
                },
              ),
              if (_showCustomers)
                const SizedBox(
                  height: 20,
                ),
              if (_showCustomers)
                BlocSelector<DropdownCubit, DropdownState,
                    DropdownSelectedState>(
                  selector: (state) {
                    if (state.groupType == 'Customer') {
                      bool isLoading = state is DropdownLoading;
                      bool hasError = state is DropdownFail;
                      List<CustomerModel> customers = [];
                      if (state is DropdownSuccess) {
                        customers = state.customersItems ?? [];
                        if (_customer == null && customers.isNotEmpty) {
                          if (widget.user != null) {
                            _customer = customers.firstWhere((element) =>
                                element.id.id == widget.user?.ownerId.id);
                          } else if (widget.customerId != null) {
                            _customer = customers.firstWhere((element) =>
                                element.id.id == widget.customerId);
                          } else {
                            _customer = customers.first;
                          }
                        }
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
                      disabled:
                          widget.user != null || widget.customerId != null,
                      initialValue: _customer,
                      items: state.items as List<CustomerModel>,
                      label: 'customer'.tr(),
                      hint: '',
                      isLoading: state.isLoading,
                      hasError: state.error,
                      onRefresh: () =>
                          context.read<DropdownCubit>().getCustomers(),
                      onSave: (value) => _customer = value,
                      validator: (value) {
                        if (value == null) {
                          return 'emptyFieldValidation'.tr();
                        }
                        return null;
                      },
                    );
                  },
                ),
              if (widget.user == null)
                const SizedBox(
                  height: 20,
                ),
              if (widget.user == null)
                CustomDropDown<String>(
                  disabled: true,
                  initialValue: 'showActivationLink',
                  items: const ['sendActivationMail', 'showActivationLink'],
                  label: 'activationLink'.tr(),
                  hint: '',
                  onSave: (value) =>
                      _sendActivationMail = value == 'sendActivationMail',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'emptyFieldValidation'.tr();
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
                child: BlocConsumer<UsersCubit, UsersState>(
                  listener: (context, state) async {
                    if (state is UsersFail) {
                      MyDialogs.showErrorDialog(context, state.message);
                    }
                    if (state is UsersSuccess) {
                      await MyDialogs.showSuccessDialog(
                          context,
                          widget.user != null
                              ? 'userUpdated'.tr()
                              : 'userCreated'.tr());
                      if (mounted) {
                        Navigator.pop(context, state.user);
                      }
                    }
                  },
                  builder: (context, state) {
                    return CustomElevatedButton(
                        isLoading: state is UsersLoading,
                        onPressed: () {
                          if (_validateForm()) {
                            _addUserFormKey.currentState!.save();
                            if (widget.user != null) {
                              _updateUser();
                              return;
                            }
                            final user = context.read<AuthCubit>().user;
                            _createUser(user!);
                          }
                        },
                        borderRadius: 10,
                        child:
                            Text(widget.user != null ? 'update' : 'add').tr());
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _createUser(UserModel user) {
    String? customerId = _authority == kCustomerRole ? _customer?.id.id : null;
    String ownerId =
        _authority == kCustomerRole ? _customer!.id.id : user.id.id;
    CreateUserParams params = CreateUserParams(
        customerId: customerId,
        ownerId: ownerId,
        email: _email,
        authority: _authority,
        firstName: _firstName,
        lastName: _lastName,
        sendActivationMail: _sendActivationMail);
    context.read<UsersCubit>().createUser(params);
  }

  void _updateUser() {
    CreateUserParams params = CreateUserParams(
      id: widget.user!.id.id,
      customerId: widget.user!.customerId!.id,
      ownerId: widget.user!.ownerId.id,
      tenantId: widget.user!.tenantId.id,
      email: _email,
      firstName: _firstName,
      lastName: _lastName,
      authority: _authority,
    );
    context.read<UsersCubit>().createUser(params);
  }

  bool _validateForm() {
    return _addUserFormKey.currentState?.validate() ?? false;
  }
}
