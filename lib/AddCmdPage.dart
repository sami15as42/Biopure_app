import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'CostumBar.dart';
import 'main.dart';
import 'Produit.dart';
import 'Laboratoire.dart';
import 'Pharmacie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCmdPage extends StatefulWidget {
  @override
  _AddCmdPageState createState() => _AddCmdPageState();
}

List<Commande> commandes = [];

class _AddCmdPageState extends State<AddCmdPage> {

  String produit;
  String produitSupp;
  List<Produit> produits = List();
  String pharmacie;
  List<Pharmacie> pharmacies = List();
  int count = 0;
  int indexColor = 0; 
  int currentQuantity = 1;
  double prix = 0;
  NumberPicker integerNumberPicker;
  List<Color> couleurs = [Colors.blue[300],Colors.green[300],Colors.yellow[300],Colors.red[300],Colors.orange[300],Colors.deepPurple[300]];

  Future getProducts() async {
    var response = await http.get("http://10.0.2.2/biopure_app/produits.php");
    var data = json.decode(response.body);
    setState(() {
      for (int i=0;i<data.length;i++) {
        produits.add(Produit(int.parse(data[i]["id_produit"]),data[i]["nom_produit"],double.parse(data[i]["prix_produit"]),Laboratoire(int.parse(data[i]["id_laboratoire"]),data[i]["nom_laboratoire"])));
      }
    });
    produit = produits[0].idProduit.toString();
    produitSupp = produits[0].idProduit.toString();
  }

  Future getPharmacies() async {
    var response = await http.get("http://10.0.2.2/biopure_app/pharmacies.php");
    var data = json.decode(response.body);
    setState(() {
      for (int i=0;i<data.length;i++) {
        pharmacies.add(Pharmacie(int.parse(data[i]["id_pharmacie"]),data[i]["nom_pharmacie"]));
      }
    });
    pharmacie = pharmacies[0].idPharmacie.toString();
  }

  Future addCmd() async {
    var response;
    response = await http.post("http://10.0.2.2/biopure_app/add_cmd.php", body: {
      "id_pharmacie": pharmacie,
      "id_fournisseur": id,
      "montant_commande": prix.toString()
    });
    var data = json.decode(response.body);
    String idCommande = data[0]["max"];
    for(int i=0;i<commandes.length;i++) {
      response = await http.post("http://10.0.2.2/biopure_app/add_ligne_cmd.php", body: {
        "id_ligne_commande": (i+1).toString(),
        "id_commande": idCommande,
        "id_produit": commandes[i].produit.idProduit.toString(),
        "quantite": commandes[i].quantite.toString(),
        "id_statut": "1",
        "id_motif": "1"
      });
    }
    setState(() {
      count = 0;
      commandes = [];
      currentQuantity = 1;
      prix = 0;
      produit = produits[0].idProduit.toString();
      produitSupp = produits[0].idProduit.toString();
      pharmacie = pharmacies[0].idPharmacie.toString();
    });
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
    getProducts();
    getPharmacies();
  }

  @override
  Widget build(BuildContext context) {
    initializeNumberPicker();
    List<Widget> children = new List.generate(count, (int i) => new Cmd(i));
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
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        CostumBar(width, height, context),
                        SizedBox(height: height*0.01),
                        Row(
                          children: <Widget>[
                            const Spacer(),
                            Text('Passer une commande', style: TextStyle(fontSize: height*0.03)),
                            const Spacer(),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(width*0.073, height*0.03, width*0.073, height*0.03),
                          child: Container(
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
                                Padding(padding: EdgeInsets.only(top: 20), child: Text('Choisir produit', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
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
                                    );}
                                  )
                                ),
                                SizedBox(height: height*0.02),
                                Container(height: 0, child: integerNumberPicker),
                                RaisedButton(
                                  padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                                  onPressed: () => showIntegerDialog(height),
                                  child: Text("Quantité : $currentQuantity", style: TextStyle(fontSize: height*0.02, color: Colors.white)),
                                  color: Colors.blue, 
                                ),
                                SizedBox(height: height*0.02),
                                CupertinoButton(child: Icon(Icons.add, color: Colors.white, size: height*0.03), padding: EdgeInsets.fromLTRB(8, 8, 8, 8), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(50), color: Colors.blue, 
                                  onPressed: () {
                                    int ind = commandes.indexWhere((e) => e.produit.idProduit.toString()==produit);
                                    if (ind==-1)
                                    {
                                      Produit p = produits.singleWhere((e) => e.idProduit.toString()==produit);
                                      commandes.add(new Commande(p, currentQuantity, couleurs[indexColor % 6]));
                                      prix += currentQuantity * p.prixProduit;
                                      indexColor += 1; 
                                      setState(() {count += 1;});
                                    }
                                  }
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),  
                        Padding(
                          padding: EdgeInsets.fromLTRB(width*0.073, 0, width*0.073, height*0.028),
                          child: Container(
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
                                Row(
                                  children: <Widget>[
                                    Padding(padding: EdgeInsets.only(top: height*0.01, bottom: 5, left: 10), child: Text('Les commandes', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                                    Spacer(),
                                    Padding(padding: EdgeInsets.only(top: height*0.01, bottom: 5, right: 10), child: Text("Prix : " + prix.toString(), style: TextStyle(fontSize: height*0.02, fontWeight: FontWeight.bold, color: Colors.grey[500])),),
                                  ]
                                ),
                                SizedBox(height: height*0.01),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                  children: children,
                                  )
                                ),
                                SizedBox(height: height*0.02),
                                CupertinoButton(child: Icon(Icons.delete_forever, color: Colors.white, size: height*0.03), padding: EdgeInsets.fromLTRB(8, 8, 8, 8), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(50), color: Colors.blue, 
                                  onPressed: () {
                                    showDeleteDialog(context);
                                  }
                                ),
                                SizedBox(height: height*0.01),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(width*0.073, 0, width*0.073, height*0.03),
                          child: Container(
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
                                      items: pharmacies
                                          .map<DropdownMenuItem<String>>((Pharmacie value) {
                                        return DropdownMenuItem<String>(
                                          value: value.idPharmacie.toString(),
                                          child: Text(value.nomPharmacie + " (" + value.idPharmacie.toString() + ")", style: TextStyle(fontSize: height*0.025)),
                                        );
                                      }).toList(),
                                    );}
                                  )
                                ),
                                SizedBox(height: height*0.01),
                              ],
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.fromLTRB(width*0.22, height*0, width*0.22, height*0.028), child: CupertinoButton(child: Text("Enregistrer", style: TextStyle(fontSize: height*0.022)), padding: EdgeInsets.fromLTRB(50, 10, 50, 10), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(10), color: Colors.blue[400], 
                          onPressed: () {
                            if (commandes.length!=0) {
                              print("Commande envoyée");
                              addCmd();
                            }
                          }),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  void initializeNumberPicker() {
    integerNumberPicker = new NumberPicker.integer(
      initialValue: currentQuantity,
      minValue: 1,
      maxValue: 1000,
      onChanged: (value) => setState(() => currentQuantity = value),
    );
  }

  void showIntegerDialog(height) {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(title: Text("Choisir la quantité", style: TextStyle(fontSize: height*0.03)), minValue: 1, maxValue: 1000, initialIntegerValue: currentQuantity);
      }
    ).then((num value) {
      if (value!=null) {
        setState(() => currentQuantity = value);
        integerNumberPicker.animateInt(value);
      }
    });
  }

  showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double width = MediaQuery.of(context).size.width;
        double height = MediaQuery.of(context).size.height;
        return new AlertDialog(
          title: Text("Choisir produit à supprimer", style: TextStyle(fontSize: height*0.03)),
          insetPadding: EdgeInsets.symmetric(horizontal: width*0.073, vertical: height*0.3),
          content: Column(
            children: <Widget>[
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return DropdownButton<String>(
                    value: produitSupp,
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 24,
                    elevation: 16,
                    underline: Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        produitSupp = newValue;
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
              ),
              SizedBox(height: 20),
              CupertinoButton(child: Text("Supprimer", style: TextStyle(fontSize: height*0.025)), padding: EdgeInsets.fromLTRB(50, 10, 50, 10), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(10), color: Colors.blue[400], 
                onPressed: () {
                  int ind = commandes.indexWhere((e) => e.produit.idProduit.toString()==produitSupp);
                  if (ind!=-1)
                  {
                    Produit p = produits.singleWhere((e) => e.idProduit.toString()==produitSupp);
                    prix -= commandes[ind].quantite * p.prixProduit;
                    commandes.removeAt(ind);
                    setState(() {count -= 1;});
                  }
                  Navigator.of(context).pop();
                }
              ),
            ]
          )
        );
      }
    );
  }
}

class Commande
{
  Produit produit;
  int quantite;
  Color couleur;

  Commande(produit, quantite, couleur)
  {
    this.produit = produit;
    this.quantite = quantite;
    this.couleur = couleur;
  }
}

class Cmd extends StatelessWidget {
  final int index;
  Cmd(this.index);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Row(
      children: <Widget>[
        SizedBox(width: 6),
        Column(
          children: <Widget>[
            Container(child: Center(child: Text("${commandes[index].quantite}", style: TextStyle(fontSize: height*0.02), textAlign: TextAlign.center)), height: height*0.06, width: height*0.06, decoration: BoxDecoration(border: Border.all(color: commandes[index].couleur, width: 5), shape: BoxShape.circle)),
            SizedBox(height: 5),
            Text("${commandes[index].produit.nomProduit}", style: TextStyle(fontSize: height*0.02)),
          ],
        ),
        SizedBox(width: 6),
      ]
    );
  }
}