import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';

class TermsAndCondition extends StatelessWidget {
  const TermsAndCondition({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeights.regular,
      color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalization.of(context)!.getTranslatedValues('termAgreement')!,
          style: textStyle,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.appSettings,
                    arguments: termsAndConditions);
              },
              child: Text(
                AppLocalization.of(context)!
                    .getTranslatedValues('termOfService')!,
                style: textStyle.copyWith(
                  decoration: TextDecoration.underline,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 5.0),
            Text(
              AppLocalization.of(context)!.getTranslatedValues('andLbl')!,
              style: textStyle,
            ),
            const SizedBox(width: 5.0),
            InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(Routes.appSettings, arguments: privacyPolicy);
              },
              child: Text(
                AppLocalization.of(context)!
                    .getTranslatedValues('privacyPolicy')!,
                style: textStyle.copyWith(
                  decoration: TextDecoration.underline,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
