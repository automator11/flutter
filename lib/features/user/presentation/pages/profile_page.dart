// import 'package:easy_localization/easy_localization.dart';
// import 'package:email_validator/email_validator.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// 
// import 'package:insurance_app/core/presentation/cubit/auth_cubit/auth_cubit.dart';
// import 'package:insurance_app/graphql/__generated/fragment_user.graphql.dart';
// import 'package:intl_phone_field/country_picker_dialog.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:intl_phone_field/phone_number.dart';
//
// import '../../../../config/themes/colors.dart';
// import '../../../../core/presentation/widgets/widgets.dart';
// import '../../params/params.dart';
// import '../cubit/profile_cubit/profile_cubit.dart';
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({Key? key}) : super(key: key);
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   final _profileFormKey = GlobalKey<FormState>();
//
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//
//   Fragment$User? user;
//
//   String _firstName = '';
//   String _lastName = '';
//   String _phone = '';
//   String _email = '';
//
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     user = context.read<AuthCubit>().user;
//     _firstNameController.text = user?.name ?? '';
//     _emailController.text = user?.email ?? '';
//     _phoneController.text = user?.mobile ?? '';
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
//       body: BlocListener<ProfileCubit, ProfileState>(
//         listener: (context, state) async {
//           if (_isLoading) {
//             _isLoading = false;
//             Navigator.pop(context);
//           }
//           if (state is ProfileFailure) {
//             String errorMessage = state.message;
//             MyDialogs.showErrorDialog(context, errorMessage);
//           }
//           if (state is ProfileSuccess) {
//             await MyDialogs.showSuccessDialog(context, 'profileUpdated'.tr());
//             if (mounted) {
//               Navigator.pop(context, true);
//             }
//           }
//           if (state is ProfileLoading) {
//             if (mounted) {
//               MyDialogs.showLoadingDialog(context, 'updatingUser'.tr());
//             }
//             _isLoading = true;
//           }
//         },
//         child: SingleChildScrollView(
//           child: Form(
//             key: _profileFormKey,
//             child: Padding(
//               padding: EdgeInsets.fromLTRB(width * 0.1, 50, width * 0.1, 0.0),
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
//                     controller: _firstNameController,
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
//                       controller: _lastNameController,
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
//                     controller: _emailController,
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
//                     controller: _phoneController,
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
//                             child: Text('update'.tr(),
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w400)),
//                           ),
//                         ),
//                         onPressed: () async {
//                           // save de fields
//                           final form = _profileFormKey.currentState;
//                           form?.save();
//                           if (form?.validate() ?? false) {
//                             UserUpdateParams params = UserUpdateParams(
//                               id: user!.id!,
//                               name: _firstName,
//                               lastName: _lastName,
//                               phone: _phone,
//                               email: _email,
//                             );
//                             context.read<ProfileCubit>().updateUser(params);
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
