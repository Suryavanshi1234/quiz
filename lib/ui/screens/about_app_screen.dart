import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  static const _titleList = [
    contactUs,
    aboutUs,
    termsAndConditions,
    privacyPolicy,
  ];

  static const _leadingList = [
    "contactus_icon.svg",
    "aboutus_icon.svg",
    "termscond_icon.svg",
    "privacypolicy_icon.svg",
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: QAppBar(
        title: Text(
            AppLocalization.of(context)!.getTranslatedValues(aboutQuizAppKey)!),
      ),
      body: Stack(
        children: [
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              vertical: size.height * UiUtils.vtMarginPct,
              horizontal: size.width * UiUtils.hzMarginPct,
            ),
            separatorBuilder: (_, i) => const SizedBox(height: 18),
            itemBuilder: (_, i) {
              return ListTile(
                onTap: () => Navigator.of(context).pushNamed(
                  Routes.appSettings,
                  arguments: _titleList[i],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: SvgPicture.asset(
                  UiUtils.getImagePath(_leadingList[i]),
                  width: 24,
                  height: 24,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  AppLocalization.of(context)!
                      .getTranslatedValues(_titleList[i])!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeights.medium,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
                tileColor: Theme.of(context).colorScheme.background,
              );
            },
            itemCount: _titleList.length,
          ),
        ],
      ),
    );
  }
}
