import 'package:flutter/material.dart';

class TextFormFieldAuthen extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorMessage;
  final FocusNode focusNode;
  final double height;
  final onfieldSubmitted;

  const TextFormFieldAuthen({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.prefixIcon,
    this.suffixIcon,
    this.errorMessage,
    required this.focusNode,
    this.height =  40.0,
    this.onfieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return 
      SizedBox(
        height: height,
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(238, 236, 236, 1)),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(238, 236, 236, 1)),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            fillColor: Colors.white,
            filled: true,
            hintText: hintText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
          focusNode: focusNode,
          onFieldSubmitted: onfieldSubmitted,
        ),
      
    );
  }
}
