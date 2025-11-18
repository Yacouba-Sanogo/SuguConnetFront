import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final String? filePath;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.filePath,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
