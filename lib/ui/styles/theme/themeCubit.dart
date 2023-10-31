import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/settings/settingsLocalDataSource.dart';
import 'package:flutterquiz/ui/styles/theme/appTheme.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';

class ThemeState {
  final AppTheme appTheme;

  const ThemeState(this.appTheme);
}

class ThemeCubit extends Cubit<ThemeState> {
  SettingsLocalDataSource settingsLocalDataSource;

  ThemeCubit(this.settingsLocalDataSource)
      : super(ThemeState(
          settingsLocalDataSource.theme() == darkThemeKey
              ? AppTheme.dark
              : AppTheme.light,
        ));

  void changeTheme(AppTheme appTheme) {
    settingsLocalDataSource
        .setTheme(appTheme == AppTheme.dark ? darkThemeKey : lightThemeKey);
    emit(ThemeState(appTheme));
  }
}
