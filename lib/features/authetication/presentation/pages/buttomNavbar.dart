import 'package:baltra/features/applicationCare/presentation/ui/application_care_page.dart';
import 'package:baltra/features/products/presentation/screens/home_page.dart';
import 'package:baltra/features/products/presentation/screens/category_page.dart';
import 'package:baltra/features/authetication/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';

class ButtomNavBar extends StatefulWidget {
  const ButtomNavBar({super.key, required this.pageno});
  final int pageno;

  @override
  _ButtomNavBarState createState() => _ButtomNavBarState();
}

class _ButtomNavBarState extends State<ButtomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    _selectedIndex = widget.pageno;
    super.initState();
  }

  final screens = [
    const HomePage(),
    CategoryPage(),
    const ApplicationCarePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: screens[_selectedIndex],
            ),
          ],
        ),
      ),

      bottomNavigationBar: SizedBox(
        height:
            55.0,
        child: CustomBottomAppBar(
          height: 50.0,
          curveHeight: 30.0,
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}

class CustomBottomAppBar extends StatelessWidget {
  final double height;
  final double curveHeight;
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomAppBar({
    super.key,
    required this.height,
    required this.curveHeight,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(curveHeight)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 8,
            blurRadius: 1,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          selectedIndex == 0
              ? GestureDetector(
                  onTap: () => onItemTapped(0),
                  child: SizedBox(
                    width: 100,
                    child: Image.asset(
                      'assets/images/home_active.png',
                      fit: BoxFit.fitWidth,
                      height: 120,
                      width: 120,
                    ),
                  ))
              : GestureDetector(
                  onTap: () => onItemTapped(0),
                  child: SizedBox(
                    width: 80,
                    child: Image.asset(
                      'assets/images/home_inactive.png',
                      fit: BoxFit.contain,
                      height: 40,
                      width: 50,
                    ),
                  )),
          selectedIndex == 1
              ? GestureDetector(
                  onTap: () => onItemTapped(1),
                  child: SizedBox(
                    width: 100,
                    child: Image.asset(
                      'assets/images/products_active.png',
                      fit: BoxFit.fitWidth,
                      height: 120,
                      width: 100,
                    ),
                  ))
              : GestureDetector(
                  onTap: () => onItemTapped(1),
                  child: SizedBox(
                    width: 80,
                    child: Image.asset(
                      'assets/images/products_inactive.png',
                      fit: BoxFit.contain,
                      height: 40,
                      width: 50,
                    ),
                  )),
          selectedIndex == 2
              ? GestureDetector(
                  onTap: () => onItemTapped(2),
                  child: SizedBox(
                    width: 100,
                    child: Image.asset(
                      'assets/images/care_active.png',
                      fit: BoxFit.fitWidth,
                      height: 120,
                      width: 120,
                    ),
                  ))
              : GestureDetector(
                  onTap: () => onItemTapped(2),
                  child: SizedBox(
                    width: 80,
                    child: Image.asset(
                      'assets/images/care_inactive.png',
                      fit: BoxFit.contain,
                      height: 40,
                      width: 50,
                    ),
                  )),
          selectedIndex == 3
              ? GestureDetector(
                  onTap: () => onItemTapped(3),
                  child: SizedBox(
                    width: 100,
                    child: Image.asset(
                      'assets/images/profile_active.png',
                      fit: BoxFit.fitWidth,
                      height: 120,
                      width: 120,
                    ),
                  ))
              : GestureDetector(
                  onTap: () => onItemTapped(3),
                  child: SizedBox(
                    width: 80,
                    child: Image.asset(
                      'assets/images/profile_unactive.png',
                      fit: BoxFit.contain,
                      height: 40,
                      width: 50,
                    ),
                  )),
        ],
      ),
    );
  }

  BoxDecoration selectedBoxDecoration(BuildContext context) {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: RadialGradient(tileMode: TileMode.decal, colors: [
          Theme.of(context).primaryColor.withOpacity(0.6),
          Theme.of(context).primaryColor.withOpacity(0.4),
          Theme.of(context).primaryColor.withOpacity(0.1),
        ]));
  }
}
