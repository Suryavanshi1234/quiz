import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/features/wallet/cubits/paymentRequestCubit.dart';
import 'package:flutterquiz/features/wallet/cubits/transactionsCubit.dart';
import 'package:flutterquiz/features/wallet/models/paymentRequest.dart';
import 'package:flutterquiz/features/wallet/walletRepository.dart';
import 'package:flutterquiz/ui/screens/wallet/widgets/redeemAmountRequestBottomSheetContainer.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<PaymentRequestCubit>(
            create: (_) => PaymentRequestCubit(WalletRepository()),
          ),
          BlocProvider<TransactionsCubit>(
            create: (_) => TransactionsCubit(WalletRepository()),
          ),
        ],
        child: const WalletScreen(),
      ),
    );
  }
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  //int _currentSelectedTab = 1;

  late final String userId = context.read<UserDetailsCubit>().userId();

  late TabController tabController;

  TextEditingController? redeemableAmountTextEditingController;

  late final ScrollController _transactionsScrollController = ScrollController()
    ..addListener(hasMoreTransactionsScrollListener);

  void hasMoreTransactionsScrollListener() {
    if (_transactionsScrollController.position.maxScrollExtent ==
        _transactionsScrollController.offset) {
      if (context.read<TransactionsCubit>().hasMoreTransactions()) {
        fetchMoreTransactions();
      } else {
        dev.log(name: 'Payout Transactions', "No more transactions");
      }
    }
  }

  void fetchTransactions() {
    context.read<TransactionsCubit>().getTransactions(userId: userId);
  }

  void fetchMoreTransactions() {
    context.read<TransactionsCubit>().getMoreTransactions(userId: userId);
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    Future.delayed(Duration.zero, () {
      fetchTransactions();
      //
      redeemableAmountTextEditingController = TextEditingController(
        text: UiUtils.calculateAmountPerCoins(
          userCoins: double.parse(context.read<UserDetailsCubit>().getCoins()!)
              .toInt(),
          amount: context
              .read<SystemConfigCubit>()
              .coinAmount(), //per x coin y amount
          coins: context.read<SystemConfigCubit>().perCoin(), //per x coins
        ).toString(),
      );

      //InterstitialAds show
      Future.delayed(Duration.zero, () {
        context.read<InterstitialAdCubit>().showAd(context);
      });

      setState(() {});
    });
  }

  double _minimumRedeemableAmount() {
    return UiUtils.calculateAmountPerCoins(
      userCoins: context.read<SystemConfigCubit>().minimumCoinLimit(),
      amount: context.read<SystemConfigCubit>().coinAmount(),
      coins: context.read<SystemConfigCubit>().perCoin(),
    );
  }

  @override
  void dispose() {
    redeemableAmountTextEditingController?.dispose();
    _transactionsScrollController
        .removeListener(hasMoreTransactionsScrollListener);
    _transactionsScrollController.dispose();
    tabController.dispose();
    super.dispose();
  }

  void showRedeemRequestAmountBottomSheet({
    required int deductedCoins,
    required double redeemableAmount,
  }) {
    showModalBottomSheet<bool>(
        isDismissible: true,
        enableDrag: true,
        isScrollControlled: true,
        elevation: 5.0,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: UiUtils.bottomSheetTopRadius,
        ),
        builder: (_) {
          return RedeemAmountRequestBottomSheetContainer(
            paymentRequestCubit: context.read<PaymentRequestCubit>(),
            deductedCoins: deductedCoins,
            redeemableAmount: redeemableAmount,
          );
        }).then((value) {
      if (value != null && value) {
        fetchTransactions();
        redeemableAmountTextEditingController?.text =
            UiUtils.calculateAmountPerCoins(
          userCoins: int.parse(context.read<UserDetailsCubit>().getCoins()!),
          amount: context.read<SystemConfigCubit>().coinAmount(),
          coins: context.read<SystemConfigCubit>().perCoin(),
        ).toString();
        tabController.animateTo(1);
      }
    });
  }

  Widget _buildPayoutRequestNote(String note) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onTertiary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              note,
              style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onTertiary.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }

  //Build request tab
  Widget _buildRequestContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.02,
        left: MediaQuery.of(context).size.width * (0.05),
        right: MediaQuery.of(context).size.width * (0.05),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                /// Total Coins
                Text(
                  AppLocalization.of(context)!
                      .getTranslatedValues(totalCoinsKey)!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontSize: 16.0,
                  ),
                ),
                BlocBuilder<UserDetailsCubit, UserDetailsState>(
                  bloc: context.read<UserDetailsCubit>(),
                  builder: (context, state) {
                    if (state is UserDetailsFetchSuccess) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            UiUtils.getImagePath("coin.svg"),
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${context.read<UserDetailsCubit>().getCoins()}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onTertiary,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                            ),
                          ),
                        ],
                      );
                    }

                    return const SizedBox();
                  },
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                /// Redeemable Amount
                Text(
                  AppLocalization.of(context)!
                      .getTranslatedValues(redeemableAmountKey)!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontWeight: FontWeight.w500,
                    fontSize: 20.0,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                    ),
                    keyboardType: TextInputType.number,
                    cursorColor: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.5),
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).colorScheme.background,
                      isDense: true,
                      border: InputBorder.none,
                      hintText: "00",
                      prefixText: "$payoutRequestCurrency ",
                      hintStyle: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context)
                            .colorScheme
                            .onTertiary
                            .withOpacity(0.6),
                      ),
                    ),
                    controller: redeemableAmountTextEditingController,
                  ),
                ),
                //SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                // Row(
                //   children: [
                //     redeemCoinOptions("100"),
                //     const SizedBox(width: 8),
                //     redeemCoinOptions("200"),
                //     const SizedBox(width: 8),
                //     redeemCoinOptions("300"),
                //   ],
                // ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                /// Payout Notes
                Column(
                  children: payoutRequestNotes(
                    context.read<SystemConfigCubit>().coinAmount().toString(),
                    context.read<SystemConfigCubit>().perCoin().toString(),
                  ).map((e) => _buildPayoutRequestNote(e)).toList(),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.03),

          /// Redeem Now Btn
          CustomRoundedButton(
            widthPercentage: 1.0,
            backgroundColor: Theme.of(context).primaryColor,
            buttonTitle: AppLocalization.of(context)!
                    .getTranslatedValues(redeemNowKey) ??
                "",
            radius: 8.0,
            showBorder: false,
            titleColor: Theme.of(context).colorScheme.background,
            fontWeight: FontWeight.bold,
            textSize: 18.0,
            onTap: () {
              final enteredRedeemAmount =
                  redeemableAmountTextEditingController!.text.trim();

              if (enteredRedeemAmount.isEmpty ||
                  double.parse(enteredRedeemAmount) <
                      _minimumRedeemableAmount()) {
                UiUtils.setSnackbar(
                    "${AppLocalization.of(context)!.getTranslatedValues(minimumRedeemableAmountKey)} $payoutRequestCurrency${_minimumRedeemableAmount()} ",
                    context,
                    false);
                return;
              }
              double maxRedeemableAmount = UiUtils.calculateAmountPerCoins(
                userCoins:
                    int.parse(context.read<UserDetailsCubit>().getCoins()!),
                amount: context
                    .read<SystemConfigCubit>()
                    .coinAmount(), //per x coin y amount
                coins:
                    context.read<SystemConfigCubit>().perCoin(), //per x coins
              );
              if (double.parse(enteredRedeemAmount) > maxRedeemableAmount) {
                UiUtils.setSnackbar(
                  AppLocalization.of(context)!
                      .getTranslatedValues(notEnoughCoinsToRedeemAmountKey)!,
                  context,
                  false,
                );
                return;
              }

              showRedeemRequestAmountBottomSheet(
                deductedCoins:
                    UiUtils.calculateDeductedCoinsForRedeemableAmount(
                  amount: context
                      .read<SystemConfigCubit>()
                      .coinAmount(), //per x coin y amount
                  coins:
                      context.read<SystemConfigCubit>().perCoin(), //per x coins
                  userEnteredAmount: double.parse(enteredRedeemAmount),
                ),
                redeemableAmount: double.parse(enteredRedeemAmount),
              );
            },
            height: 50.0,
          ),
        ],
      ),
    );
  }

  Container redeemCoinOptions(String coins) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.09),
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.06),
            spreadRadius: 1,
            blurRadius: 0,
            offset: const Offset(1, 1), // changes position of shadow
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            UiUtils.getImagePath("coin.svg"),
            width: 15,
            height: 15,
          ),
          const SizedBox(width: 4),
          Text(
            coins,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionContainer({
    required PaymentRequest paymentRequest,
    required int index,
    required int totalTransactions,
    required bool hasMoreTransactionsFetchError,
    required bool hasMore,
  }) {
    if (index == totalTransactions - 1) {
      //check if hasMore
      if (hasMore) {
        if (hasMoreTransactionsFetchError) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: IconButton(
                onPressed: fetchMoreTransactions,
                icon: Icon(
                  Icons.error,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: CircularProgressContainer(),
            ),
          );
        }
      }
    }

    final String paymentStatus;

    if (paymentRequest.status == '0') {
      paymentStatus = pendingKey;
    } else if (paymentRequest.status == '1') {
      paymentStatus = completedKey;
    } else {
      paymentStatus = wrongDetailsKey;
    }

    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * (0.0265),
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(10.0),
          ),
          height: MediaQuery.of(context).size.height * 0.13,
          //
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              SizedBox(
                width: boxConstraints.maxWidth * (0.66),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      paymentRequest.details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),

                    /// Payment Type
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${AppLocalization.of(context)!.getTranslatedValues("payment")!} : ",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiary
                                .withOpacity(0.4),
                          ),
                        ),
                        Text(
                          paymentRequest.paymentType,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * .004),

                    /// Date
                    Row(
                      children: [
                        Text(
                          paymentRequest.date.length < 11
                              ? paymentRequest.date
                              : paymentRequest.date.substring(0, 11),
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiary
                                .withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: boxConstraints.maxWidth * 0.28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).primaryColor,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      width: boxConstraints.maxWidth * 0.18,
                      alignment: Alignment.center,
                      child: Text(
                        "$payoutRequestCurrency ${UiUtils.formatNumber(double.parse(paymentRequest.paymentAmount).toInt())}",
                        maxLines: 1,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.background,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: paymentRequest.status == "0"
                            ? hurryUpTimerColor.withOpacity(0.4)
                            : addCoinColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      child: Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues(paymentStatus)!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: paymentRequest.status == "0"
                              ? hurryUpTimerColor
                              : addCoinColor,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionListContainer() {
    return BlocConsumer<TransactionsCubit, TransactionsState>(
      listener: (context, state) {
        if (state is TransactionsFetchFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      builder: (context, state) {
        if (state is TransactionsFetchInProgress ||
            state is TransactionsFetchInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is TransactionsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                convertErrorCodeToLanguageKey(state.errorMessage),
              ),
              onTapRetry: fetchTransactions,
              showErrorImage: true,
            ),
          );
        }

        final totalReqs =
            (state as TransactionsFetchSuccess).paymentRequests.length;
        return SingleChildScrollView(
          controller: _transactionsScrollController,
          padding: EdgeInsets.only(
            bottom: 20.0,
            top: MediaQuery.of(context).size.height * 0.02,
            left: MediaQuery.of(context).size.width * (0.05),
            right: MediaQuery.of(context).size.width * (0.05),
          ),
          child: Column(
            children: [
              /// Total Earnings
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * (0.1),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues(totalEarningsKey)!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      "$payoutRequestCurrency ${context.read<TransactionsCubit>().calculateTotalEarnings()}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),

              /// List of Redeem Requests
              for (var i = 0; i < totalReqs; i++) ...[
                _buildTransactionContainer(
                  paymentRequest: state.paymentRequests[i],
                  index: i,
                  totalTransactions: state.paymentRequests.length,
                  hasMoreTransactionsFetchError: state.hasMoreFetchError,
                  hasMore: state.hasMore,
                )
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title:
            Text(AppLocalization.of(context)!.getTranslatedValues(walletKey)!),
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(
              text:
                  AppLocalization.of(context)!.getTranslatedValues(requestKey)!,
            ),
            Tab(
              text: AppLocalization.of(context)!
                  .getTranslatedValues(transactionKey)!,
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildRequestContainer(),
          _buildTransactionListContainer(),
        ],
      ),
    );
  }
}
