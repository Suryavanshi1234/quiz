import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/ui/screens/auth/otp_screen.dart';

class ResendOtpTimerContainer extends StatefulWidget {
  final Function enableResendOtpButton;

  const ResendOtpTimerContainer({
    super.key,
    required this.enableResendOtpButton,
  });

  @override
  ResendOtpTimerContainerState createState() => ResendOtpTimerContainerState();
}

class ResendOtpTimerContainerState extends State<ResendOtpTimerContainer> {
  Timer? resendOtpTimer;
  int resendOtpTimeInSeconds = otpTimeOutSeconds - 1;

  //
  void setResendOtpTimer() {
    print("Start resend otp timer");
    print("------------------------------------");
    setState(() {
      resendOtpTimeInSeconds = otpTimeOutSeconds - 1;
    });
    resendOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendOtpTimeInSeconds == 0) {
        timer.cancel();
        widget.enableResendOtpButton();
      } else {
        resendOtpTimeInSeconds--;
        setState(() {});
      }
    });
  }

  void cancelOtpTimer() {
    resendOtpTimer?.cancel();
  }

  @override
  void dispose() {
    cancelOtpTimer();
    super.dispose();
  }

//to get time to display in text widget
  String getTime() {
    String secondsAsString = resendOtpTimeInSeconds < 10
        ? " 0$resendOtpTimeInSeconds"
        : resendOtpTimeInSeconds.toString();
    return " $secondsAsString";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalization.of(context)!.getTranslatedValues('resetLbl')! + getTime(),
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
