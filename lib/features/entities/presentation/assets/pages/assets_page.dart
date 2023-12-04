
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../config/themes/colors.dart';
import '../../../../../core/utils/debouncer.dart';
import '../../../../main_screen/presentation/cubit/cubits.dart';
import '../../../../main_screen/presentation/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../../common_widgets/widgets.dart';
import '../widgets/widgets.dart';

class AssetsPage extends StatefulWidget {
  final String assetType;
  final String title;

  const AssetsPage({super.key, required this.assetType, required this.title});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  EntityModel? currentEstablishment;

  String _search = '';
  String _title = '';

  @override
  void initState() {
    _title = widget.title;
    currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AssetsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const toolBarHeight = kToolbarHeight + 110;
      return BlocBuilder<AppStateCubit, AppState>(
        builder: (context, state) {
          if (state is AppStateUpdatedCurrentEstablishment) {
            currentEstablishment = state.establishment;
          }
          return Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: kPrimaryBackground,
            elevation: 5,
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverPersistentHeader(
                        pinned: true,
                        delegate: TitleHeader(
                          extent: toolBarHeight,
                          title: _title,
                          type: widget.assetType,
                          onSearch: (value) {
                            Debouncer deb = Debouncer(milliseconds: 500);
                            deb.run(() {
                              _search = value;
                              //TODO: call search method
                            });
                          },
                        )),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: AssetsListWidget(
                          type: widget.assetType,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                    top: 8,
                    right: 8,
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircleButton(
                        onTap: () {
                          context.goNamed(kMapPageRoute);
                        },
                        icon: const Icon(
                          Ionicons.close_outline,
                          color: kIconLightColor,
                          size: 18,
                        ),
                      ),
                    ))
              ],
            ),
          );
        },
      );
    });
  }
}
