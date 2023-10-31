import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnScreen extends StatelessWidget {
  const ReferAndEarnScreen({super.key});

  static const vtGap = 20.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final referCode =
        context.read<UserDetailsCubit>().getUserProfile().referCode!;

    var colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        leading: QBackButton(color: colorScheme.background),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: size.width,
          height: size.height * .8,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: size.height * .65,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                  ),
                  width: size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues(referAndEarn)!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.background,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * .01),
                      SizedBox(
                        height: size.height * (0.2),
                        child: SvgPicture.asset(
                          UiUtils.getImagePath("refer friends.svg"),
                        ),
                      ),

                      Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                UiUtils.getImagePath("coin.svg"),
                                width: 28,
                                height: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                context.read<SystemConfigCubit>().getEarnCoin(),
                                style: TextStyle(
                                  fontWeight: FontWeights.bold,
                                  fontSize: 32,
                                  color: colorScheme.background,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            AppLocalization.of(context)!
                                .getTranslatedValues("getFreeCoins")!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeights.bold,
                              color: colorScheme.background,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * .01),

                      ///
                      SizedBox(
                        width: size.width * .8,
                        child: Text(
                          "${AppLocalization.of(context)!.getTranslatedValues("referFrdLbl")!} ${AppLocalization.of(context)!.getTranslatedValues(youWillGetKey)!} ${context.read<SystemConfigCubit>().getEarnCoin()} ${AppLocalization.of(context)!.getTranslatedValues(coinsLbl)!.toLowerCase()}.\n${AppLocalization.of(context)!.getTranslatedValues(theyWillGetKey)!} ${context.read<SystemConfigCubit>().getReferCoin()} ${AppLocalization.of(context)!.getTranslatedValues(coinsLbl)!.toLowerCase()}.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeights.regular,
                            color: colorScheme.background,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * .04),

                      /// your referral code
                      DottedBorder(
                        strokeWidth: 3,
                        padding: EdgeInsets.zero,
                        borderType: BorderType.RRect,
                        dashPattern: const [6, 4],
                        color: colorScheme.background.withOpacity(.5),
                        radius: const Radius.circular(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: colorScheme.onTertiary.withOpacity(0.8),
                          ),
                          height: 60,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 25.0),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalization.of(context)!
                                        .getTranslatedValues("yourRefCOdeLbl")!,
                                    style: TextStyle(
                                      color: colorScheme.background
                                          .withOpacity(.8),
                                      fontSize: 10,
                                      fontWeight: FontWeights.semiBold,
                                    ),
                                  ),
                                  Text(
                                    referCode,
                                    style: TextStyle(
                                      color: colorScheme.background,
                                      fontSize: 18,
                                      fontWeight: FontWeights.semiBold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 5),
                              VerticalDivider(
                                color: colorScheme.background.withOpacity(.4),
                                indent: 10,
                                endIndent: 10,
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: referCode),
                                  );
                                  UiUtils.setSnackbar(
                                      AppLocalization.of(context)!
                                          .getTranslatedValues(
                                              "referCodeCopyMsg")!,
                                      context,
                                      false);
                                },
                                child: Text(
                                  "Copy\nCode",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeights.semiBold,
                                    color: colorScheme.background,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 25),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * .03),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeights.regular,
                            color: colorScheme.background.withOpacity(.8),
                          ),
                          children: [
                            const TextSpan(text: 'How it works? '),
                            TextSpan(
                              text: 'Steps',
                              style: TextStyle(
                                color: colorScheme.background,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          UiUtils.bottomSheetTopRadius,
                                    ),
                                    builder: (_) {
                                      final verticalDivider = Row(
                                        children: [
                                          const SizedBox(width: 22),
                                          Container(
                                            color: const Color(0xFF22C274),
                                            width: 2,
                                            height: 68,
                                          ),
                                          const Spacer(),
                                        ],
                                      );
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          borderRadius:
                                              UiUtils.bottomSheetTopRadius,
                                        ),
                                        height: size.height * .8,
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              size.width * UiUtils.hzMarginPct +
                                                  10,
                                        ),
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.topCenter,
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 75),
                                                  _buildStep(
                                                    context,
                                                    'step_1',
                                                    'step_1_title',
                                                    'step_1_desc',
                                                  ),
                                                  verticalDivider,
                                                  _buildStep(
                                                    context,
                                                    'step_2',
                                                    'step_2_title',
                                                    'step_2_desc',
                                                  ),
                                                  verticalDivider,
                                                  _buildStep(
                                                    context,
                                                    'step_3',
                                                    'step_3_title',
                                                    'step_3_desc',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // const SizedBox(height: 75),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 32,
                                                ),
                                                child: CustomRoundedButton(
                                                  onTap: () =>
                                                      Share.share(referCode),
                                                  widthPercentage: 1,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                  buttonTitle: AppLocalization
                                                          .of(context)!
                                                      .getTranslatedValues(
                                                          'inviteFriendsLbl')!,
                                                  radius: 8.0,
                                                  showBorder: false,
                                                  height: 58,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Share Now
              Align(
                alignment: Alignment.bottomCenter,
                child: CustomRoundedButton(
                  onTap: () => Share.share(referCode),
                  widthPercentage: .9,
                  backgroundColor: Theme.of(context).primaryColor,
                  titleColor: colorScheme.background,
                  buttonTitle: AppLocalization.of(context)!
                      .getTranslatedValues("shareNowLbl")!,
                  radius: 8.0,
                  textSize: 18.0,
                  showBorder: false,
                  fontWeight: FontWeights.semiBold,
                  height: 60.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildStep(BuildContext context, String step, String title, String desc) {
    final onTertiary = Theme.of(context).colorScheme.onTertiary;
    final step0 = AppLocalization.of(context)!.getTranslatedValues(step)!;
    final title0 = AppLocalization.of(context)!.getTranslatedValues(title)!;
    final desc0 = AppLocalization.of(context)!.getTranslatedValues(desc)!;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.background,
            border: Border.all(
              color: const Color(0xff22C274),
              width: 2,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step0,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeights.bold,
                color: onTertiary,
              ),
            ),
            Text(
              title0,
              style: TextStyle(
                fontWeight: FontWeights.bold,
                fontSize: 22,
                color: onTertiary,
              ),
            ),
            Text(
              desc0,
              style: TextStyle(
                fontWeight: FontWeights.regular,
                fontSize: 16,
                color: onTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
