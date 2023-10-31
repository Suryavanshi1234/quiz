import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuizGridCard extends StatelessWidget {
  const QuizGridCard({
    super.key,
    required this.title,
    required this.desc,
    required this.img,
    this.onTap,
    this.iconOnRight = true,
  });

  final String title;
  final String desc;
  final String img;
  final bool iconOnRight;
  final void Function()? onTap;

  ///
  static const _borderRadius = 10.0;
  static const _padding = EdgeInsets.all(12.0);
  static const _iconBorderRadius = 6.0;
  static const _iconMargin = EdgeInsets.all(5.0);

  static const _boxShadow = [
    BoxShadow(
      offset: Offset(0, 50),
      blurRadius: 30,
      spreadRadius: 5,
      color: Color(0xff45536d),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final iconSize = MediaQuery.of(context).size.width * 0.121;
          final iconColor = Theme.of(context).primaryColor;

          return Stack(
            children: [
              /// Box Shadow
              Positioned(
                top: 0,
                left: constraints.maxWidth * 0.2,
                right: constraints.maxWidth * 0.2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    boxShadow: _boxShadow,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(constraints.maxWidth * 0.525),
                    ),
                  ),
                  width: constraints.maxWidth,
                  height: constraints.maxHeight * 0.6,
                ),
              ),

              /// Card
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_borderRadius),
                  color: Theme.of(context).colorScheme.background,
                ),
                padding: _padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// Title
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.0,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),

                    /// Description
                    Expanded(
                      child: Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.6),
                        ),
                      ),
                    ),
                    //Spacer(),

                    /// Svg Icon
                    Align(
                      alignment: iconOnRight
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(_iconBorderRadius),
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        padding: _iconMargin,
                        width: iconSize,
                        height: iconSize,
                        child: SvgPicture.asset(img, color: iconColor),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
