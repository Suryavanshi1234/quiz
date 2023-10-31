import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

abstract class InAppPurchaseState {}

class InAppPurchaseInitial extends InAppPurchaseState {}

class InAppPurchaseLoading extends InAppPurchaseState {}

class InAppPurchaseNotAvailable extends InAppPurchaseState {}

class InAppPurchaseAvailable extends InAppPurchaseState {
  final List<ProductDetails> products;

  final List<String> notFoundIds;

  InAppPurchaseAvailable({required this.products, required this.notFoundIds});
}

class InAppPurchaseFailure extends InAppPurchaseState {
  final String errorMessage;
  final List<String> notFoundIds;

  InAppPurchaseFailure({required this.errorMessage, required this.notFoundIds});
}

class InAppPurchaseProcessInProgress extends InAppPurchaseState {
  final List<ProductDetails> products;

  InAppPurchaseProcessInProgress(this.products);
}

class InAppPurchaseProcessFailure extends InAppPurchaseState {
  final String errorMessage;
  final List<ProductDetails> products;

  InAppPurchaseProcessFailure(
      {required this.errorMessage, required this.products});
}

class InAppPurchaseProcessSuccess extends InAppPurchaseState {
  final List<ProductDetails> products;
  final String purchasedProductId;

  InAppPurchaseProcessSuccess(
      {required this.products, required this.purchasedProductId});
}

class InAppPurchaseCubit extends Cubit<InAppPurchaseState> {
  //product ids of consumable products
  List<String>? productIds;
  final InAppPurchase inAppPurchase = InAppPurchase.instance;

  late StreamSubscription<List<PurchaseDetails>> _subscription;

  InAppPurchaseCubit() : super(InAppPurchaseInitial());

  //load product and set up listener for purchase stream
  Future<void> initializePurchase(
    List<String> productIds,
    bool userAlreadyRemovedAds,
  ) async {
    emit(InAppPurchaseLoading());
    _subscription = inAppPurchase.purchaseStream.listen(
      _purchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (e) {
        emit(InAppPurchaseProcessFailure(
          errorMessage: purchaseErrorKey,
          products: _getProducts(),
        ));
      },
    );

    //to confirm in-app purchase is available or not
    final isAvailable = await inAppPurchase.isAvailable();
    if (!isAvailable) {
      emit(InAppPurchaseNotAvailable());
    } else {
      //if in-app purchase is available then load products with given id
      _loadProducts(productIds, userAlreadyRemovedAds);
    }
  }

  //it will load products form store
  void _loadProducts(
      List<String> productIds, bool userAlreadyRemovedAds) async {
    //load products for purchase (consumable product)
    ProductDetailsResponse productDetailResponse =
        await inAppPurchase.queryProductDetails(productIds.toSet());
    if (productDetailResponse.error != null) {
      //error while getting products from store
      print(productDetailResponse.error!);
      emit(InAppPurchaseFailure(
          errorMessage: productsFetchedFailureKey,
          notFoundIds: productDetailResponse.notFoundIDs));
    }
    //if there is not any product to purchase (consumable)
    else if (productDetailResponse.productDetails.isEmpty) {
      emit(InAppPurchaseFailure(
        errorMessage: noProductsKey,
        notFoundIds: productDetailResponse.notFoundIDs,
      ));
    } else {
      for (int i = 0; i < productDetailResponse.productDetails.length; i++) {
        //removing remove_ads products if the user already has purchased it once
        if (productDetailResponse.productDetails[i].id == removeAdsProductId &&
            userAlreadyRemovedAds) {
          productDetailResponse.productDetails.removeAt(i);
        }
      }

      productDetailResponse.productDetails
          .sort((first, second) => first.rawPrice.compareTo(second.rawPrice));
      emit(InAppPurchaseAvailable(
        products: productDetailResponse.productDetails,
        notFoundIds: productDetailResponse.notFoundIDs,
      ));
    }
  }

  Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> buyNonConsumableProducts(ProductDetails productDetails) async {
    emit(InAppPurchaseProcessInProgress(_getProducts()));
    final purchaseParam = PurchaseParam(productDetails: productDetails);
    //start purchase
    InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  //to buy product
  Future<void> buyConsumableProducts(ProductDetails productDetails) async {
    emit(InAppPurchaseProcessInProgress(_getProducts()));
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    //start purchase
    InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
  }

  //will listen purchase stream
  void _purchaseUpdate(List<PurchaseDetails> purchaseDetails) {
    for (var purchaseDetail in purchaseDetails) {
      //product purchased successfully
      if (purchaseDetail.status == PurchaseStatus.purchased) {
        print("Purchased : ${purchaseDetail.purchaseID}");
        //inAppPurchase
        emit(InAppPurchaseProcessSuccess(
          products: _getProducts(),
          purchasedProductId: purchaseDetail.productID,
        ));
      } else if (purchaseDetail.status == PurchaseStatus.pending) {
        print("Purchase is pending");
      } else if (purchaseDetail.status == PurchaseStatus.error) {
        print("Error occurred");
        print(purchaseDetail.error?.message);
        //if any error occured while making purchase
        emit(InAppPurchaseProcessFailure(
          errorMessage: purchaseErrorKey,
          products: _getProducts(),
        ));
      }

      //
      if (purchaseDetail.pendingCompletePurchase) {
        print("Mark the product delivered to the user");
        inAppPurchase.completePurchase(purchaseDetail);
      }
    }
  }

  List<ProductDetails> _getProducts() {
    if (state is InAppPurchaseAvailable) {
      return (state as InAppPurchaseAvailable).products;
    }
    if (state is InAppPurchaseProcessSuccess) {
      return (state as InAppPurchaseProcessSuccess).products;
    }
    if (state is InAppPurchaseProcessFailure) {
      return (state as InAppPurchaseProcessFailure).products;
    }
    if (state is InAppPurchaseProcessInProgress) {
      return (state as InAppPurchaseProcessInProgress).products;
    }
    return [];
  }

  @override
  Future<void> close() async {
    _subscription.cancel();
    return super.close();
  }
}
