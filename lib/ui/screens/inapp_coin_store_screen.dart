import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/inAppPurchase/inAppPurchaseCubit.dart';
import 'package:flutterquiz/features/inAppPurchase/in_app_product.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../utils/constants/fonts.dart';
import '../widgets/customRoundedButton.dart';
import 'home/widgets/guest_mode_dialog.dart';

class CoinStoreScreen extends StatefulWidget {
  final bool isGuest;
  final List<InAppProduct> iapProducts;

  const CoinStoreScreen({
    super.key,
    required this.isGuest,
    required this.iapProducts,
  });

  @override
  State<CoinStoreScreen> createState() => _CoinStoreScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<InAppPurchaseCubit>(create: (_) => InAppPurchaseCubit()),
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: CoinStoreScreen(
          isGuest: args['isGuest'],
          iapProducts: args['iapProducts'],
        ),
      ),
    );
  }
}

class _CoinStoreScreenState extends State<CoinStoreScreen>
    with SingleTickerProviderStateMixin {
  List<String> productIds = [];

  @override
  void initState() {
    super.initState();
    productIds = widget.iapProducts.map((e) => e.productId).toSet().toList();
  }

  void initPurchase() {
    context.read<InAppPurchaseCubit>().initializePurchase(
          productIds,
          context.read<UserDetailsCubit>().removeAds(),
        );
  }

  Widget _buildProducts(List<ProductDetails> products) {
    return Stack(
      children: [
        GridView.builder(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
            horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
          ),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemBuilder: (context, idx) {
            final product = products[idx];
            final iap = widget.iapProducts
                .where((e) => e.productId == products[idx].id)
                .first;

            return GestureDetector(
              onTap: () {
                if (widget.isGuest) {
                  showDialog(
                    context: context,
                    builder: (_) => GuestModeDialog(onTapYesButton: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed(Routes.login);
                    }),
                  );
                } else {
                  /// Coins 0 means IAP is Non-Consumable.
                  if (iap.coins == 0) {
                    context
                        .read<InAppPurchaseCubit>()
                        .buyNonConsumableProducts(product);
                  } else {
                    context
                        .read<InAppPurchaseCubit>()
                        .buyConsumableProducts(product);
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 15),
                      child: SvgPicture.network(
                        iap.image,
                        width: 40,
                        height: 26,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        iap.desc,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.4),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      iap.title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 4,
                      ),
                      child: Text(
                        product.price,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
        if (Platform.isIOS && !widget.isGuest)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
              child: CustomRoundedButton(
                widthPercentage: 1.0,
                backgroundColor: Theme.of(context).primaryColor,
                buttonTitle: AppLocalization.of(context)!
                    .getTranslatedValues("restorePurchaseProducts")!,
                radius: 8.0,
                showBorder: false,
                fontWeight: FontWeights.semiBold,
                height: 58.0,
                titleColor: Theme.of(context).colorScheme.background,
                onTap: () {
                  return context.read<InAppPurchaseCubit>().restorePurchases();
                },
                elevation: 6.5,
                textSize: 18.0,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    initPurchase();
    return WillPopScope(
      onWillPop: () {
        if (context.read<InAppPurchaseCubit>().state
            is InAppPurchaseProcessInProgress) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        appBar: QAppBar(
          title: Text(
            AppLocalization.of(context)!.getTranslatedValues(coinStoreKey)!,
          ),
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: BlocConsumer<InAppPurchaseCubit, InAppPurchaseState>(
                bloc: context.read<InAppPurchaseCubit>(),
                listener: (context, state) {
                  log("State change to ${state.toString()}");

                  if (state is InAppPurchaseProcessSuccess) {
                    final iap = widget.iapProducts
                        .where((e) => e.productId == state.purchasedProductId)
                        .first;

                    /// Remove Ads if IAP is remove_ads
                    if (state.purchasedProductId == removeAdsProductId) {
                      // update remotely
                      context
                          .read<UpdateUserDetailCubit>()
                          .removeAdsForUser(true);

                      // update locally
                      context.read<UserDetailsCubit>().updateUserProfile(
                            adsRemovedForUser: "1",
                          );
                    } else {
                      context.read<UserDetailsCubit>().updateCoins(
                            addCoin: true,
                            coins: iap.coins,
                          );
                      context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                            context.read<UserDetailsCubit>().userId(),
                            iap.coins,
                            true,
                            boughtCoinsKey,
                          );
                    }

                    UiUtils.setSnackbar(
                      "${iap.title} ${AppLocalization.of(context)!.getTranslatedValues("boughtSuccess")!}",
                      context,
                      false,
                    );
                  } else if (state is InAppPurchaseProcessFailure) {
                    UiUtils.setSnackbar(
                        AppLocalization.of(context)!
                            .getTranslatedValues(state.errorMessage)!,
                        context,
                        false);
                  }
                },
                builder: (context, state) {
                  //initial state of cubit
                  if (state is InAppPurchaseInitial ||
                      state is InAppPurchaseLoading) {
                    return const Center(child: CircularProgressContainer());
                  }

                  //if occurred problem while fetching product details
                  //from appstore or playstore
                  if (state is InAppPurchaseFailure) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: false,
                        errorMessage: AppLocalization.of(context)!
                            .getTranslatedValues(state.errorMessage)!,
                        onTapRetry: initPurchase,
                        showErrorImage: true,
                      ),
                    );
                  }

                  if (state is InAppPurchaseNotAvailable) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: false,
                        errorMessage: AppLocalization.of(context)!
                            .getTranslatedValues(inAppPurchaseUnavailableKey)!,
                        onTapRetry: initPurchase,
                        showErrorImage: true,
                      ),
                    );
                  }

                  //if any error occurred in while making in-app purchase
                  if (state is InAppPurchaseProcessFailure) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseAvailable) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseProcessSuccess) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseProcessInProgress) {
                    return _buildProducts(state.products);
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
