import 'dart:convert';
import 'package:decor_lens/Services/get_server_key.dart';
import 'package:http/http.dart' as http;

class SendNotificationService {
  static Future<void> sendNotificationUsingApi({
    String? token,
    String? topic,
    required String? title,
    required String? body,
    required Map<String, dynamic>? data,
  }) async {
    try {
      String serverKey = await GetServerKey().getServerKeyToken();
      String url =
          'https://fcm.googleapis.com/v1/projects/decor-lens/messages:send';

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      };

      Map<String, dynamic> message = {
        "message": {
          if (token != null) "token": token,
          if (token == null && topic != null) "topic": topic,
          "notification": {
            "title": title,
            "body": body,
          },
          "android": {
            "notification": {"channel_id": "default_channel"}
          },
          "data": data ?? {},
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully!');
      } else {
        print('❌ Failed to send notification: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception during notification sending: $e');
    }
  }
}
