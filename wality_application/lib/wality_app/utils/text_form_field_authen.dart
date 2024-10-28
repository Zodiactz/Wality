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
  });

  @override
  _TextFormFieldAuthenState createState() => _TextFormFieldAuthenState();
}

class _TextFormFieldAuthenState extends State<TextFormFieldAuthen> {
  String? errorText;
  Color? currentBorderColor;
  Timer? _errorTimer;

  @override
  void initState() {
    super.initState();
    errorText = widget.errorMessage;
    widget.controller.addListener(_onTextChanged);
    currentBorderColor = widget.borderColor;
  }

  @override
  void didUpdateWidget(TextFormFieldAuthen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the border color changes to red (error state)
    if (widget.borderColor == Colors.red && oldWidget.borderColor != Colors.red) {
      // Cancel any existing timer
      _errorTimer?.cancel();
      
      // Set the border color to red
      setState(() {
        currentBorderColor = Colors.red;
      });

      // Start a new timer to reset the border color after 3 seconds
      _errorTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            currentBorderColor = Colors.grey;
          });
        }
      });
    } else if (widget.borderColor != Colors.red) {
      // For non-error states, update the border color normally
      currentBorderColor = widget.borderColor;
    }
  }
  

  void _onTextChanged() {
    if (errorText != null && widget.controller.text.isNotEmpty) {
      setState(() {
        errorText = null;
      });
    }
  }
  

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _errorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      focusNode: widget.focusNode,
      onFieldSubmitted: widget.onFieldSubmitted,
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
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(  // Added this
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: widget.borderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: widget.borderColor, width: 1.0),
        ),
      ),
    );
  }
}