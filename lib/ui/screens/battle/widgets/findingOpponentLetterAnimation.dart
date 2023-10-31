import 'package:flutter/material.dart';

class FindOpponentLetterAnimation extends StatefulWidget {
  final AnimationController animationController;

  const FindOpponentLetterAnimation({
    super.key,
    required this.animationController,
  });

  @override
  State<FindOpponentLetterAnimation> createState() =>
      _FindOpponentLetterAnimationState();
}

class _FindOpponentLetterAnimationState
    extends State<FindOpponentLetterAnimation> with TickerProviderStateMixin {
  late final letterAnimation =
      IntTween(begin: 0, end: 25).animate(widget.animationController);

  static const letters = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z"
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          height: MediaQuery.of(context).size.height * (0.15),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.secondary,
          ),
          height: MediaQuery.of(context).size.height * (0.14),
          child: Center(
            child: AnimatedBuilder(
              animation: widget.animationController,
              builder: (_, __) => Text(
                letters[letterAnimation.value],
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
