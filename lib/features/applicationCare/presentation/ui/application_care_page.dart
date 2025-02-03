import 'package:baltra/core/utils/sessionExpirationMixin.dart';
import 'package:baltra/features/applicationCare/presentation/ui/myProduct_page.dart';
import 'package:baltra/features/applicationCare/presentation/ui/product_maintainance_page.dart';
import 'package:baltra/features/applicationCare/presentation/ui/product_tracking_page.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationCarePage extends StatefulWidget {
  const ApplicationCarePage({super.key});

  @override
  State<ApplicationCarePage> createState() => _ApplicationCarePageState();
}

Future<String> _getNameFromSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('name');
  return 'Hello, $name' ?? 'Hello, Guest';
}

class _ApplicationCarePageState extends State<ApplicationCarePage>
    with SessionManager {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
            body: Stack(
          children: [
            Positioned(top: 0, left: 0, right: 0, child: _buildAppBar()),
            Positioned(
              top: _selectedIndex == 2 ? 214 : 144,
              left: 0,
              right: 0,
              bottom: 0,
              child: DefaultTabController(
                length: 2,
                child: Scaffold(
                  appBar: AppBar(
                    flexibleSpace: TabBar(
                      // padding: EdgeInsets.all(10),
                      tabs: const [
                        Tab(
                          text: 'My Products',
                        ),
                        Tab(
                          text: 'Tracking',
                        ),
                        // Tab(
                        //   text: 'Reward Points',
                        // ),
                      ],
                      indicator: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      onTap: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      // indicatorColor: Theme.of(context).primaryColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      labelStyle: const TextStyle(
                        overflow: TextOverflow.clip,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  body: const TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      MyProductPage(),
                      ProductMaintainancePage(),
                      // RewardsPage(),
                      // Text('History'),
                    ],
                  ),
                ),
              ),
            )
          ],
        )),
      ),
    );
  }

  Widget _buildAppBar() {
    switch (_selectedIndex) {
      case 0:
        return FutureBuilder<String>(
          future: _getNameFromSharedPrefs(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final name = snapshot.data!;
              return AppBarWithSVG(
                title: name ?? 'Hello Guest',
                subtitle: 'Check out your Baltra products you own!',
                backbutton: false,
              );
            } else {
              return Container();
            }
          },
        );
      case 1:
        return const AppBarWithSVG(
          backbutton: false,
          title: 'Track your Products',
          subtitle: 'Know the status of your products.',
        );
      case 2:
        return Stack(
          children: [
            Container(
              height: 214,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      'assets/images/reward.png',
                    ),
                    fit: BoxFit.fill),
                gradient: LinearGradient(
                    colors: [Color(0xffE91C1C), Color(0xff831010)]),
              ),
            ),
            Positioned(
                top: 20,
                right: 60,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.reply,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                  ),
                )),
            const Positioned(
                bottom: 0,
                left: 10,
                child: Image(
                  image: AssetImage('assets/images/pp.png'),
                  height: 115,
                  width: 115,
                )),
            const Positioned(
                top: 60,
                right: 60,
                child: Text(
                  'Redeem history',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                )),
            Positioned(
              top: 10,
              left: 10,
              child: RichText(
                text: const TextSpan(children: [
                  TextSpan(
                      text: "Welcome to",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                      )),
                  TextSpan(
                      text: '\nBALTRA\'S\nLOYALTY PAGE',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                      )),
                ]),
              ),
            ),
            Positioned(
                top: 100,
                right: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/medal.png',
                      height: 36,
                      width: 36,
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '500 Points',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                        Text(
                          'Available Points',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ],
                    )
                  ],
                )),
            const Positioned(
              top: 160,
              right: 50,
              child: Text(
                'Redeem these points to extend\nyour warranty on your products ',
                softWrap: true,
                maxLines: 2,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w200,
                    color: Colors.white),
              ),
            ),
          ],
        );
      default:
        return AppBar(title: const Text('Default AppBar'));
    }
  }
}
