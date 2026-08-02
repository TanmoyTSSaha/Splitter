import 'package:flutter/foundation.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:splitr/Services/app_logger.dart';
import 'package:splitr/config/app_secrets.dart';

typedef SubscriptionPaymentSuccess = void Function(
  PaymentSuccessResponse response,
);

/// Razorpay checkout for donations and Splitr Pro subscriptions.
class RazorpayPaymentService extends GetxService {
  Razorpay? _razorpay;
  void Function()? _onSuccess;
  void Function(String message)? _onError;
  SubscriptionPaymentSuccess? _onSubscriptionSuccess;

  static bool get isConfigured =>
      AppSecrets.razorpayKeyId.isNotEmpty &&
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void onInit() {
    super.onInit();
    if (!isConfigured) return;
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay?.clear();
    super.onClose();
  }

  Future<void> openCheckout({
    required double amountInr,
    required String description,
    required String payerContact,
    required String payerEmail,
    required void Function() onSuccess,
    required void Function(String message) onError,
  }) async {
    if (!isConfigured) {
      onError(AppStrings.services.payment.razorpayKeyMissing);
      return;
    }

    _onSuccess = onSuccess;
    _onError = onError;
    _onSubscriptionSuccess = null;

    final options = {
      RazorpayOptionKeys.key: AppSecrets.razorpayKeyId,
      RazorpayOptionKeys.amount: (amountInr * 100).round(),
      RazorpayOptionKeys.name: AppBranding.brandName,
      RazorpayOptionKeys.description: description,
      RazorpayOptionKeys.prefill: {
        RazorpayOptionKeys.contact: payerContact,
        RazorpayOptionKeys.email: payerEmail,
      },
      RazorpayOptionKeys.theme: {
        RazorpayOptionKeys.color: AppStrings.services.payment.themeColor,
      },
    };

    try {
      _razorpay!.open(options);
    } catch (e, stack) {
      AppLogger.error(
        'Razorpay checkout open failed',
        error: e,
        stack: stack,
      );
      onError(AppStrings.services.payment.checkoutOpenFailed);
    }
  }

  Future<void> openSubscriptionCheckout({
    required String subscriptionId,
    required String payerContact,
    required String payerEmail,
    required SubscriptionPaymentSuccess onSuccess,
    required void Function(String message) onError,
    String? keyId,
  }) async {
    if (!isConfigured) {
      onError(AppStrings.services.payment.razorpayKeyMissing);
      return;
    }

    _onSuccess = null;
    _onError = onError;
    _onSubscriptionSuccess = onSuccess;

    final options = {
      RazorpayOptionKeys.key: keyId ?? AppSecrets.razorpayKeyId,
      RazorpayOptionKeys.subscriptionId: subscriptionId,
      RazorpayOptionKeys.name: AppBranding.brandPro,
      RazorpayOptionKeys.description: AppStrings.premium.headline,
      RazorpayOptionKeys.prefill: {
        RazorpayOptionKeys.contact: payerContact,
        RazorpayOptionKeys.email: payerEmail,
      },
      RazorpayOptionKeys.theme: {
        RazorpayOptionKeys.color: AppStrings.services.payment.themeColor,
      },
    };

    try {
      _razorpay!.open(options);
    } catch (e, stack) {
      AppLogger.error(
        'Razorpay subscription checkout open failed',
        error: e,
        stack: stack,
      );
      onError(AppStrings.services.payment.checkoutOpenFailed);
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    if (_onSubscriptionSuccess != null) {
      _onSubscriptionSuccess!(response);
    } else {
      _onSuccess?.call();
    }
    _clearHandlers();
  }

  void _handleError(PaymentFailureResponse response) {
    AppLogger.warning(
      'Razorpay payment failed',
      data: {'code': response.code, 'message': response.message},
    );
    _onError?.call(AppStrings.errors.paymentHumorous);
    _clearHandlers();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    AppLogger.info(
      'Razorpay external wallet selected',
      data: {'wallet': response.walletName},
    );
    _onError?.call(AppStrings.errors.paymentHumorous);
    _clearHandlers();
  }

  void _clearHandlers() {
    _onSuccess = null;
    _onError = null;
    _onSubscriptionSuccess = null;
  }
}
