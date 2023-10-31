import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/rewarded_ad_cubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/models/userProfile.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/top_curve_clipper.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/watchRewardAdDialog.dart';
import 'package:flutterquiz/utils/assets_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:flutterquiz/utils/user_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock/wakelock.dart';

import '../../../features/inAppPurchase/in_app_product.dart';
import '../../../utils/constants/api_body_parameter_labels.dart';

class CreateOrJoinRoomScreen extends StatefulWidget {
  const CreateOrJoinRoomScreen({
    super.key,
    required this.quizType,
    required this.title,
  });

  final QuizTypes quizType;
  final String title;

  @override
  State<CreateOrJoinRoomScreen> createState() => _CreateOrJoinRoomScreenState();
}

class _CreateOrJoinRoomScreenState extends State<CreateOrJoinRoomScreen> {
  late final bool isInAppPurchaseEnabled;
  List<InAppProduct> iapProducts = [];

  late final String _userId;

  String selectedCategory = selectCategoryKey;
  String selectedCategoryId = "0";
  TextEditingController customEntryFee = TextEditingController(text: '');
  late final int minEntryCoins;
  late List<int> entryFees;
  late int entryFee = entryFees.first;

  /// Screen Dimensions
  get scrWidth => MediaQuery.of(context).size.width;

  get scrHeight => MediaQuery.of(context).size.height;

  // App Localization
  String localisedValueOf(String key) =>
      AppLocalization.of(context)!.getTranslatedValues(key) ?? key;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();

    isInAppPurchaseEnabled =
        context.read<SystemConfigCubit>().isInAppPurchaseEnable();
    _userId = context.read<UserDetailsCubit>().userId();

    if (widget.quizType == QuizTypes.battle) {
      minEntryCoins =
          context.read<SystemConfigCubit>().getRandomBattleEntryCoins();
    } else {
      minEntryCoins = minCoinsForGroupBattleCreation;
    }
    entryFees = [
      minEntryCoins,
      minEntryCoins * 2,
      minEntryCoins * 3,
      minEntryCoins * 4,
    ];

    Future.delayed(Duration.zero, () {
      context.read<RewardedAdCubit>().createRewardedAd(context,
          onFbRewardAdCompleted: _addCoinsAfterRewardAd);
      if (isCategoryEnabled()) {
        context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
              languageId: UiUtils.getCurrentQuestionLanguageId(context),
              type: UiUtils.getCategoryTypeNumberFromQuizType(widget.quizType),
              userId: _userId,
            );
      }
    });

    if (isInAppPurchaseEnabled) {
      scheduleMicrotask(() async => iapProducts = await fetchInAppProducts());
    }
  }

  @override
  void dispose() {
    Wakelock.enable();
    super.dispose();
  }

  Future<List<InAppProduct>> fetchInAppProducts() async {
    try {
      final body = {accessValueKey: accessValue};
      final rawRes = await http.post(Uri.parse(getCoinStoreData), body: body);
      final res = jsonDecode(rawRes.body);

      if (res['error']) throw Exception(res['message'].toString());

      return List.from(res['data'].map((e) => InAppProduct.fromJson(e)));
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  bool isCategoryEnabled() {
    if (widget.quizType == QuizTypes.battle) {
      return context
              .read<SystemConfigCubit>()
              .getIsCategoryEnableForBattle()! ==
          "1";
    }
    return context
            .read<SystemConfigCubit>()
            .getIsCategoryEnableForGroupBattle()! ==
        "1";
  }

  void _addCoinsAfterRewardAd() {
    //ad rewards here
    //once user sees ad then add coins to user wallet
    context.read<UserDetailsCubit>().updateCoins(
          addCoin: true,
          coins: lifeLineDeductCoins,
        );

    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
          _userId,
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
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
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
              localisedValueOf(selectCategoryKey),
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
                    ? Text(localisedValueOf(selectCategoryKey))
                    : Text(name!),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  ///
  void showCreateRoomBottomSheet() {
    final title = localisedValueOf(
        widget.quizType == QuizTypes.battle ? "randomLbl" : "groupPlay");

    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      context: context,
      builder: (_) {
        final colorScheme = Theme.of(context).colorScheme;

        return StatefulBuilder(builder: (context, setState) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: UiUtils.bottomSheetTopRadius,
            ),
            height: scrHeight * 0.7,
            margin: MediaQuery.of(context).viewInsets,
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Create Room title
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "${localisedValueOf("creatingLbl")} $title",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colorScheme.onTertiary,
                    ),
                  ),
                ),

                /// horizontal divider
                const Divider(),
                const SizedBox(height: 15),

                /// select category text
                if (isCategoryEnabled())
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width *
                          UiUtils.hzMarginPct,
                    ),
                    child: Text(
                      localisedValueOf(selectCategoryKey),
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onTertiary,
                      ),
                    ),
                  ),
                const SizedBox(height: 15),

                /// Select Category Drop Down
                if (isCategoryEnabled())
                  Expanded(
                    child: BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
                        bloc: context.read<QuizCategoryCubit>(),
                        listener: (_, state) {
                          if (state is QuizCategorySuccess) {
                            selectedCategory =
                                state.categories.first.categoryName!;
                            selectedCategoryId = state.categories.first.id!;
                          }

                          if (state is QuizCategoryFailure) {
                            if (state.errorMessage == unauthorizedAccessCode) {
                              UiUtils.showAlreadyLoggedInDialog(
                                  context: context);
                              return;
                            }

                            showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                      shadowColor: Colors.transparent,
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text(
                                            localisedValueOf(retryLbl),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        )
                                      ],
                                      content: Text(
                                        localisedValueOf(
                                            convertErrorCodeToLanguageKey(
                                                state.errorMessage)),
                                      ),
                                    )).then((value) {
                              if (value != null && value) {
                                context
                                    .read<QuizCategoryCubit>()
                                    .getQuizCategoryWithUserId(
                                      languageId:
                                          UiUtils.getCurrentQuestionLanguageId(
                                              context),
                                      type: UiUtils
                                          .getCategoryTypeNumberFromQuizType(
                                              QuizTypes.groupPlay),
                                      userId: context
                                          .read<UserDetailsCubit>()
                                          .userId(),
                                    );
                              }
                            });
                          }
                        },
                        builder: (_, state) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: state is QuizCategorySuccess
                                ? _buildDropDown(
                                    values: state.categories
                                        .map((e) => {
                                              "name": e.categoryName,
                                              "id": e.id,
                                            })
                                        .toList(),
                                    keyValue: "selectCategorySuccess",
                                  )
                                : Opacity(
                                    opacity: 0.65,
                                    child: _buildDropDown(
                                      values: [
                                        {"name": selectCategoryKey, "id": "0"}
                                      ],
                                      keyValue: selectCategoryKey,
                                    ),
                                  ),
                          );
                        }),
                  ),
                const SizedBox(height: 20),

                ///
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
                  ),
                  child: Text(
                    localisedValueOf("entryCoinsForBattle"),
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
                  ),
                  child: StatefulBuilder(builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children:
                          entryFees.map((e) => _coinCard(e, state)).toList(),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: colorScheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: customEntryFee,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: colorScheme.onTertiary,
                      fontWeight: FontWeights.regular,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: localisedValueOf("plsEnterTheCoins"),
                      hintStyle: TextStyle(
                        color: colorScheme.onTertiary.withOpacity(.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localisedValueOf('yourCoins'),
                            style: TextStyle(
                              color: colorScheme.onTertiary.withOpacity(0.6),
                              fontWeight: FontWeights.regular,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${context.watch<UserDetailsCubit>().getCoins()} ${localisedValueOf(coinsLbl)}",
                            style: TextStyle(
                              color: colorScheme.onTertiary,
                              fontWeight: FontWeights.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      isInAppPurchaseEnabled
                          ? TextButton(
                              onPressed: () => Navigator.of(context).pushNamed(
                                Routes.coinStore,
                                arguments: {
                                  "isGuest": false,
                                  "iapProducts": iapProducts,
                                },
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: colorScheme.background,
                                padding: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                localisedValueOf("buyCoins"),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 14,
                                  height: 1.2,
                                  fontWeight: FontWeights.medium,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                widget.quizType == QuizTypes.battle
                    ? BlocConsumer<BattleRoomCubit, BattleRoomState>(
                        bloc: context.read<BattleRoomCubit>(),
                        listener: (context, state) {
                          if (state is BattleRoomFailure) {
                            if (state.errorMessageCode ==
                                unauthorizedAccessCode) {
                              UiUtils.showAlreadyLoggedInDialog(
                                  context: context);
                              return;
                            }
                            UiUtils.errorMessageDialog(
                              context,
                              localisedValueOf(convertErrorCodeToLanguageKey(
                                  state.errorMessageCode)),
                            );
                          } else if (state is BattleRoomCreated) {
                            //wait for others
                            Navigator.of(context).pop();
                            inviteToRoomBottomSheet();
                          }
                        },
                        builder: (context, state) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width *
                                  UiUtils.hzMarginPct,
                            ),
                            child: CustomRoundedButton(
                              widthPercentage:
                                  MediaQuery.of(context).size.width,
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 10,
                              showBorder: false,
                              height: 50,
                              onTap: () {
                                if (state is BattleRoomCreating) {
                                  return;
                                }

                                if (customEntryFee.text != "") {
                                  entryFee = int.parse(customEntryFee.text);
                                }

                                if (entryFee < 0) {
                                  UiUtils.errorMessageDialog(context,
                                      localisedValueOf(moreThanZeroCoinsKey));
                                  return;
                                }

                                UserProfile userProfile = context
                                    .read<UserDetailsCubit>()
                                    .getUserProfile();

                                if (int.parse(userProfile.coins!) < entryFee) {
                                  showAdDialog();
                                  return;
                                }

                                /// Create Room
                                context.read<BattleRoomCubit>().createRoom(
                                      categoryId: selectedCategoryId,
                                      entryFee: entryFee,
                                      name: userProfile.name,
                                      profileUrl: userProfile.profileUrl,
                                      uid: userProfile.userId,
                                      questionLanguageId:
                                          UiUtils.getCurrentQuestionLanguageId(
                                              context),
                                      shouldGenerateRoomCode: true,
                                    );
                              },
                              buttonTitle: localisedValueOf("createRoom"),
                            ),
                          );
                        },
                      )
                    : BlocConsumer<MultiUserBattleRoomCubit,
                            MultiUserBattleRoomState>(
                        bloc: context.read<MultiUserBattleRoomCubit>(),
                        listener: (_, state) {
                          if (state is MultiUserBattleRoomFailure) {
                            if (state.errorMessageCode ==
                                unauthorizedAccessCode) {
                              UiUtils.showAlreadyLoggedInDialog(
                                context: context,
                              );
                              return;
                            }
                            UiUtils.errorMessageDialog(
                              context,
                              localisedValueOf(convertErrorCodeToLanguageKey(
                                  state.errorMessageCode)),
                            );
                          } else if (state is MultiUserBattleRoomSuccess) {
                            //wait for others
                            Navigator.of(context).pop();
                            inviteToRoomBottomSheet();
                          }
                        },
                        builder: (context, state) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width *
                                  UiUtils.hzMarginPct,
                            ),
                            child: CustomRoundedButton(
                              widthPercentage:
                                  MediaQuery.of(context).size.width,
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 10,
                              showBorder: false,
                              height: 50,
                              onTap: () {
                                if (state is MultiUserBattleRoomInProgress) {
                                  return;
                                }

                                ///
                                if (entryFee < 0) {
                                  UiUtils.errorMessageDialog(
                                    context,
                                    localisedValueOf(moreThanZeroCoinsKey),
                                  );
                                  return;
                                }

                                UserProfile userProfile = context
                                    .read<UserDetailsCubit>()
                                    .getUserProfile();

                                if (customEntryFee.text != "") {
                                  entryFee = int.parse(customEntryFee.text);
                                }

                                if (int.parse(userProfile.coins!) < entryFee) {
                                  showAdDialog();
                                  return;
                                }

                                /// Create Room
                                context
                                    .read<MultiUserBattleRoomCubit>()
                                    .createRoom(
                                      categoryId: selectedCategoryId,
                                      entryFee: entryFee,
                                      name: userProfile.name,
                                      profileUrl: userProfile.profileUrl,
                                      roomType: "public",
                                      uid: userProfile.userId,
                                      questionLanguageId:
                                          UiUtils.getCurrentQuestionLanguageId(
                                              context),
                                    );
                              },
                              buttonTitle: localisedValueOf("createRoom"),
                            ),
                          );
                        }),
                const SizedBox(height: 19),
              ],
            ),
          );
        });
      },
    );
  }

  void showRoomDestroyed(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => WillPopScope(
        onWillPop: () => Future.value(false),
        child: AlertDialog(
          shadowColor: Colors.transparent,
          content: Text(
            localisedValueOf('roomDeletedOwnerLbl'),
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                localisedValueOf('okayLbl'),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  void inviteToRoomBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      context: context,
      builder: (_) {
        final colorScheme = Theme.of(context).colorScheme;

        if (widget.quizType == QuizTypes.battle) {
          String shareText = localisedValueOf("shareRoomCodeRndLbl");

          return WillPopScope(
            onWillPop: () {
              onBackTapInWaitingSheet();
              return Future.value(true);
            },
            child: BlocConsumer<BattleRoomCubit, BattleRoomState>(
              listener: (context, state) {
                if (state is BattleRoomUserFound) {
                  //if game is ready to play
                  if (state.battleRoom.readyToPlay!) {
                    //if user has joined room then navigate to quiz screen
                    if (state.battleRoom.user1!.uid !=
                        context
                            .read<UserDetailsCubit>()
                            .getUserProfile()
                            .userId) {
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.battleRoomQuiz);
                    }
                  }

                  //if owner deleted the room then show this dialog
                  if (!state.isRoomExist) {
                    if (context
                            .read<UserDetailsCubit>()
                            .getUserProfile()
                            .userId !=
                        state.battleRoom.user1!.uid) {
                      //Room destroyed by owner
                      showRoomDestroyed(context);
                    }
                  }
                }
              },
              builder: (context, state) {
                bool showShareIcon = true;
                if (state is BattleRoomUserFound) {
                  shareText = state.battleRoom.user2!.uid ==
                          context.read<UserDetailsCubit>().userId()
                      ? "Please wait, game will start soon."
                      : shareText;
                  showShareIcon = state.battleRoom.user2!.uid !=
                      context.read<UserDetailsCubit>().userId();
                }

                return StatefulBuilder(
                  builder: (context, state) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: UiUtils.bottomSheetTopRadius,
                      ),
                      height: scrHeight * 0.85,
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: scrWidth * UiUtils.hzMarginPct,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: onBackTapInWaitingSheet,
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    size: 24,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                  ),
                                ),
                                Text(
                                  localisedValueOf("joinRoom"),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: colorScheme.onTertiary,
                                  ),
                                ),
                                showShareIcon
                                    ? InkWell(
                                        onTap: () {
                                          try {
                                            String inviteMessage =
                                                "$groupBattleInviteMessage${context.read<BattleRoomCubit>().getRoomCode()}";
                                            Share.share(inviteMessage);
                                          } catch (e) {
                                            UiUtils.setSnackbar(
                                              localisedValueOf(
                                                  convertErrorCodeToLanguageKey(
                                                      defaultErrorMessageCode)),
                                              context,
                                              false,
                                            );
                                          }
                                        },
                                        child: Icon(
                                          Icons.share,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 10),

                          /// Invite Code
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colorScheme.onTertiary.withOpacity(.1),
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width *
                                  UiUtils.hzMarginPct,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 30,
                              horizontal: 45,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.read<BattleRoomCubit>().getRoomCode(),
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 18,
                                    color: colorScheme.onTertiary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  shareText,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.regular,
                                    fontSize: 16,
                                    color:
                                        colorScheme.onTertiary.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child:
                                BlocBuilder<BattleRoomCubit, BattleRoomState>(
                              builder: (_, state) {
                                print("Curr. state ${state.toString()}");
                                if (state is BattleRoomCreated) {
                                  return GridView.count(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          scrWidth * UiUtils.hzMarginPct,
                                    ),
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 20,
                                    children: [
                                      inviteRoomUserCard(
                                        true,
                                        state.battleRoom.user1!.name,
                                        state.battleRoom.user1!.profileUrl,
                                      ),
                                      inviteRoomUserCard(
                                        false,
                                        state.battleRoom.user2!.name.isEmpty
                                            ? "Player 2"
                                            : state.battleRoom.user2!.name,
                                        state.battleRoom.user2!.profileUrl,
                                      ),
                                    ],
                                  );
                                }
                                if (state is BattleRoomUserFound) {
                                  return GridView.count(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          scrWidth * UiUtils.hzMarginPct,
                                    ),
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 20,
                                    children: [
                                      inviteRoomUserCard(
                                        true,
                                        state.battleRoom.user1!.name,
                                        state.battleRoom.user1!.profileUrl,
                                      ),
                                      inviteRoomUserCard(
                                        false,
                                        state.battleRoom.user2!.name.isEmpty
                                            ? "Player 2"
                                            : state.battleRoom.user2!.name,
                                        state.battleRoom.user2!.profileUrl,
                                      ),
                                    ],
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),

                          BlocBuilder<BattleRoomCubit, BattleRoomState>(
                            bloc: context.read<BattleRoomCubit>(),
                            builder: (context, state) {
                              if (state is BattleRoomCreated) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        scrWidth * UiUtils.hzMarginPct + 10,
                                  ),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      //need minimum 2 player to start the game
                                      //mark as ready to play in database
                                      if (state.battleRoom.user2!.uid.isEmpty) {
                                        UiUtils.errorMessageDialog(
                                          context,
                                          localisedValueOf(
                                              convertErrorCodeToLanguageKey(
                                                  canNotStartGameCode)),
                                        );
                                      } else {
                                        context
                                            .read<BattleRoomCubit>()
                                            .startGame();
                                        await Future.delayed(
                                            const Duration(milliseconds: 500));
                                        //navigate to quiz screen
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                Routes.battleRoomQuiz);
                                      }
                                    },
                                    child: Text(
                                      localisedValueOf('startLbl'),
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (state is BattleRoomUserFound) {
                                if (state.battleRoom.user1!.uid !=
                                    context
                                        .read<UserDetailsCubit>()
                                        .getUserProfile()
                                        .userId) {
                                  return Container();
                                }

                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        scrWidth * UiUtils.hzMarginPct + 10,
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      //need minimum 2 player to start the game
                                      //mark as ready to play in database
                                      if (state.battleRoom.user2!.uid.isEmpty) {
                                        UiUtils.errorMessageDialog(
                                          context,
                                          localisedValueOf(
                                              convertErrorCodeToLanguageKey(
                                                  canNotStartGameCode)),
                                        );
                                      } else {
                                        context
                                            .read<BattleRoomCubit>()
                                            .startGame();
                                        await Future.delayed(
                                            const Duration(milliseconds: 500));
                                        //navigate to quiz screen
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                Routes.battleRoomQuiz);
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        )),
                                    child: Text(
                                      localisedValueOf('startLbl'),
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        } else {
          return WillPopScope(
            onWillPop: () {
              onBackTapInWaitingSheet();
              return Future.value(true);
            },
            child: BlocConsumer<MultiUserBattleRoomCubit,
                MultiUserBattleRoomState>(
              listener: (context, state) {
                if (state is MultiUserBattleRoomSuccess) {
                  //if game is ready to play
                  if (state.battleRoom.readyToPlay!) {
                    //if user has joined room then navigate to quiz screen
                    if (state.battleRoom.user1!.uid !=
                        context
                            .read<UserDetailsCubit>()
                            .getUserProfile()
                            .userId) {
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.multiUserBattleRoomQuiz);
                    }
                  }

                  //if owner deleted the room then show this dialog
                  if (!state.isRoomExist) {
                    if (context
                            .read<UserDetailsCubit>()
                            .getUserProfile()
                            .userId !=
                        state.battleRoom.user1!.uid) {
                      //Room destroyed by owner
                      showRoomDestroyed(context);
                    }
                  }
                }
              },
              builder: (context, state) {
                return StatefulBuilder(
                  builder: (context, state) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: UiUtils.bottomSheetTopRadius,
                      ),
                      height: scrHeight * 0.85,
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: scrWidth * UiUtils.hzMarginPct,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: onBackTapInWaitingSheet,
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    size: 24,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                  ),
                                ),
                                Text(
                                  localisedValueOf("joinRoom"),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: colorScheme.onTertiary,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    try {
                                      String inviteMessage =
                                          "$groupBattleInviteMessage${context.read<MultiUserBattleRoomCubit>().getRoomCode()}";
                                      Share.share(inviteMessage);
                                    } catch (e) {
                                      UiUtils.setSnackbar(
                                        localisedValueOf(
                                            convertErrorCodeToLanguageKey(
                                                defaultErrorMessageCode)),
                                        context,
                                        false,
                                      );
                                    }
                                  },
                                  child: Icon(
                                    Icons.share,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 15),

                          /// Invite Code
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colorScheme.onTertiary.withOpacity(.1),
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width *
                                  UiUtils.hzMarginPct,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 30,
                              horizontal: 45,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context
                                      .read<MultiUserBattleRoomCubit>()
                                      .getRoomCode(),
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.bold,
                                    fontSize: 18,
                                    color: colorScheme.onTertiary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  localisedValueOf("shareRoomCodeLbl"),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.regular,
                                    fontSize: 16,
                                    color:
                                        colorScheme.onTertiary.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: BlocBuilder<MultiUserBattleRoomCubit,
                                MultiUserBattleRoomState>(
                              builder: (_, state) {
                                if (state is MultiUserBattleRoomSuccess) {
                                  return GridView.count(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            scrWidth * UiUtils.hzMarginPct),
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 20,
                                    children: [
                                      inviteRoomUserCard(
                                        true,
                                        state.battleRoom.user1!.name,
                                        state.battleRoom.user1!.profileUrl,
                                      ),
                                      inviteRoomUserCard(
                                        false,
                                        state.battleRoom.user2!.name.isEmpty
                                            ? "Player 2"
                                            : state.battleRoom.user2!.name,
                                        state.battleRoom.user2!.profileUrl,
                                      ),
                                      inviteRoomUserCard(
                                        false,
                                        state.battleRoom.user3!.name.isEmpty
                                            ? "Player 3"
                                            : state.battleRoom.user3!.name,
                                        state.battleRoom.user3!.profileUrl,
                                      ),
                                      inviteRoomUserCard(
                                        false,
                                        state.battleRoom.user4!.name.isEmpty
                                            ? "Player 4"
                                            : state.battleRoom.user4!.name,
                                        state.battleRoom.user4!.profileUrl,
                                      ),
                                    ],
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          /// Start
                          BlocBuilder<MultiUserBattleRoomCubit,
                              MultiUserBattleRoomState>(
                            builder: (context, state) {
                              if (state is MultiUserBattleRoomSuccess) {
                                if (state.battleRoom.user1!.uid !=
                                    context
                                        .read<UserDetailsCubit>()
                                        .getUserProfile()
                                        .userId) {
                                  return Container();
                                }
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        scrWidth * UiUtils.hzMarginPct + 10,
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      //need minimum 2 player to start the game
                                      //mark as ready to play in database
                                      if (state.battleRoom.user2!.uid.isEmpty) {
                                        UiUtils.errorMessageDialog(
                                          context,
                                          localisedValueOf(
                                              convertErrorCodeToLanguageKey(
                                                  canNotStartGameCode)),
                                        );
                                      } else {
                                        //start quiz
                                        /*    widget.quizType==QuizTypes.battle?context.read<BattleRoomCubit>().startGame():*/ context
                                            .read<MultiUserBattleRoomCubit>()
                                            .startGame();
                                        //navigate to quiz screen
                                        widget.quizType == QuizTypes.battle
                                            ? Navigator.of(context)
                                                .pushReplacementNamed(
                                                    Routes.battleRoomQuiz)
                                            : Navigator.of(context)
                                                .pushReplacementNamed(Routes
                                                    .multiUserBattleRoomQuiz);
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    child: Text(
                                      localisedValueOf('startLbl'),
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
      },
    );
  }

  void onBackTapInWaitingSheet() {
    final textStyle = GoogleFonts.nunito(
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onTertiary,
      ),
    );
    if (widget.quizType == QuizTypes.battle) {
      if (context.read<BattleRoomCubit>().state is BattleRoomCreated ||
          context.read<BattleRoomCubit>().state is BattleRoomUserFound) {
        //if user
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shadowColor: Colors.transparent,
            backgroundColor: Theme.of(context).colorScheme.background,
            content: Text(
              localisedValueOf("roomDelete"),
              style: textStyle,
            ),
            actions: [
              CupertinoButton(
                  child: Text(
                    localisedValueOf("yesBtn"),
                    style: textStyle,
                  ),
                  onPressed: () {
                    bool createdRoom = false;

                    if (context.read<BattleRoomCubit>().state
                        is BattleRoomUserFound) {
                      createdRoom = (context.read<BattleRoomCubit>().state
                                  as BattleRoomUserFound)
                              .battleRoom
                              .user1!
                              .uid ==
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId;
                    } else {
                      createdRoom = (context.read<BattleRoomCubit>().state
                                  as BattleRoomCreated)
                              .battleRoom
                              .user1!
                              .uid ==
                          context
                              .read<UserDetailsCubit>()
                              .getUserProfile()
                              .userId;
                    }
                    //if room is created by current user then delete room
                    if (createdRoom) {
                      context.read<BattleRoomCubit>().deleteBattleRoom(
                          false); // : context.read<MultiUserBattleRoomCubit>().deleteMultiUserBattleRoom();
                    } else {
                      context
                          .read<BattleRoomCubit>()
                          .removeOpponentFromBattleRoom();
                    }
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }),
              CupertinoButton(
                onPressed: Navigator.of(context).pop,
                child: Text(localisedValueOf("noBtn"), style: textStyle),
              ),
            ],
          ),
        );
      } else if (context.read<BattleRoomCubit>().state is BattleRoomFailure) {
        Navigator.of(context).pop();
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shadowColor: Colors.transparent,
          backgroundColor: Theme.of(context).colorScheme.background,
          content: Text(localisedValueOf("roomDelete"), style: textStyle),
          actions: [
            CupertinoButton(
              child: Text(localisedValueOf("yesBtn"), style: textStyle),
              onPressed: () {
                bool createdRoom = (context
                            .read<MultiUserBattleRoomCubit>()
                            .state as MultiUserBattleRoomSuccess)
                        .battleRoom
                        .user1!
                        .uid ==
                    context.read<UserDetailsCubit>().getUserProfile().userId;

                //if room is created by current user then delete room
                if (createdRoom) {
                  context
                      .read<MultiUserBattleRoomCubit>()
                      .deleteMultiUserBattleRoom();
                } else {
                  //if room is not created by current user then remove user from room
                  context.read<MultiUserBattleRoomCubit>().deleteUserFromRoom(
                      context
                          .read<UserDetailsCubit>()
                          .getUserProfile()
                          .userId!);
                }
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              onPressed: Navigator.of(context).pop,
              child: Text(localisedValueOf("noBtn"), style: textStyle),
            ),
          ],
        ),
      );
    }
  }

  Widget inviteRoomUserCard(bool isCreator, String userName, String img) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.background,
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          img.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(27),
                  child: UserUtils.getUserProfileWidget(
                    profileUrl: img,
                    isSimpleNetworkImage: true,
                    width: 50,
                    height: 50,
                  ),
                )
              : SvgPicture.asset(
                  AssetsUtils.getImagePath("friend.svg"),
                  width: 47,
                  height: 47,
                ),
          const SizedBox(height: 20),
          Text(
            userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeights.regular,
              color: colorScheme.onTertiary,
            ),
          ),
          const SizedBox(height: 9),
          isCreator
              ? Text(
                  localisedValueOf("creator"),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeights.regular,
                    color: colorScheme.onTertiary.withOpacity(0.4),
                  ),
                )
              : Text(
                  localisedValueOf('addPlayer'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeights.regular,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.3),
                  ),
                ),
        ],
      ),
    );
  }

  void showAdDialog() {
    if (context.read<RewardedAdCubit>().state is! RewardedAdLoaded) {
      UiUtils.errorMessageDialog(
        context,
        localisedValueOf(convertErrorCodeToLanguageKey(notEnoughCoinsCode)),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => WatchRewardAdDialog(
        onTapYesButton: () => context.read<RewardedAdCubit>().showAd(
              context: context,
              onAdDismissedCallback: _addCoinsAfterRewardAd,
            ),
      ),
    );
  }

  Widget _coinCard(int coins, void Function(void Function()) state) {
    return GestureDetector(
      onTap: () => state(() => entryFee = coins),
      child: Container(
        width: 66,
        height: 86,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: entryFee == coins
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.background,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 43,
              child: Center(
                child: Text(
                  coins.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeights.regular,
                    color: entryFee == coins
                        ? Theme.of(context).colorScheme.background
                        : Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 43,
              child: Center(
                child: SvgPicture.asset(UiUtils.getImagePath("coin.svg")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showJoinRoomBottomSheet() {
    print("MS: ${context.read<MultiUserBattleRoomCubit>().state}");
    print("BS: ${context.read<BattleRoomCubit>().state}");

    final joinRoomCode = TextEditingController(text: '');
    // Reset Battle State to Initial.
    context
        .read<MultiUserBattleRoomCubit>()
        .updateState(MultiUserBattleRoomInitial(), cancelSubscription: true);
    context
        .read<BattleRoomCubit>()
        .updateState(BattleRoomInitial(), cancelSubscription: true);

    showModalBottomSheet(
      isDismissible: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      context: context,
      enableDrag: false,
      builder: (_) {
        final colorScheme = Theme.of(context).colorScheme;
        return WillPopScope(
          onWillPop: () {
            onBackTapJoinRoom();
            return Future.value(false);
          },
          child: AnimatedContainer(
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: UiUtils.bottomSheetTopRadius,
            ),
            height: scrHeight * 0.7,
            padding: const EdgeInsets.only(top: 20),
            duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Join Room title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: scrWidth * UiUtils.hzMarginPct,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: onBackTapJoinRoom,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 24,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          localisedValueOf("joinRoom"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.onTertiary,
                          ),
                        ),
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                ),

                // horizontal divider
                const Divider(),
                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.center,
                  child: Text(
                    localisedValueOf(enterRoomCodeHereKey),
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    keyboardType: TextInputType.number,
                    obscureText: false,
                    textStyle: TextStyle(color: colorScheme.onTertiary),
                    pinTheme: PinTheme(
                      selectedFillColor:
                          colorScheme.onTertiary.withOpacity(0.1),
                      inactiveColor: colorScheme.onTertiary.withOpacity(0.1),
                      activeColor: colorScheme.onTertiary.withOpacity(0.1),
                      inactiveFillColor:
                          colorScheme.onTertiary.withOpacity(0.1),
                      selectedColor: colorScheme.secondary.withOpacity(0.5),
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 45,
                      fieldWidth: 45,
                      activeFillColor: colorScheme.onTertiary.withOpacity(0.2),
                    ),
                    cursorColor: colorScheme.onTertiary,
                    animationDuration: const Duration(milliseconds: 200),
                    enableActiveFill: true,
                    onChanged: (v) {},
                    controller: joinRoomCode,
                  ),
                ),
                const SizedBox(height: 40),

                widget.quizType == QuizTypes.battle
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: BlocConsumer<BattleRoomCubit, BattleRoomState>(
                          bloc: context.read<BattleRoomCubit>(),
                          listener: (context, state) {
                            if (state is BattleRoomUserFound) {
                              Navigator.of(context).pop();
                              inviteToRoomBottomSheet();
                            } else if (state is BattleRoomFailure) {
                              if (state.errorMessageCode ==
                                  unauthorizedAccessCode) {
                                UiUtils.showAlreadyLoggedInDialog(
                                    context: context);
                                return;
                              }
                              UiUtils.errorMessageDialog(
                                context,
                                localisedValueOf(convertErrorCodeToLanguageKey(
                                    state.errorMessageCode)),
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is BattleRoomJoining) {
                              return const CircularProgressContainer();
                            }

                            return CustomRoundedButton(
                              widthPercentage:
                                  MediaQuery.of(context).size.width,
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 10,
                              showBorder: false,
                              height: 50,
                              onTap: () {
                                // Close the Sheet if roomCode is Empty.
                                final roomCode = joinRoomCode.text.trim();
                                if (roomCode.isEmpty) {
                                  Navigator.of(context).pop(true);
                                  return;
                                }

                                UserProfile user = context
                                    .read<UserDetailsCubit>()
                                    .getUserProfile();

                                context.read<BattleRoomCubit>().joinRoom(
                                      currentCoin: user.coins!,
                                      name: user.name,
                                      uid: user.userId,
                                      profileUrl: user.profileUrl,
                                      roomCode: roomCode,
                                    );
                              },
                              buttonTitle: localisedValueOf("joinRoom"),
                            );
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: BlocConsumer<MultiUserBattleRoomCubit,
                            MultiUserBattleRoomState>(
                          listener: (context, state) {
                            if (state is MultiUserBattleRoomSuccess) {
                              Navigator.of(context).pop();
                              inviteToRoomBottomSheet();
                            } else if (state is MultiUserBattleRoomFailure) {
                              if (state.errorMessageCode ==
                                  unauthorizedAccessCode) {
                                UiUtils.showAlreadyLoggedInDialog(
                                    context: context);
                                return;
                              }
                              UiUtils.errorMessageDialog(
                                context,
                                localisedValueOf(convertErrorCodeToLanguageKey(
                                    state.errorMessageCode)),
                              );
                            }
                          },
                          bloc: context.read<MultiUserBattleRoomCubit>(),
                          builder: (_, state) {
                            if (state is MultiUserBattleRoomInProgress) {
                              return const CircularProgressContainer();
                            }

                            return CustomRoundedButton(
                              widthPercentage:
                                  MediaQuery.of(context).size.width,
                              backgroundColor: Theme.of(context).primaryColor,
                              radius: 10,
                              showBorder: false,
                              height: 50,
                              onTap: () {
                                // Close Sheet if roomCode is Empty.
                                final roomCode = joinRoomCode.text.trim();
                                if (roomCode.isEmpty) {
                                  Navigator.of(context).pop(true);
                                  return;
                                }

                                UserProfile user = context
                                    .read<UserDetailsCubit>()
                                    .getUserProfile();

                                context
                                    .read<MultiUserBattleRoomCubit>()
                                    .joinRoom(
                                      currentCoin: user.coins!,
                                      name: user.name,
                                      uid: user.userId,
                                      profileUrl: user.profileUrl,
                                      roomCode: roomCode,
                                    );
                              },
                              buttonTitle: localisedValueOf("joinRoom"),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        return UiUtils.setSnackbar(
            AppLocalization.of(context)!.getTranslatedValues(enterRoomCodeMsg)!,
            context,
            false);
      }
    });
  }

  void onBackTapJoinRoom() {
    if (widget.quizType == QuizTypes.battle) {
      if (context.read<BattleRoomCubit>().state is! BattleRoomJoining) {
        Navigator.pop(context);
      }
    } else {
      if (context.read<MultiUserBattleRoomCubit>().state
          is! MultiUserBattleRoomInProgress) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("MS: ${context.read<MultiUserBattleRoomCubit>().state}");
    print("BS: ${context.read<BattleRoomCubit>().state}");

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(
            children: [
              /// Title & Back Btn
              Container(
                width: size.width,
                height: size.height * 0.65,
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
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: scrHeight * .07,
                          left: scrWidth * UiUtils.hzMarginPct,
                          right: scrWidth * UiUtils.hzMarginPct,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: Navigator.of(context).pop,
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 24.5,
                                color: Theme.of(context).colorScheme.background,
                              ),
                            ),
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 22,
                                color: Theme.of(context).colorScheme.background,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Bottom - Create/Join Container
              Positioned(
                bottom: 0,
                left: 0,
                child: ClipPath(
                  clipper: TopCurveClipper(),
                  child: Container(
                    width: size.width,
                    height: size.height * 0.4,
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    color: Theme.of(context).colorScheme.background,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// Create Room Btn
                        CustomRoundedButton(
                          widthPercentage: MediaQuery.of(context).size.width,
                          backgroundColor: Theme.of(context).primaryColor,
                          radius: 10,
                          showBorder: false,
                          height: 50,
                          onTap: showCreateRoomBottomSheet,
                          buttonTitle: localisedValueOf("createRoom"),
                        ),
                        SizedBox(height: size.height * 0.025),

                        /// Join Room Btn
                        CustomRoundedButton(
                          widthPercentage: MediaQuery.of(context).size.width,
                          backgroundColor: Theme.of(context).primaryColor,
                          radius: 10,
                          showBorder: false,
                          height: 50,
                          onTap: showJoinRoomBottomSheet,
                          buttonTitle: localisedValueOf("joinRoom"),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
