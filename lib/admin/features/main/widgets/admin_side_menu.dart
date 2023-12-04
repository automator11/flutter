import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/themes/colors.dart';
import '../../../../core/resources/destinations.dart';
import '../../../../features/main_screen/presentation/cubit/cubits.dart';
import '../../../../features/main_screen/presentation/widgets/widgets.dart';

class AdminSideMenu extends StatefulWidget {
  final VoidCallback? closeDrawer;
  final int currentIndex;
  final Function(int) onItemSelected;

  const AdminSideMenu(
      {super.key,
      required this.currentIndex,
      required this.onItemSelected,
      this.closeDrawer});

  @override
  State<AdminSideMenu> createState() => _AdminSideMenuState();
}

class _AdminSideMenuState extends State<AdminSideMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      backgroundColor: kSecondaryColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 140,
              padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 0.0),
              child: Image.asset(
                'assets/images/logo_light.png',
                fit: BoxFit.contain,
                height: 100,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                    (context, index) => DrawerListTile(
                          active: widget.currentIndex == index,
                          title: adminDestinations[index].title.tr(),
                          leading: adminDestinations[index].icon,
                          activeLeading: adminDestinations[index].selectedIcon,
                          press: () {
                            widget.onItemSelected(index);
                            if (widget.closeDrawer != null) {
                              Scaffold.of(context).closeDrawer();
                            }
                          },
                        ),
                    childCount: adminDestinations.length)),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 16.0, top: 20),
                child: DrawerListTile(
                  active: false,
                  title: 'logout'.tr(),
                  leading: Image.asset(
                    'assets/icons/logout.png',
                  ),
                  press: () {
                    context.read<AuthCubit>().logout();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
