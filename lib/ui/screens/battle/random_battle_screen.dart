import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/rewarded_ad_cubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/create_or_join_screen.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/top_curve_clipper.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/watchRewardAdDialog.dart';
import 'package:flutterquiz/utils/assets_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class RandomBattleScreen extends StatefulWidget {
  const RandomBattleScreen({super.key});

  static Route<RandomBattleScreen> route(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
        child: const RandomBattleScreen(),
      ),
    );
  }

  @override
  State<RandomBattleScreen> createState() => _RandomBattleScreenState();
}

class _RandomBattleScreenState extends State<RandomBattleScreen> {
  String selectedCategory = selectCategoryKey;
  String selectedCategoryId = "0";

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context.read<RewardedAdCubit>().createRewardedAd(context,
          onFbRewardAdCompleted: _addCoinsAfterRewardAd);
      if (context.read<SystemConfigCubit>().getIsCategoryEnableForBattle() ==
          "1") {
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
              languageId: UiUtils.getCurrentQuestionLanguageId(context),
              type: UiUtils.getCategoryTypeNumberFromQuizType(QuizTypes.battle),
              userId: context.read<UserDetailsCubit>().userId(),
            );
      }
    });
    super.initState();
  }

  void _addCoinsAfterRewardAd() {
    //ad rewards here
    //once user sees ad then add coins to user wallet
    context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: lifeLineDeductCoins,
        );

    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
          context.read<UserDetailsCubit>().userId(),
          lifeLineDeductCoins,
          true,
          watchedRewardAdKey,
        );
  }

  Widget _buildDropDown({
    required List<Map<String, String?>> values,
    required String keyValue,
  }) {
    selectedCategory = values.map((e) => e['name']).toList().first!;
    selectedCategoryId = values.map((e) => e['id']).toList().first!;

    return StatefulBuilder(
      builder: (context, setState) {
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.background,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DropdownButton<String>(
            key: Key(keyValue),
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(8),
            dropdownColor: colorScheme.background,
            style: TextStyle(
              color: colorScheme.onTertiary,
              fontSize: 16,
              fontWeight: FontWeights.regular,
            ),
            isExpanded: true,
            alignment: Alignment.center,
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.onTertiary.withOpacity(0.4),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onTertiary,
              ),
            ),
            value: selectedCategory,
            hint: Text(
              AppLocalization.of(context)!
                  .getTranslatedValues(selectCategoryKey)!,
              style: TextStyle(
                color: colorScheme.onTertiary.withOpacity(0.4),
                fontSize: 16,
                fontWeight: FontWeights.regular,
              ),
            ),
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;

                // set id for selected category
                for (var v in values) {
                  if (v['name'] == selectedCategory) {
                    selectedCategoryId = v['id']!;
                  }
                }
              });
            },
            items: values.map((e) => e['name']).toList().map((name) {
              return DropdownMenuItem(
                value: name,
                child: name == selectCategoryKey
                    ? Text(AppLocalization.of(context)!
                        .getTranslatedValues(selectCategoryKey)!)
                    : Text(name!),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget selectCategoryDropDown() {
    return context.read<SystemConfigCubit>().getIsCategoryEnableForBattle() ==
            '1'
        ? BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
            listener: (context, state) {
              if (state is QuizCategorySuccess) {
                setState(() {
                  selectedCategory = state.categories.first.categoryName!;
                  selectedCategoryId = state.categories.first.id!;
                });
              }

              if (state is QuizCategoryFailure) {
                if (state.errorMessage == unauthorizedAccessCode) {
                  UiUtils.showAlreadyLoggedInDialog(context: context);
                  return;
                }
                showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                                //context.read<QuizCategoryCubit>().getQuizCategory(UiUtils.getCurrentQuestionLanguageId(context), "");
                              },
                              child: Text(
                                AppLocalization.of(context)!
                                    .getTranslatedValues(retryLbl)!,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          ],
                          content: Text(AppLocalization.of(context)!
                              .getTranslatedValues(
                                  convertErrorCodeToLanguageKey(
                                      state.errorMessage))!),
                        )).then((value) {
                  if (value != null && value) {
                    context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
                          languageId:
                              UiUtils.getCurrentQuestionLanguageId(context),
                          type: UiUtils.getCategoryTypeNumberFromQuizType(
                              QuizTypes.battle),
                          userId: context.read<UserDetailsCubit>().userId(),
                        );
                  }
                });
              }
            },
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: state is QuizCategorySuccess
                    ? _buildDropDown(
                        values: state.categories
                            .map((e) => {"name": e.categoryName, "id": e.id})
                            .toList(),
                        keyValue: "selectCategorySuccess",
                      )
                    : Opacity(
                        opacity: 0.65,
                        child: _buildDropDown(
                          values: [
                            {"name": selectCategoryKey, "id": "0"}
                          ],
                          keyValue: "selectCategory",
                        ),
                      ),
              );
            },
          )
        : const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
      listener: (context, state) {
        if (state is UpdateScoreAndCoinsFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                /// Title & Back Btn
                Container(
                  width: size.width,
                  height: size.height * .45,
                  color: Theme.of(context).primaryColor,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      /// BG
                      SvgPicture.asset(
                        AssetsUtils.getImagePath("battle_design.svg"),
                        fit: BoxFit.cover,
                        width: size.width,
                        height: size.height,
                      ),

                      /// VS
                      Padding(
                        padding: const EdgeInsets.only(top: 75, left: 3),
                        child: SvgPicture.asset(
                          AssetsUtils.getImagePath("vs.svg"),
                          width: 247.177,
                          height: 126.416,
                        ),
                      ),

                      /// Title & Back Button
                      Padding(
                        padding:
                            EdgeInsets.only(top: size.height * 0.07, left: 25),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: GestureDetector(
                                onTap: Navigator.of(context).pop,
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 24.5,
                                  color:
                                      Theme.of(context).colorScheme.background,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                AppLocalization.of(context)!
                                    .getTranslatedValues("randomLbl")!,
                                style: TextStyle(
                                  fontSize: 22,
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  child: ClipPath(
                    clipper: TopCurveClipper(),
                    child: Container(
                      width: size.width,
                      height: size.height * .63,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * UiUtils.hzMarginPct,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: size.height * .07),

                          /// Select Category
                          if (context
                                  .read<SystemConfigCubit>()
                                  .getIsCategoryEnableForBattle() ==
                              "1")
                            Text(
                              AppLocalization.of(context)!
                                  .getTranslatedValues(selectCategoryKey)!,
                              style: TextStyle(
                                fontWeight: FontWeights.regular,
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onTertiary,
                              ),
                            ),

                          /// dropDown
                          if (context
                                  .read<SystemConfigCubit>()
                                  .getIsCategoryEnableForBattle() ==
                              "1")
                            SizedBox(height: size.height * .01),
                          if (context
                                  .read<SystemConfigCubit>()
                                  .getIsCategoryEnableForBattle() ==
                              "1")
                            selectCategoryDropDown(),

                          /// Entry fees & Current user coins
                          SizedBox(height: size.height * .02),
                          _buildEntryFeesAndCoinsCard(context, size),

                          /// Let's Play
                          SizedBox(height: size.height * .04),
                          letsPlayButton(size, context),

                          /// OR
                          SizedBox(height: size.height * .02),
                          _buildOrDivider(context, size),

                          /// Let's Play
                          SizedBox(height: size.height * .02),
                          playWithFrndsButton(size, context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  CustomRoundedButton playWithFrndsButton(Size size, BuildContext context) {
    return CustomRoundedButton(
      widthPercentage: size.width,
      backgroundColor: Theme.of(context).primaryColor,
      buttonTitle:
          AppLocalization.of(context)!.getTranslatedValues("playWithFrdLbl")!,
      radius: 8,
      showBorder: false,
      height: size.height * .07,
      fontWeight: FontWeights.semiBold,
      textSize: 18,
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => BlocProvider<UpdateScoreAndCoinsCubit>(
              create: (context) =>
                  UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
              child: CreateOrJoinRoomScreen(
                quizType: QuizTypes.battle,
                title: AppLocalization.of(context)!
                    .getTranslatedValues("playWithFrdLbl")!,
              ),
            ),
          ),
        );
      },
    );
  }

  CustomRoundedButton letsPlayButton(Size size, BuildContext context) {
    return CustomRoundedButton(
      widthPercentage: size.width,
      backgroundColor: Theme.of(context).primaryColor,
      buttonTitle:
          AppLocalization.of(context)!.getTranslatedValues("letsPlay")!,
      radius: 8,
      showBorder: false,
      height: size.height * .07,
      fontWeight: FontWeights.semiBold,
      textSize: 18,
      onTap: () {
        UserProfile userProfile =
            context.read<UserDetailsCubit>().getUserProfile();

        if (int.parse(userProfile.coins!) < randomBattleEntryCoins) {
          //if ad not loaded than show not enough coins
          if (context.read<RewardedAdCubit>().state is! RewardedAdLoaded) {
            UiUtils.errorMessageDialog(
                context,
                AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(notEnoughCoinsCode))!);
            return;
          }

          showDialog(
            context: context,
            builder: (_) => WatchRewardAdDialog(
              onTapYesButton: () {
                //showAd
                context.read<RewardedAdCubit>().showAd(
                      context: context,
                      onAdDismissedCallback: _addCoinsAfterRewardAd,
                    );
              },
            ),
          );
          return;
        }
        if (selectedCategory == selectCategoryKey &&
            context.read<SystemConfigCubit>().getIsCategoryEnableForBattle() ==
                "1") {
          UiUtils.errorMessageDialog(
              context,
              AppLocalization.of(context)!
                  .getTranslatedValues(pleaseSelectCategoryKey)!);
          return;
        }

        Navigator.of(context).pushReplacementNamed(
          Routes.battleRoomFindOpponent,
          arguments: selectedCategoryId,
        );
      },
    );
  }

  Container _buildEntryFeesAndCoinsCard(BuildContext context, Size size) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      width: size.width,
      height: size.height * .14,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      "${AppLocalization.of(context)!.getTranslatedValues("entryFeesLbl")!}\n",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeights.regular,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(.4),
                  ),
                ),
                TextSpan(
                  text:
                      '$randomBattleEntryCoins ${AppLocalization.of(context)!.getTranslatedValues(coinsLbl)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeights.bold,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(
            indent: size.width * .07,
            endIndent: size.width * .07,
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(.6),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      "${AppLocalization.of(context)!.getTranslatedValues(currentCoinsKey)!}\n",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeights.regular,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(.4),
                  ),
                ),
                WidgetSpan(
                  child: BlocBuilder<UserDetailsCubit, UserDetailsState>(
                    bloc: context.read<UserDetailsCubit>(),
                    builder: (context, state) {
                      return state is UserDetailsFetchSuccess
                          ? Text(
                              "${context.read<UserDetailsCubit>().getCoins()!} ${AppLocalization.of(context)!.getTranslatedValues(coinsLbl)}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeights.bold,
                                color: Theme.of(context).colorScheme.onTertiary,
                              ),
                            )
                          : const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row _buildOrDivider(BuildContext context, Size size) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(.6),
            thickness: .5,
            indent: size.width * .1,
            endIndent: size.width * .05,
          ),
        ),
        Text(
          AppLocalization.of(context)!.getTranslatedValues(orLbl)!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeights.regular,
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(.6),
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(.6),
            thickness: .5,
            indent: size.width * .05,
            endIndent: size.width * .1,
          ),
        ),
      ],
    );
  }
}
