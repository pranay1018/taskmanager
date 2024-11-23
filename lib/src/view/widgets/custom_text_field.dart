import 'package:flutter/material.dart';
import 'package:taskmanager/src/utils/color_constants.dart';

class CustomForm extends StatelessWidget {
  final String hintText;
  final double height;
  final RegExp validationRegExp;
  final bool obscureText;
  final TextEditingController controller;


  const CustomForm(
      {super.key,
        required this.hintText,
        required this.height,
        required this.validationRegExp,
        this.obscureText =false,
        required this.controller

      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: (value) {
          if (value != null && validationRegExp.hasMatch(value)) {
            return null;
          }
          return "Enter a valid ${hintText.toLowerCase()}";
        },
        decoration: InputDecoration(
          filled: true,
          fillColor:Colors.white,
          hintText: hintText,
          border: OutlineInputBorder(
            borderSide: const BorderSide(width: 2),
            borderRadius: BorderRadius.circular(12),
          ),

          hintStyle: const TextStyle(
              color: ColorConstants.text
          ),


        ),


      ),
    );
  }
}
