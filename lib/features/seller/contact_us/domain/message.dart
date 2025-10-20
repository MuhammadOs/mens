import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final int id;
  final String content;

  // Map the JSON key 'sentAt' to our field 'createdAt'
  @JsonKey(name: 'sentAt')
  final DateTime createdAt;

  // Map the JSON key 'isFromUser' to our field 'isSentByStoreOwner'
  @JsonKey(name: 'isFromUser')
  final bool isSentByStoreOwner;

  Message({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.isSentByStoreOwner,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}