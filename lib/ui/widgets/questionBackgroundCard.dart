import 'package:flutter/material.dart';

class QuestionBackgroundCard extends StatelessWidget {
  final double opacity;
  final double widthPercentage;
  final double topMarginPercentage;
  final double heightPercentage;

  const QuestionBackgroundCard(
      {super.key,
      required this.opacity,
      required this.heightPercentage,
      required this.topMarginPercentage,
      required this.widthPercentage});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * topMarginPercentage),
        width: MediaQuery.of(context).size.width * widthPercentage,
        height: MediaQuery.of(context).size.height * heightPercentage,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}
