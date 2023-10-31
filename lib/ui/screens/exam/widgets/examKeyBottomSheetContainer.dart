import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ExamKeyBottomSheetContainer extends StatefulWidget {
  final Exam exam;
  final Function navigateToExamScreen;

  const ExamKeyBottomSheetContainer({
    super.key,
    required this.exam,
    required this.navigateToExamScreen,
  });

  @override
  State<ExamKeyBottomSheetContainer> createState() =>
      _ExamKeyBottomSheetContainerState();
}

class _ExamKeyBottomSheetContainerState
    extends State<ExamKeyBottomSheetContainer> {
  late final examKeyController = TextEditingController();

  late String errorMessage = "";

  bool showAllExamRules = false;

  late bool showViewAllRulesButton = examRules.length > 2;

  late bool rulesAccepted = false;

  final double horizontalPaddingPercentage = (0.125);

  Widget _buildAcceptRulesContainer() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal:
            MediaQuery.of(context).size.width * (horizontalPaddingPercentage),
        vertical: 10.0,
      ),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 2.0),
          InkWell(
            onTap: () {
              setState(() {
                rulesAccepted = !rulesAccepted;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rulesAccepted
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 1.5,
                  color: rulesAccepted
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              child: Icon(
                Icons.check,
                color: rulesAccepted
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).colorScheme.onTertiary,
                size: 15.0,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Text(
            AppLocalization.of(context)!
                .getTranslatedValues(iAgreeWithExamRulesKey)!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRuleLine(String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7.5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onTertiary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10.0),
          Flexible(
              child: Text(
            rule,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
              fontSize: 12,
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildExamRules() {
    List<String> allExamRules = [];
    if (showAllExamRules) {
      allExamRules = examRules;
    } else {
      allExamRules =
          examRules.length >= 2 ? examRules.sublist(0, 2) : examRules;
    }

    return Column(
      children: allExamRules.map((e) => _buildRuleLine(e)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (context.read<ExamCubit>().state is ExamFetchInProgress) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: BlocListener<ExamCubit, ExamState>(
        bloc: context.read<ExamCubit>(),
        listener: (context, state) {
          if (state is ExamFetchFailure) {
            setState(() {
              errorMessage = AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage))!;
            });
          } else if (state is ExamFetchSuccess) {
            widget.navigateToExamScreen();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20.0)),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          padding: const EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Title
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Enter in Exam",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
                Divider(
                  color:
                      Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
                  thickness: 1.5,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Please enter the exam key",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                /// Enter Exam Key
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.2,
                    ),
                    child: PinCodeTextField(
                      controller: examKeyController,
                      appContext: context,
                      length: 4,
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      textStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary),
                      pinTheme: PinTheme(
                        selectedFillColor: Theme.of(context)
                            .colorScheme
                            .onTertiary
                            .withOpacity(0.1),
                        inactiveColor: Theme.of(context)
                            .colorScheme
                            .onTertiary
                            .withOpacity(0.1),
                        activeColor: Theme.of(context)
                            .colorScheme
                            .onTertiary
                            .withOpacity(0.1),
                        inactiveFillColor: Theme.of(context)
                            .colorScheme
                            .onTertiary
                            .withOpacity(0.1),
                        selectedColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5),
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 45,
                        fieldWidth: 45,
                        activeFillColor: Theme.of(context)
                            .colorScheme
                            .onTertiary
                            .withOpacity(0.2),
                      ),
                      cursorColor: Theme.of(context).colorScheme.onTertiary,
                      animationDuration: const Duration(milliseconds: 200),
                      enableActiveFill: true,
                      onChanged: (v) {},
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * .0125),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.1),
                  ),
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues(examRulesKey)!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildExamRules(),

                      /// View All/Show less
                      GestureDetector(
                        onTap: () => setState(() {
                          showAllExamRules = !showAllExamRules;
                        }),
                        child: Text(
                          showAllExamRules
                              ? "Show Less"
                              : AppLocalization.of(context)!
                                  .getTranslatedValues(viewAllRulesKey)!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onTertiary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                _buildAcceptRulesContainer(),

                //show any error message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: errorMessage.isEmpty
                      ? const SizedBox(height: 20.0)
                      : SizedBox(
                          height: 20.0,
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                          ),
                        ),
                ),

                //show submit button
                BlocBuilder<ExamCubit, ExamState>(
                  bloc: context.read<ExamCubit>(),
                  builder: (context, state) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width *
                            UiUtils.hzMarginPct,
                      ),
                      child: CustomRoundedButton(
                        widthPercentage: MediaQuery.of(context).size.width,
                        backgroundColor: rulesAccepted
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.onTertiary,
                        buttonTitle: state is ExamFetchInProgress
                            ? AppLocalization.of(context)!
                                .getTranslatedValues(submittingButton)!
                            : AppLocalization.of(context)!
                                .getTranslatedValues(submitBtn)!,
                        radius: 8.0,
                        showBorder: false,
                        onTap: state is ExamFetchInProgress
                            ? () {}
                            : () {
                                if (!rulesAccepted) {
                                  setState(() {
                                    errorMessage = AppLocalization.of(context)!
                                        .getTranslatedValues(
                                            pleaseAcceptExamRulesKey)!;
                                  });
                                } else if (examKeyController.text.trim() ==
                                    widget.exam.examKey) {
                                  context.read<ExamCubit>().startExam(
                                        exam: widget.exam,
                                        userId: context
                                            .read<UserDetailsCubit>()
                                            .userId(),
                                      );
                                } else {
                                  setState(() {
                                    errorMessage = AppLocalization.of(context)!
                                        .getTranslatedValues(
                                            enterValidExamKey)!;
                                  });
                                }
                              },
                        fontWeight: FontWeight.bold,
                        titleColor: Theme.of(context).colorScheme.background,
                        height: 45.0,
                      ),
                    );
                  },
                ),

                SizedBox(height: MediaQuery.of(context).size.height * .05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
