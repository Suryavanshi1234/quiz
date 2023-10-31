import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../utils/ui_utils.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(context) => SizedBox(
        height: 66,
        width: 168,
        child: Image.asset(UiUtils.getImagePath("bappa.png"))
        // SvgPicture.asset(
        //    UiUtils.getImagePath("splash_logo.svg"),
        //   color: Theme.of(context).primaryColor,
        // ),
      );
}
