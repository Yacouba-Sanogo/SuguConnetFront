class DetailCommande {
  final String numero;
  final String producteur;
  final String produit;
  final int quantite;
  final double prixUnitaire;
  final String imagePath;

  DetailCommande({
    required this.numero,
    required this.producteur,
    required this.produit,
    required this.quantite,
    required this.prixUnitaire,
    required this.imagePath,
  });

  double get prixTotal => quantite * prixUnitaire;
}
