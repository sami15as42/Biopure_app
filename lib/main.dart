import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'AddCmdPage.dart';
import 'StatisticsPage.dart';
import 'GetStartedPage.dart';
import 'MenuPageA.dart';
import 'MenuPageF.dart';
import 'MenuPageAdmin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

String id;
String nom;
String prenom;
String codeSite;
String profession;
String droitAcces;
String image;
double showNotifications;
Widget menu;
int nbNotifications;

SharedPreferences preferences;
bool newUser;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biopure_App',
      debugShowCheckedModeBanner: false,
      home: SplashScreenPage(),
    );
  }
}

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {checkLogin();},);
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue 
            )
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitFadingCircle(
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text("Chargement...", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ]
      ),
    );
  }

  void checkLogin() async {
    preferences = await SharedPreferences.getInstance();
    newUser = (preferences.getBool('login') ?? true);
    if (newUser==false) {
      id = preferences.getString("id");
      nom = preferences.getString("nom");
      prenom = preferences.getString("prenom");
      codeSite = preferences.getString("codeSite");
      droitAcces = preferences.getString("droitAcces");
      profession = preferences.getString("profession");
      if (profession=="Fournisseur") {
        var response = await http.post("http://10.0.2.2/biopure_app/get_image_fournisseur.php", body: {
          'id_fournisseur': id
        });
        var data = json.decode(response.body);
        image = data[0]["image"];
        showNotifications = 0;
        nbNotifications = 0;
        menu = MenuPageF();
        Navigator.push(context, MaterialPageRoute(builder: (context) => AddCmdPage()));
      }
      else {
        if (profession=="Administrateur") {
          var response = await http.post("http://10.0.2.2/biopure_app/get_image_administrateur.php", body: {
            'id_administrateur': id
          });
          var data = json.decode(response.body);
          image = data[0]["image"];
          showNotifications = 0;
          nbNotifications = 0;
          menu = MenuPageAdmin();
          Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPageAdmin())); 
        }
        else {
          var response = await http.post("http://10.0.2.2/biopure_app/get_image_agent_gestion_cmds.php", body: {
            'id_agent': id
          });
          var data = json.decode(response.body);
          image = data[0]["image"];
          response = await http.post("http://10.0.2.2/biopure_app/nb_commandes.php", body: {
            'code_site': codeSite,
          });
          data = json.decode(response.body);
          showNotifications = 1;
          nbNotifications = int.parse(data[0]['nb']);
          menu = MenuPageA();
          Navigator.push(context, MaterialPageRoute(builder: (context) => StatisticsPage()));
        }
      }
    }
    else Navigator.push(context, MaterialPageRoute(builder: (context) => GetStartedPage()));
  }
}