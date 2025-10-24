// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationMessage _$ConversationMessageFromJson(Map<String, dynamic> json) =>
    ConversationMessage(
      id: (json['id'] as num).toInt(),
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      isFromUser: json['isFromUser'] as bool,
    );

Map<String, dynamic> _$ConversationMessageToJson(
  ConversationMessage instance,
) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'sentAt': instance.sentAt.toIso8601String(),
  'isFromUser': instance.isFromUser,
};

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  userName: json['userName'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  messages: (json['messages'] as List<dynamic>)
      .map((e) => ConversationMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'createdAt': instance.createdAt.toIso8601String(),
      'messages': instance.messages,
    };
