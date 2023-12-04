import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../config/themes/colors.dart';
import '../../../../injector.dart';
import '../../../main_screen/presentation/widgets/widgets.dart';
import '../cubits/alerts_cubit.dart';
import '../widgets/widgets.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).viewPadding;
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding:
                EdgeInsets.only(left: 24, right: 24, top: safePadding.top),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  title: const Text(
                    'alerts',
                    style: TextStyle(color: kSecondaryColor),
                  ).tr(),
                  backgroundColor: Colors.white,
                ),
                SliverFillRemaining(
                  child: BlocProvider(
                    create: (context) => injector<AlertsCubit>(),
                    child: const AlertsListWidget(),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              top: safePadding.top,
              left: 24,
              child: MenuButton(
                onTap: () {
                  context.pop(false);
                },
                icon: const Icon(
                  Ionicons.chevron_back_outline,
                  color: Colors.black,
                  size: 40,
                ),
              )),
        ],
      ),
    );
  }
}
