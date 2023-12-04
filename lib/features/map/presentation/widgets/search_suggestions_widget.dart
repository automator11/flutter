import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../entities/data/models/models.dart';
import '../../../entities/presentation/assets/cubits/cubits.dart';
import '../../../main_screen/presentation/widgets/widgets.dart';

class SearchSuggestionsWidget extends StatefulWidget {
  final String? parentId;
  final Function(EntityModel) onItemSelected;

  const SearchSuggestionsWidget(
      {super.key, this.parentId, required this.onItemSelected});

  @override
  State<SearchSuggestionsWidget> createState() =>
      _SearchSuggestionsWidgetState();
}

class _SearchSuggestionsWidgetState extends State<SearchSuggestionsWidget> {
  final PagingController<int, EntitySearchModel> _pagingController =
      PagingController(firstPageKey: 0);

  late Widget child;

  String _searchQuery = '';
  String _parentId = '';

  @override
  void initState() {
    _parentId = widget.parentId ?? '';
    _pagingController.addPageRequestListener((pageKey) {
      context
          .read<SearchCubit>()
          .getPagedSearch(pageKey, _searchQuery, _parentId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchCubit, SearchState>(
      listener: (context, state) {
        if (state is SearchStart) {
          setState(() {
            _searchQuery = state.searchQuery;
            _parentId = state.parentId;
          });
          _pagingController.refresh();
        }
      },
      builder: (context, state) {
        if (widget.parentId == null) {
          child = const Text(
            'unselectedEstablishment',
            style: TextStyle(fontStyle: FontStyle.italic),
          ).tr();
        } else {
          if (state is SearchInitial) {
            child = const Text(
              'searchInitialMessage',
              style: TextStyle(fontStyle: FontStyle.italic),
            ).tr();
          } else {
            child = PagedListView(
              padding: EdgeInsets.zero,
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<EntitySearchModel>(
                itemBuilder: (context, asset, index) => ListTile(
                  onTap: () => widget.onItemSelected(asset.toEntityModel()),
                  title: Text(asset.latest.label),
                  subtitle: Text(asset.latest.type ?? ''),
                ),
                firstPageErrorIndicatorBuilder: (context) =>
                    FirstPageErrorWidget(
                  message: _pagingController.error.toString(),
                  onRetry: () {
                    _pagingController.refresh();
                  },
                ),
                newPageErrorIndicatorBuilder: (context) => NewPageErrorWidget(
                  message: _pagingController.error.toString(),
                  onRetry: () {
                    _pagingController.refresh();
                  },
                ),
                noItemsFoundIndicatorBuilder: (context) => NoItemsFoundWidget(
                  onRefresh: () {
                    _pagingController.refresh();
                  },
                ),
              ),
            );
          }
          if (state is SearchNewPage) {
            _pagingController.value = PagingState(
              nextPageKey: state.pageKey,
              error: state.error,
              itemList: state.page,
            );
          }
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
              color: Colors.white,
              elevation: 4.0,
              child: Container(
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: child)),
        );
      },
    );
  }
}
