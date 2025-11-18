// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produit_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProduitDetail _$ProduitDetailFromJson(Map<String, dynamic> json) =>
    ProduitDetail(
      id: (json['id'] as num).toInt(),
      nom: json['nom'] as String,
      description: json['description'] as String,
      prixUnitaire: (json['prixUnitaire'] as num).toDouble(),
      unite: json['unite'] as String,
      stockDisponible: (json['stockDisponible'] as num).toInt(),
      quantite: (json['quantite'] as num).toInt(),
      photos:
          (json['photos'] as List<dynamic>).map((e) => e as String).toList(),
      producteurId: (json['producteurId'] as num).toInt(),
      nomProducteur: json['nomProducteur'] as String,
      prenomProducteur: json['prenomProducteur'] as String,
      telephoneProducteur: json['telephoneProducteur'] as String,
      emailProducteur: json['emailProducteur'] as String,
      localisationProducteur: json['localisationProducteur'] as String,
      categorieId: (json['categorieId'] as num).toInt(),
      libelleCategorie: json['libelleCategorie'] as String,
      noteMoyenne: (json['noteMoyenne'] as num).toInt(),
      nombreEvaluations: (json['nombreEvaluations'] as num).toInt(),
    );

Map<String, dynamic> _$ProduitDetailToJson(ProduitDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'description': instance.description,
      'prixUnitaire': instance.prixUnitaire,
      'unite': instance.unite,
      'stockDisponible': instance.stockDisponible,
      'quantite': instance.quantite,
      'photos': instance.photos,
      'producteurId': instance.producteurId,
      'nomProducteur': instance.nomProducteur,
      'prenomProducteur': instance.prenomProducteur,
      'telephoneProducteur': instance.telephoneProducteur,
      'emailProducteur': instance.emailProducteur,
      'localisationProducteur': instance.localisationProducteur,
      'categorieId': instance.categorieId,
      'libelleCategorie': instance.libelleCategorie,
      'noteMoyenne': instance.noteMoyenne,
      'nombreEvaluations': instance.nombreEvaluations,
    };
