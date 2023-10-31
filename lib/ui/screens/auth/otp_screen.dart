import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/auth/cubits/signInCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/app_logo.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/resend_otp_timer_container.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/terms_and_condition.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

const int otpTimeOutSeconds = 60;

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<SignInCubit>(
        child: const OtpScreen(),
        create: (_) => SignInCubit(AuthRepository()),
      ),
    );
  }
}

class _OtpScreen extends State<OtpScreen> {
  TextEditingController phoneNumberController = TextEditingController();

  CountryCode? selectedCountryCode;
  final smsCodeController = TextEditingController();

  final resendOtpTimerContainerKey = GlobalKey<ResendOtpTimerContainerState>();

  bool codeSent = false;
  bool hasError = false;
  String errorMessage = "";
  bool isLoading = false;
  String userVerificationId = "";

  bool enableResendOtpButton = false;

  void signInWithPhoneNumber({required String phoneNumber}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: const Duration(seconds: otpTimeOutSeconds),
      phoneNumber: '${selectedCountryCode!.dialCode} $phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) {
        print("Phone number verified");
      },
      verificationFailed: (FirebaseAuthException e) {
        //if otp code does not verify
        print("Firebase Auth error------------");
        print(e.message);
        print("---------------------");
        UiUtils.setSnackbar(
            AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(defaultErrorMessageCode))!,
            context,
            false);

        setState(() {
          isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        print("Code sent successfully");
        setState(() {
          codeSent = true;
          userVerificationId = verificationId;
          isLoading = false;
        });

        Future.delayed(const Duration(milliseconds: 75)).then((value) {
          resendOtpTimerContainerKey.currentState?.setResendOtpTimer();
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Widget _buildOTPSentToPhoneNumber() {
    if (codeSent) {
      return Column(
        children: [
          Text(
            AppLocalization.of(context)!.getTranslatedValues(otpSendLbl)!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
              fontSize: 16.0,
            ),
          ),
          Text(
            '${selectedCountryCode!.dialCode} ${phoneNumberController.text.trim()}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
              fontSize: 16.0,
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        if (isLoading) {
          print("Is loading is true");
          return Future.value(false);
        }
        if (context.read<SignInCubit>().state is SignInProgress) {
          return Future.value(false);
        }

        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: size.height * UiUtils.vtMarginPct,
                horizontal: size.shortestSide * UiUtils.hzMarginPct + 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: size.height * .07),
                  _backButton(),
                  SizedBox(height: size.height * 0.02),
                  !codeSent ? const AppLogo() : const SizedBox(),
                  SizedBox(height: size.height * 0.03),
                  _registerText(),
                  SizedBox(height: size.height * 0.03),
                  _buildOTPSentToPhoneNumber(),
                  SizedBox(height: size.height * 0.04),
                  codeSent
                      ? _buildSmsCodeContainer()
                      : _buildMobileNumberWithCountryCode(),
                  SizedBox(height: size.height * 0.04),
                  codeSent
                      ? _buildSubmitOtpContainer()
                      : _buildRequestOtpContainer(),
                  codeSent ? _buildResendText() : const SizedBox(),
                  SizedBox(height: size.height * 0.04),
                  const TermsAndCondition(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backButton() {
    return Row(
      children: [
        InkWell(
          onTap: Navigator.of(context).pop,
          child: Icon(
            Icons.arrow_back_rounded,
            size: 24,
            color: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
      ],
    );
  }

  Widget _registerText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalization.of(context)!.getTranslatedValues("registration")!,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeights.bold,
            color: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
        if (!codeSent) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width * .7,
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues("regSubtitle")!,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeights.regular,
                color:
                    Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget otpLabelIos() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: QBackButton(color: Theme.of(context).primaryColor),
        ),
        Expanded(
          flex: 10,
          child: Text(
            AppLocalization.of(context)!
                .getTranslatedValues('otpVerificationLbl')!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget otpLabel() {
    return Text(
      AppLocalization.of(context)!.getTranslatedValues('otpVerificationLbl')!,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMobileNumberWithCountryCode() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IgnorePointer(
            ignoring: isLoading,
            child: CountryCodePicker(
              onInit: (countryCode) {
                selectedCountryCode = countryCode;
              },
              onChanged: (countryCode) {
                selectedCountryCode = countryCode;
              },
              flagDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
              ),
              textStyle: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary.withOpacity(.6),
                fontSize: 16,
              ),
              initialSelection: initialSelectedCountryCode,
              showCountryOnly: false,
              alignLeft: false,
            ),
          ),
          Flexible(
            child: TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              cursorColor: Theme.of(context).primaryColor,
              inputFormatters: [
                LengthLimitingTextInputFormatter(maxPhoneNumberLength),
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
                  fontSize: 16,
                ),
                hintText: " 000 000 0000",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmsCodeContainer() {
    final colorScheme = Theme.of(context).colorScheme;

    return PinCodeTextField(
      onChanged: (value) {},
      keyboardType: TextInputType.number,
      appContext: context,
      length: 6,
      obscureText: false,
      hintCharacter: '0',
      hintStyle: TextStyle(color: colorScheme.onTertiary.withOpacity(.3)),
      textStyle: TextStyle(color: colorScheme.onTertiary),
      pinTheme: PinTheme(
        selectedFillColor: colorScheme.secondary,
        inactiveColor: colorScheme.background,
        activeColor: colorScheme.background,
        inactiveFillColor: colorScheme.background,
        selectedColor: colorScheme.secondary.withOpacity(0.5),
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(5),
        fieldHeight: 45,
        fieldWidth: 45,
        activeFillColor: colorScheme.background,
      ),
      cursorColor: colorScheme.background,
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      controller: smsCodeController,
    );
  }

  Widget _buildSubmitOtpContainer() {
    return BlocConsumer<SignInCubit, SignInState>(
      bloc: context.read<SignInCubit>(),
      builder: (context, state) {
        if (state is SignInProgress) {
          return const CircularProgressContainer(
            whiteLoader: false,
            size: 50.0,
          );
        }

        return Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.width * (0.04),
          ),
          width: MediaQuery.of(context).size.width,
          child: CustomRoundedButton(
            widthPercentage: 1,
            backgroundColor: Theme.of(context).primaryColor,
            buttonTitle:
                AppLocalization.of(context)!.getTranslatedValues(submitBtn)!,
            textSize: 20,
            fontWeight: FontWeights.bold,
            radius: 8,
            showBorder: false,
            height: 58,
            onTap: () async {
              if (smsCodeController.text.trim().length == 6) {
                context.read<SignInCubit>().signInUser(
                      AuthProvider.mobile,
                      smsCode: smsCodeController.text.trim(),
                      verificationId: userVerificationId,
                    );
              }
            },
          ),
        );
      },
      listener: (context, state) {
        if (state is SignInSuccess) {
          //update auth details
          context.read<AuthCubit>().updateAuthDetails(
                authProvider: AuthProvider.mobile,
                authStatus: true,
                firebaseId: state.user.uid,
                isNewUser: state.isNewUser,
              );

          if (state.isNewUser) {
            context.read<UserDetailsCubit>().fetchUserDetails();
            Navigator.of(context).pop();
            Navigator.of(context)
                .pushReplacementNamed(Routes.selectProfile, arguments: true);
          } else {
            context.read<UserDetailsCubit>().fetchUserDetails();
            Navigator.of(context).pop();
            Navigator.of(context)
                .pushReplacementNamed(Routes.home, arguments: false);
          }
        } else if (state is SignInFailure) {
          UiUtils.setSnackbar(
            AppLocalization.of(context)!.getTranslatedValues(
              convertErrorCodeToLanguageKey(state.errorMessage),
            )!,
            context,
            false,
          );
        }
      },
    );
  }

  Widget _buildRequestOtpContainer() {
    if (isLoading) {
      return const CircularProgressContainer(
        whiteLoader: false,
        size: 50.0,
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: CupertinoButton(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).primaryColor,
        onPressed: () async {
          if (phoneNumberController.text.trim().length < 6) {
            UiUtils.setSnackbar(
              AppLocalization.of(context)!.getTranslatedValues(validMobMsg)!,
              context,
              false,
            );
          } else {
            setState(() {
              isLoading = true;
            });
            signInWithPhoneNumber(
                phoneNumber: phoneNumberController.text.trim());
          }
        },
        child: Text(
          AppLocalization.of(context)!.getTranslatedValues("requestOtpLbl")!,
          maxLines: 1,
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.background,
              fontSize: 20,
              fontWeight: FontWeights.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ResendOtpTimerContainer(
            key: resendOtpTimerContainerKey,
            enableResendOtpButton: () {
              setState(() {
                enableResendOtpButton = true;
              });
            }),
        TextButton(
          onPressed: enableResendOtpButton
              ? () async {
                  print("Resend otp ");
                  setState(() {
                    isLoading = false;
                    enableResendOtpButton = false;
                  });
                  resendOtpTimerContainerKey.currentState?.cancelOtpTimer();
                  signInWithPhoneNumber(
                    phoneNumber: phoneNumberController.text.trim(),
                  );
                }
              : null,
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues("resendBtn")!,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
