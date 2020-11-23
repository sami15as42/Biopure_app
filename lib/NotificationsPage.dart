import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'CostumBar.dart';
import 'Commande.dart';
import 'Produit.dart';
import 'Laboratoire.dart';
import 'LigneCommande.dart';
import 'Fournisseur.dart';
import 'Statut.dart';
import 'Motif.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> { 

  List<Commande> notifications = List();
  List<Commande> allNotifications = List();
  List<Commande> notAllNotifications = List();
  String statut;
  List<Statut> statuts = List();
  String motif;
  List<Motif> motifs = List();
  int action = 0;
  TextEditingController controllerQuantity = new TextEditingController();
  String produit;
  List<Produit> produits = List();
  String fournisseur;
  List<Fournisseur> fournisseurs = List();
  String laboratoire;
  List<Laboratoire> laboratoires = List();
  bool showAll = false;

  Future editCmd(Commande commande,index,action) async {
    if (action==1) {
      await http.post("http://10.0.2.2/biopure_app/edit_cmd.php", body: {
        "id_commande": commande.idCommande.toString(),
        "montant_commande": commande.montant.toString()
      });
      await http.post("http://10.0.2.2/biopure_app/edit_ligne_cmd.php", body: {
        "id_ligne_commande": (index + 1).toString(),
        "id_commande": commande.idCommande.toString(),
        "id_statut": "6",
        "id_motif": commande.lignesCommandes[index].motif.id.toString()
      });
      await http.post("http://10.0.2.2/biopure_app/add_ligne_cmd.php", body: {
        "id_ligne_commande": (commande.lignesCommandes.length + 1).toString(),
        "id_commande": commande.idCommande.toString(),
        "id_produit": commande.lignesCommandes[index].produit.idProduit.toString(),
        "quantite": commande.lignesCommandes[index].quantite.toString(),
        "id_statut": "1",
        "id_motif": "1"
      });
    }
    else {
      if (action==2) {
        await http.post("http://10.0.2.2/biopure_app/edit_cmd.php", body: {
          "id_commande": commande.idCommande.toString(),
          "montant_commande": commande.montant.toString()
        });
      }
      await http.post("http://10.0.2.2/biopure_app/edit_ligne_cmd.php", body: {
        "id_ligne_commande": (index + 1).toString(),
        "id_commande": commande.idCommande.toString(),
        "id_statut": commande.lignesCommandes[index].statut.id.toString(),
        "id_motif": commande.lignesCommandes[index].motif.id.toString()
      });
    }
  }

  Future getStatuts() async {
    var response = await http.get("http://10.0.2.2/biopure_app/statuts.php");
    var data = json.decode(response.body);
    setState(() {
      for (int i=0;i<data.length;i++) {
        statuts.add(Statut(int.parse(data[i]["id_statut"]),data[i]["designation_statut"]));
      }
    });
    statut = statuts[0].id.toString();
  }

  Future getMotifs() async {
    var response = await http.get("http://10.0.2.2/biopure_app/motifs.php");
    var data = json.decode(response.body);
    setState(() {
      for (int i=0;i<data.length;i++) {
        motifs.add(Motif(int.parse(data[i]["id_motif"]),data[i]["designation_motif"]));
      }
    });
    motif = motifs[0].id.toString();
  }

  Future getCommandes() async {
    var response = await http.post("http://10.0.2.2/biopure_app/nb_commandes.php", body: {
        'code_site': codeSite,
      });
    var data = json.decode(response.body);
    nbNotifications = int.parse(data[0]['nb']);
    response = await http.post("http://10.0.2.2/biopure_app/notifications.php", body: {
      'id_fournisseur': fournisseur == null ? "-1" : fournisseur,
      'id_produit': produit == null ? "-1" : produit,
      'id_laboratoire': laboratoire == null ? "-1" : laboratoire,
      "code_site": codeSite,
    });
    data = json.decode(response.body);
    setState(() {
      allNotifications = new List();
      int idCommande = -1;
      List<LigneCommande> lignesCommandes;
      for (int i=0;i<data.length;i++) {
        if (data[i]["id_commande"]!=idCommande.toString()) {
          idCommande = int.parse(data[i]["id_commande"]);
          lignesCommandes = new List();
          allNotifications.add(Commande(idCommande,int.parse(data[i]["id_pharmacie"]),data[i]["date_commande"],Fournisseur(data[i]["id_fournisseur"],data[i]["nom_fournisseur"],data[i]["prenom_fournisseur"],data[i]["image"]),double.parse(data[i]["montant_commande"]),lignesCommandes));
          lignesCommandes.add(LigneCommande(int.parse(data[i]["id_ligne_commande"]),Produit(int.parse(data[i]["id_produit"]), data[i]["nom_produit"], double.parse(data[i]["prix_produit"]),Laboratoire(int.parse(data[i]["id_laboratoire"]),data[i]["nom_laboratoire"])),int.parse(data[i]["quantite"]),Statut(int.parse(data[i]["id_statut"]),data[i]["designation_statut"]),Motif(int.parse(data[i]["id_motif"]),data[i]["designation_motif"])));
        }
        else {
          lignesCommandes.add(LigneCommande(int.parse(data[i]["id_ligne_commande"]),Produit(int.parse(data[i]["id_produit"]), data[i]["nom_produit"], double.parse(data[i]["prix_produit"]),Laboratoire(int.parse(data[i]["id_laboratoire"]),data[i]["nom_laboratoire"])),int.parse(data[i]["quantite"]),Statut(int.parse(data[i]["id_statut"]),data[i]["designation_statut"]),Motif(int.parse(data[i]["id_motif"]),data[i]["designation_motif"])));
        }
      }
      notAllNotifications = new List();
      for (int i=0;i<allNotifications.length;i++) {
        if (check(allNotifications[i].lignesCommandes)) notAllNotifications.add(allNotifications[i]);
      }
      if (showAll) notifications = allNotifications;
      else notifications = notAllNotifications;
    });
  }

  bool check(liste) {
    for (int i=0;i<liste.length;i++) {
      if (liste[i].statut.id<4) return true;
    }
    return false;
  }

  Future getProducts() async {
    var response = await http.get("http://10.0.2.2/biopure_app/produits.php");
    var data = json.decode(response.body);
    setState(() {
      produits.add(Produit(-1,"Tout",0.0,null));
      for (int i=0;i<data.length;i++) {
        produits.add(Produit(int.parse(data[i]["id_produit"]),data[i]["nom_produit"],double.parse(data[i]["prix_produit"]),Laboratoire(int.parse(data[i]["id_laboratoire"]),data[i]["nom_laboratoire"])));
      }
    });
    produit = produits[0].idProduit.toString();
  }

  Future getFournisseurs() async {
    var response = await http.get("http://10.0.2.2/biopure_app/fournisseurs.php");
    var data = json.decode(response.body);
    setState(() {
      fournisseurs.add(Fournisseur("-1","Tout","",""));
      for (int i=0;i<data.length;i++) {
        fournisseurs.add(Fournisseur(data[i]["id_fournisseur"],data[i]["nom_fournisseur"],data[i]["prenom_fournisseur"],data[i]["image"]));
      }
    });
    fournisseur = fournisseurs[0].idFournisseur;
  }

  Future getLaboratoires() async {
    var response = await http.get("http://10.0.2.2/biopure_app/laboratoires.php");
    var data = json.decode(response.body);
    setState(() {
      laboratoires.add(Laboratoire(-1,"Tout"));
      for (int i=0;i<data.length;i++) {
        laboratoires.add(Laboratoire(int.parse(data[i]["id_laboratoire"]),data[i]["nom_laboratoire"]));
      }
    });
    laboratoire = laboratoires[0].idLaboratoire.toString();
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
    getCommandes();
    getStatuts();
    getMotifs();
    getProducts();
    getFournisseurs();
    getLaboratoires();
  }

  @override
  Widget build(BuildContext context) {
    getCommandes();
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
              child : Column(
                children: [
                  CostumBar(width, height, context),
                  SizedBox(height: height*0.03),
                  Container(
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
                          Column(
                            children: <Widget>[
                              Padding(padding: EdgeInsets.only(top: 20), child: Text('Produit', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState) {
                                    return DropdownButton<String>(
                                      value: produit,
                                      icon: Icon(Icons.keyboard_arrow_down),
                                      iconSize: 24,
                                      elevation: 16,
                                      underline: Container(height: 1, color: Colors.grey,),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          produit = newValue;
                                        });
                                      },
                                      items: produits
                                          .map<DropdownMenuItem<String>>((Produit value) {
                                        return DropdownMenuItem<String>(
                                          value: value.idProduit.toString(),
                                          child: Text(value.nomProduit, style: TextStyle(fontSize: height*0.025)),
                                        );
                                      }).toList(),
                                    );
                                  }
                                )
                              ),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Padding(padding: EdgeInsets.only(top: 20), child: Text('Fournisseur', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState) {
                                    return DropdownButton<String>(
                                      value: fournisseur,
                                      icon: Icon(Icons.keyboard_arrow_down),
                                      iconSize: 24,
                                      elevation: 16,
                                      underline: Container(height: 1, color: Colors.grey,),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          fournisseur = newValue;
                                        });
                                      },
                                      items: fournisseurs
                                          .map<DropdownMenuItem<String>>((Fournisseur value) {
                                        return DropdownMenuItem<String>(
                                          value: value.idFournisseur,
                                          child: Text(value.nomFournisseur + " " + value.prenomFournisseur, style: TextStyle(fontSize: height*0.025)),
                                        );
                                      }).toList(),
                                    );
                                  }
                                )
                              ),
                            ]
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.only(top: 20), child: Text('Laboratoire', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return DropdownButton<String>(
                                          value: laboratoire,
                                          icon: Icon(Icons.keyboard_arrow_down),
                                          iconSize: 24,
                                          elevation: 16,
                                          underline: Container(height: 1, color: Colors.grey,),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              laboratoire = newValue;
                                            });
                                          },
                                          items: laboratoires
                                              .map<DropdownMenuItem<String>>((Laboratoire value) {
                                            return DropdownMenuItem<String>(
                                              value: value.idLaboratoire.toString(),
                                              child: Text(value.nomLaboratoire, style: TextStyle(fontSize: height*0.025)),
                                            );
                                          }).toList(),
                                        );
                                      }
                                    )
                                  ),
                                ]
                              ),
                              SizedBox(width: width*0.1),
                              Padding(
                                padding: EdgeInsets.only(top: 25),
                                child: CupertinoButton(child: Icon(Icons.list_alt, color: Colors.white, size: height*0.037), padding: EdgeInsets.fromLTRB(8, 8, 8, 8), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(50), color: Colors.blue, 
                                  onPressed: () {
                                    setState(() {
                                      if (showAll) {
                                        showAll = false;
                                        notifications = notAllNotifications;
                                      }
                                      else {
                                        showAll = true;
                                        notifications = allNotifications;
                                      }
                                    });
                                  }
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height*0.015),
                        ],
                      ),
                    ),
                  SizedBox(height: height*0.02),
                  Expanded(
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return ListView.builder(
                          itemCount: notifications == null ? 0 : notifications.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: <Widget>[
                                SizedBox(height: 10),
                                Center(
                                  child: InkWell(
                                    onTap: () {
                                      if (showAll) openNotification(notifications[index], true, height, width);
                                      else openNotification(notifications[index], false, height, width);
                                    },
                                    child: Container(
                                      height: height*0.17,
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
                                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10.0), 
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(3.0),
                                                child: Container(
                                                  child: Image.network("http://10.0.2.2/biopure_app/photos/${notifications[index].fournisseur.image}"),
                                                  width: height*0.13,
                                                  height: height*0.13,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        Text(notifications[index].fournisseur.nomFournisseur + " " + notifications[index].fournisseur.prenomFournisseur, style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontSize: height*0.025)),
                                                        Spacer(),
                                                        Text(notifications[index].date, style: TextStyle(color:Colors.grey, fontSize: height*0.015)),
                                                      ]
                                                    ),
                                                    Text("ID commande : " + notifications[index].idCommande.toString(), style: TextStyle(color:Colors.black, fontSize: height*0.02)),
                                                    Text("ID pharmacie : " + notifications[index].idPharmacie.toString(), style: TextStyle(color:Colors.black, fontSize: height*0.02)),
                                                    Text("Montant : " + notifications[index].montant.toString(), style: TextStyle(color:Colors.black, fontSize: height*0.02)),
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
                ]
              ),
            ),
          ),
        ),
      )
    );
  }
  
  showEditDialog(commande,index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color couleur = Colors.blue[400];
        double height = MediaQuery.of(context).size.height;
        return new AlertDialog( 
          title: Text("Modifier la commande", style: TextStyle(fontSize: height*0.03)),
          insetPadding: EdgeInsets.symmetric(vertical: height*0.18),
          scrollable: true,
          content: Column(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text('Statut', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
              ),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return DropdownButton<String>(
                    value: statut,
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 24,
                    elevation: 16,
                    underline: Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        statut = newValue;
                      });
                    },
                    items: statuts
                    .map<DropdownMenuItem<String>>((Statut value) {
                      return DropdownMenuItem<String>(
                        value: value.id.toString(),
                        child: Text(value.designation, style: TextStyle(fontSize: height*0.025)),
                      );
                    }).toList(),
                  );
                }
              ),
              SizedBox(height: 10),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text('Quantité', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 5),
                child: TextFormField(
                  style: TextStyle(fontSize: height*0.025),
                  controller: controllerQuantity,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(filled: true, fillColor: Colors.grey[200]),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text('Motif', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),
                ),
              ),
              SizedBox(height: 5),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return DropdownButton<String>(
                    value: motif,
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 24,
                    elevation: 16,
                    underline: Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        motif = newValue;
                      });
                    },
                    items: motifs
                    .map<DropdownMenuItem<String>>((Motif value) {
                      return DropdownMenuItem<String>(
                        value: value.id.toString(),
                        child: Text(value.designation, style: TextStyle(fontSize: height*0.025)),
                      );
                    }).toList(),
                  );
                }
              ),
              SizedBox(height: 10),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return CupertinoButton(child: Text("Modifier", style: TextStyle(fontSize: height*0.025)), padding: EdgeInsets.fromLTRB(50, 10, 50, 10), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(10), color: couleur, 
                    onPressed: () {
                      if ((((statut=="5") | (statut=="6") | controllerQuantity.text.isNotEmpty) & (motif!="1")) | (((statut!="5") & (statut!="6") & controllerQuantity.text.isEmpty) & (motif=="1"))) 
                      {
                        if (motif!="1") commande.lignesCommandes[index].motif = Motif(int.parse(motif),motifs.singleWhere((e) => e.id.toString()==motif).designation);
                        commande.lignesCommandes[index].statut = Statut(int.parse(statut),statuts.singleWhere((e) => e.id.toString()==statut).designation);
                        if (controllerQuantity.text.isNotEmpty) 
                        {
                          int q = int.parse(controllerQuantity.text);
                          if (q!=commande.lignesCommandes[index].quantite) 
                          { 
                            action = 1;
                            commande.montant -= commande.lignesCommandes[index].quantite * commande.lignesCommandes[index].produit.prixProduit;
                            commande.montant += q * commande.lignesCommandes[index].produit.prixProduit;
                            commande.lignesCommandes[index].quantite = q;
                          }
                        }
                        else 
                        {
                          if ((statut=="5") | (statut=="6"))
                          {
                            action = 2;
                            commande.montant -= commande.lignesCommandes[index].quantite * commande.lignesCommandes[index].produit.prixProduit;
                          }
                        }
                        editCmd(commande,index,action);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage()));
                      }
                      else setState(() {couleur = Colors.red;});
                      setState(() {
                        controllerQuantity.text = "";
                        action = 0;
                      });
                    }
                  );
                }
              ),
            ]
          )
        );
      }
    );
  }
  
  void openNotification(commande, showAll, height, width) {
    List<DataRow> listDataRows = [];
    int idStatut;
    if (showAll) idStatut = 7;
    else idStatut = 4;
    for (int i=0;i<commande.lignesCommandes.length;i++) {
      if (commande.lignesCommandes[i].statut.id < idStatut) //statut.id != 4, 5 et 6
      {
        if (droitAcces=="Lecture/Ecriture")
        listDataRows.add(
          DataRow(cells: [
            DataCell(Icon(Icons.edit, color: Colors.grey, size: height*0.03), onTap: () {
                statut = statuts[0].id.toString();
                showEditDialog(commande,i);
            }),
            DataCell(Text(commande.lignesCommandes[i].idLigneCommande.toString(), style: TextStyle(fontSize: height*0.02))), 
            DataCell(Text(commande.lignesCommandes[i].produit.nomProduit, style: TextStyle(fontSize: height*0.02))),
            DataCell(Text(commande.lignesCommandes[i].produit.laboratoire.nomLaboratoire, style: TextStyle(fontSize: height*0.02))), 
            DataCell(Text(commande.lignesCommandes[i].produit.prixProduit.toString(), style: TextStyle(fontSize: height*0.02))), 
            DataCell(Text(commande.lignesCommandes[i].quantite.toString(), style: TextStyle(fontSize: height*0.02))), 
            DataCell(Text(commande.lignesCommandes[i].statut.designation, style: TextStyle(fontSize: height*0.02))), 
            DataCell(Text(commande.lignesCommandes[i].motif.designation, style: TextStyle(fontSize: height*0.02)))
          ])
        );
        else 
        listDataRows.add(
          DataRow(cells: [
            DataCell(Icon(Icons.edit_off, color: Colors.grey, size: height*0.03), onTap: () {}),
            DataCell(Text(commande.lignesCommandes[i].idLigneCommande.toString(), style: TextStyle(fontSize: height*0.02))), 
            DataCell(Text(commande.lignesCommandes[i].produit.nomProduit, style: TextStyle(fontSize: height*0.02))),
            DataCell(Text(commande.lignesCommandes[i].produit.laboratoire.nomLaboratoire, style: TextStyle(fontSize: height*0.02))), 
            DataCell(Text(commande.lignesCommandes[i].produit.prixProduit.toString(), style: TextStyle(fontSize: height*0.02))), 
            DataCell(Text(commande.lignesCommandes[i].quantite.toString(), style: TextStyle(fontSize: height*0.02))), 
            DataCell(Text(commande.lignesCommandes[i].statut.designation, style: TextStyle(fontSize: height*0.02))), 
            DataCell(Text(commande.lignesCommandes[i].motif.designation, style: TextStyle(fontSize: height*0.02)))
          ])
        );
      } 
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
              padding: const EdgeInsets.all(15),
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
                                    Text("ID commande : " + commande.idCommande.toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: height*0.025),),
                                    Spacer(),
                                    Text(commande.date, style: TextStyle(color: Colors.black, fontSize: height*0.02),),
                                    SizedBox(width: 5),
                                    Icon(Icons.calendar_today, color: Colors.blue, size: height*0.025),
                                  ],
                                ),
                                Text("ID pharmacie : " + commande.idPharmacie.toString(), style: TextStyle(color: Colors.black, fontSize: height*0.02),),
                                Row(
                                  children: <Widget>[
                                    Text("Montant total : " + commande.montant.toString(), style: TextStyle(color: Colors.black, fontSize: height*0.02),),  
                                    Spacer(),
                                    CupertinoButton(child: Icon(Icons.list_alt, color: Colors.white, size: height*0.035), padding: EdgeInsets.fromLTRB(8, 8, 8, 8), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(50), color: Colors.blue, 
                                      onPressed: () {
                                        Navigator.pop(context);
                                        if (showAll) openNotification(commande, false, height, width);
                                        else openNotification(commande, true, height, width);
                                      }
                                    ),
                                  ],
                                ),
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
                          DataColumn(label: Text("Edit", style: TextStyle(fontSize: height*0.02))),
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
                    ),
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