import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:flutter/material.dart';

import 'package:gighire/esewa/esewa_constant/esewa.dart';

class Esewa {
  pay() {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId: kEsewaClientId,
          secretId: kEsewaSecretKey,
        ),
        esewaPayment: EsewaPayment(
          productId: "1d71jd81",
          productName: "Product One",
          productPrice: "20",
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult result) {
          debugPrint('SUCCESS');
          verify(result);
        },
        onPaymentFailure: () {
          debugPrint('FAIL');
        },
        onPaymentCancellation: () {
          debugPrint('CANCEL');
        },
      );
    } catch (e) {
      debugPrint('EXCEPTION');
    }
  }

  verify(EsewaPaymentSuccessResult result) {
    //TODO: after success call the function to verify transaction
  }
}
