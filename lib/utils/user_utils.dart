import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/ui/widgets/circularImageContainer.dart';

class UserUtils {
  //this function will return image widget according to the profile url
  static Widget getUserProfileWidget({
    required String profileUrl,
    Color? pngBackgroundColor,
    double? width,
    double? height,
    bool isSimpleNetworkImage = false,
    BoxFit fit = BoxFit.cover,
  }) {
    bool isSvg = false;
    try {
      isSvg = profileUrl.split(".").last.toString().toLowerCase() == "svg";
    } catch (_) {}
    if (isSimpleNetworkImage) {
      if (isSvg) {
        return SvgPicture.network(
          profileUrl,
          fit: fit,
          width: width,
          height: height,
        );
      } else {
        return CachedNetworkImage(
          imageUrl: profileUrl,
          fit: fit,
          width: width,
          height: height,
        );
      }
    }
    return CircularImageContainer(
      imagePath: profileUrl,
      height: height ?? 10,
      width: width ?? 10,
      isSvg: isSvg,
      backgroundColor: pngBackgroundColor,
    );
  }
}
