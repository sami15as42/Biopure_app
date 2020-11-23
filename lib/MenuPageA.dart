import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'StatisticsPage.dart';
import 'AboutPage.dart';
import 'NotificationsPage.dart';
import 'main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:footer/footer.dart';
import 'package:footer/footer_view.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuPageA extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MenuPageAState();
  }
}

class MenuPageAState extends State<MenuPageA> {

  final picker = ImagePicker();

  Future choiceImage() async {
    var pickedImage = await picker.getImage(source: ImageSource.gallery);
    File _image = File(pickedImage.path);
    final uri = Uri.parse("http://10.0.2.2/biopure_app/upload_agent.php");
    var request = http.MultipartRequest('POST',uri);
    request.fields['id_agent'] = id;
    var pic = await http.MultipartFile.fromPath("image", _image.path);
    request.files.add(pic);
    await request.send();
    var response = await http.post("http://10.0.2.2/biopure_app/get_image_agent_gestion_cmds.php", body: {
      'id_agent': id
    });
    var data = json.decode(response.body);
    image = data[0]["image"];
    Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPageA()));
  }

  Future updatePWAgent(String motPasse) async {
    await http.post("http://10.0.2.2/biopure_app/update_pw_agent.php", body: {
      "id_agent": id,
      "mot_passe_agent": motPasse
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

  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: height*0.3,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          InkWell(
                            child: Container(
                              width: width*0.15,
                              height: width*0.15,
                              child: CircleAvatar(backgroundColor: Colors.transparent, backgroundImage: NetworkImage("http://10.0.2.2/biopure_app/photos/$image")),
                            ),
                            onTap: () {
                              showInfoDialog(context, height);
                            },
                          ),
                          Spacer(),
                          InkWell(
                            child: Icon(Icons.camera, color: Colors.white, size: height*0.04),
                            onTap: () {
                              choiceImage();
                            },
                          ),
                        ]
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: <Widget>[
                          Text(nom + " " + prenom, style: TextStyle(fontSize: height*0.03, fontWeight: FontWeight.w600, color: Colors.white)),
                          SizedBox(width: 10),
                          InkWell(
                            child: Icon(Icons.admin_panel_settings, color: Colors.white, size: height*0.04),
                            onTap: () {
                              createAlertDialog(context);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 3),
                      Text(profession, style: TextStyle(fontSize: height*0.02, color: Colors.white)),
                    ]
                  )
                ),
              ),
            ),
            SizedBox(height: height*0.05),
            ListTile(
              leading: Icon(Icons.dashboard, size: height*0.04),
              title: Text("Tableau de bord", style: TextStyle(fontSize: height*0.025)),
              onTap: () {
                print("Tableau de bord");
                Navigator.push(context, MaterialPageRoute(builder: (context) => StatisticsPage()));
              }
            ),
            SizedBox(height: height*0.02),
            ListTile(
              leading: Icon(Icons.notifications, size: height*0.04),
              title: Text("Notifications", style: TextStyle(fontSize: height*0.025)),
              onTap: () {
                print("Notifications");
                Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage()));
              }
            ),
            SizedBox(height: height*0.02),
            ListTile(
              leading: Icon(Icons.info_outline, size: height*0.04),
              title: Text("A propos", style: TextStyle(fontSize: height*0.025)),
              onTap: () {
                print("A propos");
                Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
              }
            ),
            Flexible(
              child: FooterView(
                children: [],
                footer: Footer(
                  backgroundColor: Colors.grey[300],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:<Widget>[
                      Text('Copyright ©2020, Tous les droits sont réservés.', style: TextStyle(fontWeight: FontWeight.w500, fontSize: height*0.015, color: Color(0xFF162A49)),),
                      Text('Powered by BIOPURE',style: TextStyle(fontWeight: FontWeight.w600, fontSize: height*0.016,color: Color(0xFF162A49)),),
                    ]
                  ),
                )
              ),
            ),
          ]
        ),
      )
    );
  }

  Future createAlertDialog(BuildContext context) {
    TextEditingController controllerPW = TextEditingController();
    double height = MediaQuery.of(context).size.height;
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Modifier le mot de passe", style: TextStyle(fontSize: height*0.03)),
        content: TextField(
          style: TextStyle(fontSize: height*0.025),
          controller: controllerPW,
          obscureText: true,
          decoration: InputDecoration(filled: true, fillColor: Colors.grey[200]),
        ),
        actions: [
          MaterialButton(
            elevation: 5,
            child: Text("Modifier", style: TextStyle(fontSize: height*0.023, fontWeight: FontWeight.bold, color: Colors.blue[500])),
            onPressed: () {
              if (controllerPW.text.isNotEmpty) {
                updatePWAgent(controllerPW.text);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    });
  }
}

showInfoDialog(BuildContext context, double height) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        elevation: 24,
        content: Container(
          height: height*0.25, 
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: new BorderRadius.circular(10.0),
                child: Container(
                  child: CircleAvatar(backgroundColor: Colors.transparent, backgroundImage: NetworkImage("http://10.0.2.2/biopure_app/photos/$image")),
                  width: height*0.13,
                  height: height*0.13,
                ),
              ),
              SizedBox(height: 16),
              Text(nom + " " + prenom, style: TextStyle(fontWeight: FontWeight.bold, fontSize: height*0.03)),
              SizedBox(height: 5),
              Text(profession, style: TextStyle(fontSize: height*0.025)),
            ]
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () async {
              SharedPreferences preferences = await SharedPreferences.getInstance();
              preferences.setBool("login", true);
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            }, 
            child: Text("Se déconnecter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: height*0.025)),
          )
        ],
      );
    }
  );
}