import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

import '../../../../config/routes/routes.dart';
import '../../../../config/themes/colors.dart';
import '../../../main_screen/presentation/widgets/widgets.dart';
import '../cubit/reset_password_cubit/reset_password_cubit.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _forgotPasswordFormKey = GlobalKey<FormState>();

  String _email = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackground,
      body: BlocListener<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) async {
          if (_isLoading) {
            setState(() {
              _isLoading = false;
            });
          }
          if (state is ResetPasswordFailure) {
            String errorMessage = state.message;
            MyDialogs.showErrorDialog(context, errorMessage);
          }
          if (state is ResetPasswordSuccess) {
            await MyDialogs.showSuccessDialog(
                context, 'requestResetPasswordSuccess'.tr());

            if (mounted) {
              Navigator.pop(context, true);
            }
          }
          if (state is ResetPasswordLoading) {
            setState(() {
              _isLoading = true;
            });
          }
        },
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Align(
            alignment: Alignment.topCenter,
            child: Card(
              elevation: 4.0,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Container(
                color: kSecondaryBackground,
                child: Container(
                  width: 345,
                  constraints: const BoxConstraints(maxHeight: 500),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.only(
                      //     top: 20,
                      //   ),
                      //   child: SizedBox(
                      //     width: 25.0,
                      //     height: 25.0,
                      //     child: Image.asset(
                      //       'assets/images/logo.png',
                      //       width: 25.0,
                      //       height: 25.0,
                      //       fit: BoxFit.contain,
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: const Text(
                          'forgotPassword',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Circular',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ).tr(),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: const Text(
                            'forgotPasswordSubtitle',
                            style: TextStyle(fontSize: 14),
                          ).tr(),
                        ),
                      ),
                      const SizedBox(
                        height: 26,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _forgotPasswordFormKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                  label: 'email'.tr(),
                                  onSave: (value) => _email = value,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'emptyFieldValidation'.tr();
                                    }
                                    if (!EmailValidator.validate(value)) {
                                      return 'emailValidation'.tr();
                                    }
                                    return null;
                                  }),
                              const SizedBox(
                                height: 12,
                              ),
                              Container(
                                constraints:
                                    const BoxConstraints.expand(height: 48),
                                child: ElevatedButton(
                                  style: Theme.of(context)
                                      .elevatedButtonTheme
                                      .style,
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          if (_forgotPasswordFormKey
                                                      .currentState ==
                                                  null ||
                                              !_forgotPasswordFormKey
                                                  .currentState!
                                                  .validate()) {
                                            return;
                                          }
                                          context
                                              .read<ResetPasswordCubit>()
                                              .sendResetPasswordEmail(_email);
                                        },
                                  child: const Text(
                                    'forgotPassword',
                                    style: TextStyle(color: Colors.white),
                                  ).tr(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: _isLoading
                            ? null
                            : () async {
                                context.goNamed(kLoginPageRoute);
                              },
                        child: const Text(
                          'login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kPrimaryColor,
                          ),
                        ).tr(),
                      ),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }
}
