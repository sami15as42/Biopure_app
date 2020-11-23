import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'CostumBar.dart';
import 'package:http/http.dart' as http;

class AddFournisseurPage extends StatefulWidget {
  @override
  _AddFournisseurPageState createState() => _AddFournisseurPageState();
}

class _AddFournisseurPageState extends State<AddFournisseurPage> {

  TextEditingController controllerID = new TextEditingController();
  TextEditingController controllerNom = new TextEditingController();
  TextEditingController controllerPrenom = new TextEditingController();
  TextEditingController controllerPW = new TextEditingController();

  Future addFournisseur() async {
    await http.post("http://10.0.2.2/biopure_app/add_fournisseur.php", body: {
      "id_fournisseur": controllerID.text,
      "nom_fournisseur": controllerNom.text,
      "prenom_fournisseur": controllerPrenom.text,
      "mot_passe_fournisseur": controllerPW.text
    });
    setState(() {
      controllerID.text = "";
      controllerNom.text = "";
      controllerPrenom.text = "";
      controllerPW.text = "";
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
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        CostumBar(width, height, context),
                        SizedBox(height: height*0.01),
                        Row(
                          children: <Widget>[
                            const Spacer(),
                            Text('Ajouter un fournisseur', style: TextStyle(fontSize: height*0.03)),
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
                                Row(children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 20, left: 40),
                                    child: Text('ID fournisseur', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                                ]),
                                Padding(
                                  padding: EdgeInsets.only(left: 16, right: 16, top: 5),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: height*0.023),
                                      controller: controllerID,
                                      decoration: InputDecoration(filled: true, fillColor: Colors.grey[200]),
                                    ),
                                ),
                                Row(children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 20, left: 40),
                                    child: Text('Nom fournisseur', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                                ]),
                                Padding(
                                  padding: EdgeInsets.only(left: 16, right: 16, top: 5),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: height*0.023),
                                      controller: controllerNom,
                                      decoration: InputDecoration(filled: true, fillColor: Colors.grey[200]),
                                    ),
                                ),
                                Row(children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 20, left: 40),
                                    child: Text('Prénom fournisseur', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                                ]),
                                Padding(
                                  padding: EdgeInsets.only(left: 16, right: 16, top: 5),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: height*0.023),
                                      controller: controllerPrenom,
                                      decoration: InputDecoration(filled: true, fillColor: Colors.grey[200]),
                                    ),
                                ),
                                Row(children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 20, left: 40),
                                    child: Text('Mot de passe', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                                ]),
                                Padding(
                                  padding: EdgeInsets.only(left: 16, right: 16, top: 5),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: height*0.023),
                                      controller: controllerPW,
                                      obscureText: true,
                                      decoration: InputDecoration(filled: true, fillColor: Colors.grey[200]),
                                    ),
                                ),
                                SizedBox(height: height*0.02),
                                CupertinoButton(child: Icon(Icons.add, color: Colors.white, size: height*0.03), padding: EdgeInsets.fromLTRB(8, 8, 8, 8), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(50), color: Colors.blue, 
                                  onPressed: () {
                                    if (controllerID.text.isNotEmpty & controllerPW.text.isNotEmpty & controllerNom.text.isNotEmpty & controllerPrenom.text.isNotEmpty)
                                      addFournisseur();
                                  }
                                ),
                                SizedBox(height: height*0.02),
                              ],
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
}