// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
      id: (json['id'] as num).toInt(),
      titre: json['titre'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      lue: json['lue'] as bool,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      utilisateur: User.fromJson(json['utilisateur'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titre': instance.titre,
      'message': instance.message,
      'type': instance.type,
      'lue': instance.lue,
      'dateCreation': instance.dateCreation.toIso8601String(),
      'utilisateur': instance.utilisateur,
    };

NotificationCount _$NotificationCountFromJson(Map<String, dynamic> json) =>
    NotificationCount(
      total: (json['total'] as num).toInt(),
      nonLues: (json['nonLues'] as num).toInt(),
    );

Map<String, dynamic> _$NotificationCountToJson(NotificationCount instance) =>
    <String, dynamic>{
      'total': instance.total,
      'nonLues': instance.nonLues,
    };
