import 'LigneCommande.dart';
import 'Fournisseur.dart';
import 'Pharmacie.dart';

class Commande
{
  int idCommande;
  Pharmacie pharmacie;
  String date;
  Fournisseur fournisseur;
  double montant;
  List<LigneCommande> lignesCommandes;  

  Commande(idCommande, pharmacie, date, fournisseur, montant, lignesCommandes)
  {
    this.idCommande = idCommande;
    this.pharmacie = pharmacie;
    this.date = date;
    this.fournisseur = fournisseur;
    this.montant = montant;
    this.lignesCommandes = lignesCommandes;
  }
}