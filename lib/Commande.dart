import 'LigneCommande.dart';
import 'Fournisseur.dart';

class Commande
{
  int idCommande;
  int idPharmacie;
  String date;
  Fournisseur fournisseur;
  double montant;
  List<LigneCommande> lignesCommandes;  

  Commande(idCommande, idPharmacie, date, fournisseur, montant, lignesCommandes)
  {
    this.idCommande = idCommande;
    this.idPharmacie = idPharmacie;
    this.date = date;
    this.fournisseur = fournisseur;
    this.montant = montant;
    this.lignesCommandes = lignesCommandes;
  }
}