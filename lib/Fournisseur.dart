import 'Laboratoire.dart';

class Fournisseur
{
  String idFournisseur;
  String nomFournisseur;
  String prenomFournisseur;
  Laboratoire laboratoire;
  String image;

  Fournisseur(id, nom, prenom, laboratoire, image)
  {
    this.idFournisseur = id;
    this.nomFournisseur = nom;
    this.prenomFournisseur = prenom;
    this.laboratoire = laboratoire;
    this.image = image;
  }
}