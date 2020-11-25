import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'CostumBar.dart';
import 'package:http/http.dart' as http;

class AddLaboratoirePage extends StatefulWidget {
  @override
  _AddLaboratoirePageState createState() => _AddLaboratoirePageState();
}

class _AddLaboratoirePageState extends State<AddLaboratoirePage> {

  TextEditingController controllerID = new TextEditingController();
  TextEditingController controllerNom = new TextEditingController();
  TextEditingController controllerAdresse = new TextEditingController();
  TextEditingController controllerTelNum = new TextEditingController();

  Future addLaboratoire() async {
    await http.post("http://10.0.2.2/biopure_app/add_laboratoire.php", body: {
      "id_laboratoire": controllerID.text,
      "nom_laboratoire": controllerNom.text,
      "adresse_laboratoire": controllerAdresse.text,
      "numéro_téléphone_laboratoire": controllerTelNum.text
    });
    setState(() {
      controllerID.text = "";
      controllerNom.text = "";
      controllerAdresse.text = "";
      controllerTelNum.text = "";
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
                            Text('Ajouter un laboratoire', style: TextStyle(fontSize: height*0.03)),
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
                                    child: Text('ID laboratoire', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                                ]),
                                Padding(
                                  padding: EdgeInsets.only(left: 16, right: 16, top: 5),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: height*0.023),
                                      controller: controllerID,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(filled: true, fillColor: Colors.grey[200]),
                                    ),
                                ),
                                Row(children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 20, left: 40),
                                    child: Text('Nom laboratoire', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
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
                                    child: Text('Adresse laboratoire', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                                ]),
                                Padding(
                                  padding: EdgeInsets.only(left: 16, right: 16, top: 5),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: height*0.023),
                                      controller: controllerAdresse,
                                      decoration: InputDecoration(filled: true, fillColor: Colors.grey[200]),
                                    ),
                                ),
                                Row(children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 20, left: 40),
                                    child: Text('Numéro téléphone laboratoire', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                                ]),
                                Padding(
                                  padding: EdgeInsets.only(left: 16, right: 16, top: 5),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: height*0.023),
                                      controller: controllerTelNum,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(filled: true, fillColor: Colors.grey[200]),
                                    ),
                                ),
                                SizedBox(height: height*0.02),
                                CupertinoButton(child: Icon(Icons.add, color: Colors.white, size: height*0.03), padding: EdgeInsets.fromLTRB(8, 8, 8, 8), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(50), color: Colors.blue, 
                                  onPressed: () {
                                    if (controllerID.text.isNotEmpty & controllerTelNum.text.isNotEmpty & controllerNom.text.isNotEmpty & controllerAdresse.text.isNotEmpty)
                                      addLaboratoire();
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