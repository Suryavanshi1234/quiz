import 'package:flutterquiz/features/wallet/models/payoutMethod.dart';

const appName = "Elite Quiz";
const packageName = "com.foundercodes.bappa";
const iosAppId = "585027354";

//supported language codes
//Add language code in this list
//visit this to find languageCode for your respective language
//https://developers.google.com/admin-sdk/directory/v1/languages
const supportedLocales = ['en', 'hi', 'ur', "en-GB"];
//
const defaultLanguageCode = 'en';

//Enter 2 Letter ISO Code of country
//It will be use for phone auth.
const initialSelectedCountryCode = 'IN';

//Hive all boxes name
const authBox = "auth";
const settingsBox = "settings";
const bookmarkBox = "bookmark";
const guessTheWordBookmarkBox = "guessTheWordBookmarkBox";
const audioBookmarkBox = "audioBookmarkBox";
const userDetailsBox = "userdetails";
const examBox = "exam";

//authBox keys
const isLoginKey = "isLogin";
const jwtTokenKey = "jwtToken";
const firebaseIdBoxKey = "firebaseId";
const authTypeKey = "authType";
const isNewUserKey = "isNewUser";

//userBox keys
const nameBoxKey = "name";
const userUIdBoxKey = "userUID";
const emailBoxKey = "email";
const mobileNumberBoxKey = "mobile";
const rankBoxKey = "rank";
const coinsBoxKey = "coins";
const scoreBoxKey = "score";
const profileUrlBoxKey = "profileUrl";
const statusBoxKey = "status";
const referCodeBoxKey = "referCode";

//settings box keys
const showIntroSliderKey = "showIntroSlider";
const vibrationKey = "vibration";
const backgroundMusicKey = "backgroundMusic";
const soundKey = "sound";
const languageCodeKey = "language";
const fontSizeKey = "fontSize";
const rewardEarnedKey = "rewardEarned";
const fcmTokenBoxKey = "fcmToken";
const settingsThemeKey = "theme";

//Database related constants

//Add your database url
//make sure to not add '/' at the end of url
// make sure to check if admin panel is http or https
const databaseUrl = "https://bappasecond.apponrent.com";

const baseUrl = '$databaseUrl/Api/';

const accessValue = "";

//lifelines
const fiftyFifty = "fiftyFifty";
const audiencePoll = "audiencePoll";
const skip = "skip";
const resetTime = "resetTime";

//firestore collection names
const battleRoomCollection = "battleRoom"; //  testBattleRoom
const multiUserBattleRoomCollection =
    "multiUserBattleRoom"; //testMultiUserBattleRoom
const messagesCollection = "messages"; // testMessages

//api end pos
const addUserUrl = "${baseUrl}user_signup";

const getQuestionForOneToOneBattle = "${baseUrl}get_random_questions";
const getQuestionForMultiUserBattle = "${baseUrl}get_question_by_room_id";
const createMultiUserBattleRoom = "${baseUrl}create_room";
const deleteMultiUserBattleRoom = "${baseUrl}destroy_room_by_room_id";

const getBookmarkUrl = "${baseUrl}get_bookmark";
const updateBookmarkUrl = "${baseUrl}set_bookmark";

const getNotificationUrl = "${baseUrl}get_notifications";

const getUserDetailsByIdUrl = "${baseUrl}get_user_by_id";
const checkUserExistUrl = "${baseUrl}check_user_exists";

const uploadProfileUrl = "${baseUrl}upload_profile_image";
const updateUserCoinsAndScoreUrl = "${baseUrl}set_user_coin_score";
const updateProfileUrl = "${baseUrl}update_profile";

const getCategoryUrl = "${baseUrl}get_categories";
const getQuestionsByLevelUrl = "${baseUrl}get_questions_by_level";
const getQuestionForDailyQuizUrl = "${baseUrl}get_daily_quiz";
const getLevelUrl = "${baseUrl}get_level_data";
const getSubCategoryUrl = "${baseUrl}get_subcategory_by_maincategory";
const getQuestionForSelfChallengeUrl =
    "${baseUrl}get_questions_for_self_challenge";
const updateLevelUrl = "${baseUrl}set_level_data";
const getMonthlyLeaderboardUrl = "${baseUrl}get_monthly_leaderboard";
const getDailyLeaderboardUrl = "${baseUrl}get_daily_leaderboard";
const getAllTimeLeaderboardUrl = "${baseUrl}get_globle_leaderboard";
const getQuestionByTypeUrl = "${baseUrl}get_questions_by_type";
const getQuestionContestUrl = "${baseUrl}get_questions_by_contest";
const setContestLeaderboardUrl = "${baseUrl}set_contest_leaderboard";
const getContestLeaderboardUrl = "${baseUrl}get_contest_leaderboard";

const getFunAndLearnUrl = "${baseUrl}get_fun_n_learn";
const getFunAndLearnQuestionsUrl = "${baseUrl}get_fun_n_learn_questions";

const getStatisticUrl = "${baseUrl}get_users_statistics";
const updateStatisticUrl = "${baseUrl}set_users_statistics";

const getContestUrl = "${baseUrl}get_contest";
const getSystemConfigUrl = "${baseUrl}get_system_configurations";
const getCoinStoreData = "${baseUrl}get_coin_store_data";

const getSupportedQuestionLanguageUrl = "${baseUrl}get_languages";
const getGuessTheWordQuestionUrl = "${baseUrl}get_guess_the_word";
const getAppSettingsUrl = "${baseUrl}get_settings";
const reportQuestionUrl = "${baseUrl}report_question";
const getQuestionsByCategoryOrSubcategory = "${baseUrl}get_questions";
const updateFcmIdUrl = "${baseUrl}update_fcm_id";
const getAudioQuestionUrl = "${baseUrl}get_audio_questions"; //
const getUserBadgesUrl = "${baseUrl}get_user_badges";
const setUserBadgesUrl = "${baseUrl}set_badges";
const setBattleStatisticsUrl = "${baseUrl}set_battle_statistics";
const getBattleStatisticsUrl = "${baseUrl}get_battle_statistics";

const getExamModuleUrl = "${baseUrl}get_exam_module";
const getExamModuleQuestionsUrl = "${baseUrl}get_exam_module_questions";
const setExamModuleResultUrl = "${baseUrl}set_exam_module_result";
const deleteUserAccountUrl = "${baseUrl}delete_user_account";
const getCoinHistoryUrl = "${baseUrl}get_tracker_data";
const makePaymentRequestUrl = "${baseUrl}set_payment_request";
const getTransactionsUrl = "${baseUrl}get_payment_request";
const getLatexQuestionUrl = "${baseUrl}get_maths_questions";

//This will be in use to mark x category or y sub category played , and fun n learn para
const setQuizCategoryPlayedUrl = "${baseUrl}set_quiz_categories";

// Phone Number
const maxPhoneNumberLength = 16;

const inBetweenQuestionTimeInSeconds = 1;

//it is the waiting time for finding opponent. Once user has waited for
//given seconds it will show opponent not found
const waitForOpponentDurationInSeconds = 30;
//time to read paragraph
// const comprehensionParagraphReadingTimeInSeconds = 60;

//answer correctness track name
const correctAnswerSoundTrack = "assets/sounds/right.mp3";
const wrongAnswerSoundTrack = "assets/sounds/wrong.mp3";
//this will be in use while playing self challenge
const clickEventSoundTrack = "assets/sounds/click.mp3";

//coins and answer pos and win percentage
int lifeLineDeductCoins = 5;
const numberOfHintsPerGuessTheWordQuestion = 2;
const wrongAnswerDeductPoints = 2;

//pos for correct answer in battle
const correctAnswerPointsForBattle = 4;

const guessTheWordCorrectAnswerPoints = 6;
const guessTheWordWrongAnswerDeductPoints = 3;
const double winPercentageBreakPoint = 30.0; // more than 30% declare winner

// const double maxCoinsWinningPercentage =
//     80.0; //it is highest percentage to earn maxCoins
// const maxWinningCoins = 4;

int guessTheWordMaxWinningCoins = 6;
//Coins to give winner of battle (1 vs 1)
// const battleWinnerCoins = 5;
int randomBattleEntryCoins = 5;

//if user give the answer of battle with in 1 or 2 seconds
const extraPointForQuickestAnswer = 2;
//if user give the answer of battle with in 3 or 4 seconds
const extraPointForSecondQuickestAnswer = 1;
//minimum coins for creating group battle
const minCoinsForGroupBattleCreation = 5;
// const maxCoinsForGroupBattleCreation = 50;

//Coins to deduct for seeing Review answers
int reviewAnswersDeductCoins = 10;

//other constants
const defaultQuestionLanguageId = "";

//Group battle invite message
const groupBattleInviteMessage =
    "Hello, Join a group battle in $appName app. Go to group battle in the app and join using the code : ";

// Currency Symbol used in wallet screen, set from admin panel.
late final String payoutRequestCurrency;

//predefined messages for battle
const predefinedMessages = [
  "Hello..!!",
  "How are you..?",
  "Fine..!!",
  "Have a nice day..",
  "Well played",
  "What a performance..!!",
  "Thanks..",
  "Welcome..",
  "Merry Christmas",
  "Happy new year",
  "Happy Diwali",
  "Good night",
  "Hurry Up",
  "Dudeeee"
];

//constants for badges and rewards
const minimumQuestionsForBadges = 5;

//
const badgeTypes = [
  "dashing_debut",
  "combat_winner",
  "clash_winner",
  "most_wanted_winner",
  "ultimate_player",
  "quiz_warrior",
  "super_sonic",
  "flashback",
  "brainiac",
  "big_thing",
  "elite",
  "thirsty",
  "power_elite",
  "sharing_caring",
  "streak"
];

//
const roomCodeGenerateCharacters = "1234567890"; //Numeric
//to make roomCode alpha numeric use below string in roomCodeGenerateCharacters
//AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890

///
///Add your exam rules here
///
const examRules = [
  "I will not copy and give this exam with honesty",
  "If you lock your phone then exam will complete automatically",
  "If you minimize application or open other application and don't come back to application with in 5 seconds then exam will complete automatically",
  "Screen recording is prohibited",
  "In Android screenshot capturing is prohibited",
  "In ios, if you take screenshot then rules will violate and it will inform to examiner"
];

//
//Add notes for wallet request
//

List<String> payoutRequestNotes(String amount, String coins) {
  return [
    "Minimum Redeemable amount is $payoutRequestCurrency $amount ($coins Coins).",
    "Payout will take 3 - 5 working days",
  ];
}

//To add more payout methods here
final payoutMethods = [
  //Paypal
  PayoutMethod(
    //Specify the input parameters label here
    inputDetailsFromUser: const ["Enter paypal id"],
    inputDetailsIsNumber: const [false],
    image: "assets/images/paypal.svg",
    type: "Paypal",
  ),

  //Paytm
  PayoutMethod(
    //Specify the input parameters label here
    inputDetailsFromUser: const ["Enter mobile number"],
    inputDetailsIsNumber: const [true],
    image: "assets/images/paytm.svg",
    type: "Paytm",
  ),

  //UPI
  PayoutMethod(
    //Specify the input parameters label here
    inputDetailsFromUser: const ["Enter upi id"],
    inputDetailsIsNumber: const [false],
    image: "assets/images/upi.svg",
    type: "UPI",
  ),

  /*
  //Sample payment method
  //Bank Transfer - Payment method name
  PayoutMethod(
      //Specify the input parameters label here
      //What are the details user need to give for this payment method
      //
      inputDetailsFromUser: [
        "Enter bank name",
        "Enter account number ",
        "Enter bank ifsc code",
      ], image: "assets/images/paytm.svg",
      type: "Bank Transfer"),
  */
];

// Max Group Battle Players, do not change.
const maxUsersInGroupBattle = 4;

const String removeAdsProductId = "remove_ads";
