class ProduitPopulaire {
  final int produitId;
  final String nomProduit;
  final String description;
  final double prixUnitaire;
  final String unite;
  final String photoUrl;
  final int nombreCommandes;
  final int producteurId;
  final String nomProducteur;
  final int categorieId;
  final String libelleCategorie;

  ProduitPopulaire({
    required this.produitId,
    required this.nomProduit,
    required this.description,
    required this.prixUnitaire,
    required this.unite,
    required this.photoUrl,
    required this.nombreCommandes,
    required this.producteurId,
    required this.nomProducteur,
    required this.categorieId,
    required this.libelleCategorie,
  });

  factory ProduitPopulaire.fromJson(Map<String, dynamic> json) {
    return ProduitPopulaire(
      produitId: json['produitId'] as int,
      nomProduit: json['nomProduit'] as String,
      description: json['description'] as String,
      prixUnitaire: (json['prixUnitaire'] as num).toDouble(),
      unite: json['unite'] as String,
      photoUrl: json['photoUrl'] as String,
      nombreCommandes: json['nombreCommandes'] as int,
      producteurId: json['producteurId'] as int,
      nomProducteur: json['nomProducteur'] as String,
      categorieId: json['categorieId'] as int,
      libelleCategorie: json['libelleCategorie'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'produitId': produitId,
      'nomProduit': nomProduit,
      'description': description,
      'prixUnitaire': prixUnitaire,
      'unite': unite,
      'photoUrl': photoUrl,
      'nombreCommandes': nombreCommandes,
      'producteurId': producteurId,
      'nomProducteur': nomProducteur,
      'categorieId': categorieId,
      'libelleCategorie': libelleCategorie,
    };
  }
}
