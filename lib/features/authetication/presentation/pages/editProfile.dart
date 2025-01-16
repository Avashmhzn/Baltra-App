import 'package:baltra/features/authetication/models/user.dart';
import 'package:baltra/features/authetication/presentation/pages/profile_page.dart';
import 'package:baltra/features/authetication/presentation/pages/resetPassowrd.dart';
import 'package:baltra/features/authetication/presentation/widgets/profileText.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';

class Editprofile extends StatelessWidget {
  const Editprofile({super.key, required this.data});

  final User data;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            const AppBarWithSVG(
                subtitle: 'Edit your profile',
                title: 'My Profile',
                backbutton: true),
            const SizedBox(
              height: 18,
            ),
            CircleAvatar(
              radius: 60,
              foregroundImage: NetworkImage(data.image_url ??
                  'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg'),
            ),
            const SizedBox(
              height: 18,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  ProfileTextField(
                    initialValue: "${data.firstname} ${data.lastname}",
                    title: "Full Name",
                  ),
                  ProfileTextField(
                    initialValue: data.email,
                    title: 'Email',
                  ),
                  ProfileTextField(
                    initialValue: '${data.contact}',
                    readonly: true,
                    title: "Phone",
                  ),
                  // Resetpassword
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Resetpassword(
                              phone: 9861490173,
                            ),
                          ));
                    },
                    child: const ProfileDetailCard(
                      detail: "Password",
                      title: 'Change Password',
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      child: Container(
                        height: 35,
                        width: 95,
                        color: const Color(0xff202D31),
                        padding: const EdgeInsets.all(8),
                        child: const Text(
                          'Save Profile',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 64,
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
