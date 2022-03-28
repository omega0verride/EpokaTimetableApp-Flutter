import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void openLink(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw "Could not launch $url";
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xff152238),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Container(
              width: double.infinity,
              color: Colors.blue,
              padding: const EdgeInsets.all(20),
              child: Text(
                "Epoka University",
                style: GoogleFonts.bebasNeue(
                  color: Colors.white,
                  letterSpacing: 6,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
                textAlign: TextAlign.center,
              )),
          const SizedBox(
            height: 15,
          ),
          ListTile(
            leading: const Icon(
              Icons.calendar_today,
              color: Colors.white,
            ),
            title: Text("Weekly Calendar",
                style:
                    GoogleFonts.josefinSans(color: Colors.white, fontSize: 15)),
            onTap: () {
              Navigator.pushNamed(context, '/weekly');
            },
          ),
          const SizedBox(
            height: 15,
          ),
          ListTile(
            leading: const Icon(
              Icons.today,
              color: Colors.white,
            ),
            title: Text("Today",
                style:
                    GoogleFonts.josefinSans(color: Colors.white, fontSize: 15)),
            onTap: () {
              Navigator.pushNamed(context, '/today');
            },
          ),
          const SizedBox(
            height: 15,
          ),
          ListTile(
            leading: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            title: Text("Change Timetable Selection",
                style:
                    GoogleFonts.josefinSans(color: Colors.white, fontSize: 15)),
            onTap: () {
              Navigator.pushNamed(context, '/select');
            },
          ),
          const SizedBox(
            height: 15,
          ),
          ListTile(
            leading: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            title: Text("Settings",
                style:
                    GoogleFonts.josefinSans(color: Colors.white, fontSize: 15)),
            onTap: () {},
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
          ListTile(
            leading: Container(
              child: Image.asset("images/git.png"),
              width: 20,
            ),
            title: Transform.translate(
                offset: Offset(-20, 0),
                child: Text("omega0verride",
                    style: GoogleFonts.josefinSans(
                        color: Colors.white, fontSize: 15))),
            contentPadding: EdgeInsets.only(left: 20),
            onTap: () {
              openLink('https://github.com/omega0verride');
            },
          ),
        ],
      ),
    );
  }
}
