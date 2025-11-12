import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'product.dart';

part 'order.g.dart';

@JsonSerializable()
class Commande {
  final int id;
  final String numeroCommande;
  final DateTime dateCommande;
  final DateTime? dateLivraison;
  final double montantTotal;
  final String statut;
  final Consommateur consommateur;
  final List<DetailCommande> detailsCommande;
  final Paiement? paiement;
  final Livraison? livraison;
  final Remboursement? remboursement;

  Commande({
    required this.id,
    required this.numeroCommande,
    required this.dateCommande,
    this.dateLivraison,
    required this.montantTotal,
    required this.statut,
    required this.consommateur,
    required this.detailsCommande,
    this.paiement,
    this.livraison,
    this.remboursement,
  });

  factory Commande.fromJson(Map<String, dynamic> json) => _$CommandeFromJson(json);
  Map<String, dynamic> toJson() => _$CommandeToJson(this);

  String get montantFormate => '${montantTotal.toStringAsFixed(2)} €';
  bool get estLivree => statut == 'LIVREE';
  bool get estAnnulee => statut == 'ANNULEE';
}

@JsonSerializable()
class DetailCommande {
  final int id;
  final int quantite;
  final double prixUnitaire;
  final double prixTotal;
  final Produit produit;
  final Commande commande;

  DetailCommande({
    required this.id,
    required this.quantite,
    required this.prixUnitaire,
    required this.prixTotal,
    required this.produit,
    required this.commande,
  });

  factory DetailCommande.fromJson(Map<String, dynamic> json) => _$DetailCommandeFromJson(json);
  Map<String, dynamic> toJson() => _$DetailCommandeToJson(this);
}

@JsonSerializable()
class Paiement {
  final int id;
  final String methodePaiement;
  final String statut;
  final double montant;
  final String? numeroTransaction;
  final DateTime datePaiement;
  final Commande commande;

  Paiement({
    required this.id,
    required this.methodePaiement,
    required this.statut,
    required this.montant,
    this.numeroTransaction,
    required this.datePaiement,
    required this.commande,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) => _$PaiementFromJson(json);
  Map<String, dynamic> toJson() => _$PaiementToJson(this);

  String get montantFormate => '${montant.toStringAsFixed(2)} €';
  bool get estPaye => statut == 'PAYE';
}

@JsonSerializable()
class Livraison {
  final int id;
  final String adresseLivraison;
  final String? numeroSuivi;
  final String statut;
  final DateTime? dateLivraison;
  final String? commentaire;
  final Commande commande;

  Livraison({
    required this.id,
    required this.adresseLivraison,
    this.numeroSuivi,
    required this.statut,
    this.dateLivraison,
    this.commentaire,
    required this.commande,
  });

  factory Livraison.fromJson(Map<String, dynamic> json) => _$LivraisonFromJson(json);
  Map<String, dynamic> toJson() => _$LivraisonToJson(this);

  bool get estLivree => statut == 'LIVREE';
  bool get estEnCours => statut == 'EN_COURS';
}

@JsonSerializable()
class Remboursement {
  final int id;
  final double montant;
  final String motif;
  final String statut;
  final DateTime dateDemande;
  final DateTime? dateTraitement;
  final String? commentaire;
  final Commande commande;

  Remboursement({
    required this.id,
    required this.montant,
    required this.motif,
    required this.statut,
    required this.dateDemande,
    this.dateTraitement,
    this.commentaire,
    required this.commande,
  });

  factory Remboursement.fromJson(Map<String, dynamic> json) => _$RemboursementFromJson(json);
  Map<String, dynamic> toJson() => _$RemboursementToJson(this);

  String get montantFormate => '${montant.toStringAsFixed(2)} €';
  bool get estApprouve => statut == 'APPROUVE';
  bool get estRefuse => statut == 'REFUSE';
}
