import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:badges/badges.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NotificationsPage.dart';
import 'main.dart';
import 'LoginPage.dart';


// ignore: non_constant_identifier_names
Widget CostumBar(width, height, context) {
  return Row(
    children: <Widget>[
      Container(
        height: height*0.1,
        child: Row(
          children: <Widget>[
            Container(
              height: height*0.1,
              width: width * 0.05,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: height*0.1,
                  width: width * 0.15,
                  child: InkWell(
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(10.0),
                      child: Container(
                        child: CircleAvatar(backgroundColor: Colors.transparent, backgroundImage: NetworkImage("http://10.0.2.2/biopure_app/photos/$image")),
                        width: height*0.1,
                        height: height*0.1,
                      ),
                    ),
                    onTap: () {
                      showInfoDialog(context, height);
                    },
                  ),
                ),
              ],
            ),
            Container(
              height: height*0.1,
              width: width * 0.05,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Opacity(
                  opacity: showNotifications,
                  child: Container(
                    height: height*0.045,
                    width: width * 0.15,
                    child: InkWell(
                      child: Badge(
                        showBadge: (nbNotifications!=0),
                        position: BadgePosition.topEnd(top: -8, end: width*0.04), //0.055
                        badgeColor: Colors.blue,
                        badgeContent: Text(nbNotifications.toString(), style: TextStyle(fontSize: height*0.02, color: Colors.white)),
                        child: Image(
                          fit: BoxFit.scaleDown,
                          image: AssetImage('images/alert.png'),
                        ),
                      ),
                      onTap: () {
                        if (showNotifications==1) {
                          print("Notifications");
                          Navigator.push(context, PageTransition(type: PageTransitionType.rotate, child: NotificationsPage()));
                        }                    
                      },
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      Container(height: height*0.1, width: width * 0.4),
      Container(
        height: height*0.13,
        width: width * 0.2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40)),
          border: Border.all(width: 3, color: Colors.white, style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          child: ClipRRect(
            borderRadius: new BorderRadius.circular(10.0),
            child: Image(
              fit: BoxFit.fill,
              image: AssetImage('images/menubar.png'),
            ),
          ),
          onTap: () {
            print('Menu');
            Navigator.push(context, PageTransition(type: PageTransitionType.rotate, child: menu));
          },
        ),
      ),
    ],
  );
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