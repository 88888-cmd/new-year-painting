import 'package:app/utils/constants.dart';

class UserAIMessageModel {
  int id = 0;
  MessageRole role = MessageRole.human;
  String image_url = '';
  String text = '';
  String session_id = '';
  int user_id = 0;
  String create_time = '';

  UserAIMessageModel.fromJson(dynamic json) {
    id = int.parse(json['id'].toString());
    role = _parseRole(json['role'].toString());
    image_url =
        json['image_url']?.toString().isNotEmpty == true
            ? '${Constants.mediaBaseUrl}${json['image_url'].toString()}'
            : '';
    text = json['text'].toString();
    session_id = json['session_id'].toString();
    user_id = int.parse(json['user_id'].toString());
    create_time = json['create_time'].toString();
  }

  MessageRole _parseRole(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'human':
        return MessageRole.human;
      case 'ai':
        return MessageRole.ai;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.human;
    }
  }
}

enum MessageRole { human, ai, system }
