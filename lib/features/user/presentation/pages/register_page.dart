// import 'package:easy_localization/easy_localization.dart';
// import 'package:email_validator/email_validator.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// 
// import 'package:intl_phone_field/country_picker_dialog.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
//
// import '../../../../config/themes/colors.dart';
// import '../../../../core/params/params.dart';
// import '../../../../core/presentation/widgets/widgets.dart';
// import '../cubit/register_cubit/register_cubit.dart';
//
// class RegisterPage extends StatefulWidget {
//   const RegisterPage({Key? key}) : super(key: key);
//
//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }
//
// class _RegisterPageState extends State<RegisterPage> {
//   final _registerFormKey = GlobalKey<FormState>();
//
//   String _firstName = '';
//   String _lastName = '';
//   String _phone = '';
//   String _password = '';
//   String _confirmPassword = '';
//   String _email = '';
//
//   bool _obscurePasswordTextEnabled = true;
//   bool _obscureConfirmPasswordTextEnabled = true;
//   bool _isLoading = false;
//
//   bool validateStructure(String value) {
//     String pattern =
//         r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
//     RegExp regExp = RegExp(pattern);
//     return regExp.hasMatch(value);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       backgroundColor: kBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: kBackgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Ionicons.arrow_back, color: kPrimaryColor),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: BlocListener<RegisterCubit, RegisterState>(
//         listener: (context, state) {
//           if (_isLoading) {
//             _isLoading = false;
//             Navigator.pop(context);
//           }
//           if (state is RegisterFailure) {
//             String errorMessage = state.message;
//             ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text("Register failed. $errorMessage")));
//           }
//           if (state is RegisterSuccess) {
//             Navigator.pop(context, true);
//           }
//           if (state is RegisterLoading) {
//             MyDialogs.showLoadingDialog(context, 'loadingRegister'.tr());
//             _isLoading = true;
//           }
//         },
//         child: SingleChildScrollView(
//           child: Form(
//             key: _registerFormKey,
//             child: Padding(
//               padding:
//                   EdgeInsets.fromLTRB(width * 0.1, 50, width * 0.1, 0.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: <Widget>[
//                   Placeholder(
//                     fallbackHeight: 80,
//                   ),
//                   SizedBox(
//                     height: 50,
//                   ),
//                   TextFormField(
//                     style: const TextStyle(color: Colors.black),
//                     onSaved: (value) => _firstName = value ?? '',
//                     validator: (value) {
//                       if (value == '') {
//                         return 'nonEmptyField'.tr();
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(
//                       isDense: true,
//                       prefixIcon: SizedBox(
//                         width: 20,
//                       ),
//                       label: Text(
//                         '${'firstName'.tr()}*',
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   TextFormField(
//                       style: const TextStyle(color: Colors.black),
//                       onSaved: (value) => _lastName = value ?? '',
//                       validator: (value) {
//                         if (value == '') {
//                           return 'nonEmptyField'.tr();
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(
//                         isDense: true,
//                         prefixIcon: SizedBox(
//                           width: 20,
//                         ),
//                         label: Text('${'lastName'.tr()}*'),
//                       )),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   TextFormField(
//                     style: const TextStyle(color: Colors.black),
//                     onSaved: (value) => _email = value ?? '',
//                     validator: (value) => EmailValidator.validate(value!)
//                         ? null
//                         : 'validEmail'.tr(),
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: InputDecoration(
//                         isDense: true,
//                         prefixIcon: SizedBox(
//                           width: 20,
//                         ),
//                         label: Text('${'email'.tr()}*')),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   IntlPhoneField(
//                     style: const TextStyle(color: Colors.black),
//                     decoration: InputDecoration(
//                       labelText: 'phone'.tr(),
//                     ),
//                     initialCountryCode: 'US',
//                     countries: const ['US'],
//                     onChanged: (phone) {
//                       _phone = phone.completeNumber;
//                     },
//                     pickerDialogStyle: PickerDialogStyle(
//                         searchFieldInputDecoration:
//                             InputDecoration(labelText: 'searchCountry'.tr())),
//                     disableLengthCheck: true,
//                     inputFormatters: [LengthLimitingTextInputFormatter(10)],
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   TextFormField(
//                     style: const TextStyle(color: Colors.black),
//                     onSaved: (value) => _password = value ?? '',
//                     validator: (value) {
//                       if (value == '' || !validateStructure(value!)) {
//                         return 'validPassword'.tr();
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(
//                         isDense: true,
//                         prefixIcon: SizedBox(
//                           width: 20,
//                         ),
//                         label: Text('${'password'.tr()}*'),
//                         suffixIcon: Padding(
//                           padding: const EdgeInsets.only(right: 12.0),
//                           child: IconButton(
//                             icon: _obscurePasswordTextEnabled
//                                 ? const Icon(
//                                     Ionicons.visibility,
//                                     size: 30,
//                                   )
//                                 : const Icon(
//                                     Ionicons.visibility_off,
//                                     size: 30,
//                                   ),
//                             onPressed: () {
//                               setState(() {
//                                 _obscurePasswordTextEnabled =
//                                     _obscurePasswordTextEnabled ? false : true;
//                               });
//                             },
//                           ),
//                         )),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   TextFormField(
//                     style: const TextStyle(color: Colors.black),
//                     onSaved: (value) => _confirmPassword = value ?? '',
//                     validator: (value) {
//                       if (value != _password) {
//                         return 'validConfPassword'.tr();
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(
//                         isDense: true,
//                         prefixIcon: SizedBox(
//                           width: 20,
//                         ),
//                         label: Text('${'confirmPassword'.tr()}*'),
//                         suffixIcon: Padding(
//                           padding: const EdgeInsets.only(right: 12.0),
//                           child: IconButton(
//                             icon: _obscureConfirmPasswordTextEnabled
//                                 ? const Icon(
//                                     Ionicons.visibility,
//                                     size: 30,
//                                   )
//                                 : const Icon(
//                                     Ionicons.visibility_off,
//                                     size: 30,
//                                   ),
//                             onPressed: () {
//                               setState(() {
//                                 _obscureConfirmPasswordTextEnabled =
//                                     _obscureConfirmPasswordTextEnabled
//                                         ? false
//                                         : true;
//                               });
//                             },
//                           ),
//                         )),
//                   ),
//                   const SizedBox(
//                     height: 30,
//                   ),
//                   Center(
//                     child: SizedBox(
//                       height: 50,
//                       width: 160,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: kPrimaryColor),
//                         child: Container(
//                           constraints:
//                               BoxConstraints.expand(height: height * 0.08),
//                           child: Align(
//                             alignment: Alignment.center,
//                             child: Text('register'.tr(),
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w400)),
//                           ),
//                         ),
//                         onPressed: () async {
//                           // save de fields
//                           final form = _registerFormKey.currentState;
//                           form?.save();
//                           if (form?.validate() ?? false) {
//                             UserRegisterParams params = UserRegisterParams(
//                               name: _firstName,
//                               lastName: _lastName,
//                               phone: _phone,
//                               email: _email,
//                               password: _password,
//                             );
//                             context.read<RegisterCubit>().register(params);
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
