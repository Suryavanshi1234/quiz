import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app_localization.dart';

class WatchRewardAdDialog extends StatelessWidget {
  final Function onTapYesButton;
  final Function? onTapNoButton;

  const WatchRewardAdDialog({
    super.key,
    required this.onTapYesButton,
    this.onTapNoButton,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shadowColor: Colors.transparent,
      backgroundColor: Theme.of(context).colorScheme.background,
      content: Text(
        AppLocalization.of(context)!.getTranslatedValues("showAdsLbl")!,
      ),
      actions: [
        CupertinoButton(
          onPressed: () {
            onTapYesButton();
            Navigator.pop(context);
          },
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues("yesBtn")!,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        CupertinoButton(
          onPressed: () {
            if (onTapNoButton != null) {
              onTapNoButton!();
              return;
            }
            Navigator.pop(context);
          },
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues("noBtn")!,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }
}
