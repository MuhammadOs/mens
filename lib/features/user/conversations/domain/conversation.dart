import 'package:json_annotation/json_annotation.dart';

part 'conversation.g.dart';

@JsonSerializable()
class ConversationMessage {
  final int id;
  final String content;
  final DateTime sentAt;
  final bool isFromUser;

  ConversationMessage({
    required this.id,
    required this.content,
    required this.sentAt,
    required this.isFromUser,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      _$ConversationMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationMessageToJson(this);
}

@JsonSerializable()
class Conversation {
  final int id;
  final int userId;
  final String userName;
  final DateTime createdAt;
  final List<ConversationMessage> messages;

  Conversation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}
