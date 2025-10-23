import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
  final int id;
  final String titre;
  final String message;
  final String type;
  final bool lue;
  final DateTime dateCreation;
  final User utilisateur;

  Notification({
    required this.id,
    required this.titre,
    required this.message,
    required this.type,
    required this.lue,
    required this.dateCreation,
    required this.utilisateur,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  String get typeFormate {
    switch (type) {
      case 'COMMANDE':
        return 'Commande';
      case 'LIVRAISON':
        return 'Livraison';
      case 'PAIEMENT':
        return 'Paiement';
      case 'EVALUATION':
        return 'Évaluation';
      case 'PRODUIT':
        return 'Produit';
      default:
        return 'Notification';
    }
  }
}

@JsonSerializable()
class NotificationCount {
  final int total;
  final int nonLues;

  NotificationCount({
    required this.total,
    required this.nonLues,
  });

  factory NotificationCount.fromJson(Map<String, dynamic> json) => _$NotificationCountFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationCountToJson(this);
}
