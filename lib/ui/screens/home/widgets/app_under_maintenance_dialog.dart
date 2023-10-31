import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class AppUnderMaintenanceDialog extends StatelessWidget {
  const AppUnderMaintenanceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.275),
              width: MediaQuery.of(context).size.width * (0.8),
              child: SvgPicture.asset(
                  UiUtils.getImagePath("undermaintenance.svg")),
            ),
            Text(
              AppLocalization.of(context)!
                  .getTranslatedValues(appUnderMaintenanceKey)!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColor),
            )
          ],
        ),
      ),
    );
  }
}
