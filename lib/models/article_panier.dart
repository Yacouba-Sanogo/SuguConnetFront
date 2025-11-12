class ArticlePanier {
  final String nom;
  final String producteur;
  final String prixUnitaire;
  final String imageUrl;
  int quantite;

  ArticlePanier({
    required this.nom,
    required this.producteur,
    required this.prixUnitaire,
    required this.imageUrl,
    required this.quantite,
  });
}