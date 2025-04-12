import 'package:baltra/core/utils/sessionController.dart';
import 'package:baltra/core/utils/sessionExpirationMixin.dart';
import 'package:baltra/features/authetication/controller/profileController.dart';
import 'package:baltra/features/authetication/presentation/pages/changepassword.dart';
import 'package:baltra/features/authetication/presentation/pages/editProfile.dart';
import 'package:baltra/features/authetication/presentation/pages/loginPage.dart';
import 'package:baltra/features/products/presentation/widgets/appWithSvg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Add this import

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SessionManager {
  final ProfileController controller = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    checkSession(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        } else if (controller.userData.value == null) {
          return const Center(child: Text('No data available'));
        }

        final user = controller.userData.value!;
        return SingleChildScrollView(
          child: Column(
            children: [
              const AppBarWithSVG(
                  subtitle: 'Edit your profile',
                  title: 'My Profile',
                  backbutton: false),
              const SizedBox(height: 18),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      foregroundImage: CachedNetworkImageProvider(
                        user.image_url ??
                            'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg',
                      ),
                    ),
                    Text(
                      ' ${user.firstname} ${user.lastname}', // Name
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff202D31)),
                    ),
                    Text(
                      user.email, // Email
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff202D31)),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile Details',
                            style: TextStyle(
                                fontSize: 24,
                                color: Color(0xff202d31),
                                fontWeight: FontWeight.w500),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfile(
                                        data: user,
                                      )));
                            },
                            child: Container(
                              height: 35,
                              width: 95,
                              color: const Color(0xff202D31),
                              padding: const EdgeInsets.all(8),
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ProfileDetailCard(
                      detail: user.email, // Email
                      title: 'Email',
                    ),
                    ProfileDetailCard(
                      detail: "${user.firstname} ${user.lastname}", // Name
                      title: 'Name',
                    ),
                    ProfileDetailCard(
                      detail: user.contact.toString(), // Phone
                      title: 'Phone',
                    ),
                    // Add the Change Password GestureDetector here
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordPage(
                              phone: 9861490173,
                            ),
                          ),
                        );
                      },
                      child: const ProfileDetailCard(
                        detail: "Password",
                        title: 'Change Password',
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Logout from this account',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1a1a1a)),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                'Logout',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              content: const Text(
                                  'Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'No',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                    final sessionController =
                                    Get.find<SessionController>();
                                    final profileController =
                                    Get.find<ProfileController>();

                                    // Clear session and user data
                                    await sessionController.setLoggedOut();
                                    await prefs.clear();

                                    // Reset ProfileController's userData
                                    profileController.userData.value = null;

                                    // Redirect to login page
                                    Get.offAll(() => const Loginpage());
                                  },
                                  child: const Text(
                                    'Yes',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 35,
                        width: 95,
                        decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xff000C22))),
                        padding: const EdgeInsets.all(8),
                        child: const Center(
                          child: Text(
                            'Logout',
                            style: TextStyle(
                                color: Color(0xff000C22),
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ProfileDetailCard extends StatelessWidget {
  const ProfileDetailCard({
    super.key,
    required this.title,
    required this.detail,
  });

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 15,
              color: Color(0xff4F4F4F),
              fontWeight: FontWeight.w500),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffd7d7d7)),
            borderRadius: BorderRadius.circular(5),
          ),
          margin: const EdgeInsets.only(bottom: 15, top: 10),
          height: 50,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              detail,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}