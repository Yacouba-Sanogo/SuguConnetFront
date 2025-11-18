import 'package:json_annotation/json_annotation.dart';

part 'paiement.g.dart';

@JsonSerializable()
class Paiement {
  final int id;
  final int commandeId;
  final String methodePaiement;
  final double montant;
  final String statut;
  final String? referenceTransaction;
  final String? numeroTelephone;
  final DateTime dateCreation;
  final DateTime? dateMiseAJour;

  Paiement({
    required this.id,
    required this.commandeId,
    required this.methodePaiement,
    required this.montant,
    required this.statut,
    this.referenceTransaction,
    this.numeroTelephone,
    required this.dateCreation,
    this.dateMiseAJour,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) =>
      _$PaiementFromJson(json);

  Map<String, dynamic> toJson() => _$PaiementToJson(this);
}
