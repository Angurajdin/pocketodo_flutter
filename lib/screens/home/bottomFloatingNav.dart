import 'package:pocketodo/initPage.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';


class bottomFloatingNav extends StatefulWidget {

  int currentIndex;
  bottomFloatingNav({required this.currentIndex});

  @override
  _bottomFloatingNavState createState() => _bottomFloatingNavState();
}

class _bottomFloatingNavState extends State<bottomFloatingNav> {

  int _index = 0;

  @override
  void initState() {
    _index = widget.currentIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingNavbar(
      onTap: (int val) {
        setState(() { _index = val; } );
        if(val==0){
          Navigator.pushReplacementNamed(context, '/todolist');
        }
        if(val==1){
          Navigator.pushReplacementNamed(context, '/category');
        }
        if(val==2){
          Navigator.pushReplacementNamed(context, '/groups');
        }
        if(val==3){
          Navigator.pushReplacementNamed(context, '/notification');
        }
      },
      backgroundColor: Color(0xFF9088D3),
      currentIndex: _index,
      items: [
        FloatingNavbarItem(icon: Icons.format_list_bulleted_sharp),
        FloatingNavbarItem(icon: Icons.apps_rounded, ),
        FloatingNavbarItem(icon: Icons.supervisor_account_rounded),
        FloatingNavbarItem(icon: Icons.notifications),
      ],
    );
  }
}

