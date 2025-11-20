// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProduitCommande _$ProduitCommandeFromJson(Map<String, dynamic> json) =>
    ProduitCommande(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String,
      prix: (json['prixUnitaire'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$ProduitCommandeToJson(ProduitCommande instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prixUnitaire': instance.prix,
    };

DetailCommande _$DetailCommandeFromJson(Map<String, dynamic> json) =>
    DetailCommande(
      id: (json['id'] as num).toInt(),
      quantite: (json['quantite'] as num?)?.toInt() ?? 0,
      prixUnitaire: (json['prixUnitaire'] as num?)?.toDouble() ?? 0.0,
      prixTotal: (json['prixTotal'] as num?)?.toDouble() ?? 0.0,
      produit:
          ProduitCommande.fromJson(json['produit'] as Map<String, dynamic>),
      commande: json['commande'] == null
          ? null
          : Commande.fromJson(json['commande'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DetailCommandeToJson(DetailCommande instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quantite': instance.quantite,
      'prixUnitaire': instance.prixUnitaire,
      'prixTotal': instance.prixTotal,
      'produit': instance.produit,
      'commande': instance.commande,
    };

Commande _$CommandeFromJson(Map<String, dynamic> json) => Commande(
      id: (json['idCommande'] as num?)?.toInt() ?? 0,
      numeroCommande: json['numeroCommande'] as String? ?? '',
      dateCommande: DateTime.parse(json['dateCommande'] as String),
      dateLivraison: json['dateLivraison'] == null
          ? null
          : DateTime.parse(json['dateLivraison'] as String),
      montantTotal: (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      statut: json['statutCommande'] as String? ?? '',
      motifRejet: json['motifRejet'] as String? ?? '',
      receptionValidee: json['receptionValidee'] as bool? ?? false,
      dateReceptionValidee: json['dateReceptionValidee'] == null
          ? null
          : DateTime.parse(json['dateReceptionValidee'] as String),
      modePaiement: json['modePaiement'] as String? ?? '',
      consommateur:
          Consommateur.fromJson(json['consommateur'] as Map<String, dynamic>),
      detailsCommande: (json['commandeProduits'] as List<dynamic>)
          .map((e) => DetailCommande.fromJson(e as Map<String, dynamic>))
          .toList(),
      paiement: json['paiement'] == null
          ? null
          : Paiement.fromJson(json['paiement'] as Map<String, dynamic>),
      livraison: json['livraison'] == null
          ? null
          : Livraison.fromJson(json['livraison'] as Map<String, dynamic>),
      remboursement: json['remboursement'] == null
          ? null
          : Remboursement.fromJson(
              json['remboursement'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommandeToJson(Commande instance) => <String, dynamic>{
      'idCommande': instance.id,
      'numeroCommande': instance.numeroCommande,
      'dateCommande': instance.dateCommande.toIso8601String(),
      'dateLivraison': instance.dateLivraison?.toIso8601String(),
      'montantTotal': instance.montantTotal,
      'statutCommande': instance.statut,
      'motifRejet': instance.motifRejet,
      'receptionValidee': instance.receptionValidee,
      'dateReceptionValidee': instance.dateReceptionValidee?.toIso8601String(),
      'modePaiement': instance.modePaiement,
      'consommateur': instance.consommateur,
      'commandeProduits': instance.detailsCommande,
      'paiement': instance.paiement,
      'livraison': instance.livraison,
      'remboursement': instance.remboursement,
    };

Paiement _$PaiementFromJson(Map<String, dynamic> json) => Paiement(
      id: (json['idPaiement'] as num?)?.toInt() ?? 0,
      methodePaiement: json['methodePaiement'] as String? ?? '',
      statut: json['statutPaiement'] as String? ?? '',
      montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
      numeroTransaction: json['numeroTransaction'] as String?,
      datePaiement: DateTime.parse(json['datePaiement'] as String),
      commande: json['commande'] == null
          ? null
          : Commande.fromJson(json['commande'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaiementToJson(Paiement instance) => <String, dynamic>{
      'idPaiement': instance.id,
      'methodePaiement': instance.methodePaiement,
      'statutPaiement': instance.statut,
      'montant': instance.montant,
      'numeroTransaction': instance.numeroTransaction,
      'datePaiement': instance.datePaiement.toIso8601String(),
      'commande': instance.commande,
    };

Livraison _$LivraisonFromJson(Map<String, dynamic> json) => Livraison(
      id: (json['id'] as num?)?.toInt() ?? 0,
      adresseLivraison: json['adresseLivraison'] as String? ?? '',
      numeroSuivi: json['numeroSuivi'] as String?,
      statut: json['statut'] as String? ?? '',
      dateLivraison: json['dateLivraison'] == null
          ? null
          : DateTime.parse(json['dateLivraison'] as String),
      commentaire: json['commentaire'] as String?,
      commande: json['commande'] == null
          ? null
          : Commande.fromJson(json['commande'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LivraisonToJson(Livraison instance) => <String, dynamic>{
      'id': instance.id,
      'adresseLivraison': instance.adresseLivraison,
      'numeroSuivi': instance.numeroSuivi,
      'statut': instance.statut,
      'dateLivraison': instance.dateLivraison?.toIso8601String(),
      'commentaire': instance.commentaire,
      'commande': instance.commande,
    };

Remboursement _$RemboursementFromJson(Map<String, dynamic> json) =>
    Remboursement(
      id: (json['id'] as num?)?.toInt() ?? 0,
      montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
      motif: json['motif'] as String? ?? '',
      statut: json['statut'] as String? ?? '',
      dateDemande: json['dateDemande'] == null
          ? null
          : DateTime.parse(json['dateDemande'] as String),
      dateTraitement: json['dateTraitement'] == null
          ? null
          : DateTime.parse(json['dateTraitement'] as String),
      commentaire: json['commentaire'] as String?,
      commande: json['commande'] == null
          ? null
          : Commande.fromJson(json['commande'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RemboursementToJson(Remboursement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'montant': instance.montant,
      'motif': instance.motif,
      'statut': instance.statut,
      'dateDemande': instance.dateDemande?.toIso8601String(),
      'dateTraitement': instance.dateTraitement?.toIso8601String(),
      'commentaire': instance.commentaire,
      'commande': instance.commande,
    };
