// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: (json['id'] as num).toInt(),
  senderId: (json['senderId'] as num).toInt(),
  receiverId: (json['receiverId'] as num).toInt(),
  content: json['content'] as String,
  type: json['type'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  isRead: json['isRead'] as bool? ?? false,
  filePath: json['filePath'] as String?,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'senderId': instance.senderId,
  'receiverId': instance.receiverId,
  'content': instance.content,
  'type': instance.type,
  'timestamp': instance.timestamp.toIso8601String(),
  'isRead': instance.isRead,
  'filePath': instance.filePath,
};
