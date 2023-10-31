import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class BadgesIconContainer extends StatelessWidget {
  final Badges badge;
  final BoxConstraints constraints;
  final bool addTopPadding;

  const BadgesIconContainer({
    super.key,
    required this.badge,
    required this.constraints,
    required this.addTopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: addTopPadding ? Alignment.topCenter : Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(
              top: constraints.maxHeight * (addTopPadding ? 0.095 : 0),
            ),
            child: Container(
              foregroundDecoration: BoxDecoration(
                color: badge.status == "0"
                    ? const Color(0xFABEBABE)
                    : Colors.transparent,
                backgroundBlendMode: BlendMode.saturation,
              ),
              width: constraints.maxWidth * (0.775),
              height: constraints.maxHeight * (0.5),
              child: SvgPicture.asset(
                UiUtils.getImagePath("hexagon.svg"),
              ),
            ),
          ),
        ),
        Align(
          alignment: addTopPadding ? Alignment.topCenter : Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(
              top: constraints.maxHeight *
                  (addTopPadding
                      ? 0.100
                      : 0), //outer hexagon top padding + difference of inner and outer height
            ),
            child: SizedBox(
              width: constraints.maxWidth * (0.725),
              height: constraints.maxHeight * (0.5),
              child: Padding(
                padding: const EdgeInsets.all(12.5),
                child: CachedNetworkImage(imageUrl: badge.badgeIcon),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
