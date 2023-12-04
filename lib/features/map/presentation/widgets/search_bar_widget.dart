import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

import '../../../entities/data/models/models.dart';
import '../../../entities/presentation/assets/cubits/cubits.dart';
import '../../../main_screen/presentation/cubit/cubits.dart';
import '../cubits/map_filter_cubit/map_filter_cubit.dart';
import 'widgets.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _searchController = FloatingSearchBarController();
  EntityModel? _currentEstablishment;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentEstablishment = context.read<AppStateCubit>().currentEstablishment;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: FloatingSearchBar(
          controller: _searchController,
          hint: 'search'.tr(),
          margins: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          axisAlignment: -1.0,
          openAxisAlignment: 0.0,
          borderRadius: BorderRadius.circular(10),
          clearQueryOnClose: false,
          closeOnBackdropTap: false,
          automaticallyImplyDrawerHamburger: false,
          backdropColor: Colors.transparent,
          actions: [
            FloatingSearchBarAction.searchToClear(
              color: const Color(0xFFB6B6B6),
              searchButtonSemanticLabel: 'search'.tr(),
              clearButtonSemanticLabel: 'clear'.tr(),
            )
          ],
          onQueryChanged: (query) {
            if (_currentEstablishment == null) {
              return;
            }
            if (query.isEmpty) {
              context.read<SearchCubit>().resetSuggestions();
              return;
            }
            final parentId =
                context.read<AppStateCubit>().currentEstablishment!.id.id;

            context.read<SearchCubit>().searchAsset(parentId, query);
          },
          debounceDelay: const Duration(milliseconds: 500),
          builder: (context, transition) {
            return SearchSuggestionsWidget(
              onItemSelected: (value) async {
                context.read<MapFilterCubit>().itemSelected(value);
                _searchController.clear();
              },
              parentId: _currentEstablishment?.id.id,
            );
          }),
    );
  }
}
