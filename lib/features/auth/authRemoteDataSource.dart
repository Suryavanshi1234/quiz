import 'dart:convert';

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:flutterquiz/features/auth/auhtException.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/utils/constants/api_body_parameter_labels.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:apple_sign_in_safety/apple_sign_in.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //to addUser
  Future<Map<String, dynamic>> addUser({
    String? firebaseId,
    String? type,
    String? name,
    String? profile,
    String? mobile,
    String? email,
    String? referCode,
    String? friendCode,
  }) async {
    try {
      String fcmToken = await getFCMToken();
      //body of post request
      final body = {
        accessValueKey: accessValue,
        firebaseIdKey: firebaseId,
        typeKey: type,
        nameKey: name,
        emailKey: email ?? "",
        profileKey: profile ?? "",
        mobileKey: mobile ?? "",
        fcmIdKey: fcmToken,
        friendCodeKey: friendCode ?? ""
      };

      print("Add User Body: $body");
      final response = await http.post(Uri.parse(addUserUrl), body: body);
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw AuthException(errorMessageCode: responseJson['message']);
      }
      return Map<String, dynamic>.from(responseJson['data']);
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: noInternetCode);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //to addUser
  Future<String> getJWTTokenOfUser({
    required String firebaseId,
    required String type,
  }) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        firebaseIdKey: firebaseId,
        typeKey: type,
      };

      final response = await http.post(Uri.parse(addUserUrl), body: body);
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw AuthException(errorMessageCode: responseJson['message']);
      }
      return (responseJson['data']['api_token']).toString();
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: noInternetCode);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<bool> isUserExist(String firebaseId) async {
    try {
      final body = {
        accessValueKey: accessValue,
        firebaseIdKey: firebaseId,
      };
      final response =
          await http.post(Uri.parse(checkUserExistUrl), body: body);
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw AuthException(errorMessageCode: responseJson['message']);
      }

      return responseJson['message'].toString() == "130";
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: noInternetCode);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<void> updateFcmId({
    required String firebaseId,
    required bool userLoggingOut,
  }) async {
    try {
      final String fcmId = userLoggingOut
          ? "empty"
          : await fcm.FirebaseMessaging.instance.getToken() ?? "empty";
      final body = {
        accessValueKey: accessValue,
        fcmIdKey: fcmId,
        firebaseIdKey: firebaseId.isNotEmpty ? firebaseId : "firebaseId"
      };
      final response = await http.post(Uri.parse(updateFcmIdUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        //throw AuthException(errorMessageCode: responseJson['message']);
      }
    } catch (e) {
      //throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

//signIn using phone number
  Future<UserCredential> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);

    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(phoneAuthCredential);
    return userCredential;
  }

  //SignIn user will accept AuthProvider (enum)
  Future<Map<String, dynamic>> signInUser(
    AuthProvider authProvider, {
    String? email,
    String? password,
    String? verificationId,
    String? smsCode,
  }) async {
    //user creadential contains information of signin user and is user new or not
    Map<String, dynamic> result = {};

    try {
      if (authProvider == AuthProvider.gmail) {
        UserCredential userCredential = await signInWithGoogle();

        result['user'] = userCredential.user!;
        result['isNewUser'] = userCredential.additionalUserInfo!.isNewUser;
      } else if (authProvider == AuthProvider.mobile) {
        UserCredential userCredential = await signInWithPhoneNumber(
            verificationId: verificationId!, smsCode: smsCode!);

        result['user'] = userCredential.user!;
        result['isNewUser'] = userCredential.additionalUserInfo!.isNewUser;
      } else if (authProvider == AuthProvider.email) {
        UserCredential userCredential =
            await signInWithEmailAndPassword(email!, password!);

        result['user'] = userCredential.user!;
        result['isNewUser'] = userCredential.additionalUserInfo!.isNewUser;
      } else if (authProvider == AuthProvider.apple) {
        UserCredential userCredential = await signInWithApple();
        result['user'] = _firebaseAuth.currentUser!;
        result['isNewUser'] = userCredential.additionalUserInfo!.isNewUser;
      }
      return result;
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: noInternetCode);
    }
    //firebase auht errors
    on FirebaseAuthException catch (e) {
      throw AuthException(errorMessageCode: firebaseErrorCodeToNumber(e.code));
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //signIn using google account
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    return userCredential;
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final AuthorizationResult appleResult =
          await AppleSignIn.performRequests([
        const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      if (appleResult.status == AuthorizationStatus.authorized) {
        final appleIdCredential = appleResult.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        if (userCredential.additionalUserInfo!.isNewUser) {
          final user = userCredential.user!;
          final String givenName = appleIdCredential.fullName!.givenName ?? "";

          final String familyName =
              appleIdCredential.fullName!.familyName ?? "";
          await user.updateDisplayName("$givenName $familyName");
          await user.reload();
        }

        return userCredential;
      } else if (appleResult.status == AuthorizationStatus.error) {
        throw AuthException(errorMessageCode: defaultErrorMessageCode);
      } else {
        throw AuthException(errorMessageCode: defaultErrorMessageCode);
      }
    } catch (error) {
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    //sign in using email
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    if (userCredential.user!.emailVerified) {
      return userCredential;
    } else {
      throw AuthException(errorMessageCode: "135");
    }
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  static Future<String> getFCMToken() async {
    try {
      return await fcm.FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      return "";
    }
  }

  //create user account
  Future<void> signUpUser(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //verify email address
      await userCredential.user!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(errorMessageCode: firebaseErrorCodeToNumber(e.code));
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: noInternetCode);
    } catch (e) {
      throw AuthException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<void> signOut(AuthProvider? authProvider) async {
    _firebaseAuth.signOut();
    if (authProvider == AuthProvider.gmail) {
      _googleSignIn.signOut();
    }
  }
}
