import 'Laboratoire.dart';

class Produit
{
  int idProduit;
  String nomProduit;
  double prixProduit;
  Laboratoire laboratoire;

  Produit(id, nom, prix, labo)
  {
    this.idProduit = id;
    this.nomProduit = nom;
    this.prixProduit = prix;
    this.laboratoire = labo;
  }
}