import 'Statut.dart';
import 'Produit.dart';
import 'Motif.dart';

class LigneCommande
{
  int idLigneCommande;
  Produit produit;
  int quantite;
  Statut statut;
  Motif motif;

  LigneCommande(idLigneCommande, produit, quantite, statut, motif) 
  {
    this.idLigneCommande = idLigneCommande;
    this.produit = produit;
    this.quantite = quantite;
    this.statut = statut;
    this.motif = motif;
  }
}