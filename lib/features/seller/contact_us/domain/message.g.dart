// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: (json['id'] as num).toInt(),
  content: json['content'] as String,
  createdAt: DateTime.parse(json['sentAt'] as String),
  isSentByStoreOwner: json['isFromUser'] as bool,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'sentAt': instance.createdAt.toIso8601String(),
  'isFromUser': instance.isSentByStoreOwner,
};
