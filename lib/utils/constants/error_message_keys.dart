//errorMessagesKey for localization
//error message code starts from 101 to 159

//
//if you make any changes here in keys make sure to update in all languages files
//
import 'package:flutterquiz/utils/constants/string_labels.dart';

const String defaultErrorMessageKey =
    "defaultErrorMessage"; //something went wrong
const String noInternetKey = "noInternet";
const String invalidHashKey = "invalidHash";
const String dataNotFoundKey = "dataNotFound";
const String fillAllDataKey = "fillAllData";
const String fileUploadFailKey = "fileUploadFail";
const String dailyQuizAlreadyPlayedKey = "dailyQuizAlreadyPlayed";
const String noMatchesPlayedKey = "noMatchesPlayed";
const String noUpcomingContestKey = "noUpcomingContest";
const String noContestKey = "noContest";
const String notPlayedContestKey = "notPlayedContest";
const String contestAlreadyPlayedKey = "contestAlreadyPlayed";
const String roomAlreadyCreatedKey = "roomAlreadyCreated";
const String unauthorizedAccessKey = "unauthorizedAccess";

//
//firebase auth exceptions
//
const String invalidEmailKey = "invalid-email";
const String userDisabledKey = "user-disabled";
const String userNotFoundKey = "user-not-found";
const String wrongPasswordKey = "wrong-password";
const String accountExistCredentialKey =
    "account-exists-with-different-credential";
const String invalidCredentialKey = "invalid-credential";
const String operationNotAllowedKey = "operation-not-allowed";
const String invalidVerificationCodeKey = "invalid-verification-code";
const String invalidVerificationIdKey = "invalid-verification-id";
const String emailExistKey = "email-already-in-use";
const String weakPasswordKey = "weak-password";
const String verifyEmailKey = "verifyEmail";
const String levelLockedKey = "levelLocked";
const String updateBookmarkFailureKey = "updateBookmarkFailure";
const String lifeLineUsedKey = "lifeLineUsed";
const String notEnoughCoinsKey = "notEnoughCoins";
const String notesNotAvailableKey = "notesNotAvailable";
const String selectAllValuesKey = "selectAllValues";
const String canNotStartGameKey = "canNotStartGame";
const String roomCodeInvalidKey = "roomCodeInvalid";
const String gameStartedKey = "gameStarted";
const String roomIsFullKey = "roomIsFull";
const String alreadyInExamKey = "alreadyInExam";
const String noExamForTodayKey = "noExamForToday";
const String haveNotCompletedExamKey = "haveNotCompletedExam";
const String requireRecentLoginKey = "requires-recent-login";
const String noTransactionsKey = "noTransactions";
const String accountHasBeenDeactiveKey = "accountHasBeenDeactive";
const String canNotMakeRequestKey = "canNotMakeRequest";

//
//error message code that is not given from api
//error code after 137 occurs in frontend.
//
const String defaultErrorMessageCode = "122";
const String noInternetCode = "126";
const String levelLockedCode = "138";
const String updateBookmarkFailureCode = "139";
const String lifeLineUsedCode = "140";
const String notEnoughCoinsCode = "141";
const String notesNotAvailableCode = "142";
const String selectAllValuesCode = "143";
const String canNotStartGameCode = "144";
const String roomCodeInvalidCode = "145";
const String gameStartedCode = "146";
const String roomIsFullCode = "147";
const String unableToCreateRoomCode = "148";
const String unableToFindRoomCode = "149";
const String unableToJoinRoomCode = "150";
const String unableToSubmitAnswerCode = "151";
const String alreadyInExamCode = "152";
const String noExamForTodayCode = "153";
const String haveNotCompletedExamCode = "154";
const String requireRecentLoginCode = "155";
const String noTransactionsCode = "156";
const String accountHasBeenDeactiveCode = "157";
const String canNotMakeRequestCode = "158";
const String userNotFoundCode = "159";
const String unauthorizedAccessCode = "129";

//
//firebase auth exceptions code
//
String firebaseErrorCodeToNumber(String firebaseErrorCode) {
  switch (firebaseErrorCode) {
    case "invalid-email":
      return "127";
    case "user-disabled":
      return "128";
    case "user-not-found":
      return userNotFoundCode;
    case "wrong-password":
      return "130";
    case "account-exists-with-different-credential":
      return "131";
    case "invalid-credential":
      return "132";
    case "operation-not-allowed":
      return "133";
    case "invalid-verification-code":
      return "134";
    case "verifyEmail":
      return "135";
    case "email-already-in-use":
      return "136";
    case "weak-password":
      return "137";
    case "requires-recent-login":
      return "155";

    default:
      return defaultErrorMessageCode;
  }
}

//
//to convert error code into error keys for localization
//every error occurs in app will have code assign to it
//
String convertErrorCodeToLanguageKey(String code) {
  switch (code) {
    case "101":
      return invalidHashKey;
    case "102":
      return dataNotFoundKey;
    case "103":
      return fillAllDataKey;
    case "104":
      return defaultErrorMessageKey;
    case "105":
      return defaultErrorMessageKey;
    case "106":
      return defaultErrorMessageKey;
    case "107":
      return fileUploadFailKey;
    case "108":
      return defaultErrorMessageKey;
    case "109":
      return defaultErrorMessageKey;
    case "110":
      return defaultErrorMessageKey;
    case "111":
      return defaultErrorMessageKey;
    case "112":
      return dailyQuizAlreadyPlayedKey;
    case "113":
      return noMatchesPlayedKey;
    case "114":
      return noUpcomingContestKey;
    case "115":
      return noContestKey;
    case "116":
      return notPlayedContestKey;
    case "117":
      return contestAlreadyPlayedKey;
    case "118":
      return defaultErrorMessageKey;
    case "119":
      return roomAlreadyCreatedKey;
    case "120":
      return defaultErrorMessageKey;
    case "121":
      return defaultErrorMessageKey;
    case "122":
      return defaultErrorMessageKey;
    case "123":
      return defaultErrorMessageKey;
    case "124":
      return invalidHashKey;
    case "125":
      return unauthorizedAccessKey;
    case "126":
      return noInternetKey;
    case "127":
      return invalidEmailKey;
    case "128":
      return userDisabledKey;
    case "129":
      return unauthorizedAccessKey;
    case "130":
      return wrongPasswordKey;
    case "131":
      return accountExistCredentialKey;
    case "132":
      return invalidCredentialKey;
    case "133":
      return operationNotAllowedKey;
    case "134":
      return invalidVerificationCodeKey;
    case "135":
      return verifyEmailKey;
    case "136":
      return emailExistKey;
    case "137":
      return weakPasswordKey;

    case "138":
      return levelLockedKey;

    case "139":
      return updateBookmarkFailureKey;

    case "140":
      return lifeLineUsedKey;

    case "141":
      return notEnoughCoinsKey;

    case "142":
      return notesNotAvailableKey;

    case "143":
      return selectAllValuesKey;

    case "144":
      return canNotStartGameKey;

    case "145":
      return roomCodeInvalidKey;

    case "146":
      return gameStartedKey;

    case "147":
      return roomIsFullKey;

    case "148":
      return unableToCreateRoomKey;

    case "149":
      return unableToFindRoomKey;

    case "150":
      return unableToJoinRoomCode;

    case "151":
      return unableToSubmitAnswerCode;

    case "152":
      return alreadyInExamKey;

    case "153":
      return noExamForTodayKey;

    case "154":
      return haveNotCompletedExamKey;

    case "155":
      return requireRecentLoginKey;

    case "156":
      return noTransactionsKey;

    case "157":
      return accountHasBeenDeactiveKey;
    case "158":
      return canNotMakeRequestKey;

    case "159":
      return userNotFoundKey;

    default:
      {
        return defaultErrorMessageKey;
      }
  }
}
