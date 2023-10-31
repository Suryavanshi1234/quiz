import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/badgesExecption.dart';
import 'package:flutterquiz/features/badges/badgesRemoteDataSource.dart';
import 'package:flutterquiz/utils/constants/constants.dart';

class BadgesRepository {
  static final BadgesRepository _badgesRepository =
      BadgesRepository._internal();
  late BadgesRemoteDataSource _badgesRemoteDataSource;

  factory BadgesRepository() {
    _badgesRepository._badgesRemoteDataSource = BadgesRemoteDataSource();
    return _badgesRepository;
  }

  BadgesRepository._internal();

  Future<List<Badges>> getBadges({required String userId}) async {
    try {
      List<Badges> badges = [];
      final badgesResult =
          await _badgesRemoteDataSource.getBadges(userId: userId);

      //get badges
      for (var element in badgeTypes) {
        print(badgesResult[element]);
        badges.add(Badges.fromJson(Map.from(badgesResult[element])));
      }

      return badges;
    } catch (e) {
      throw BadgesException(errorMessageCode: e.toString());
    }
  }

  Future<void> setBadge(
      {required String userId, required String badgeType}) async {
    try {
      await _badgesRemoteDataSource.setBadges(
          userId: userId, badgeType: badgeType);
    } catch (e) {
      print("Error while updating badge");
      print(e.toString());
    }
  }
}
