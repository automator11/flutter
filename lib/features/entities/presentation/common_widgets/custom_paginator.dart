import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/themes/colors.dart';

class CustomPaginator extends StatefulWidget {
  final int? nextPage;
  final int pageSize;
  final int total;
  final Function(int) onPageSelected;

  const CustomPaginator(
      {super.key,
      required this.pageSize,
      this.nextPage,
      required this.onPageSelected,
      required this.total});

  @override
  State<CustomPaginator> createState() => _CustomPaginatorState();
}

class _CustomPaginatorState extends State<CustomPaginator> {
  late int prevPage;
  late int nextPage;
  late List<int> interPages;
  late int currentPage;

  void _initPages() {
    int lastPage =
        widget.total == widget.pageSize ? 0 : widget.total ~/ widget.pageSize;
    currentPage = widget.nextPage != null
        ? widget.nextPage! - 1
        : widget.total <= widget.pageSize
            ? 0
            : lastPage;
    prevPage = currentPage > 0 ? currentPage - 1 : -1;
    nextPage = widget.nextPage != null
        ? widget.nextPage!
        : lastPage == 0
            ? -1
            : lastPage;
    int pages = 3;
    if (lastPage - currentPage < 3 && lastPage < 2) {
      pages = lastPage + 1;
    }
    interPages = List.generate(pages, (index) {
      if (lastPage - currentPage < 3) {
        return lastPage < 2 ? index : lastPage - (pages - index);
      }
      return currentPage + index;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPages();
  }

  @override
  void didUpdateWidget(covariant CustomPaginator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initPages();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 280,
          height: 35,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: kSecondaryBackground,
              border: const Border.fromBorderSide(
                  BorderSide(color: kInputDefaultBorderColor))),
          alignment: Alignment.centerRight,
          child: Center(
            child: const Text(
              'entriesShown',
              style: TextStyle(
                  color: kPrimaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ).tr(args: [
              _getFirstEntry().toString(),
              getLastEntry().toString(),
              widget.total.toString()
            ]),
          ),
        ),
        Container(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            constraints: const BoxConstraints.expand(height: 35, width: 300),
            decoration: BoxDecoration(
                color: kSecondaryBackground,
                borderRadius: BorderRadius.circular(10),
                border: const Border.fromBorderSide(
                    BorderSide(color: kInputDefaultBorderColor))),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                      onPressed: prevPage == -1
                          ? null
                          : () => widget.onPageSelected(prevPage),
                      child: const Text('previous',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryText))
                          .tr()),
                ),
                ...interPages
                    .map((page) => SizedBox(
                          width: 35,
                          height: 35,
                          child: TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: page == currentPage
                                      ? kSecondaryColor
                                      : kSecondaryBackground,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  side: const BorderSide(
                                      color: kInputDefaultBorderColor)),
                              onPressed: () => widget.onPageSelected(page),
                              child: Text('${page + 1}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: page == currentPage
                                          ? Colors.white
                                          : kPrimaryText))),
                        ))
                    ,
                Expanded(
                  child: TextButton(
                      onPressed: widget.nextPage == null
                          ? null
                          : () => widget.onPageSelected(nextPage),
                      child: const Text('next',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryText))
                          .tr()),
                )
              ],
            )),
      ],
    );
  }

  int _getFirstEntry() {
    return widget.pageSize * currentPage + 1;
  }

  int getLastEntry() {
    final last = widget.pageSize > widget.total
        ? widget.total
        : widget.pageSize *
            (widget.nextPage ?? (widget.total ~/ widget.pageSize + 1));
    return last;
  }
}
