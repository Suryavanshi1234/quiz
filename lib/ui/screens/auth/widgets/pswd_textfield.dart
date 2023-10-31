import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';

class PswdTextField extends StatefulWidget {
  const PswdTextField({
    super.key,
    required this.controller,
    this.validator,
    this.hintText,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? hintText;

  @override
  State<PswdTextField> createState() => _PswdTextFieldState();
}

class _PswdTextFieldState extends State<PswdTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onTertiary;

    return TextFormField(
      controller: widget.controller,
      style: TextStyle(
        color: textColor.withOpacity(0.8),
        fontSize: 16,
        fontWeight: FontWeights.regular,
      ),
      obscureText: _obscureText,
      obscuringCharacter: "*",
      validator: widget.validator ??
          (val) {
            if (val!.isEmpty) {
              return AppLocalization.of(context)!
                  .getTranslatedValues('passwordRequired')!;
            } else if (val.length < 6) {
              return AppLocalization.of(context)!
                  .getTranslatedValues('pwdLengthMsg')!;
            }
            return null;
          },
      decoration: InputDecoration(
        fillColor: Theme.of(context).colorScheme.background,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(15),
        hintText: widget.hintText ??
            "${AppLocalization.of(context)!.getTranslatedValues('pwdLbl')!}*",
        hintStyle: TextStyle(
          color: textColor.withOpacity(0.4),
          fontWeight: FontWeights.regular,
          fontSize: 16,
        ),
        prefixIcon: const Icon(CupertinoIcons.lock),
        prefixIconColor: textColor.withOpacity(0.4),
        suffixIconColor: textColor.withOpacity(0.4),
        suffixIcon: GestureDetector(
          child: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onTap: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
    );
  }
}
