import 'package:flutter/material.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:http/http.dart' as http; // Required for API calls
import 'dart:convert'; // For JSON decoding

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  // eSewa Test Credentials
  static const String CLIENT_ID = 'JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R';
  static const String SECRET_KEY = 'BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==';

  // Merchant credentials for verification (replace with your credentials)
  static const String MERCHANT_ID = 'YOUR_MERCHANT_ID';
  static const String MERCHANT_SECRET = 'YOUR_MERCHANT_SECRET';

  // Payment Initialization Method
  void initiateEsewaPayment(BuildContext context) {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test, // Change to Environment.live for production
          clientId: CLIENT_ID,
          secretId: SECRET_KEY,
        ),
        esewaPayment: EsewaPayment(
          productId: "PROD123", // Unique Product ID
          productName: "Sample Product", // Product Name
          productPrice: "100", callbackUrl: '', // Amount in NPR
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment Success: ${data.message}")),
          );

          // Call verification function
          verifyTransactionStatus(data.refId, context); // Verify using the transaction refId
        },
        onPaymentFailure: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment Failed: $data")),
          );
        },
        onPaymentCancellation: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment Cancelled: $data")),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error initializing payment: $e")),
      );
    }
  }

  // Transaction Verification Method
  Future<void> verifyTransactionStatus(String refId, BuildContext context) async {
    const String verificationUrl = 'https://rc.esewa.com.np/mobile/transaction?txnRefId='; // For production, remove 'rc'.

    try {
      final response = await http.get(
        Uri.parse('$verificationUrl$refId'),
        headers: {
          'Content-Type': 'application/json',
          'merchantId': MERCHANT_ID,
          'merchantSecret': MERCHANT_SECRET,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transactionDetails = data[0]['transactionDetails'];

        if (transactionDetails['status'] == 'COMPLETE') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Transaction Verified: ${transactionDetails['referenceId']}")),
          );
          // TODO: Handle successful verification (e.g., update UI or backend)
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Transaction Not Complete: ${transactionDetails['status']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during verification: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('eSewa Payment Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => initiateEsewaPayment(context),
          child: Text('Pay with eSewa'),
        ),
      ),
    );
  }
}
