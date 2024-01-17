import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BoxEmpty {
  static const SizedBox sizeBox5 = SizedBox(height: 5, width: 5);
  static const SizedBox sizeBox10 = SizedBox(height: 10, width: 10);
  static const SizedBox sizeBox15 = SizedBox(height: 15, width: 15);
  static const SizedBox sizeBox20 = SizedBox(height: 20, width: 20);
  static const SizedBox sizeBox25 = SizedBox(height: 25, width: 25);
}

Widget customInput(TextEditingController controller, BuildContext context,
    String labelText, String hintText, TextInputType type,
    {String? suffixText}) {
  return TextField(
    autofocus: false,
    controller: controller,
    keyboardType: type,
    decoration: InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      hintStyle: Theme.of(context).textTheme.headlineMedium,
      suffixText: suffixText,
    ),
    maxLines: null,
  );
}
