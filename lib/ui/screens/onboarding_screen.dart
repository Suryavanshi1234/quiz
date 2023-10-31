import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/utils/assets_utils.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class Slide {
  final String image;
  final String title;
  final String description;

  Slide({
    required this.image,
    required this.title,
    required this.description,
  });
}

class IntroSliderScreen extends StatefulWidget {
  const IntroSliderScreen({super.key});

  @override
  State<IntroSliderScreen> createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<IntroSliderScreen>
    with TickerProviderStateMixin {
  int sliderIndex = 0;

  //
  late AnimationController buttonController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late Animation<double> buttonSqueezeAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: buttonController,
    curve: Curves.easeInOut,
  ));

  late AnimationController circleAnimationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 500))
        ..forward();
  late Animation<double> circleAnimation =
      Tween<double>().animate(CurvedAnimation(
    parent: circleAnimationController,
    curve: Curves.easeInCubic,
  ));

  late AnimationController imageSlideAnimationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500))
    ..repeat(reverse: true);
  late Animation<Offset> imageSlideAnimation =
      Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -0.025)).animate(
          CurvedAnimation(
              parent: imageSlideAnimationController, curve: Curves.easeInOut));

  late AnimationController pageIndicatorAnimationController =
      AnimationController(
          vsync: this, duration: const Duration(milliseconds: 300));
  late Tween<Alignment> pageIndicator =
      AlignmentTween(begin: Alignment.centerLeft, end: Alignment.centerLeft);
  late Animation<Alignment> pageIndicatorAnimation = pageIndicator.animate(
      CurvedAnimation(
          parent: pageIndicatorAnimationController, curve: Curves.easeInOut));

  late AnimationController animationController;
  late Animation animation;

  late AnimationController animationController1;
  late Animation animation1;
  late final List<Slide> slideList = [
    Slide(
      image: AssetsUtils.getImagePath("onboadin_a.svg"),
      title: AppLocalization.of(context)!.getTranslatedValues("title1")!,
      description:
          AppLocalization.of(context)!.getTranslatedValues("description1")!,
    ),
    Slide(
      image: AssetsUtils.getImagePath("onboadin_b.svg"),
      title: AppLocalization.of(context)!.getTranslatedValues("title2")!,
      description:
          AppLocalization.of(context)!.getTranslatedValues("description2")!,
    ),
    Slide(
      image: AssetsUtils.getImagePath("onboadin_c.svg"),
      title: AppLocalization.of(context)!.getTranslatedValues("title3")!,
      description:
          AppLocalization.of(context)!.getTranslatedValues("description3")!,
    ),
  ];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInCubic,
    );
    animationController.addStatusListener(animationStatusListener);
    animationController.forward();

    animationController1 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    animation1 = CurvedAnimation(
      parent: animationController1,
      curve: Curves.easeInCubic,
    );
    animationController1.addStatusListener(animationStatusListener1);
    animationController1.forward();
    buttonController.forward();
  }

  @override
  void dispose() {
    buttonController.dispose();
    imageSlideAnimationController.dispose();
    pageIndicatorAnimationController.dispose();
    circleAnimationController.dispose();
    animationController1.dispose();
    animationController.dispose();
    super.dispose();
  }

  void animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationController.reverse();
    } else if (status == AnimationStatus.dismissed) {
      animationController.forward();
    }
  }

  void animationStatusListener1(AnimationStatus stat) {
    if (stat == AnimationStatus.completed) {
      animationController1.reverse();
    } else if (stat == AnimationStatus.dismissed) {
      animationController1.forward();
    }
  }

  void onPageChanged(int index) {
    if (index == 0) {
      buttonController.forward();
      pageIndicator.begin = pageIndicator.end;
      pageIndicator.end = Alignment.centerLeft;
    } else if (index == 1) {
      buttonController.forward();
      pageIndicator.begin = pageIndicator.end;
      pageIndicator.end = Alignment.center;
    } else {
      pageIndicator.begin = pageIndicator.end;
      pageIndicator.end = Alignment.centerRight;
      buttonController.reverse();
    }
    /* Future.delayed(Duration.zero, () {
      pageIndicatorAnimationController.forward(from: 0.0);
    });*/
    setState(() {
      sliderIndex = index;
    });
  }

  Widget _buildPageIndicatorNew() {
    const indicatorWidth = 8.0;
    const indicatorHeight = 8.0;
    const selectedIndicatorWidth = 8.0 * 3;
    final borderRadius = BorderRadius.circular(4.0);
    final secondaryColor = Theme.of(context).primaryColor;
    const duration = Duration(milliseconds: 150);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: duration,
          height: indicatorHeight,
          width: sliderIndex == 0 ? selectedIndicatorWidth : indicatorWidth,
          decoration: BoxDecoration(
            color: sliderIndex == 0
                ? secondaryColor
                : secondaryColor.withOpacity(0.5),
            borderRadius: borderRadius,
          ),
        ),
        const SizedBox(width: 3),
        AnimatedContainer(
          duration: duration,
          height: indicatorHeight,
          width: sliderIndex == 1 ? selectedIndicatorWidth : indicatorWidth,
          decoration: BoxDecoration(
            color: sliderIndex == 1
                ? secondaryColor
                : secondaryColor.withOpacity(0.5),
            borderRadius: borderRadius,
          ),
        ),
        const SizedBox(width: 3),
        AnimatedContainer(
          duration: duration,
          height: indicatorHeight,
          width: sliderIndex == 2 ? selectedIndicatorWidth : indicatorWidth,
          decoration: BoxDecoration(
            color: sliderIndex == 2
                ? secondaryColor
                : secondaryColor.withOpacity(0.5),
            borderRadius: borderRadius,
          ),
        ),
      ],
    );
  }

  Widget _buildIntroSlider() {
    return PageView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SlideTransition(
              position: imageSlideAnimation,
              child: Container(
                height: MediaQuery.of(context).size.height * (0.4),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  slideList[index].image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .01),
            Text(
              slideList[index].title,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary,
                fontSize: 22.0,
                fontWeight: FontWeights.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .0175),
            SizedBox(
              height: 58,
              width: MediaQuery.of(context).size.width * .8,
              child: Text(
                slideList[index].description,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontWeight: FontWeights.medium,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        );
      },
      itemCount: slideList.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            color: Theme.of(context).primaryColor,
          ),
          Container(
            height: size.height * 0.75,
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: _buildIntroSlider(),
          ),
          Container(
            width: size.width,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.shortestSide * 0.12,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: size.width * UiUtils.hzMarginPct,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPageIndicatorNew(),
                AnimatedBuilder(
                  builder: (context, child) {
                    return Transform.scale(
                      scale: buttonSqueezeAnimation.value,
                      child: child,
                    );
                  },
                  animation: buttonController,
                  child: InkWell(
                    onTap: () {
                      context.read<SettingsCubit>().changeShowIntroSlider();
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.home, arguments: true);
                    },
                    child: Text(
                      AppLocalization.of(context)!.getTranslatedValues("skip")!,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeights.regular,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {
                context.read<SettingsCubit>().changeShowIntroSlider();
                Navigator.of(context)
                    .pushReplacementNamed(Routes.home, arguments: true);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: size.height * 0.10),
                height: 50,
                width: size.width * 0.5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    AppLocalization.of(context)!
                        .getTranslatedValues("getStarted")!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 22,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
