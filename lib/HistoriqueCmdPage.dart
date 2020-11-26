import 'package:biopure_app/Fournisseur.dart';
import 'package:biopure_app/Produit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'CostumBar.dart';
import 'Pharmacie.dart';
import 'Commande.dart';
import 'LigneCommande.dart';
import 'Produit.dart';
import 'Laboratoire.dart';
import 'Statut.dart';
import 'Motif.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoriqueCmdPage extends StatefulWidget {
  @override
  _HistoriqueCmdPageState createState() => _HistoriqueCmdPageState();
}

class _HistoriqueCmdPageState extends State<HistoriqueCmdPage> { 

  String pharmacie;
  List<Pharmacie> pharmacies = List();
  List<Commande> commandes = List();

  Future getCommandes() async {
    var response = await http.post("http://10.0.2.2/biopure_app/commandes.php", body: {
      "id_fournisseur": id,
      "id_pharmacie": pharmacie
    });
    var data = json.decode(response.body);
    setState(() {
      commandes = new List();
      int idCommande = -1;
      List<LigneCommande> lignesCommandes;
      for (int i=0;i<data.length;i++) {
        if (data[i]["id_commande"]!=idCommande.toString()) {
          idCommande = int.parse(data[i]["id_commande"]);
          lignesCommandes = new List();
          commandes.add(Commande(idCommande,Pharmacie(int.parse(pharmacie),"","",""),data[i]["date_commande"],Fournisseur(id,"","",null,""),double.parse(data[i]["montant_commande"]),lignesCommandes));
          lignesCommandes.add(LigneCommande(int.parse(data[i]["id_ligne_commande"]),Produit(int.parse(data[i]["id_produit"]), data[i]["nom_produit"], double.parse(data[i]["prix_produit"]),Laboratoire(int.parse(data[i]["id_laboratoire"]),data[i]["nom_laboratoire"])),int.parse(data[i]["quantite"]),Statut(int.parse(data[i]["id_statut"]),data[i]["designation_statut"]),Motif(int.parse(data[i]["id_motif"]),data[i]["designation_motif"])));
        }
        else {
          lignesCommandes.add(LigneCommande(int.parse(data[i]["id_ligne_commande"]),Produit(int.parse(data[i]["id_produit"]), data[i]["nom_produit"], double.parse(data[i]["prix_produit"]),Laboratoire(int.parse(data[i]["id_laboratoire"]),data[i]["nom_laboratoire"])),int.parse(data[i]["quantite"]),Statut(int.parse(data[i]["id_statut"]),data[i]["designation_statut"]),Motif(int.parse(data[i]["id_motif"]),data[i]["designation_motif"])));
        }
      }
    });
  }

  Future getPharmacies() async {
    var response = await http.get("http://10.0.2.2/biopure_app/pharmacies.php");
    var data = json.decode(response.body);
    setState(() {
      for (int i=0;i<data.length;i++) {
        pharmacies.add(Pharmacie(int.parse(data[i]["id_pharmacie"]),data[i]["nom_pharmacie"],data[i]["adresse_pharmacie"],data[i]["numéro_téléphone_pharmacie"]));
      }
    });
    pharmacie = pharmacies[0].idPharmacie.toString();
  }

  Future<bool> _onBackPressed() {
    double height = MediaQuery.of(context).size.height;
    return showDialog(
      context: context,
      builder: (context) =>AlertDialog(
        title: Text("Voulez-vous quitter l'application ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: height*0.025)),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context,false), 
            child: Text("Non", style: TextStyle(fontWeight: FontWeight.bold, fontSize: height*0.023))
          ),
          FlatButton(
            onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'), 
            child: Text("Oui", style: TextStyle(fontWeight: FontWeight.bold, fontSize: height*0.023))
          ),
        ],
      )
    );
  }

  @override
  void initState() {
    super.initState();
    getPharmacies();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: Scaffold(
            body: Container(
              color: Color(0xffEBECF0),
              child: Column(
                children: <Widget>[
                  CostumBar(width, height, context),
                  SizedBox(height: height*0.03),
                  Padding(
                    padding: EdgeInsets.fromLTRB(width*0.05, 0, width*0.05, height*0.03),
                    child: Container(
                      width: width*0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Padding(padding: EdgeInsets.only(top: 20), child: Text('Choisir pharmacie', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return DropdownButton<String>(
                                  value: pharmacie,
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  iconSize: 24,
                                  elevation: 16,
                                  underline: Container(height: 1, color: Colors.grey,),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      pharmacie = newValue;
                                    });
                                  },
                                  items: pharmacies.map<DropdownMenuItem<String>>((Pharmacie value) {
                                    return DropdownMenuItem<String>(
                                      value: value.idPharmacie.toString(),
                                      child: Text(value.nomPharmacie + " (" + value.idPharmacie.toString() + ")", style: TextStyle(fontSize: height*0.025)),
                                    );
                                  }).toList(),
                                );
                              }
                            )
                          ),
                          SizedBox(height: height*0.01),
                          CupertinoButton(child: Icon(Icons.remove_red_eye, color: Colors.white, size: height*0.03), padding: EdgeInsets.fromLTRB(8, 8, 8, 8), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(50), color: Colors.blue, 
                            onPressed: () {
                              getCommandes(); 
                            }
                          ),
                          SizedBox(height: height*0.01),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return ListView.builder(
                          itemCount: commandes == null ? 0 : commandes.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: <Widget>[
                                SizedBox(height: 10),
                                Center(
                                  child: InkWell(
                                    onTap: () {
                                      openNotification(commandes[index].lignesCommandes, commandes[index].idCommande, commandes[index].montant, commandes[index].date, height, width);
                                    },
                                    child: Container(
                                      height: height*0.15,
                                      width: width*0.9,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        Text("ID commande : " + commandes[index].idCommande.toString(), style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize: height*0.025)),
                                                        Spacer(),
                                                        Text(commandes[index].date, style: TextStyle(color:Colors.grey, fontSize: height*0.015)),
                                                      ]
                                                    ),
                                                    Text("Montant : " + commandes[index].montant.toString(), style: TextStyle(color:Colors.black, fontSize: height*0.02)),
                                                    Text("Nombre de produits : " + commandes[index].lignesCommandes.length.toString(), style: TextStyle(color:Colors.black, fontSize: height*0.02)),
                                                  ] 
                                                ),
                                              ),
                                            ),
                                          ]
                                        ),
                                      ),
                                    ),
                                  ) 
                                ),
                                SizedBox(height: 10),
                              ]
                            );
                          },
                        );
                      }
                    ) 
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  void openNotification(lignesCommandes, id, montant, date, height, width) {
    List<DataRow> listDataRows = [];
    for (int i=0;i<lignesCommandes.length;i++) {
      listDataRows.add(
        DataRow(cells: [
          DataCell(Text(lignesCommandes[i].idLigneCommande.toString(), style: TextStyle(fontSize: height*0.02))), 
          DataCell(Text(lignesCommandes[i].produit.nomProduit, style: TextStyle(fontSize: height*0.02))),
          DataCell(Text(lignesCommandes[i].produit.laboratoire.nomLaboratoire, style: TextStyle(fontSize: height*0.02))), 
          DataCell(Text(lignesCommandes[i].produit.prixProduit.toString(), style: TextStyle(fontSize: height*0.02))), 
          DataCell(Text(lignesCommandes[i].quantite.toString(), style: TextStyle(fontSize: height*0.02))), 
          DataCell(Text(lignesCommandes[i].statut.designation, style: TextStyle(fontSize: height*0.02))), 
          DataCell(Text(lignesCommandes[i].motif.designation, style: TextStyle(fontSize: height*0.02)))
        ])
      );
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            height: height*0.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView( 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text("ID commande : " + id.toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: height*0.025),),
                                    Spacer(),
                                    Text(date, style: TextStyle(color: Colors.black, fontSize: height*0.02),),
                                    SizedBox(width: 5),
                                    Icon(Icons.calendar_today, color: Colors.blue, size: height*0.025),
                                  ],
                                ),
                                Text("Montant total : " + montant.toString(), style: TextStyle(color: Colors.black, fontSize: height*0.02),),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: height*0.01),
                    Text("Contenu :", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: height*0.025),),
                    SizedBox(height: height*0.02),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text("ID", style: TextStyle(fontSize: height*0.02)), numeric: true),
                          DataColumn(label: Text("Produit", style: TextStyle(fontSize: height*0.02))),
                          DataColumn(label: Text("Laboratoire", style: TextStyle(fontSize: height*0.02))),
                          DataColumn(label: Text("Prix", style: TextStyle(fontSize: height*0.02)), numeric: true),
                          DataColumn(label: Text("Quantité", style: TextStyle(fontSize: height*0.02)), numeric: true),
                          DataColumn(label: Text("Statut", style: TextStyle(fontSize: height*0.02))),
                          DataColumn(label: Text("Motif", style: TextStyle(fontSize: height*0.02))),
                        ], 
                        rows: listDataRows,
                      ),
                    )
                  ],
                ),
              )
            ),
          ),
        );
      }
    );
  }
}