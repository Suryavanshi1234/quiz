import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String message;
  final String roomId;
  final String by;
  final Timestamp timestamp;
  final bool isTextMessage;

  Message({
    required this.by,
    required this.isTextMessage,
    required this.message,
    required this.messageId,
    required this.roomId,
    required this.timestamp,
  });

  static Message buildEmptyMessage() {
    return Message(
      by: "",
      isTextMessage: false,
      message: "",
      messageId: "",
      roomId: "",
      timestamp: Timestamp.now(),
    );
  }

  static Message fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> json = Map.from(documentSnapshot.data() as Map);
    return Message(
      by: json['by'] ?? "",
      isTextMessage: json['isTextMessage'] ?? false,
      message: json['message'] ?? "",
      messageId: documentSnapshot.id,
      roomId: json['roomId'] ?? "",
      timestamp: json['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['by'] = by;
    json['roomId'] = roomId;
    json['message'] = message;
    json['isTextMessage'] = isTextMessage;
    json['timestamp'] = timestamp;
    return json;
  }

  Message copyWith({String? messageDocumentId}) {
    return Message(
      by: by,
      isTextMessage: isTextMessage,
      message: message,
      messageId: messageDocumentId ?? messageId,
      roomId: roomId,
      timestamp: timestamp,
    );
  }
}
