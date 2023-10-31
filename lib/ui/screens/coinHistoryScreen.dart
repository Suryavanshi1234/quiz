import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/coinHistory/coinHistoryCubit.dart';
import 'package:flutterquiz/features/coinHistory/coinHistoryRepository.dart';
import 'package:flutterquiz/features/coinHistory/models/coinHistory.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:intl/intl.dart';

class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key});

  @override
  _CoinHistoryScreenState createState() => _CoinHistoryScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<CoinHistoryCubit>(
          create: (_) => CoinHistoryCubit(CoinHistoryRepository()),
          child: const CoinHistoryScreen()),
    );
  }
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  late final _coinHistoryScrollController = ScrollController()
    ..addListener(hasMoreCoinHistoryScrollListener);

  void getCoinHistory() {
    Future.delayed(Duration.zero, () {
      context
          .read<CoinHistoryCubit>()
          .getCoinHistory(userId: context.read<UserDetailsCubit>().userId());
    });
  }

  @override
  void initState() {
    getCoinHistory();
    super.initState();
  }

  @override
  void dispose() {
    _coinHistoryScrollController
        .removeListener(hasMoreCoinHistoryScrollListener);
    _coinHistoryScrollController.dispose();
    super.dispose();
  }

  void hasMoreCoinHistoryScrollListener() {
    if (_coinHistoryScrollController.position.maxScrollExtent ==
        _coinHistoryScrollController.offset) {
      print("At the end of the list");
      if (context.read<CoinHistoryCubit>().hasMoreCoinHistory()) {
        //
        context.read<CoinHistoryCubit>().getMoreCoinHistory(
            userId: context.read<UserDetailsCubit>().userId());
      } else {
        print("No more coin history");
      }
    }
  }

  Widget _buildCoinHistoryContainer({
    required CoinHistory coinHistory,
    required int index,
    required int totalCurrentCoinHistory,
    required bool hasMoreCoinHistoryFetchError,
    required bool hasMore,
  }) {
    if (index == totalCurrentCoinHistory - 1) {
      //check if hasMore
      if (hasMore) {
        if (hasMoreCoinHistoryFetchError) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              child: IconButton(
                onPressed: () {
                  context.read<CoinHistoryCubit>().getMoreCoinHistory(
                      userId: context.read<UserDetailsCubit>().userId());
                },
                icon: Icon(Icons.error, color: Theme.of(context).primaryColor),
              ),
            ),
          );
        } else {
          return const Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: CircularProgressContainer()),
          );
        }
      }
    }
    final formattedDate = DateFormat("d MMM, y").format(
      DateTime.parse(coinHistory.date),
    );
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => print(coinHistory.type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: colorScheme.background,
          borderRadius: BorderRadius.circular(10.0),
        ),
        height: size.height * (0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size.width * (0.63),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalization.of(context)!
                            .getTranslatedValues(coinHistory.type) ??
                        coinHistory.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onTertiary,
                      fontSize: 16.5,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                  const SizedBox(height: 3.5),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: colorScheme.onTertiary.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: size.width * 0.1,
              width: size.width * .180,
              decoration: BoxDecoration(
                color: coinHistory.status == "1"
                    ? hurryUpTimerColor
                    : addCoinColor,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                coinHistory.status == "0"
                    ? "+ ${UiUtils.formatNumber(int.parse(coinHistory.points))}"
                    : UiUtils.formatNumber(int.parse(coinHistory.points)),
                maxLines: 1,
                style: TextStyle(
                  color: colorScheme.background,
                  fontSize: 17.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinHistory() {
    return BlocConsumer<CoinHistoryCubit, CoinHistoryState>(
      listener: (context, state) {
        if (state is CoinHistoryFetchFailure) {
          if (state.errorMessage == unauthorizedAccessCode) {
            UiUtils.showAlreadyLoggedInDialog(context: context);
          }
        }
      },
      bloc: context.read<CoinHistoryCubit>(),
      builder: (context, state) {
        if (state is CoinHistoryFetchInProgress ||
            state is CoinHistoryInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is CoinHistoryFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessageColor: Theme.of(context).primaryColor,
              errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage)),
              onTapRetry: getCoinHistory,
              showErrorImage: true,
            ),
          );
        }
        return ListView.separated(
          controller: _coinHistoryScrollController,
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
            horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
          ),
          itemCount: (state as CoinHistoryFetchSuccess).coinHistory.length,
          separatorBuilder: (_, i) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            return _buildCoinHistoryContainer(
              coinHistory: state.coinHistory[index],
              hasMore: state.hasMore,
              hasMoreCoinHistoryFetchError: state.hasMoreFetchError,
              index: index,
              totalCurrentCoinHistory: state.coinHistory.length,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(
             AppLocalization.of(context)!.getTranslatedValues(coinHistoryKey)!),
      ),
      body: _buildCoinHistory(),
    );
  }
}
