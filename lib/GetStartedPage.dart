import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'LoginPage.dart';

class GetStartedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GetStartedPageState();
  }
}

class GetStartedPageState extends State<GetStartedPage> with TickerProviderStateMixin {
  
  final GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();

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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,  
      child: Scaffold(
        key: _globalKey,
        body: OverBoard(
          pages: pages,
          showBullets: true,
          finishText: "COMMENCER",
          nextText: "SUIVANT",
          skipText: "PASSER",
          skipCallback: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
          },
          finishCallback: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
          },
        ),
      )
    );
  }

  final pages = [
    PageModel(
      color: const Color(0xfff0DBBD6),
      imageAssetPath: 'images/getstarted1.png',
      title: "C'est parti",
      body: 'Bienvenue dans cette application !',
      doAnimateImage: true),
    PageModel(
      color: const Color(0xfff11A0B6),
      imageAssetPath: 'images/getstarted2.png',
      title: 'Passer une commande',
      body: "Permettre aux délégués de passer des commandes d'une manière facile, intuitive et rapide",
      doAnimateImage: true),
    PageModel(
      color: const Color(0xfff157DE6),
      imageAssetPath: 'images/getstarted3.png',
      title: 'Recevoir des notifications',
      body: 'Permettre aux commerciaux de rester toujours à jour en recevant des notifications des dernières commandes',
      doAnimateImage: true),
  ];
}