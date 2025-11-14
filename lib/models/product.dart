import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'product.g.dart';

@JsonSerializable()
class Produit {
  final int id;
  final String nom;
  final String description;
  final double prix;
  final int quantiteStock;
  final String categorie;
  final String? imageUrl;
  final bool bio;
  final String? uniteMesure;
  final DateTime dateCreation;
  final DateTime? dateMiseAJour;
  final Producteur producteur;

  Produit({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.quantiteStock,
    required this.categorie,
    this.imageUrl,
    required this.bio,
    this.uniteMesure,
    required this.dateCreation,
    this.dateMiseAJour,
    required this.producteur,
  });

  factory Produit.fromJson(Map<String, dynamic> json) => _$ProduitFromJson(json);
  Map<String, dynamic> toJson() => _$ProduitToJson(this);
  String get prixFormate {
    final isInt = prix % 1 == 0;
    final amount = isInt ? prix.toStringAsFixed(0) : prix.toStringAsFixed(2);
    String unit = '';
    if (uniteMesure != null && uniteMesure!.isNotEmpty) {
      final u = uniteMesure!.toUpperCase();
      switch (u) {
        case 'KILOGRAMME':
        case 'KG':
          unit = 'kg';
          break;
        case 'LITRE':
        case 'L':
          unit = 'L';
          break;
        case 'SAC':
          unit = 'sac';
          break;
        case 'CARTON':
          unit = 'carton';
          break;
        case 'TONNE':
        case 'T':
          unit = 't';
          break;
        case 'PIECE':
        case 'PIÈCE':
          unit = 'pc';
          break;
        case 'UNITE':
        case 'UNITÉ':
          unit = 'u';
          break;
        case 'PAQUET':
          unit = 'pkt';
          break;
        default:
          unit = u.toLowerCase();
      }
      unit = ' / $unit';
    }
    return '$amount fcfa$unit';
  }
  bool get enStock => quantiteStock > 0;
}

@JsonSerializable()
class Categorie {
  final int id;
  final String nom;
  final String? description;
  final String? imageUrl;
  final DateTime dateCreation;

  Categorie({
    required this.id,
    required this.nom,
    this.description,
    this.imageUrl,
    required this.dateCreation,
  });

  factory Categorie.fromJson(Map<String, dynamic> json) => _$CategorieFromJson(json);
  Map<String, dynamic> toJson() => _$CategorieToJson(this);
}

@JsonSerializable()
class Evaluation {
  final int id;
  final int note;
  final String? commentaire;
  final DateTime dateCreation;
  final Consommateur consommateur;
  final Producteur producteur;

  Evaluation({
    required this.id,
    required this.note,
    this.commentaire,
    required this.dateCreation,
    required this.consommateur,
    required this.producteur,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) => _$EvaluationFromJson(json);
  Map<String, dynamic> toJson() => _$EvaluationToJson(this);

  String get noteEtoiles {
    return '★' * note + '☆' * (5 - note);
  }
}
