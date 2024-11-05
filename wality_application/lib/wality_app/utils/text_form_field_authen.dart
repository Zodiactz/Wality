// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';

class TextFormFieldAuthen extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorMessage;
  final FocusNode focusNode;
  final double height;
  final Function(String)? onFieldSubmitted;
  final Color borderColor;
  final Function(PointerDownEvent)? onTapOutside;
  final bool enableInteractiveSelection;

  const TextFormFieldAuthen({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.prefixIcon,
    this.suffixIcon,
    this.errorMessage,
    required this.focusNode,
    this.height = 40.0,
    this.onFieldSubmitted,
    this.borderColor = Colors.grey,
    this.onTapOutside,
    this.enableInteractiveSelection = true,
  });

  @override
  _TextFormFieldAuthenState createState() => _TextFormFieldAuthenState();
}

class _TextFormFieldAuthenState extends State<TextFormFieldAuthen> {
  String? errorText;
  Color currentBorderColor = Colors.grey;
  Timer? _errorTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    errorText = widget.errorMessage;
    widget.controller.addListener(_onTextChanged);
    currentBorderColor = widget.borderColor;
    
    // Set up focus listener to reset border color when focus is lost
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!widget.focusNode.hasFocus && !_isDisposed) {
      setState(() {
        currentBorderColor = Colors.grey;
      });
    }
  }

  @override
  void didUpdateWidget(TextFormFieldAuthen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the border color changes to red (error state)
    if (widget.borderColor == Colors.red && oldWidget.borderColor != Colors.red) {
      _errorTimer?.cancel();

      setState(() {
        currentBorderColor = Colors.red;
      });

      // Start a new timer to reset the border color after 3 seconds
      _errorTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && !_isDisposed) {
          setState(() {
            currentBorderColor = Colors.grey;
          });
        }
      });
    } else if (widget.borderColor != oldWidget.borderColor) {
      setState(() {
        currentBorderColor = widget.borderColor;
      });
    }
  }

  void _onTextChanged() {
    if (errorText != null && widget.controller.text.isNotEmpty) {
      setState(() {
        errorText = null;
        currentBorderColor = Colors.grey;
      });
    }
  }

  void _resetBorderColor() {
    if (!_isDisposed && mounted) {
      setState(() {
        currentBorderColor = Colors.grey;
        errorText = null;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChange);
    _errorTimer?.cancel();
    _resetBorderColor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      focusNode: widget.focusNode,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      onTapOutside: widget.onTapOutside,
      onFieldSubmitted: (value) {
        widget.onFieldSubmitted?.call(value);
        _resetBorderColor();
      },
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.black54),
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: currentBorderColor, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: currentBorderColor, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: currentBorderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: currentBorderColor, width: 1.0),
        ),
      ),
    );
  }
}