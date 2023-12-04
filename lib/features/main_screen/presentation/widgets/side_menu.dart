import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/themes/colors.dart';
import '../../../../core/resources/destinations.dart';
import '../../../entities/data/models/models.dart';
import '../cubit/cubits.dart';
import 'widgets.dart';

class SideMenu extends StatefulWidget {
  final VoidCallback? closeDrawer;
  final int currentIndex;
  final Function(int) onItemSelected;

  const SideMenu(
      {super.key,
      required this.currentIndex,
      required this.onItemSelected,
      this.closeDrawer});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  EntityModel? currentEstablishment;

  @override
  void initState() {
    currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    super.initState();
  }

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
                delegate: SliverChildBuilderDelegate((context, index) {
              Widget tile = DrawerListTile(
                active: widget.currentIndex == index,
                title: allDestinations[index].title.tr(),
                leading: allDestinations[index].icon,
                activeLeading: allDestinations[index].selectedIcon,
                press: () {
                  widget.onItemSelected(index);
                  if (widget.closeDrawer != null) {
                    Scaffold.of(context).closeDrawer();
                  }
                },
              );
              Widget? header;
              TextStyle headerStyle = const TextStyle(
                  color: kTertiaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500);
              if (index == 1) {
                header = Text(
                  'devices'.tr().toUpperCase(),
                  style: headerStyle,
                );
              }
              if (index == 6) {
                header = Text(
                  'animalsManagement'.tr().toUpperCase(),
                  style: headerStyle,
                );
              }
              if (index == 9) {
                header = Text(
                  'establishment'.tr().toUpperCase(),
                  style: headerStyle,
                );
              }
              if (header != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20),
                      child: header,
                    ),
                    tile
                  ],
                );
              }
              return tile;
            }, childCount: allDestinations.length)),
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
