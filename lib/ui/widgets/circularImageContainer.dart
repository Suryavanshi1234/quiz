import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CircularImageContainer extends StatelessWidget {
  final String imagePath;
  //width percentage must be more than 0.15 to height percentage
  final double width;
  final double height;
  final bool isSvg;
  final Color? backgroundColor;
  const CircularImageContainer(
      {super.key,
      required this.height,
      required this.imagePath,
      required this.width,
      this.backgroundColor,
      this.isSvg = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: isSvg
          ? ClipRRect(
              borderRadius: BorderRadius.circular(height),
              child: SvgPicture.network(imagePath),
            )
          : CircleAvatar(
              backgroundColor:
                  backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
              radius: height,
              backgroundImage: CachedNetworkImageProvider(
                imagePath,
              ),
            ),
    );
  }
}
