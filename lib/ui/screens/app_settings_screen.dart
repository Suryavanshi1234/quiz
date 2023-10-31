import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/systemConfig/cubits/appSettingsCubit.dart';
import 'package:flutterquiz/features/systemConfig/system_config_repository.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';

import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:webview_flutter/webview_flutter.dart';

class AppSettingsScreen extends StatefulWidget {
  final String title;

  const AppSettingsScreen({super.key, required this.title});

  static Route<AppSettingsScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<AppSettingsCubit>(
              create: (_) => AppSettingsCubit(
                SystemConfigRepository(),
              ),
              child:
                  AppSettingsScreen(title: routeSettings.arguments as String),
            ));
  }

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

//about_us / privacy_policy / terms_conditions / contact_us / instructions
class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late WebViewController webViewController;

  String getType() {
    if (widget.title == aboutUs) {
      return "about_us";
    }
    if (widget.title == privacyPolicy) {
      return "privacy_policy";
    }
    if (widget.title == termsAndConditions) {
      return "terms_conditions";
    }
    if (widget.title == contactUs) {
      return "contact_us";
    }
    if (widget.title == howToPlayLbl) {
      return "instructions";
    }
    print(widget.title);
    return "";
  }

  @override
  void initState() {
    getAppSetting();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  void getAppSetting() {
    Future.delayed(Duration.zero, () {
      context.read<AppSettingsCubit>().getAppSetting(getType());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(
            AppLocalization.of(context)!.getTranslatedValues(widget.title)!),
      ),
      body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        bloc: context.read<AppSettingsCubit>(),
        builder: (context, state) {
          if (state is AppSettingsFetchInProgress ||
              state is AppSettingsIntial) {
            return const Center(child: CircularProgressContainer());
          }
          if (state is AppSettingsFetchFailure) {
            return Center(
              child: ErrorContainer(
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(state.errorCode))!,
                onTapRetry: getAppSetting,
                showErrorImage: true,
                errorMessageColor: Theme.of(context).primaryColor,
              ),
            );
          }
          if (state is AppSettingsFetchSuccess) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical:
                    MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
                horizontal:
                    MediaQuery.of(context).size.width * UiUtils.hzMarginPct +
                        10,
              ),
              child: HtmlWidget(
                state.settingsData,
                onErrorBuilder: (_, element, error) {
                  return Text('$element error: $error');
                },
                onLoadingBuilder: (_, e, l) {
                  return const Center(child: CircularProgressIndicator());
                },
                renderMode: RenderMode.column,
                textStyle: const TextStyle(fontSize: 14),
                onTapUrl: (url) async {
                  final canLaunch = await canLaunchUrl(
                    Uri.parse(url),
                  );
                  if (canLaunch) {
                    launchUrl(Uri.parse(url));
                  } else {
                    print("error");
                  }
                  return false;
                },
                //webViewDebuggingEnabled: false,
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
