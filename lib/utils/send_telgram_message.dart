import 'package:http/http.dart' as http;

final botToken = '6793281063:AAENViH0WaGZXRQPDAO2R9Qt7xGXCprlUmY';
final chatId = '957151940';

Future<void> sendTelegramMessage(String message) async {
  final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
  final response = await http.post(
    url,
    body: {
      'chat_id': chatId,
      'text': message,
    },
  );

  if (response.statusCode != 200) {
    print(
        'Failed to send message to Telegram: ${response.statusCode} - ${response.body}');
  }
}
