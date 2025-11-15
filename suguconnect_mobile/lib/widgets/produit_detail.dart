class ProduitDetail {
  final String nom;
  final double prix;
  final String unite;
  final List<String> images;
  final String description;

  final String producteurNom;
  final String producteurFerme;
  final String producteurDescription;
  final String producteurImage;

  const ProduitDetail({
    required this.nom,
    required this.prix,
    required this.unite,
    required this.images,
    required this.description,
    required this.producteurNom,
    required this.producteurFerme,
    required this.producteurDescription,
    required this.producteurImage,
  });
}
