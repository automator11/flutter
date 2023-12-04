import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../config/themes/colors.dart';

class CustomDropDown<T> extends StatefulWidget {
  final String? label;
  final String hint;
  final T? initialValue;
  final bool isLoading;
  final bool hasError;
  final List<T> items;
  final VoidCallback? onRefresh;
  final Function(T?)? onSave;
  final Function(T?) validator;
  final Function(T?)? onChange;
  final bool disabled;
  final TextStyle? style;
  final List<DropdownMenuItem<T>>? menuItems;
  final List<Widget> Function(BuildContext)? selectedItemBuilder;
  final bool allowNullValue;

  const CustomDropDown(
      {super.key,
      required this.items,
      this.label,
      required this.hint,
      this.initialValue,
      this.isLoading = false,
      this.hasError = false,
      this.onRefresh,
      this.onSave,
      required this.validator,
      this.onChange,
      this.disabled = false,
      this.style,
      this.menuItems,
      this.selectedItemBuilder,
      this.allowNullValue = false});

  @override
  State<CustomDropDown<T>> createState() => _CustomDropDownState();
}

class _CustomDropDownState<T> extends State<CustomDropDown<T>> {
  T? selectedValue;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      selectedValue = widget.initialValue;
    } else if (widget.items.isNotEmpty && !widget.allowNullValue) {
      selectedValue = widget.items.first;
    }
  }

  @override
  void didUpdateWidget(covariant CustomDropDown<T> oldWidget) {
    if (widget.initialValue != null) {
      selectedValue = widget.initialValue;
    } else if (widget.items.isNotEmpty && !widget.allowNullValue) {
      selectedValue = widget.items.first;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 12),
            child: Text(
              widget.label!,
              style: const TextStyle(
                  color: kPrimaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        DropdownButtonFormField<T>(
          focusColor: Colors.white,
          borderRadius: BorderRadius.circular(9),
          icon: widget.isLoading
              ? const SizedBox(
                  width: 10,
                  height: 10,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: kPrimaryColor,
                      strokeWidth: 0.5,
                    ),
                  ),
                )
              : widget.hasError
                  ? InkWell(
                      onTap: widget.onRefresh,
                      child: const Icon(
                        Ionicons.refresh_outline,
                        color: kSecondaryColor,
                      ))
                  : const Icon(
                      Ionicons.chevron_down_outline,
                      color: kPrimaryText,
                      size: 15,
                    ),
          isDense: true,
          items: widget.menuItems ??
              widget.items
                  .map((e) => DropdownMenuItem<T>(
                      value: e,
                      child: Text(
                        e.toString(),
                        style: const TextStyle(
                            color: kSecondaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ).tr()))
                  .toList(),
          selectedItemBuilder: widget.selectedItemBuilder,
          value: selectedValue,
          onChanged: widget.disabled
              ? null
              : (value) {
                  setState(() {
                    selectedValue = value;
                  });
                  if (widget.onChange != null) {
                    widget.onChange!(value);
                  }
                },
          onSaved: widget.onSave,
          hint: widget.hasError
              ? Text(
                  'errorLoadingData',
                  style: TextStyle(color: Colors.red[700]),
                ).tr()
              : Text(
                  widget.hint,
                ),
          style: widget.style ??
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          validator: (value) => widget.validator(value),
          decoration: const InputDecoration(
            contentPadding:
                EdgeInsets.only(left: 16, top: 12, bottom: 12, right: 16),
          ),
        ),
      ],
    );
  }
}
