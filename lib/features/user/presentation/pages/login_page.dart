import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../config/themes/colors.dart';
import '../../../../core/resources/constants.dart';
import '../../../../core/utils/local_storage_helper.dart';
import '../../../../injector.dart';
import '../../../main_screen/presentation/cubit/cubits.dart';
import '../../../main_screen/presentation/widgets/widgets.dart';
import '../../data/params/params.dart';
import '../cubit/login_cubit/login_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();

  String _password = '';
  String _email = '';

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryBackground,
      body: MultiBlocListener(
        listeners: [
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) async {
              if (state is LoginFailure) {
                setState(() {
                  _isLoading = false;
                });
                String errorMessage = state.message;
                MyDialogs.showErrorDialog(context, errorMessage.tr());
              }
              if (state is LoginSuccess) {
                context.read<AuthCubit>().user = state.user;
                final storage = injector<LocalStorageHelper>();
                storage.writeString(kActiveUserKey, state.user.id.id);
                context.read<AppStateCubit>().restoreAppState(state.user);
              }
              if (state is LoginLoading) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
          ),
          // BlocListener<AppStateCubit, AppState>(
          //   listener: (context, state) {
          //     if (state is AppStateRestored) {
          //       final user = context.read<AuthCubit>().user;
          //       if (user?.authority == kTenantAdminRole) {
          //         context.goNamed(kDashboardPageRoute);
          //       } else {
          //         context.goNamed(kMapPageRoute);
          //       }
          //       setState(() {
          //         _isLoading = false;
          //       });
          //     }
          //   },
          // ),
        ],
        child: Center(
          child: Card(
            elevation: 10.0,
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: SingleChildScrollView(
              child: Container(
                color: kSecondaryColor,
                constraints: const BoxConstraints(maxHeight: 400),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: const Text(
                          'welcome',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ).tr(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: const Text(
                          'loginInfo',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: kSecondaryText),
                        ).tr(),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Form(
                          key: _loginFormKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelColor: Colors.white,
                                  label: 'userName'.tr(),
                                  onSave: (value) => _email = value,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'emptyFieldValidation'.tr();
                                    }
                                    return null;
                                  }),
                              CustomTextField(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelColor: Colors.white,
                                  isPasswordField: true,
                                  inputAction: TextInputAction.done,
                                  label: 'password'.tr(),
                                  onSave: (value) => _password = value,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'emptyFieldValidation'.tr();
                                    }
                                    return null;
                                  }),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                constraints:
                                    const BoxConstraints.expand(height: 45),
                                child: CustomElevatedButton(
                                  isLoading: _isLoading,
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          if (_loginFormKey.currentState ==
                                                  null ||
                                              !_loginFormKey.currentState!
                                                  .validate()) {
                                            return;
                                          }
                                          _loginFormKey.currentState?.save();
                                          UserLoginParams params =
                                              UserLoginParams(
                                                  email: _email,
                                                  password: _password);
                                          context
                                              .read<LoginCubit>()
                                              .login(params);
                                        },
                                  child: Container(
                                    constraints: const BoxConstraints.expand(),
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'signIn',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.white),
                                          ).tr(),
                                        ),
                                        const Positioned(
                                          top: 8,
                                          right: 0,
                                          bottom: 8,
                                          child: Icon(
                                            Ionicons.chevron_forward_outline,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
