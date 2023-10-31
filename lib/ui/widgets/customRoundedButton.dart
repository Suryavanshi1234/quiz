import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomRoundedButton extends StatelessWidget {
  final String? buttonTitle;
  final double height;
  final double widthPercentage;
  final Function? onTap;
  final Color backgroundColor;
  final double radius;
  final Color? shadowColor;
  final bool showBorder;
  final Color? borderColor;
  final Color? titleColor;
  final double? textSize;
  final FontWeight? fontWeight;
  final double? elevation;

  const CustomRoundedButton({
    super.key,
    required this.widthPercentage,
    required this.backgroundColor,
    this.borderColor,
    this.elevation,
    required this.buttonTitle,
    this.onTap,
    required this.radius,
    this.shadowColor,
    required this.showBorder,
    required this.height,
    this.titleColor,
    this.fontWeight,
    this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shadowColor: shadowColor ?? Colors.black54,
      elevation: elevation ?? 0.0,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap as void Function()?,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          //
          alignment: Alignment.center,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: showBorder
                ? Border.all(
                    color: borderColor ??
                        Theme.of(context).scaffoldBackgroundColor,
                  )
                : null,
          ),
          width: MediaQuery.of(context).size.width * widthPercentage,
          child: Text(
            "$buttonTitle",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                fontSize: textSize ?? 16.0,
                color: titleColor ?? Theme.of(context).scaffoldBackgroundColor,
                fontWeight: fontWeight ?? FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QTextButton extends StatelessWidget {
  const QTextButton(
    this.text, {
    super.key,
    required this.borderColor,
    required this.fontWeight,
    required this.height,
    this.radius = 0.0,
    required this.showBorder,
    required this.textSize,
    required this.width,
    this.textColor,
    this.backgroundColor,
    this.onTap,
  });

  final double height;
  final double width;

  final Color? textColor;
  final FontWeight fontWeight;
  final String text;
  final double textSize;

  final double radius;
  final bool showBorder;
  final Color borderColor;
  final Color? backgroundColor;

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
      ),
    );
  }
}
