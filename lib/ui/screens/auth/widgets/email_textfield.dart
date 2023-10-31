import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/validators.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onTertiary;
    final hintText =
        "${AppLocalization.of(context)!.getTranslatedValues('emailAddress')!}*";

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      validator: (val) => Validators.validateEmail(
        val!,
        AppLocalization.of(context)!.getTranslatedValues('emailRequiredMsg')!,
        AppLocalization.of(context)!.getTranslatedValues('enterValidEmailMsg'),
      ),
      style: TextStyle(
        color: textColor.withOpacity(0.8),
        fontSize: 16,
        fontWeight: FontWeights.regular,
      ),
      decoration: InputDecoration(
        fillColor: Theme.of(context).colorScheme.background,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.mail_outline_rounded),
        prefixIconColor: textColor.withOpacity(0.4),
        hintText: hintText,
        hintStyle: TextStyle(
          color: textColor.withOpacity(0.4),
          fontSize: 16,
          fontWeight: FontWeights.regular,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
