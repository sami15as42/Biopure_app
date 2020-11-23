import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'AddCmdPage.dart';
import 'StatisticsPage.dart';
import 'MenuPageA.dart';
import 'MenuPageF.dart';
import 'MenuPageAdmin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String categorie = "Fournisseur";
  bool resterConnecte = true;
  String msg = "";
  Color couleur = Colors.blue[400];
  TextEditingController controllerID = new TextEditingController();
  TextEditingController controllerPW = new TextEditingController();

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

  Future login() async {
    var response;
    if (categorie=="Fournisseur") {
      response = await http.post("http://10.0.2.2/biopure_app/login_fournisseur.php", body: {
        "id_fournisseur": controllerID.text,
        "mot_passe_fournisseur": controllerPW.text,
      }); 
    }
    else {
      if (categorie=="Administrateur") {
        response = await http.post("http://10.0.2.2/biopure_app/login_admin.php", body: {
          "id_administrateur": controllerID.text,
          "mot_passe_administrateur": controllerPW.text,
        });
      }
      else {
        response = await http.post("http://10.0.2.2/biopure_app/login_agent.php", body: {
          "id_agent": controllerID.text,
          "mot_passe_agent": controllerPW.text,
        }); 
      }
    }
    var dataUser = json.decode(response.body);
    if (dataUser.length==0) {
      setState(() {
        msg = "Connexion échouée";
      });
    }
    else {
      if (categorie=="Fournisseur" || categorie=="Administrateur") codeSite = ""; 
      else {
        codeSite = dataUser[0]['code_site'];
        droitAcces = dataUser[0]['droit_acces'];
      }
      setState(() {
        couleur = Colors.green[400];
      });
      if (categorie=="Fournisseur") {
        id = dataUser[0]['id_fournisseur'];
        nom = dataUser[0]['nom_fournisseur'];
        prenom = dataUser[0]['prenom_fournisseur'];
        profession = "Fournisseur";
        showNotifications = 0;
        nbNotifications = 0;
        menu = MenuPageF();
        var response = await http.post("http://10.0.2.2/biopure_app/get_image_fournisseur.php", body: {
          'id_fournisseur': id
        });
        var data = json.decode(response.body);
        image = data[0]["image"];
        sleep(Duration(seconds:2));
        Navigator.push(context, MaterialPageRoute(builder: (context) => AddCmdPage()));
      }
      else {
        if (categorie=="Administrateur") {
          id = dataUser[0]['id_administrateur'];
          nom = dataUser[0]['nom_administrateur'];
          prenom = dataUser[0]['prenom_administrateur'];
          profession = "Administrateur";
          showNotifications = 0;
          nbNotifications = 0;
          menu = MenuPageAdmin();
          var response = await http.post("http://10.0.2.2/biopure_app/get_image_administrateur.php", body: {
            'id_administrateur': id
          });
          var data = json.decode(response.body);
          image = data[0]["image"];
          sleep(Duration(seconds:2));
          Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPageAdmin()));
        }
        else {
          response = await http.post("http://10.0.2.2/biopure_app/nb_commandes.php", body: {
            'code_site': codeSite,
          });
          var data = json.decode(response.body);
          id = dataUser[0]['id_agent'];
          nom = dataUser[0]['nom_agent'];
          prenom = dataUser[0]['prenom_agent'];
          profession = "Agent de gestion des commandes";
          showNotifications = 1;
          nbNotifications = int.parse(data[0]['nb']);
          menu = MenuPageA();
          response = await http.post("http://10.0.2.2/biopure_app/get_image_agent_gestion_cmds.php", body: {
            'id_agent': id
          });
          data = json.decode(response.body);
          image = data[0]["image"];
          sleep(Duration(seconds:2));
          Navigator.push(context, MaterialPageRoute(builder: (context) => StatisticsPage()));
        }
      }
      SharedPreferences preferences;
      if (resterConnecte) {
        preferences = await SharedPreferences.getInstance();
        preferences.setBool("login", false);
        preferences.setString("id", id);
        preferences.setString("nom", nom);
        preferences.setString("prenom", prenom);
        preferences.setString("profession", profession);
        preferences.setString("codeSite", codeSite);
        preferences.setString("droitAcces", droitAcces);
      }
      else {
        preferences = await SharedPreferences.getInstance();
        preferences.setBool("login", true);
      }
    }
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
      child: Builder(
        builder: (BuildContext context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Card(
              color: Colors.grey[200],
              child: Padding(
                padding: EdgeInsets.fromLTRB(width*0.065, height*0.075, width*0.065, height*0.055),
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
                      Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                        child: Text('Login', style: TextStyle(fontSize: height*0.045)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(30))),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text('Catégorie', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: DropdownButton<String>(
                          value: categorie,
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconSize: 24,
                          elevation: 16,
                          underline: Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              categorie = newValue;
                            });
                          },
                          items: <String>[
                            'Administrateur',
                            'Fournisseur',
                            'Agent de gestion des commandes'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(fontSize: height*0.023)),
                            );
                          }).toList(),
                        ),
                      ),
                      Row(children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20, left: 40),
                          child: Text('Identifiant', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
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
                          child: Text('Mot de passe', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),
                        ),
                      ]),
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 5),
                        child: TextField(
                          style: TextStyle(fontSize: height*0.023),
                          controller: controllerPW,
                          obscureText: true,
                          decoration: InputDecoration(
                              filled: true, fillColor: Colors.grey[200]),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 0, left: 40),
                            child: Text('Rester Connecté', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 0),
                            child: Transform.scale(
                              scale: 0.75,
                              child: CupertinoSwitch(
                                value: resterConnecte,
                                activeColor: Colors.blue[400],
                                trackColor: Colors.grey[300],
                                onChanged: (value) {
                                  setState(() {
                                    resterConnecte = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: CupertinoButton(
                            child: Text("Login", style: TextStyle(fontSize: height*0.025)),
                            padding: EdgeInsets.fromLTRB(80, 10, 80, 10),
                            pressedOpacity: 0.7,
                            borderRadius: BorderRadius.circular(10),
                            color: couleur,
                            onPressed: () async {
                              print("ID : " + controllerID.text);
                              print("Mot de passe : " + controllerPW.text);
                              print("Catégorie : " + categorie);
                              print("Rester connecté : " + resterConnecte.toString());
                              if (controllerID.text.isNotEmpty && controllerPW.text.isNotEmpty) 
                              {
                                login();
                              }
                            }),
                      ),
                      SizedBox(height: 20),
                      Text(msg, style: TextStyle(fontSize: height*0.02, color: Colors.red)),
                    ],
                  ),
                ),
              ),
            )
          );
        },
      )
    );
  }
}