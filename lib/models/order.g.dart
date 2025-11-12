// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Commande _$CommandeFromJson(Map<String, dynamic> json) => Commande(
      id: (json['id'] as num).toInt(),
      numeroCommande: json['numeroCommande'] as String,
      dateCommande: DateTime.parse(json['dateCommande'] as String),
      dateLivraison: json['dateLivraison'] == null
          ? null
          : DateTime.parse(json['dateLivraison'] as String),
      montantTotal: (json['montantTotal'] as num).toDouble(),
      statut: json['statut'] as String,
      consommateur:
          Consommateur.fromJson(json['consommateur'] as Map<String, dynamic>),
      detailsCommande: (json['detailsCommande'] as List<dynamic>)
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
      'id': instance.id,
      'numeroCommande': instance.numeroCommande,
      'dateCommande': instance.dateCommande.toIso8601String(),
      'dateLivraison': instance.dateLivraison?.toIso8601String(),
      'montantTotal': instance.montantTotal,
      'statut': instance.statut,
      'consommateur': instance.consommateur,
      'detailsCommande': instance.detailsCommande,
      'paiement': instance.paiement,
      'livraison': instance.livraison,
      'remboursement': instance.remboursement,
    };

DetailCommande _$DetailCommandeFromJson(Map<String, dynamic> json) =>
    DetailCommande(
      id: (json['id'] as num).toInt(),
      quantite: (json['quantite'] as num).toInt(),
      prixUnitaire: (json['prixUnitaire'] as num).toDouble(),
      prixTotal: (json['prixTotal'] as num).toDouble(),
      produit: Produit.fromJson(json['produit'] as Map<String, dynamic>),
      commande: Commande.fromJson(json['commande'] as Map<String, dynamic>),
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

Paiement _$PaiementFromJson(Map<String, dynamic> json) => Paiement(
      id: (json['id'] as num).toInt(),
      methodePaiement: json['methodePaiement'] as String,
      statut: json['statut'] as String,
      montant: (json['montant'] as num).toDouble(),
      numeroTransaction: json['numeroTransaction'] as String?,
      datePaiement: DateTime.parse(json['datePaiement'] as String),
      commande: Commande.fromJson(json['commande'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaiementToJson(Paiement instance) => <String, dynamic>{
      'id': instance.id,
      'methodePaiement': instance.methodePaiement,
      'statut': instance.statut,
      'montant': instance.montant,
      'numeroTransaction': instance.numeroTransaction,
      'datePaiement': instance.datePaiement.toIso8601String(),
      'commande': instance.commande,
    };

Livraison _$LivraisonFromJson(Map<String, dynamic> json) => Livraison(
      id: (json['id'] as num).toInt(),
      adresseLivraison: json['adresseLivraison'] as String,
      numeroSuivi: json['numeroSuivi'] as String?,
      statut: json['statut'] as String,
      dateLivraison: json['dateLivraison'] == null
          ? null
          : DateTime.parse(json['dateLivraison'] as String),
      commentaire: json['commentaire'] as String?,
      commande: Commande.fromJson(json['commande'] as Map<String, dynamic>),
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
      id: (json['id'] as num).toInt(),
      montant: (json['montant'] as num).toDouble(),
      motif: json['motif'] as String,
      statut: json['statut'] as String,
      dateDemande: DateTime.parse(json['dateDemande'] as String),
      dateTraitement: json['dateTraitement'] == null
          ? null
          : DateTime.parse(json['dateTraitement'] as String),
      commentaire: json['commentaire'] as String?,
      commande: Commande.fromJson(json['commande'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RemboursementToJson(Remboursement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'montant': instance.montant,
      'motif': instance.motif,
      'statut': instance.statut,
      'dateDemande': instance.dateDemande.toIso8601String(),
      'dateTraitement': instance.dateTraitement?.toIso8601String(),
      'commentaire': instance.commentaire,
      'commande': instance.commande,
    };
