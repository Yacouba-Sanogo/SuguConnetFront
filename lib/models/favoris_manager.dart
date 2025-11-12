import 'package:suguconnect_mobile/models/produit.dart';
import 'package:suguconnect_mobile/widgets/produit_detail.dart';

class GestionnaireFavoris {
  static final List<Produit> _favorisProduit = [];
  static final List<ProduitDetail> _favorisProduitDetail = [];

  static List<Produit> get favorisProduit => List.unmodifiable(_favorisProduit);
  static List<ProduitDetail> get favorisProduitDetail => List.unmodifiable(_favorisProduitDetail);

  // Méthodes pour les objets Produit
  static bool estFavori(Produit produit) {
    return _favorisProduit.contains(produit);
  }

  static void basculerFavori(Produit produit) {
    if (_favorisProduit.contains(produit)) {
      _favorisProduit.remove(produit);
    } else {
      _favorisProduit.add(produit);
    }
  }
  
  static void ajouterFavori(Produit produit) {
    if (!_favorisProduit.contains(produit)) {
      _favorisProduit.add(produit);
    }
  }
  
  static void retirerFavori(Produit produit) {
    _favorisProduit.remove(produit);
  }
  
  // Méthodes pour les objets ProduitDetail
  static bool estFavoriProduitDetail(ProduitDetail produit) {
    return _favorisProduitDetail.contains(produit);
  }

  static void basculerFavoriProduitDetail(ProduitDetail produit) {
    if (_favorisProduitDetail.contains(produit)) {
      _favorisProduitDetail.remove(produit);
    } else {
      _favorisProduitDetail.add(produit);
    }
  }
  
  static void ajouterFavoriProduitDetail(ProduitDetail produit) {
    if (!_favorisProduitDetail.contains(produit)) {
      _favorisProduitDetail.add(produit);
    }
  }
  
  static void retirerFavoriProduitDetail(ProduitDetail produit) {
    _favorisProduitDetail.remove(produit);
  }
}