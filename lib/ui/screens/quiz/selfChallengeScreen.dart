import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class SelfChallengeScreen extends StatefulWidget {
  const SelfChallengeScreen({super.key});

  @override
  State<SelfChallengeScreen> createState() => _SelfChallengeScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => const SelfChallengeScreen());
  }
}

class _SelfChallengeScreenState extends State<SelfChallengeScreen> {
  static const String _defaultSelectedCategoryValue = selectCategoryKey;
  static const String _defaultSelectedSubcategoryValue = selectSubCategoryKey;

  //to display category and suncategory
  String? selectedCategory = _defaultSelectedCategoryValue;
  String? selectedSubcategory = _defaultSelectedSubcategoryValue;

  //id to pass for selfChallengeQuestionsScreen
  String? selectedCategoryId = "";
  String? selectedSubcategoryId = "";

  //minutes for self challenge
  int? selectedMinutes;

  //nunber of questions
  int? selectedNumberOfQuestions;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
            type: UiUtils.getCategoryTypeNumberFromQuizType(
                QuizTypes.selfChallenge),
            userId: context.read<UserDetailsCubit>().userId(),
          );
    });
  }

  void startSelfChallenge() {
    //
    if (context.read<SubCategoryCubit>().state is SubCategoryFetchFailure) {
      //If there is not any sub category then fetch the all quesitons from given category
      if ((context.read<SubCategoryCubit>().state as SubCategoryFetchFailure)
              .errorMessage ==
          "102") {
        //

        if (selectedCategory != _defaultSelectedCategoryValue &&
            selectedMinutes != null &&
            selectedNumberOfQuestions != null) {
          //to see what keys to pass in arguments see static function route of SelfChallengeQuesitonsScreen

          print("Get questions");
          Navigator.of(context)
              .pushNamed(Routes.selfChallengeQuestions, arguments: {
            "numberOfQuestions": selectedNumberOfQuestions.toString(),
            "categoryId": selectedCategoryId, //
            "minutes": selectedMinutes,
            "subcategoryId": "",
          });
          return;
        } else {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          UiUtils.setSnackbar(
              AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(selectAllValuesCode))!,
              context,
              false);
          return;
        }
      }
    }

    if (selectedCategory != _defaultSelectedCategoryValue &&
        selectedSubcategory != _defaultSelectedSubcategoryValue &&
        selectedMinutes != null &&
        selectedNumberOfQuestions != null) {
      //to see what keys to pass in arguments see static function route of SelfChallengeQuesitonsScreen

      print("Get questions");
      Navigator.of(context)
          .pushNamed(Routes.selfChallengeQuestions, arguments: {
        "numberOfQuestions": selectedNumberOfQuestions.toString(),
        "categoryId": "", //catetoryId
        "minutes": selectedMinutes,
        "subcategoryId": selectedSubcategoryId,
      });
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      UiUtils.setSnackbar(
          AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(selectAllValuesCode))!,
          context,
          false);
    }
  }

  Widget _buildDropdownIcon() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.4),
        ),
      ),
      child: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 25,
        color: Theme.of(context).colorScheme.onTertiary,
      ),
    );
  }

  //using for category and subcategory
  Widget _buildDropdown({
    required bool forCategory,
    required List<Map<String, String?>>
        values, //keys of value will be name and id
    required String keyValue, // need to have this keyValues for fade animation
  }) {
    return DropdownButton<String>(
        key: Key(keyValue),
        dropdownColor: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(8.0),
        //same as background of dropdown color
        style: GoogleFonts.nunito(
          textStyle: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
            fontSize: 16.0,
          ),
        ),
        isExpanded: true,
        onChanged: (value) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          if (!forCategory) {
            // if it's for subcategory

            //if no subcategory selected then do nothing
            if (value != _defaultSelectedSubcategoryValue) {
              int index =
                  values.indexWhere((element) => element['name'] == value);
              setState(() {
                selectedSubcategory = value;
                selectedSubcategoryId = values[index]['id'];
              });
            }
          } else {
            //if no category selected then do nothing
            if (value != _defaultSelectedCategoryValue) {
              int index =
                  values.indexWhere((element) => element['name'] == value);
              setState(() {
                selectedCategory = value;
                selectedCategoryId = values[index]['id'];
                selectedSubcategory = _defaultSelectedSubcategoryValue; //
              });

              context.read<SubCategoryCubit>().fetchSubCategory(
                    selectedCategoryId!,
                    context.read<UserDetailsCubit>().userId(),
                  );
            } else {
              context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
                    languageId: UiUtils.getCurrentQuestionLanguageId(context),
                    type: UiUtils.getCategoryTypeNumberFromQuizType(
                        QuizTypes.selfChallenge),
                    userId: context.read<UserDetailsCubit>().userId(),
                  );
            }
          }
        },
        icon: _buildDropdownIcon(),
        underline: const SizedBox(),
        //values is map of name and id. only passing name to dropdown
        items: values.map((e) => e['name']).toList().map((name) {
          return DropdownMenuItem(
            value: name,
            child: name! == selectCategoryKey || name == selectSubCategoryKey
                ? Text(AppLocalization.of(context)!.getTranslatedValues(name)!)
                : Text(name),
          );
        }).toList(),
        value: forCategory ? selectedCategory : selectedSubcategory);
  }

  //dropdown container with border
  Widget _buildDropdownContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: child,
    );
  }

  //for selecting time and question
  Widget _buildSelectTimeAndQuestionContainer(
      {bool? forSelectQuestion,
      int? value,
      Color? textColor,
      Color? backgroundColor,
      required Color borderColor}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (forSelectQuestion!) {
            selectedNumberOfQuestions = value;
          } else {
            selectedMinutes = value;
          }
        });
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 10.0),
        height: 30.0,
        width: 45.0,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Text(
          "$value",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleContainer(String title) {
    return Text(
      title,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onTertiary,
      ),
    );
  }

  Widget _buildSubCategoryDropdownContainer(SubCategoryState state) {
    if (state is SubCategoryFetchSuccess) {
      return _buildDropdown(
          forCategory: false,
          values: state.subcategoryList
              .map((e) => {"name": e.subcategoryName, "id": e.id})
              .toList(),
          keyValue: "selectSubcategorySuccess${state.categoryId}");
    }

    return Opacity(
      opacity: 0.75,
      child: _buildDropdown(
        forCategory: false,
        values: [
          {"name": _defaultSelectedSubcategoryValue}
        ],
        keyValue: "selectSubcategory",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        //await Future.delayed(Duration.zero);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: QAppBar(
          title: Text(
            AppLocalization.of(context)!.getTranslatedValues("selfChallenge")!,
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical:
                  MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
              horizontal:
                  MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Category Dropdown
                BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
                  bloc: context.read<QuizCategoryCubit>(),
                  listener: (context, state) {
                    if (state is QuizCategorySuccess) {
                      setState(() {
                        selectedCategory = state.categories.first.categoryName;
                        selectedCategoryId = state.categories.first.id;
                      });
                      context.read<SubCategoryCubit>().fetchSubCategory(
                            state.categories.first.id!,
                            context.read<UserDetailsCubit>().userId(),
                          );
                    }
                    if (state is QuizCategoryFailure) {
                      if (state.errorMessage == unauthorizedAccessCode) {
                        UiUtils.showAlreadyLoggedInDialog(context: context);
                        return;
                      }

                      UiUtils.setSnackbar(
                          AppLocalization.of(context)!.getTranslatedValues(
                              convertErrorCodeToLanguageKey(
                                  state.errorMessage))!,
                          context,
                          true,
                          duration: const Duration(days: 365),
                          onPressedAction: () {
                        //to get categories
                        context
                            .read<QuizCategoryCubit>()
                            .getQuizCategoryWithUserId(
                              languageId:
                                  UiUtils.getCurrentQuestionLanguageId(context),
                              type: UiUtils.getCategoryTypeNumberFromQuizType(
                                  QuizTypes.selfChallenge),
                              userId: context.read<UserDetailsCubit>().userId(),
                            );
                      });
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalization.of(context)!
                              .getTranslatedValues("selectCategory")!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildDropdownContainer(
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: state is QuizCategorySuccess
                                ? _buildDropdown(
                                    forCategory: true,
                                    values: state.categories
                                        .map((e) => {
                                              "name": e.categoryName,
                                              "id": e.id,
                                            })
                                        .toList(),
                                    keyValue: "selectCategorySuccess",
                                  )
                                : Opacity(
                                    opacity: 0.75,
                                    child: _buildDropdown(
                                      forCategory: true,
                                      values: [
                                        {
                                          "name": _defaultSelectedCategoryValue,
                                          "id": "0"
                                        }
                                      ],
                                      keyValue: "selectCategory",
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 25),

                //Sub Category Dropdown
                BlocConsumer<SubCategoryCubit, SubCategoryState>(
                  bloc: context.read<SubCategoryCubit>(),
                  listener: (context, state) {
                    if (state is SubCategoryFetchSuccess) {
                      setState(() {
                        selectedSubcategory =
                            state.subcategoryList.first.subcategoryName;
                        selectedSubcategoryId = state.subcategoryList.first.id;
                      });
                    } else if (state is SubCategoryFetchFailure) {
                      if (state.errorMessage == unauthorizedAccessCode) {
                        //
                        UiUtils.showAlreadyLoggedInDialog(
                          context: context,
                        );
                        return;
                      }

                      // if no subcategory is available.
                      if (state.errorMessage == "102") {
                        return;
                      }

                      UiUtils.setSnackbar(
                          AppLocalization.of(context)!.getTranslatedValues(
                              convertErrorCodeToLanguageKey(
                                  state.errorMessage))!,
                          context,
                          true,
                          duration: const Duration(days: 365),
                          onPressedAction: () {
                        //load subcategory again
                        context.read<SubCategoryCubit>().fetchSubCategory(
                              selectedCategoryId!,
                              context.read<UserDetailsCubit>().userId(),
                            );
                      });
                    }
                  },
                  builder: (context, state) {
                    if (state is SubCategoryFetchFailure) {
                      //if there is no subcategory then show empty sized box
                      if (state.errorMessage == "102") {
                        return const SizedBox();
                      }
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalization.of(context)!
                              .getTranslatedValues("selectSubCategory")!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildDropdownContainer(
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: _buildSubCategoryDropdownContainer(state),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 25.0),

                /// Select no. of Questions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleContainer(
                      AppLocalization.of(context)!
                          .getTranslatedValues("selectNoQusLbl")!,
                    ),
                    const SizedBox(height: 15.0),
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(10, (index) => (index + 1) * 5)
                            .map((e) => _buildSelectTimeAndQuestionContainer(
                                  forSelectQuestion: true,
                                  value: e,
                                  borderColor: selectedNumberOfQuestions == e
                                      ? Theme.of(context).colorScheme.secondary
                                      : Colors.grey.shade400,
                                  backgroundColor:
                                      selectedNumberOfQuestions == e
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                              .colorScheme
                                              .background,
                                  textColor: selectedNumberOfQuestions == e
                                      ? Theme.of(context).colorScheme.background
                                      : Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25.0),

                /// Select challenge duration in minutes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleContainer(
                      AppLocalization.of(context)!
                          .getTranslatedValues("selectTimeLbl")!,
                    ),
                    const SizedBox(height: 15.0),
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List
                                .generate(
                                    context
                                            .read<SystemConfigCubit>()
                                            .getSelfChallengeTime() ~/
                                        3,
                                    (index) => (index + 1) * 3)
                            .map((e) => _buildSelectTimeAndQuestionContainer(
                                forSelectQuestion: false,
                                value: e,
                                backgroundColor: selectedMinutes == e
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).colorScheme.background,
                                textColor: selectedMinutes == e
                                    ? Theme.of(context).colorScheme.background
                                    : Theme.of(context).colorScheme.onTertiary,
                                borderColor: selectedMinutes == e
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.grey.shade400))
                            .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40.0),

                /// Start Challenge
                CustomRoundedButton(
                  elevation: 5.0,
                  widthPercentage: 1.0,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle: AppLocalization.of(context)!
                      .getTranslatedValues("startLbl")!
                      .toUpperCase(),
                  fontWeight: FontWeight.bold,
                  radius: 8.0,
                  onTap: startSelfChallenge,
                  showBorder: false,
                  titleColor: Theme.of(context).colorScheme.background,
                  shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
