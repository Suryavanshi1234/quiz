import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/notification/cubit/notificationCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<NotificationCubit>(
        create: (_) => NotificationCubit(),
        child: const NotificationScreen(),
      ),
    );
  }
}

class _NotificationScreen extends State<NotificationScreen> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    controller.addListener(scrollListener);
    context.read<NotificationCubit>().fetchNotifications("20");
    context.read<InterstitialAdCubit>().showAd(context);
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<NotificationCubit>().hasMore) {
        context.read<NotificationCubit>().fetchMoreNotifications("20");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: QAppBar(
        title: Text(AppLocalization.of(context)!
            .getTranslatedValues("notificationLbl")!),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: size.height * UiUtils.vtMarginPct,
          horizontal: size.width * UiUtils.hzMarginPct,
        ),
        child: Container(
          height: size.height * .84,
          alignment: Alignment.topCenter,
          child: BlocConsumer<NotificationCubit, NotificationState>(
            bloc: context.read<NotificationCubit>(),
            listener: (context, state) {
              if (state is NotificationFailure) {
                if (state.errorMessageCode == unauthorizedAccessCode) {
                  UiUtils.showAlreadyLoggedInDialog(context: context);
                }
              }
            },
            builder: (context, state) {
              if (state is NotificationProgress ||
                  state is NotificationInitial) {}
              if (state is NotificationFailure) {
                return ErrorContainer(
                  showBackButton: false,
                  errorMessageColor: Theme.of(context).colorScheme.onTertiary,
                  showErrorImage: true,
                  errorMessage: AppLocalization.of(context)!
                      .getTranslatedValues(convertErrorCodeToLanguageKey(
                          state.errorMessageCode)),
                  onTapRetry: () {
                    context.read<NotificationCubit>().fetchNotifications("20");
                  },
                );
              }

              if (state is NotificationSuccess) {
                return ListView.separated(
                  controller: controller,
                  itemCount: state.notificationList.length,
                  separatorBuilder: (_, i) =>
                      const SizedBox(height: UiUtils.listTileGap),
                  itemBuilder: (_, i) {
                    if (state.hasMore &&
                        i == (state.notificationList.length - 1)) {
                      return const Center(child: CircularProgressContainer());
                    }
                    return _NotificationCard(state.notificationList[i]);
                  },
                );
              }

              return const Center(child: CircularProgressContainer());
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard(this.notification);

  final Map<String, dynamic> notification;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd/MM 'at' ").add_jm();
    final formattedDate =
        dateFormat.format(DateTime.parse(notification['date_sent'] ?? ""));

    return GestureDetector(
      onTap: () {
        if (notification["type"] == "category") {
          Navigator.of(context).pushNamed(Routes.category, arguments: {
            "quizType": QuizTypes.quizZone,
            "type": notification["type"],
            "typeId": notification["type_id"]
          });
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            /// Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: notification["image"],
                  fit: BoxFit.cover,
                  placeholder: (_, s) {
                    return Image.asset(UiUtils.getImagePath('ic_launcher.png'));
                  },
                  errorWidget: (_, s, d) {
                    return Image.asset(UiUtils.getImagePath('ic_launcher.png'));
                  },
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    notification["title"] ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),

                  /// Desc
                  Text(
                    notification["message"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 6),

                  /// Date
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
