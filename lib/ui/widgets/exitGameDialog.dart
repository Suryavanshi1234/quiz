import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class ExitGameDialog extends StatelessWidget {
  final Function()? onTapYes;

  const ExitGameDialog({super.key, this.onTapYes});

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.nunito(
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onTertiary,
      ),
    );

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.background,
      shadowColor: Colors.transparent,
      content: Text(
        AppLocalization.of(context)!.getTranslatedValues("quizExitLbl")!,
        style: textStyle,
      ),
      actions: [
        CupertinoButton(
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues("yesBtn")!,
              style: textStyle,
            ),
            onPressed: () {
              if (onTapYes != null) {
                onTapYes!();
              } else {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            }),
        CupertinoButton(
          onPressed: Navigator.of(context).pop,
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues("noBtn")!,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}
