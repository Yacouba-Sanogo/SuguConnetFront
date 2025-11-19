// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Produit _$ProduitFromJson(Map<String, dynamic> json) => Produit(
  id: (json['id'] as num).toInt(),
  nom: json['nom'] as String,
  description: json['description'] as String,
  prix: (json['prix'] as num).toDouble(),
  quantiteStock: (json['quantiteStock'] as num).toInt(),
  categorie: json['categorie'] as String,
  imageUrl: json['imageUrl'] as String?,
  bio: json['bio'] as bool,
  uniteMesure: json['uniteMesure'] as String?,
  dateCreation: DateTime.parse(json['dateCreation'] as String),
  dateMiseAJour: json['dateMiseAJour'] == null
      ? null
      : DateTime.parse(json['dateMiseAJour'] as String),
  producteur: Producteur.fromJson(json['producteur'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProduitToJson(Produit instance) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'description': instance.description,
  'prix': instance.prix,
  'quantiteStock': instance.quantiteStock,
  'categorie': instance.categorie,
  'imageUrl': instance.imageUrl,
  'bio': instance.bio,
  'uniteMesure': instance.uniteMesure,
  'dateCreation': instance.dateCreation.toIso8601String(),
  'dateMiseAJour': instance.dateMiseAJour?.toIso8601String(),
  'producteur': instance.producteur.toJson(),
};

Categorie _$CategorieFromJson(Map<String, dynamic> json) => Categorie(
  id: (json['id'] as num).toInt(),
  nom: json['nom'] as String,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  dateCreation: DateTime.parse(json['dateCreation'] as String),
);

Map<String, dynamic> _$CategorieToJson(Categorie instance) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'dateCreation': instance.dateCreation.toIso8601String(),
};

Evaluation _$EvaluationFromJson(Map<String, dynamic> json) => Evaluation(
  id: (json['id'] as num).toInt(),
  note: (json['note'] as num).toInt(),
  commentaire: json['commentaire'] as String?,
  dateCreation: DateTime.parse(json['dateCreation'] as String),
  consommateur: Consommateur.fromJson(
    json['consommateur'] as Map<String, dynamic>,
  ),
  producteur: Producteur.fromJson(json['producteur'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EvaluationToJson(Evaluation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'note': instance.note,
      'commentaire': instance.commentaire,
      'dateCreation': instance.dateCreation.toIso8601String(),
      'consommateur': instance.consommateur.toJson(),
      'producteur': instance.producteur.toJson(),
    };
