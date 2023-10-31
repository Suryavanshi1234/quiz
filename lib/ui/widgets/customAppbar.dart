import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class QAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QAppBar({
    super.key,
    required this.title,
    this.roundedAppBar = true,
    this.removeSnackBars = true,
    this.bottom,
    this.bottomHeight = 52,
    this.usePrimaryColor = false,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.onTapBackButton,
    this.elevation,
  });

  final Widget title;
  final double? elevation;
  final TabBar? bottom;
  final bool automaticallyImplyLeading;
  final Function()? onTapBackButton;
  final List<Widget>? actions;
  final bool roundedAppBar;
  final double bottomHeight;
  final bool removeSnackBars;
  final bool usePrimaryColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: elevation ?? (roundedAppBar ? 2 : 0),
      centerTitle: true,
      shadowColor: Theme.of(context).colorScheme.background.withOpacity(0.4),
      foregroundColor: usePrimaryColor
          ? Theme.of(context).primaryColor
          : Theme.of(context).colorScheme.onTertiary,
      backgroundColor: roundedAppBar
          ? Theme.of(context).colorScheme.background
          : Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
      ),
      leading: automaticallyImplyLeading
          ? QBackButton(
              onTap: onTapBackButton,
              removeSnackBars: removeSnackBars,
              color: usePrimaryColor ? Theme.of(context).primaryColor : null,
            )
          : const SizedBox(),
      titleTextStyle: GoogleFonts.nunito(
        textStyle: TextStyle(
          color: usePrimaryColor
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.onTertiary,
          fontWeight: FontWeights.bold,
          fontSize: 18.0,
        ),
      ),
      title: title,
      actions: actions,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context)
                      .colorScheme
                      .onTertiary
                      .withOpacity(0.08),
                ),
                child: bottom,
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => bottom == null
      ? const Size.fromHeight(kToolbarHeight)
      : Size.fromHeight(kToolbarHeight + bottomHeight);
}
