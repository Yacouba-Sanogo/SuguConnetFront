// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paiement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Paiement _$PaiementFromJson(Map<String, dynamic> json) => Paiement(
  id: (json['id'] as num).toInt(),
  commandeId: (json['commandeId'] as num).toInt(),
  methodePaiement: json['methodePaiement'] as String,
  montant: (json['montant'] as num).toDouble(),
  statut: json['statut'] as String,
  referenceTransaction: json['referenceTransaction'] as String?,
  numeroTelephone: json['numeroTelephone'] as String?,
  dateCreation: DateTime.parse(json['dateCreation'] as String),
  dateMiseAJour: json['dateMiseAJour'] == null
      ? null
      : DateTime.parse(json['dateMiseAJour'] as String),
);

Map<String, dynamic> _$PaiementToJson(Paiement instance) => <String, dynamic>{
  'id': instance.id,
  'commandeId': instance.commandeId,
  'methodePaiement': instance.methodePaiement,
  'montant': instance.montant,
  'statut': instance.statut,
  'referenceTransaction': instance.referenceTransaction,
  'numeroTelephone': instance.numeroTelephone,
  'dateCreation': instance.dateCreation.toIso8601String(),
  'dateMiseAJour': instance.dateMiseAJour?.toIso8601String(),
};
