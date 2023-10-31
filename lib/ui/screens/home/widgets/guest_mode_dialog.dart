import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app_localization.dart';

class GuestModeDialog extends StatelessWidget {
  const GuestModeDialog({
    super.key,
    required this.onTapYesButton,
    this.onTapNoButton,
  });

  final Function() onTapYesButton;
  final Function? onTapNoButton;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: Theme.of(context).primaryColor);
    final appLocalization = AppLocalization.of(context);
    return AlertDialog(
      content: Text(appLocalization!.getTranslatedValues("guestMode")!),
      actions: [
        CupertinoButton(
          onPressed: () {
            if (onTapNoButton != null) {
              onTapNoButton!();
              return;
            }
            Navigator.pop(context);
          },
          child: Text(
            appLocalization.getTranslatedValues("cancel")!,
            style: textStyle,
          ),
        ),
        CupertinoButton(
          onPressed: onTapYesButton,
          child: Text(
            appLocalization.getTranslatedValues("loginLbl")!,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}
