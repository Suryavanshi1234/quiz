class Badges {
  Badges({
    required this.id,
    required this.type,
    required this.badgeLabel,
    required this.badgeNote,
    required this.badgeReward,
    required this.badgeIcon,
    required this.badgeCounter,
    required this.status,
  });

  late final String id;
  late final String type;
  late final String badgeLabel;
  late final String badgeNote;
  late final String badgeReward;
  late final String badgeIcon;
  late final String badgeCounter;
  late final String status;

  Badges.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    type = json['type'] ?? "";
    badgeLabel = json['badge_label'] ?? "";
    badgeNote = json['badge_note'] ?? "";
    badgeReward = json['badge_reward'] ?? "";
    badgeIcon = json['badge_icon'] ?? "";
    badgeCounter = json['badge_counter'] ?? "";
    status = json['status'] ?? "0";
  }

  Badges copyWith({String? updatedStatus}) {
    return Badges(
      id: id,
      type: type,
      badgeLabel: badgeLabel,
      badgeNote: badgeNote,
      badgeReward: badgeReward,
      badgeIcon: badgeIcon,
      badgeCounter: badgeCounter,
      status: updatedStatus ?? status,
    );
  }
}
