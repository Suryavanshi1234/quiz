import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class AlreadyLoggedInDialog extends StatelessWidget {
  final Function()? onAlreadyLoggedInCallBack;

  const AlreadyLoggedInDialog({super.key, this.onAlreadyLoggedInCallBack});

  @override
  Widget build(BuildContext context) {
    final okay = AppLocalization.of(context)!.getTranslatedValues(okayLbl)!;
    final alreadyLoggedIn =
        AppLocalization.of(context)!.getTranslatedValues(alreadyLoggedInKey)!;

    final width = MediaQuery.of(context).size.width;
    final primaryColor = Theme.of(context).colorScheme.onTertiary;

    return AlertDialog(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width * .5,
            height: width * .5,
            child: SvgPicture.asset(UiUtils.getImagePath("already_login.svg")),
          ),
          const SizedBox(height: 15.0),
          Text(alreadyLoggedIn, style: TextStyle(color: primaryColor)),
          const SizedBox(height: 15.0),
          GestureDetector(
            onTap: () {
              onAlreadyLoggedInCallBack?.call();
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushReplacementNamed(Routes.login);
            },
            child: Container(
              width: width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: primaryColor),
              ),
              height: 40.0,
              child: Text(okay, style: TextStyle(color: primaryColor)),
            ),
          )
        ],
      ),
    );
  }
}
