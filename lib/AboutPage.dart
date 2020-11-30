import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'CostumBar.dart';
//this is the about page

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

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

  String description = "Biopure App est une application de passation, de gestion et de suivi des commandes. Elle est destinée principalement aux commerciaux et aux délégués des fournisseurs. C'est une application fluide, intuitive et très simple à utiliser."; 
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child:Scaffold(
            body: Container(
              color: Color(0xffEBECF0),
              child: Column(
                children: [
                  CostumBar(width, height, context),
                  Padding(
                    padding: EdgeInsets.fromLTRB(width*0.073, height*0.05, width*0.073, height*0.05),
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
                          SizedBox(height: 20),
                          Container(
                            height: height*0.15,
                            width: height*0.15,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: AssetImage('images/logo.png')),
                            ),
                          ),
                          SizedBox(height: height*0.02),
                          Container(
                            alignment: Alignment.center,
                            child: Text("Biopure App", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, fontSize: height*0.042)),
                          ),
                          SizedBox(height: height*0.015),
                          Container(
                            alignment: Alignment.center,
                            child: Text("Version 1.0", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w400, fontSize: height*0.022)),
                          ),
                          SizedBox(height: height*0.03),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            child: Text(description, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: height*0.022)),
                          ),
                          SizedBox(height: 20),
                        ]
                      ),
                    ),
                  ),
                ],
              ),
            ), 
          ),
        )
      )
    );
  }
}