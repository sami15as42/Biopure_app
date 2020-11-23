import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'CostumBar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAgentPage extends StatefulWidget {
  @override
  _AddAgentPageState createState() => _AddAgentPageState();
}

class _AddAgentPageState extends State<AddAgentPage> {

  TextEditingController controllerID = new TextEditingController();
  TextEditingController controllerNom = new TextEditingController();
  TextEditingController controllerPrenom = new TextEditingController();
  TextEditingController controllerPW = new TextEditingController();
  String droitAcces = "Lecture seule";
  String site;
  List<String> sites = List(); 

  Future addAgent() async {
    await http.post("http://10.0.2.2/biopure_app/add_agent.php", body: {
      "id_agent": controllerID.text,
      "nom_agent": controllerNom.text,
      "prenom_agent": controllerPrenom.text,
      "mot_passe_agent": controllerPW.text,
      "droit_acces": droitAcces,
      "code_site": site,
    });
    setState(() {
      controllerID.text = "";
      controllerNom.text = "";
      controllerPrenom.text = "";
      controllerPW.text = "";
    });
  }

  Future getSites() async {
    var response = await http.get("http://10.0.2.2/biopure_app/sites.php");
    var data = json.decode(response.body);
    setState(() {
      for (int i=0;i<data.length;i++) {
        sites.add(data[i]["code_site"]);
      }
    });
    site = sites[0];
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
    getSites();
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
                            Text('Ajouter un commercial', style: TextStyle(fontSize: height*0.03)),
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
                                    child: Text('ID commercial', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
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
                                    child: Text('Nom commercial', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
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
                                    child: Text('Prénom commercial', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
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
                                Column(
                                  children: <Widget>[
                                    Padding(padding: EdgeInsets.only(top: 20), child: Text('Choisir le site', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                                    Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return DropdownButton<String>(
                                          value: site,
                                          icon: Icon(Icons.keyboard_arrow_down),
                                          iconSize: 24,
                                          elevation: 16,
                                          underline: Container(height: 1, color: Colors.grey,),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              site = newValue;
                                            });
                                          },
                                          items: sites
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value, style: TextStyle(fontSize: height*0.025)),
                                            );
                                          }).toList(),
                                        );}
                                      )
                                    ),
                                    SizedBox(height: height*0.01),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Padding(padding: EdgeInsets.only(top: 10), child: Text("Droit d'accès", style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                                    Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return DropdownButton<String>(
                                          value: droitAcces,
                                          icon: Icon(Icons.keyboard_arrow_down),
                                          iconSize: 24,
                                          elevation: 16,
                                          underline: Container(height: 1, color: Colors.grey,),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              droitAcces = newValue;
                                            });
                                          },
                                          items: ["Lecture seule","Lecture/Ecriture"]
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value, style: TextStyle(fontSize: height*0.025)),
                                            );
                                          }).toList(),
                                        );}
                                      )
                                    ),
                                    SizedBox(height: height*0.01),
                                  ],
                                ),
                                CupertinoButton(child: Icon(Icons.add, color: Colors.white, size: height*0.03), padding: EdgeInsets.fromLTRB(8, 8, 8, 8), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(50), color: Colors.blue, 
                                  onPressed: () {
                                    if (controllerID.text.isNotEmpty & controllerPW.text.isNotEmpty & controllerNom.text.isNotEmpty & controllerPrenom.text.isNotEmpty)
                                      addAgent();
                                  }
                                ),
                                SizedBox(height: height*0.01),
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