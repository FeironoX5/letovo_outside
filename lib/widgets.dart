import 'package:flutter/material.dart';

final colors = {
  'background': Color(0xff000000),
  'backgroundLight': Color(0xff2C2C2C),
  'text': Color(0xffFFFFFF),
  'textLight': Color(0xff808080),
};

final textStyles = {
  'title': TextStyle(
    color: colors['text'],
    fontSize: 33,
    fontFamily: "IFKica",
    height: 1,
    fontWeight: FontWeight.w700,
  ),
  'text': TextStyle(
      fontFamily: "Lato",
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: colors['text']),
  'subtext':
      TextStyle(fontFamily: "Lato", fontSize: 20, color: colors['textLight']),
  'textOnLight': TextStyle(
      fontFamily: "Lato",
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: colors['background']),
  'subtextOnLight':
      TextStyle(fontFamily: "Lato", fontSize: 20, color: colors['background']),
  'placeholder': TextStyle(
      fontFamily: "Lato",
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: colors['textLight']),
};

class customTextField extends StatelessWidget {
  const customTextField(
      this.hintText, this.controller, this.obscureText, this.keyboardType,
      {super.key});

  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) => TextFormField(
        keyboardType: keyboardType,
        obscureText: obscureText,
        controller: controller,
        style: textStyles['text'],
        decoration: InputDecoration(
          hintStyle: textStyles['placeholder'],
          filled: true,
          contentPadding: EdgeInsets.all(20.0),
          fillColor: colors['backgroundLight'],
          hintText: hintText,
          focusedBorder: InputBorder.none,
        ),
      );
}

class customButton extends StatelessWidget {
  const customButton(this.text, this.active, this.callback, {super.key});

  final String text;
  final bool active;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: callback,
        child: Text(text,
            style: active ? textStyles['text'] : textStyles['placeholder']),
        style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor:
                active ? colors['backgroundLight'] : colors['background'],
            padding: EdgeInsets.all(20)),
      );
}
