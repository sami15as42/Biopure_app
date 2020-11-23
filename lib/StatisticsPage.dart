import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'CostumBar.dart';
import 'main.dart';
import 'Produit.dart';
import 'Laboratoire.dart';
import 'Fournisseur.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel;

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {

  List<List<DataRow>> liste = [[], [], [], [], [], []];
  List<double> montants = [0, 0, 0, 0, 0, 0];
  DateTime dateStart = DateTime(2020,11,1);
  DateTime dateEnd = DateTime.now();
  String produit;
  List<Produit> produits = List();
  String fournisseur;
  List<Fournisseur> fournisseurs = List();
  String laboratoire;
  List<Laboratoire> laboratoires = List();

  Future<Null> selectTimePickerStart(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context, 
      initialDate: dateStart, 
      firstDate: DateTime(2010), 
      lastDate: DateTime(2040)
    );
    if (picked!=null && picked!=dateStart) {
      setState(() {
        dateStart = picked;
        getStatistics(MediaQuery.of(context).size.height);
      });
    }
  }

  Future<Null> selectTimePickerEnd(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context, 
      initialDate: dateEnd, 
      firstDate: DateTime(2010), 
      lastDate: DateTime(2040)
    );
    if (picked!=null && picked!=dateEnd) {
      setState(() {
        dateEnd = picked;
        getStatistics(MediaQuery.of(context).size.height);
      });
    }
  } 

  Future getStatistics(height) async {
    var response = await http.post("http://10.0.2.2/biopure_app/stats.php", body: {
      'id_fournisseur': fournisseur == null ? "-1" : fournisseur,
      'id_produit': produit == null ? "-1" : produit,
      'id_laboratoire': laboratoire == null ? "-1" : laboratoire,
      'code_site': codeSite,
      'date_start': dateStart.year.toString() + "-" + dateStart.month.toString() + "-" + dateStart.day.toString(),
      'date_end': dateEnd.year.toString() + "-" + dateEnd.month.toString() + "-" + dateEnd.day.toString()
    });
    var data = json.decode(response.body);
    setState(() {
      int pos = 0;
      List<DataRow> listDataRows;
      for (int i=0;i<data.length;i++) {
        if (data[i]["id_statut"]==(pos+1).toString()) {
          listDataRows = new List();
          liste[pos] = listDataRows;
          montants[pos] = 0;
          pos += 1; 
        }
        if (data[i]["nom_fournisseur"]!=null) {
          montants[pos-1] += double.parse(data[i]["montant"]);  
          listDataRows.add(
            DataRow(cells: [
              DataCell(Text(data[i]["nom_fournisseur"], style: TextStyle(fontSize: height*0.02))), 
              DataCell(Text(data[i]["prenom_fournisseur"], style: TextStyle(fontSize: height*0.02))),
              DataCell(Text(data[i]["id_commande"], style: TextStyle(fontSize: height*0.02))),
              DataCell(Text(data[i]["id_ligne_commande"], style: TextStyle(fontSize: height*0.02))), 
              DataCell(Text(data[i]["nom_produit"], style: TextStyle(fontSize: height*0.02))),
              DataCell(Text(data[i]["quantite"], style: TextStyle(fontSize: height*0.02))),
              DataCell(Text(data[i]["montant"], style: TextStyle(fontSize: height*0.02))),
            ])
          ); 
        }
      }
    });
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

  Future sendFile(fileName, addressMail) async {
    var response = await http.post("http://10.0.2.2/biopure_app/stats.php", body: {
      'id_fournisseur': fournisseur == null ? "-1" : fournisseur,
      'id_produit': produit == null ? "-1" : produit,
      'id_laboratoire': laboratoire == null ? "-1" : laboratoire,
      'code_site': codeSite,
      'date_start': dateStart.year.toString() + "-" + dateStart.month.toString() + "-" + dateStart.day.toString(),
      'date_end': dateEnd.year.toString() + "-" + dateEnd.month.toString() + "-" + dateEnd.day.toString()
    });
    var dashboard = json.decode(response.body);
    fileName = fileName + ".xlsx";
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = appDocDir.path;
    final excel.Workbook workbook = new excel.Workbook();
    final excel.Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1').setText("designation_statut");
    sheet.getRangeByName('B1').setText("nom_fournisseur");
    sheet.getRangeByName('C1').setText("prenom_fournisseur");
    sheet.getRangeByName('D1').setText("id_commande");
    sheet.getRangeByName('E1').setText("id_ligne_commande");
    sheet.getRangeByName('F1').setText("nom_produit");
    sheet.getRangeByName('G1').setText("quantite");
    sheet.getRangeByName('H1').setText("montant");
    for (int i=2;i<dashboard.length+2;i++) {
      sheet.getRangeByName('A$i').setText(dashboard[i-2]["designation_statut"]);
      if (dashboard[i-2]["nom_fournisseur"]!=null) {
        sheet.getRangeByName('B$i').setText(dashboard[i-2]["nom_fournisseur"]);
        sheet.getRangeByName('C$i').setText(dashboard[i-2]["prenom_fournisseur"]);
        sheet.getRangeByName('D$i').setNumber(double.parse(dashboard[i-2]["id_commande"]));
        sheet.getRangeByName('E$i').setNumber(double.parse(dashboard[i-2]["id_ligne_commande"]));
        sheet.getRangeByName('F$i').setText(dashboard[i-2]["nom_produit"]);
        sheet.getRangeByName('G$i').setNumber(double.parse(dashboard[i-2]["quantite"]));
        sheet.getRangeByName('H$i').setNumber(double.parse(dashboard[i-2]["montant"]));
      }
    }
    List<int> bytes = workbook.saveAsStream();
    File('$path/$fileName').writeAsBytes(bytes);
    workbook.dispose();
    final MailOptions mailOptions = MailOptions(
      body: "Voici ci-joint le fichier excel : " + fileName + ". (envoyé par Biopure App)",
      subject: "Envoie du fichier excel : " + fileName,
      recipients: [addressMail],
      isHTML: true,
      attachments: ['$path/$fileName'],
    );
    await FlutterMailer.send(mailOptions);
  }

  @override
  void initState() {
    super.initState();
    getProducts();
    getFournisseurs();
    getLaboratoires();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    getStatistics(height);
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
                            Text('Tableau de bord', style: TextStyle(fontSize: height*0.035)),
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
                                SizedBox(height: height*0.01),
                                CupertinoButton(child: Text("Exporter vers Excel", style: TextStyle(color: Colors.white, fontSize: height*0.025)), padding: EdgeInsets.fromLTRB(8, 8, 8, 8), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(10), color: Colors.blue, 
                                  onPressed: () {
                                    showEmailSendingDialog();
                                  }
                                ),
                                SizedBox(height: height*0.02),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(width*0.073, 0, width*0.073, height*0.03),
                          child: Container(
                            height: 450,
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
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                height: height*0.6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: SingleChildScrollView(
                                  child: Column( 
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("De", style: TextStyle(fontSize: height*0.02)),
                                          SizedBox(width: width*0.02),
                                          FlatButton(
                                            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                                            color: Colors.blue,
                                            textColor: Colors.white,
                                            child: Text(dateStart.day.toString() + "-" + dateStart.month.toString() + "-" + dateStart.year.toString(), style: TextStyle(fontSize: height*0.02)),
                                            onPressed: () {
                                              selectTimePickerStart(context);
                                            }, 
                                          ),
                                          SizedBox(width: width*0.02),
                                          Text("à", style: TextStyle(fontSize: height*0.02)),
                                          SizedBox(width: width*0.02),
                                          FlatButton(
                                            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                                            color: Colors.blue,
                                            textColor: Colors.white,
                                            child: Text(dateEnd.day.toString() + "-" + dateEnd.month.toString() + "-" + dateEnd.year.toString(), style: TextStyle(fontSize: height*0.02)),
                                            onPressed: () {
                                              selectTimePickerEnd(context);
                                            }, 
                                          ),    
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 10),
                                          Text("Statut 1 (Nombre : " + liste[0].length.toString() + ", montant : " + montants[0].toString() + ")", style: TextStyle(fontWeight: FontWeight.bold, fontSize: height*0.022)),
                                          SizedBox(height: 10),
                                          Container(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                columns: [
                                                  DataColumn(label: Text("Nom", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("Prénom", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("ID commande", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("ID ligne commande", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("Produit", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("Quantité", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("Montant", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                ], 
                                                rows: liste[0],
                                              ),
                                            )
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 10),
                                          Text("Statut 2 (Nombre : " + liste[1].length.toString() + ", montant : " + montants[1].toString() + ")", style: TextStyle(fontWeight: FontWeight.bold, fontSize: height*0.022)),
                                          SizedBox(height: 10),
                                          Container(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                columns: [
                                                  DataColumn(label: Text("Nom", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("Prénom", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("ID commande", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("ID ligne commande", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("Produit", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("Quantité", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("Montant", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                ], 
                                                rows: liste[1],
                                              ),
                                            )
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 10),
                                          Text("Statut 3 (Nombre : " + liste[2].length.toString() + ", montant : " + montants[2].toString() + ")", style: TextStyle(fontWeight: FontWeight.bold, fontSize: height*0.022)),
                                          SizedBox(height: 10),
                                          Container(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                columns: [
                                                  DataColumn(label: Text("Nom", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("Prénom", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("ID commande", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("ID ligne commande", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("Produit", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("Quantité", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("Montant", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                ], 
                                                rows: liste[2],
                                              ),
                                            )
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 10),
                                          Text("Livrée (Nombre : " + liste[3].length.toString() + ", montant : " + montants[3].toString() + ")", style: TextStyle(fontWeight: FontWeight.bold, fontSize: height*0.022)),
                                          SizedBox(height: 10),
                                          Container(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                columns: [
                                                  DataColumn(label: Text("Nom", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("Prénom", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("ID commande", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("ID ligne commande", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("Produit", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("Quantité", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("Montant", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                ], 
                                                rows: liste[3],
                                              ),
                                            )
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 10),
                                          Text("Annulée (Nombre : " + liste[4].length.toString() + ", montant : " + montants[4].toString() + ")", style: TextStyle(fontWeight: FontWeight.bold, fontSize: height*0.022)),
                                          SizedBox(height: 10),
                                          Container(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                columns: [
                                                  DataColumn(label: Text("Nom", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("Prénom", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("ID commande", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("ID ligne commande", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("Produit", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("Quantité", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("Montant", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                ], 
                                                rows: liste[4],
                                              ),
                                            )
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 10),
                                          Text("Remplacée (Nombre : " + liste[5].length.toString() + ", montant : " + montants[5].toString() + ")", style: TextStyle(fontWeight: FontWeight.bold, fontSize: height*0.022)),
                                          SizedBox(height: 10),
                                          Container(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                columns: [
                                                  DataColumn(label: Text("Nom", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("Prénom", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("ID commande", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("ID ligne commande", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("Produit", style: TextStyle(fontSize: height*0.02))),
                                                  DataColumn(label: Text("Quantité", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                  DataColumn(label: Text("Montant", style: TextStyle(fontSize: height*0.02)), numeric: true),
                                                ], 
                                                rows: liste[5],
                                              ),
                                            )
                                          ),
                                        ],
                                      ),
                                    ]
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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

  showEmailSendingDialog() {
    TextEditingController controllerAddressMail = new TextEditingController();
    TextEditingController controllerFileName = new TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color couleur = Colors.blue[400];
        double height = MediaQuery.of(context).size.height;
        return new AlertDialog(
          insetPadding: EdgeInsets.symmetric(vertical: height*0.18),
          scrollable: true,
          content: Column(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text('Adresse mail du récepteur', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 5),
                child: TextFormField(
                  style: TextStyle(fontSize: height*0.025),
                  controller: controllerAddressMail,
                  decoration: InputDecoration(filled: true, fillColor: Colors.grey[200]),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text('Nom du fichier excel', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 5),
                child: TextFormField(
                  style: TextStyle(fontSize: height*0.025),
                  controller: controllerFileName,
                  decoration: InputDecoration(filled: true, fillColor: Colors.grey[200]),
                ),
              ),
              SizedBox(height: 10),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return CupertinoButton(child: Text("Envoyer", style: TextStyle(fontSize: height*0.025)), padding: EdgeInsets.fromLTRB(50, 10, 50, 10), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(10), color: couleur, 
                    onPressed: () {
                      if (controllerFileName.text.isNotEmpty & controllerAddressMail.text.isNotEmpty) {
                        sendFile(controllerFileName.text, controllerAddressMail.text);
                        Navigator.pop(context);
                      }
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
}