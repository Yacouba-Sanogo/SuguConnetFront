import 'package:json_annotation/json_annotation.dart';

part 'produit_detail.g.dart';

@JsonSerializable()
class ProduitDetail {
  final int id;
  final String nom;
  final String description;
  final double prixUnitaire;
  final String unite;
  final int stockDisponible;
  final int quantite;
  final List<String> photos;
  final int producteurId;
  final String nomProducteur;
  final String prenomProducteur;
  final String telephoneProducteur;
  final String emailProducteur;
  final String localisationProducteur;
  final int categorieId;
  final String libelleCategorie;
  final int noteMoyenne;
  final int nombreEvaluations;

  ProduitDetail({
    required this.id,
    required this.nom,
    required this.description,
    required this.prixUnitaire,
    required this.unite,
    required this.stockDisponible,
    required this.quantite,
    required this.photos,
    required this.producteurId,
    required this.nomProducteur,
    required this.prenomProducteur,
    required this.telephoneProducteur,
    required this.emailProducteur,
    required this.localisationProducteur,
    required this.categorieId,
    required this.libelleCategorie,
    required this.noteMoyenne,
    required this.nombreEvaluations,
  });

  factory ProduitDetail.fromJson(Map<String, dynamic> json) =>
      _$ProduitDetailFromJson(json);
  Map<String, dynamic> toJson() => _$ProduitDetailToJson(this);

  String get prixFormate {
    final isInt = prixUnitaire % 1 == 0;
    final amount = isInt
        ? prixUnitaire.toStringAsFixed(0)
        : prixUnitaire.toStringAsFixed(2);
    String unit = '';
    if (unite.isNotEmpty) {
      final u = unite.toUpperCase();
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

  bool get enStock => stockDisponible > 0;

  String get producteurFullName => '$prenomProducteur $nomProducteur';
}
