import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/themes/colors.dart';
import '../../../../core/resources/constants.dart';
import '../../../main_screen/presentation/cubit/cubits.dart';
import '../../../user/data/models/user_model.dart';
import '../cubits/settings_cubit/settings_cubit.dart';
import '../widgets/preference_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late UserModel? _currentUser;
  late SharedPreferences _prefs;

  bool _enableNotifications = true;
  bool _isLoading = false;

  void _getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      if (_currentUser != null) {
        final userPrefsStr = _prefs.getString(_currentUser!.id.id);
        if (userPrefsStr != null) {
          Map<String, dynamic> userPrefs = jsonDecode(userPrefsStr);
          _enableNotifications = userPrefs[kEnableNotifications] ?? true;
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  @override
  void initState() {
    _currentUser = context.read<AuthCubit>().user;
    _getPrefs();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    if (widget != oldWidget) {
      _getPrefs();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        _isLoading = state is SettingsLoading;
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              centerTitle: true,
              automaticallyImplyLeading: false,
              elevation: 0,
              title: const Text(
                'settings',
                style: TextStyle(color: kSecondaryColor),
              ).tr(),
              backgroundColor: Colors.white,
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 10),
            ),
            SliverToBoxAdapter(
              child: PreferenceTile(
                title: _enableNotifications
                    ? 'enableNotifications'.tr()
                    : 'disableNotifications'.tr(),
                subtitle: _enableNotifications
                    ? 'enableNotificationsMessages'.tr()
                    : 'disableNotificationsMessages'.tr(),
                trailing: CupertinoSwitch(
                    value: _enableNotifications,
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            if (_currentUser != null) {
                              _enableNotifications = value;
                              final userPrefsJson =
                                  _prefs.getString(_currentUser!.id.id) ?? "{}";
                              final userPrefs = jsonDecode(userPrefsJson);
                              userPrefs[kEnableNotifications] = value;
                              _prefs.setString(
                                  _currentUser!.id.id, jsonEncode(userPrefs));
                              if (!value) {
                                context
                                    .read<SettingsCubit>()
                                    .unsubscribeNotifications(
                                        _currentUser!.customerId!.id);
                              } else {
                                context
                                    .read<SettingsCubit>()
                                    .subscribeNotifications(
                                        _currentUser!.customerId!.id);
                              }
                            }
                          }),
              ),
            )
          ],
        );
      },
    );
  }
}
