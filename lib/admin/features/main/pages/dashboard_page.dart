import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:trackeano_web_app/config/routes/routes.dart';

import '../../../../injector.dart';
import '../../customers/presentation/cubits/customers_list_cubit/customers_list_cubit.dart';
import '../widgets/widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        int tilesPerRow = constraints.maxWidth ~/ 300;
        return GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: tilesPerRow,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          children: [
            DashBoardTileWidget(
              title: 'customers'.tr(),
              icon: const Icon(
                Ionicons.storefront_outline,
                color: Colors.white,
                size: 100,
              ),
              onTap: () {
                context.goNamed(kAdminCustomersPageRoute);
              },
            ),
            DashBoardTileWidget(
              title: 'users'.tr(),
              icon: const Icon(
                Ionicons.people_outline,
                color: Colors.white,
                size: 100,
              ),
              onTap: () {
                context.goNamed(kAdminUsersPageRoute);

              },
            ),
            DashBoardTileWidget(
              title: 'devices'.tr(),
              icon: const Icon(
                Ionicons.rocket_outline,
                color: Colors.white,
                size: 100,
              ),
              onTap: () {
                context.goNamed(kAdminDevicesPageRoute);
              },
            ),
            DashBoardTileWidget(
              title: 'clientsManagement'.tr(),
              icon: const Icon(
                Ionicons.stats_chart_outline,
                color: Colors.white,
                size: 100,
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => BlocProvider(
                        create: (context) => injector<CustomersListCubit>(),
                        child: const SelectCustomerDialog()));
              },
            ),
          ],
        );
      }),
    );
  }
}
