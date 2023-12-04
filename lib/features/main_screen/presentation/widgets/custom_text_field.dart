import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../config/themes/colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final Function(String) onSave;
  final Function(String)? onChange;
  final Function(String?)? validator;
  final int? minLines;
  final double? borderRadius;
  final bool readOnly;
  final bool isPasswordField;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final Color? fillColor;
  final Color? labelColor;
  final bool filled;
  final TextInputAction? inputAction;

  const CustomTextField(
      {super.key,
      required this.label,
      this.hint,
      required this.onSave,
      this.onChange,
      this.validator,
      this.minLines,
      this.borderRadius,
      this.readOnly = false,
      this.isPasswordField = false,
      this.keyboardType,
      this.controller,
      this.focusNode,
      this.inputFormatters,
      this.fillColor,
      this.labelColor,
      this.filled = false,
      this.inputAction});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureTextEnabled = true;

  @override
  void initState() {
    _obscureTextEnabled = widget.isPasswordField;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80, maxHeight: 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 12),
            child: Text(
              widget.label,
              style: TextStyle(
                  color: widget.labelColor ?? kPrimaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
          TextFormField(
            focusNode: widget.focusNode,
            controller: widget.controller,
            style: const TextStyle(color: Colors.black, fontSize: 12),
            onSaved: (value) {
              widget.onSave(value ?? '');
            },
            validator: (value) {
              if (widget.validator != null) {
                return widget.validator!(value);
              }
              return null;
            },
            onChanged: (value) {
              if (widget.onChange != null) {
                widget.onChange!(value);
              }
            },
            minLines: widget.minLines ?? 1,
            maxLines: widget.minLines ?? 1,
            textInputAction: widget.inputAction,
            readOnly: widget.readOnly,
            obscureText: _obscureTextEnabled,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
                filled: widget.filled,
                fillColor: widget.fillColor,
                isDense: true,
                hintText: widget.hint,
                suffixIcon: widget.isPasswordField
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: IconButton(
                          icon: _obscureTextEnabled
                              ? const Icon(
                                  Ionicons.eye_outline,
                                  size: 25,
                                )
                              : const Icon(
                                  Ionicons.eye_off_outline,
                                  size: 25,
                                ),
                          onPressed: () {
                            setState(() {
                              _obscureTextEnabled =
                                  _obscureTextEnabled ? false : true;
                            });
                          },
                        ),
                      )
                    : null),
          )
        ],
      ),
    );
  }
}
