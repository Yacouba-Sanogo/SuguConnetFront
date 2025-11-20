import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'product.dart';

part 'order.g.dart';

@JsonSerializable()
class ProduitCommande {
  final int id;
  final String nom;

  @JsonKey(name: 'prixUnitaire', defaultValue: 0.0)
  final double prix;

  ProduitCommande({
    required this.id,
    required this.nom,
    required this.prix,
  });

  factory ProduitCommande.fromJson(Map<String, dynamic> json) =>
      _$ProduitCommandeFromJson(json);
  Map<String, dynamic> toJson() => _$ProduitCommandeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.none)
class DetailCommande {
  final int id;

  @JsonKey(defaultValue: 0)
  final int quantite;

  @JsonKey(defaultValue: 0.0)
  final double prixUnitaire;

  @JsonKey(defaultValue: 0.0)
  final double prixTotal;

  final ProduitCommande produit;
  final Commande? commande;

  DetailCommande({
    required this.id,
    required this.quantite,
    required this.prixUnitaire,
    required this.prixTotal,
    required this.produit,
    this.commande,
  });

  factory DetailCommande.fromJson(Map<String, dynamic> json) =>
      _$DetailCommandeFromJson(json);
  Map<String, dynamic> toJson() => _$DetailCommandeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.none)
class Commande {
  @JsonKey(name: 'idCommande', defaultValue: 0)
  final int id;

  @JsonKey(defaultValue: '')
  final String numeroCommande;

  @JsonKey(name: 'dateCommande')
  final DateTime dateCommande;

  final DateTime? dateLivraison;

  @JsonKey(defaultValue: 0.0)
  final double montantTotal;

  @JsonKey(name: 'statutCommande', defaultValue: '')
  final String statut;

  @JsonKey(defaultValue: '')
  final String motifRejet;

  @JsonKey(defaultValue: false)
  final bool receptionValidee;

  final DateTime? dateReceptionValidee;

  @JsonKey(defaultValue: '')
  final String modePaiement;

  final Consommateur consommateur;

  @JsonKey(name: 'commandeProduits')
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
    required this.motifRejet,
    required this.receptionValidee,
    this.dateReceptionValidee,
    required this.modePaiement,
    required this.consommateur,
    required this.detailsCommande,
    this.paiement,
    this.livraison,
    this.remboursement,
  });

  factory Commande.fromJson(Map<String, dynamic> json) =>
      _$CommandeFromJson(json);
  Map<String, dynamic> toJson() => _$CommandeToJson(this);

  String get montantFormate => '${montantTotal.toStringAsFixed(2)} €';
  bool get estLivree => statut == 'LIVREE';
  bool get estAnnulee => statut == 'ANNULEE';
}

@JsonSerializable()
class Paiement {
  @JsonKey(name: 'idPaiement', defaultValue: 0)
  final int id;

  @JsonKey(name: 'methodePaiement', defaultValue: '')
  final String methodePaiement;

  @JsonKey(name: 'statutPaiement', defaultValue: '')
  final String statut;

  @JsonKey(defaultValue: 0.0)
  final double montant;

  final String? numeroTransaction;

  @JsonKey(name: 'datePaiement')
  final DateTime datePaiement;

  final Commande? commande;

  Paiement({
    required this.id,
    required this.methodePaiement,
    required this.statut,
    required this.montant,
    this.numeroTransaction,
    required this.datePaiement,
    this.commande,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) =>
      _$PaiementFromJson(json);
  Map<String, dynamic> toJson() => _$PaiementToJson(this);

  String get montantFormate => '${montant.toStringAsFixed(2)} €';
  bool get estPaye => statut == 'PAYE';
}

@JsonSerializable(fieldRename: FieldRename.none)
class Livraison {
  final int id;

  @JsonKey(name: 'adresseLivraison', defaultValue: '')
  final String adresseLivraison;

  final String? numeroSuivi;

  @JsonKey(defaultValue: '')
  final String statut;

  final DateTime? dateLivraison;

  final String? commentaire;

  final Commande? commande;

  Livraison({
    required this.id,
    required this.adresseLivraison,
    this.numeroSuivi,
    required this.statut,
    this.dateLivraison,
    this.commentaire,
    this.commande,
  });

  factory Livraison.fromJson(Map<String, dynamic> json) =>
      _$LivraisonFromJson(json);
  Map<String, dynamic> toJson() => _$LivraisonToJson(this);

  bool get estLivree => statut == 'LIVREE';
  bool get estEnCours => statut == 'EN_COURS';
}

@JsonSerializable(fieldRename: FieldRename.none)
class Remboursement {
  final int id;

  @JsonKey(defaultValue: 0.0)
  final double montant;

  @JsonKey(defaultValue: '')
  final String motif;

  @JsonKey(defaultValue: '')
  final String statut;

  @JsonKey(name: 'dateDemande')
  final DateTime dateDemande;

  final DateTime? dateTraitement;

  final String? commentaire;

  final Commande? commande;

  Remboursement({
    required this.id,
    required this.montant,
    required this.motif,
    required this.statut,
    required this.dateDemande,
    this.dateTraitement,
    this.commentaire,
    this.commande,
  });

  factory Remboursement.fromJson(Map<String, dynamic> json) =>
      _$RemboursementFromJson(json);
  Map<String, dynamic> toJson() => _$RemboursementToJson(this);

  String get montantFormate => '${montant.toStringAsFixed(2)} €';
  bool get estApprouve => statut == 'APPROUVE';
  bool get estRefuse => statut == 'REFUSE';
}
