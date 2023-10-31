import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomRemoteDataSource.dart';
import 'package:flutterquiz/features/battleRoom/models/battleRoom.dart';
import 'package:flutterquiz/features/battleRoom/models/message.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';

import 'battleRoomExecption.dart';

class BattleRoomRepository {
  static final BattleRoomRepository _battleRoomRepository =
      BattleRoomRepository._internal();
  late BattleRoomRemoteDataSource _battleRoomRemoteDataSource;

  factory BattleRoomRepository() {
    _battleRoomRepository._battleRoomRemoteDataSource =
        BattleRoomRemoteDataSource();

    return _battleRoomRepository;
  }

  BattleRoomRepository._internal();

  //search battle room
  Future<List<DocumentSnapshot>> searchBattleRoom(
      {required String categoryId,
      required String name,
      required String profileUrl,
      required String uid,
      required String questionLanguageId}) async {
    try {
      final documents = await _battleRoomRemoteDataSource.searchBattleRoom(
          categoryId, questionLanguageId);

      //if room is created by user who is searching the room then delete room
      //so user will not join room that was created by him/her self
      int index = documents.indexWhere((element) =>
          (element.data() as Map<String, dynamic>)['createdBy'] == uid);
      if (index != -1) {
        deleteBattleRoom(documents[index].id, false);
        documents.removeAt(index);
      }
      return documents;
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  Future<DocumentSnapshot> createBattleRoom({
    required String categoryId,
    required String name,
    required String profileUrl,
    required String uid,
    String? roomCode,
    String? roomType,
    int? entryFee,
    required String questionLanguageId,
  }) async {
    try {
      return await _battleRoomRemoteDataSource.createBattleRoom(
        categoryId: categoryId,
        name: name,
        profileUrl: profileUrl,
        uid: uid,
        entryFee: entryFee,
        roomCode: roomCode,
        roomType: roomType,
        questionLanguageId: questionLanguageId,
      );
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //join multi user battle room
  Future<Map<String, dynamic>> joinBattleRoomFrd(
      {String? name,
      String? profileUrl,
      String? uid,
      String? roomCode,
      int? currentCoin}) async {
    try {
      //verify roomCode is valid or not
      QuerySnapshot querySnapshot = await _battleRoomRemoteDataSource
          .getMultiUserBattleRoom(roomCode, "battle");

      //invalid room code
      if (querySnapshot.docs.isEmpty) {
        throw BattleRoomException(
            errorMessageCode: roomCodeInvalidCode); //invalid roomcode
      }

      //game started code
      if ((querySnapshot.docs.first.data()
          as Map<String, dynamic>)['readyToPlay']) {
        throw BattleRoomException(errorMessageCode: gameStartedCode);
      }

      //not enough coins
      if ((querySnapshot.docs.first.data()
              as Map<String, dynamic>)['entryFee'] >
          currentCoin) {
        throw BattleRoomException(errorMessageCode: notEnoughCoinsCode);
      }

      //fetch questions for quiz
      final questions = await getQuestions(
        categoryId: "",
        matchId: roomCode!,
        forMultiUser: false,
        roomCreater: false,
        roomDocumentId: querySnapshot.docs.first.id,
        languageId: defaultQuestionLanguageId,
        destroyBattleRoom: "0",
      );

      print("GetSomeData$questions");

      //get roomRef
      DocumentReference documentReference = querySnapshot.docs.first.reference;
      //using transaction so we get latest document before updating roomDocument
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        //get latest document
        DocumentSnapshot documentSnapshot = await documentReference.get();
        Map user2Details =
            Map.from(documentSnapshot.data() as Map<String, dynamic>)['user2'];

        if (user2Details['uid'].toString().isEmpty) {
          //join as user2
          transaction.update(documentReference, {
            "user2.name": name,
            "user2.uid": uid,
            "user2.profileUrl": profileUrl,
          });
        } else {
          //room is full
          throw BattleRoomException(errorMessageCode: roomIsFullCode);
        }
        return {"roomId": documentSnapshot.id, "questions": questions};
      });
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //create multi user battle room
  Future<DocumentSnapshot> createMultiUserBattleRoom(
      {required String categoryId,
      String? name,
      String? profileUrl,
      String? uid,
      String? roomCode,
      String? roomType,
      int? entryFee,
      String? questionLanguageId}) async {
    try {
      return await _battleRoomRemoteDataSource.createMutliUserBattleRoom(
          categoryId: categoryId,
          name: name,
          profileUrl: profileUrl,
          roomCode: roomCode,
          uid: uid,
          roomType: roomType,
          entryFee: entryFee,
          questionLanguageId: questionLanguageId);
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //join multi user battle room
  Future<Map<String, dynamic>> joinMultiUserBattleRoom(
      {String? name,
      String? profileUrl,
      String? uid,
      String? roomCode,
      int? currentCoin}) async {
    try {
      //verify roomCode is valid or not
      QuerySnapshot querySnapshot = await _battleRoomRemoteDataSource
          .getMultiUserBattleRoom(roomCode, "");

      //invalid room code
      if (querySnapshot.docs.isEmpty) {
        throw BattleRoomException(
            errorMessageCode: roomCodeInvalidCode); //invalid roomcode
      }

      //game started code
      if ((querySnapshot.docs.first.data()
          as Map<String, dynamic>)['readyToPlay']) {
        throw BattleRoomException(errorMessageCode: gameStartedCode);
      }

      //not enough coins
      if ((querySnapshot.docs.first.data()
              as Map<String, dynamic>)['entryFee'] >
          currentCoin) {
        throw BattleRoomException(errorMessageCode: notEnoughCoinsCode);
      }

      //fetch questions for quiz
      final questions = await getQuestions(
          categoryId: "",
          matchId: roomCode!,
          forMultiUser: true,
          roomCreater: false,
          roomDocumentId: querySnapshot.docs.first.id,
          languageId: defaultQuestionLanguageId);

      //get roomRef
      DocumentReference documentReference = querySnapshot.docs.first.reference;

      //using transaction so we get latest document before updating roomDocument
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        //get latest document
        DocumentSnapshot documentSnapshot = await documentReference.get();
        Map? user4Details =
            Map.from(documentSnapshot.data() as Map<String, dynamic>)['user4'];
        Map? user3Details =
            Map.from(documentSnapshot.data() as Map<String, dynamic>)['user3'];
        Map user2Details =
            Map.from(documentSnapshot.data() as Map<String, dynamic>)['user2'];

        if (user2Details['uid'].toString().isEmpty) {
          //join as user2
          transaction.update(documentReference, {
            "user2.name": name,
            "user2.uid": uid,
            "user2.profileUrl": profileUrl,
          });
        } else if (user3Details!['uid'].toString().isEmpty) {
          //join as user3
          transaction.update(documentReference, {
            "user3.name": name,
            "user3.uid": uid,
            "user3.profileUrl": profileUrl,
          });
        } else if (user4Details!['uid'].toString().isEmpty) {
          //join as user4

          transaction.update(documentReference, {
            "user4.name": name,
            "user4.uid": uid,
            "user4.profileUrl": profileUrl,
          });
        } else {
          //room is full
          throw BattleRoomException(errorMessageCode: roomIsFullCode);
        }

        return {"roomId": documentSnapshot.id, "questions": questions};
      });
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //subscribe to battle room
  Stream<DocumentSnapshot> subscribeToBattleRoom(
      String? battleRoomDocumentId, bool forMultiUser) {
    return _battleRoomRemoteDataSource.subscribeToBattleRoom(
        battleRoomDocumentId, forMultiUser);
  }

  //delete room by id
  Future<void> deleteBattleRoom(String? documentId, bool forMultiUser,
      {String? roomCode}) async {
    try {
      await _battleRoomRemoteDataSource
          .deleteBattleRoom(documentId, forMultiUser, roomCode: roomCode);
    } catch (e) {}
  }

  Future<void> removeOpponentFromBattleRoom(String roomId) async {
    try {
      await _battleRoomRemoteDataSource.removeOpponentFromBattleRoom(roomId);
    } catch (e) {}
  }

  Future<void> deleteUnusedBattleRoom(String userId) async {
    try {
      final rooms =
          await _battleRoomRemoteDataSource.getRoomCreatedByUser(userId);
      for (var element in rooms['groupBattle']!) {
        BattleRoom battleRoom = BattleRoom.fromDocumentSnapshot(element);
        if (!battleRoom.readyToPlay!) {
          print("${battleRoom.roomId} deleted");
          _battleRoomRemoteDataSource.deleteBattleRoom(battleRoom.roomId, true,
              roomCode: battleRoom.roomCode);
        }
      }
      for (var element in rooms['battle']!) {
        print("${element.id} deleted");
        _battleRoomRemoteDataSource.deleteBattleRoom(element.id, false);
      }
    } catch (e) {}
  }

  //get quesitons for battle
  Future<List<Question>> getQuestions(
      {required String languageId,
      required String categoryId,
      required String matchId,
      required bool forMultiUser,
      required bool roomCreater,
      required String roomDocumentId,
      String? destroyBattleRoom}) async {
    try {
      List? quesions;
      if (forMultiUser) {
        quesions = await _battleRoomRemoteDataSource
            .getMultiUserBattleQuestions(matchId);
      } else {
        quesions = await _battleRoomRemoteDataSource.getQuestions(
            destroyRoom: destroyBattleRoom ?? "1",
            categoryId: categoryId,
            languageId: languageId,
            matchId: matchId);
      }

      return quesions!.map((e) => Question.fromJson(Map.from(e))).toList();
    } catch (e) {
      if (roomCreater) {
        //if any error occurs while fetching question deleteRoom
        deleteBattleRoom(roomDocumentId, forMultiUser);
      }
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  Future<void> destroyBattleRoomInDatabase(
      {required String languageId,
      required String categoryId,
      required String matchId}) async {
    try {
      await _battleRoomRemoteDataSource.getQuestions(
          languageId: languageId,
          categoryId: categoryId,
          matchId: matchId,
          destroyRoom: "1");
    } catch (e) {
      print(e.toString());
    }
  }

  //to join battle room (one to one)
  Future<bool> joinBattleRoom(
      {String? battleRoomDocumentId,
      String? name,
      String? profileUrl,
      String? uid}) async {
    try {
      return await _battleRoomRemoteDataSource.joinBattleRoom(
        battleRoomDocumentId: battleRoomDocumentId,
        name: name,
        profileUrl: profileUrl,
        uid: uid,
      );
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //submit answer and update correct answer count and points
  Future<void> submitAnswer(
      {required bool forUser1,
      List? submittedAnswer,
      String? battleRoomDocumentId,
      int? points,
      int? correctAnswers}) async {
    try {
      Map<String, dynamic> submitAnswer = {};
      if (forUser1) {
        submitAnswer.addAll({
          "user1.answers": submittedAnswer,
          "user1.points": points,
          "user1.correctAnswers": correctAnswers
        });
      } else {
        submitAnswer.addAll({
          "user2.answers": submittedAnswer,
          "user2.points": points,
          "user2.correctAnswers": correctAnswers
        });
      }
      await _battleRoomRemoteDataSource.submitAnswer(
          battleRoomDocumentId: battleRoomDocumentId,
          submitAnswer: submitAnswer,
          forMultiUser: false);
    } catch (e) {}
  }

  //submit answer and update correct answer count
  Future<void> submitAnswerForMultiUserBattleRoom(
      {String? userNumber,
      List? submittedAnswer,
      String? battleRoomDocumentId,
      int? correctAnswers}) async {
    try {
      Map<String, dynamic> submitAnswer = {};
      if (userNumber == "1") {
        submitAnswer.addAll({
          "user1.answers": submittedAnswer,
          "user1.correctAnswers": correctAnswers
        });
      } else if (userNumber == "2") {
        submitAnswer.addAll({
          "user2.answers": submittedAnswer,
          "user2.correctAnswers": correctAnswers
        });
      } else if (userNumber == "3") {
        submitAnswer.addAll({
          "user3.answers": submittedAnswer,
          "user3.correctAnswers": correctAnswers
        });
      } else {
        submitAnswer.addAll({
          "user4.answers": submittedAnswer,
          "user4.correctAnswers": correctAnswers
        });
      }

      await _battleRoomRemoteDataSource.submitAnswer(
          battleRoomDocumentId: battleRoomDocumentId,
          submitAnswer: submitAnswer,
          forMultiUser: true);
    } catch (e) {}
  }

  // Delete User from room
  Future<void> deleteUserFromRoom(int userNumber, BattleRoom battleRoom) async {
    try {
      final updatedData = <String, dynamic>{};
      if (userNumber == 1) {
        updatedData['user1'] = {
          "name": "",
          "points": 0,
          "correctAnswers": 0,
          "answers": [],
          "uid": "",
          "profileUrl": ""
        };
        updatedData['user2'] = {
          "name": battleRoom.user2!.name,
          "points": battleRoom.user2!.points,
          "correctAnswers": battleRoom.user2!.correctAnswers,
          "answers": battleRoom.user2!.answers,
          "uid": battleRoom.user2!.uid,
          "profileUrl": battleRoom.user2!.profileUrl,
        };
      } else {
        updatedData['user1'] = {
          "name": battleRoom.user1!.name,
          "points": battleRoom.user1!.points,
          "correctAnswers": battleRoom.user1!.correctAnswers,
          "answers": battleRoom.user1!.answers,
          "uid": battleRoom.user1!.uid,
          "profileUrl": battleRoom.user1!.profileUrl,
        };
        updatedData['user2'] = {
          "name": "",
          "points": 0,
          "correctAnswers": 0,
          "answers": [],
          "uid": "",
          "profileUrl": ""
        };
      }
      _battleRoomRemoteDataSource.updateUserDataInRoom(
        battleRoom.roomId,
        updatedData,
        isMultiUserRoom: false,
      );
    } catch (e) {
      log(e.toString(), name: 'DeleteUserFromRoom');
    }
  }

  //delete user from multi user battle room (this will be call when user left the game)
  Future<void> deleteUserFromMultiUserRoom(
      int userNumber, BattleRoom battleRoom) async {
    try {
      final Map<String, dynamic> updatedData = {};
      if (userNumber == 1) {
        //move users to one step ahead
        updatedData['user1'] = {
          "name": battleRoom.user2!.name,
          "correctAnswers": battleRoom.user2!.correctAnswers,
          "answers": battleRoom.user2!.answers,
          "uid": battleRoom.user2!.uid,
          "profileUrl": battleRoom.user2!.profileUrl
        };
        updatedData['user2'] = {
          "name": battleRoom.user3!.name,
          "correctAnswers": battleRoom.user3!.correctAnswers,
          "answers": battleRoom.user3!.answers,
          "uid": battleRoom.user3!.uid,
          "profileUrl": battleRoom.user3!.profileUrl
        };
        updatedData['user3'] = {
          "name": battleRoom.user4!.name,
          "correctAnswers": battleRoom.user4!.correctAnswers,
          "answers": battleRoom.user4!.answers,
          "uid": battleRoom.user4!.uid,
          "profileUrl": battleRoom.user4!.profileUrl
        };
        updatedData['user4'] = {
          "name": "",
          "correctAnswers": 0,
          "answers": [],
          "uid": "",
          "profileUrl": ""
        };
      } else if (userNumber == 2) {
        updatedData['user2'] = {
          "name": battleRoom.user3!.name,
          "correctAnswers": battleRoom.user3!.correctAnswers,
          "answers": battleRoom.user3!.answers,
          "uid": battleRoom.user3!.uid,
          "profileUrl": battleRoom.user3!.profileUrl
        };
        updatedData['user3'] = {
          "name": battleRoom.user4!.name,
          "correctAnswers": battleRoom.user4!.correctAnswers,
          "answers": battleRoom.user4!.answers,
          "uid": battleRoom.user4!.uid,
          "profileUrl": battleRoom.user4!.profileUrl
        };
        updatedData['user4'] = {
          "name": "",
          "correctAnswers": 0,
          "answers": [],
          "uid": "",
          "profileUrl": ""
        };
      } else if (userNumber == 3) {
        updatedData['user3'] = {
          "name": battleRoom.user4!.name,
          "correctAnswers": battleRoom.user4!.correctAnswers,
          "answers": battleRoom.user4!.answers,
          "uid": battleRoom.user4!.uid,
          "profileUrl": battleRoom.user4!.profileUrl
        };
        updatedData['user4'] = {
          "name": "",
          "correctAnswers": 0,
          "answers": [],
          "uid": "",
          "profileUrl": ""
        };
      } else {
        updatedData['user4'] = {
          "name": "",
          "correctAnswers": 0,
          "answers": [],
          "uid": "",
          "profileUrl": ""
        };
      }
      _battleRoomRemoteDataSource.updateUserDataInRoom(
        battleRoom.roomId,
        updatedData,
        isMultiUserRoom: true,
      );
    } catch (e) {
      log(e.toString(), name: 'deleteUserFromMultiUserRoom');
    }
  }

  Future<void> startMultiUserQuiz(
    String? battleRoomDocumentId, {
    required bool isMultiUserRoom,
  }) async {
    try {
      _battleRoomRemoteDataSource.updateUserDataInRoom(
        battleRoomDocumentId,
        {"readyToPlay": true},
        isMultiUserRoom: isMultiUserRoom,
      );
    } catch (e) {}
  }

  //All the message related code start from here
  Stream<List<Message>> subscribeToMessages({required String roomId}) {
    return _battleRoomRemoteDataSource
        .subscribeToMessages(roomId: roomId)
        .map((event) {
      if (event.docs.isEmpty) {
        return [];
      } else {
        print("Messages length is : ${event.docs.length}");
        return event.docs.map((e) => Message.fromDocumentSnapshot(e)).toList();
      }
    });
  }

  //to add messgae
  Future<String> addMessage(Message message) async {
    try {
      return await _battleRoomRemoteDataSource.addMessage(message.toJson());
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //to delete messgae
  Future<void> deleteMessage(Message message) async {
    try {
      _battleRoomRemoteDataSource.deleteMessage(message.messageId);
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }

  //to delete messgae
  Future<void> deleteMessagesByUserId(String roomId, String by) async {
    try {
      //fetch all messages of given roomId
      List<DocumentSnapshot> messages =
          await _battleRoomRemoteDataSource.getMessagesByUserId(roomId, by);
      //delete all messages
      for (var element in messages) {
        try {
          _battleRoomRemoteDataSource.deleteMessage(element.id);
        } catch (e) {}
      }
    } catch (e) {
      throw BattleRoomException(errorMessageCode: e.toString());
    }
  }
}
