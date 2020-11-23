import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'CostumBar.dart';
import 'Agent.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangeDroitAccesPage extends StatefulWidget {
  @override
  _ChangeDroitAccesPageState createState() => _ChangeDroitAccesPageState();
}

class _ChangeDroitAccesPageState extends State<ChangeDroitAccesPage> {

  String droitAcces = "Lecture seule";
  String agent;
  List<Agent> agents = List(); 

  Future getAgents() async {
    var response = await http.get("http://10.0.2.2/biopure_app/agents.php");
    var data = json.decode(response.body);
    setState(() {
      for (int i=0;i<data.length;i++) {
        agents.add(Agent(data[i]["id_agent"],data[i]["nom_agent"],data[i]["prenom_agent"]));
      }
    });
    agent = agents[0].idAgent;
  }

  Future updateAgent() async {
    await http.post("http://10.0.2.2/biopure_app/update_agent.php", body: {
      "id_agent": agent,
      "droit_acces": droitAcces
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
    getAgents();
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
                            Text("Changer droit d'accès", style: TextStyle(fontSize: height*0.03)),
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
                                    Padding(padding: EdgeInsets.only(top: 20), child: Text('Choisir le commericial', style: TextStyle(fontSize: height*0.02, color: Colors.grey[500])),),
                                    Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return DropdownButton<String>(
                                          value: agent,
                                          icon: Icon(Icons.keyboard_arrow_down),
                                          iconSize: 24,
                                          elevation: 16,
                                          underline: Container(height: 1, color: Colors.grey,),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              agent = newValue;
                                            });
                                          },
                                          items: agents
                                              .map<DropdownMenuItem<String>>((Agent value) {
                                            return DropdownMenuItem<String>(
                                              value: value.idAgent,
                                              child: Text(value.nomAgent + " " + value.prenomAgent, style: TextStyle(fontSize: height*0.025)),
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
                                CupertinoButton(child: Text("Modifier", style: TextStyle(color: Colors.white, fontSize: height*0.025)), padding: EdgeInsets.fromLTRB(8, 8, 8, 8), pressedOpacity: 0.7, borderRadius: BorderRadius.circular(10), color: Colors.blue, 
                                  onPressed: () {
                                      updateAgent();
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeDroitAccesPage()));
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