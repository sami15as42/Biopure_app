import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'CostumBar.dart';

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

  String description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation. Lorem ipsum dolor sit amet, consectetur adipiscing elit."; 
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
                    padding: EdgeInsets.fromLTRB(width*0.073, height*0.073, width*0.073, height*0.088),
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
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: AssetImage('images/logo.png')),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            alignment: Alignment.center,
                            child: Text("Biopure App", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30)),
                          ),
                          SizedBox(height: 10),
                          Container(
                            alignment: Alignment.center,
                            child: Text("Version 1.0", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
                          ),
                          SizedBox(height: 25),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            child: Text(description, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          ),
                          SizedBox(height: 25),
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