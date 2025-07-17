import 'dart:convert';
import 'package:currency_converter/currency.dart';
import 'package:currency_converter/currency_converter.dart';
import 'package:decor_lens/app_constants.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': await CurrencyConverterHelper.calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var secretKey = AppConstants.stripeSecretKey;
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer $secretKey',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      return jsonDecode(response.body.toString());
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }
}

class CurrencyConverterHelper {
  static Future<double> fetchExchangeRate() async {
    try {
      Currency myCurrency = await CurrencyConverter.getMyCurrency();
      double? usdConvert = await CurrencyConverter.convert(
        from: Currency.pkr,
        to: myCurrency, // Fetch PKR to USD conversion
        amount: 1,
        withoutRounding: true,
      );

      return usdConvert ?? 0.0036; // Ensure it never returns null
    } catch (e) {
      print('Error fetching exchange rate: $e');
      return 0.0036; // Fallback rate
    }
  }

  static Future<String> calculateAmount(String amount) async {
    double exchangeRate = await fetchExchangeRate();
    final priceInDollars = double.parse(amount) * exchangeRate;
    final priceInCents = (priceInDollars * 100).round(); // Convert to cents
    return (priceInCents < 50 ? 50 : priceInCents)
        .toString(); // Ensure min 50 cents
  }
}
