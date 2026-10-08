import 'dart:developer';
import 'package:baltra/core/utils/sessionExpirationMixin.dart';
import 'package:baltra/features/applicationCare/controller/myProductController.dart';
import 'package:baltra/features/applicationCare/data/productRepository.dart';
import 'package:baltra/features/applicationCare/presentation/ui/my_product_detail.dart';
import 'package:baltra/features/applicationCare/presentation/widgets/add_product_dialog.dart';
import 'package:baltra/features/authetication/presentation/pages/buttomNavbar.dart';
import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/data/productRepository.dart';
import 'package:baltra/features/products/models/product.dart';
import 'package:baltra/features/products/presentation/screens/reward_point_page.dart';
import 'package:baltra/features/products/presentation/widgets/product_detail_loading%20_page_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SessionManager {
  final ProductController productController =
      Get.put(ProductController(productRepository: ProductRepository()));

  final Myproductcontroller myProductController =
      Get.isRegistered<Myproductcontroller>()
          ? Get.find<Myproductcontroller>()
          : Get.put(
              Myproductcontroller(productRepository: MyProductRepository()));

  String name = 'Guest';
  int loyaltyPoint = 0;
  String? profileImageUrl;
  int _itemsToShow = 4;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    checkSession(context);
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      myProductController.fetchMyProduct();
      myProductController.fetchAllComplaints();
    });

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final imgUrl = prefs.getString('image_url');

    // Debug logging
    log('=== SharedPreferences Debug ===');
    log('name: ${prefs.getString('name')}');
    log('reward_points: ${prefs.getInt('reward_points')}');
    log('image_url: $imgUrl');
    log('auth_token exists: ${prefs.getString('auth_token') != null}');
    log('==============================');

    setState(() {
      name = prefs.getString('name') ?? 'Guest';
      loyaltyPoint = prefs.getInt('reward_points') ?? 0;
      profileImageUrl = imgUrl;
    });
  }

  void _loadMoreItems() {
    setState(() {
      _itemsToShow += 4;
    });
  }

  Future<void> _refreshProducts() async {
    productController.allProductsList.clear();
    await productController.fetchProducts(1);
    await myProductController.fetchMyProduct();
    await myProductController.fetchAllComplaints();
    setState(() {
      _itemsToShow = 4;
    });
    await _loadUserData();
  }

  List<Product> _getSortedProducts() {
    final products = productController.allProductsList.toList();
    products.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return products;
  }

  Future<void> _navigateToProductDetails(int productId) async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      log("Navigating to ProductDetailLoadingPage for productId: $productId");
      await Get.to(() => ProductDetailLoadingPage(productId: productId));
    } finally {
      _isNavigating = false;
    }
  }

  // ── shared helpers ──
  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Text(text,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      );

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 20, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffC81920), Color(0xff8B1014)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('$loyaltyPoint Reward Points',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          _drawerItem(Icons.home, 'Home', 0),
          _drawerItem(Icons.category, 'Products', 1),
          _drawerItem(Icons.build, 'Appliance Care', 2),
          _drawerItem(Icons.person, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int pageIndex) {
    final isSelected = pageIndex == 0; // home is always selected in HomePage
    return ListTile(
      leading:
          Icon(icon, color: isSelected ? const Color(0xffC81920) : Colors.grey),
      title: Text(label,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? const Color(0xffC81920) : Colors.black87)),
      tileColor:
          isSelected ? const Color(0xffC81920).withValues(alpha: 0.08) : null,
      onTap: () {
        Navigator.pop(context);
        if (pageIndex != 0) {
          Get.offAll(() => ButtomNavBar(pageno: pageIndex));
        }
      },
    );
  }

  // ════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          drawer: _buildDrawer(context),
          body: Builder(builder: (scaffoldContext) {
            return RefreshIndicator(
              onRefresh: _refreshProducts,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: 70.0 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingHeader(scaffoldContext),
                    _buildRewardsSection(),
                    _buildWhatCanYouDoSection(),
                    _buildGettingStartedSection(),
                    _buildMyAppliancesSection(),
                    _buildBottomPromotion(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // 1. top bar + greeting
  Widget _buildGreetingHeader(BuildContext scaffoldContext) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.menu,
                      color: Color(0xffC81920), size: 28),
                  onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                ),
                const SizedBox(width: 6),
                Image.asset('assets/images/logo_red.png',
                    width: 126, height: 32),
              ]),
              // Stack(
              //   clipBehavior: Clip.none,
              //   children: [
              //     const Icon(Icons.notifications_none_rounded, size: 31),
              //     Positioned(
              //       right: -5,
              //       top: -7,
              //       child: Container(
              //         padding: const EdgeInsets.all(4),
              //         decoration: const BoxDecoration(
              //             color: Color(0xffC81920), shape: BoxShape.circle),
              //         child: const Text('3',
              //             style: TextStyle(
              //                 color: Colors.white,
              //                 fontSize: 10,
              //                 fontWeight: FontWeight.bold)),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.black),
                children: [
                  const TextSpan(text: 'Hello, '),
                  TextSpan(
                      text: '$name!',
                      style: const TextStyle(color: Color(0xffC81920))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('Glad to have you with us.',
                  style: TextStyle(fontSize: 16, color: Color(0xff555555)))),
        ],
      ),
    );
  }

  // 2. rewards card + illustration
  Widget _buildRewardsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 46,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: _cardDecoration(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/medal.png',
                          width: 52, height: 52),
                      const SizedBox(height: 8),
                      const Text('Rewards Points',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xff555555))),
                      Text('$loyaltyPoint',
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Color(0xffC81920))),
                      const SizedBox(height: 8),
                      const Text("You're doing great!",
                          style: TextStyle(
                              fontSize: 13, color: Color(0xff555555))),
                    ]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 54,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset('assets/images/female_applience.jpeg',
                    fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. "What can you do" icons
  Widget _buildWhatCanYouDoSection() {
    final items = [
      {'icon': Icons.add_box_outlined, 'label': 'Add & Register\nProducts'},
      {'icon': Icons.shield_outlined, 'label': 'Extend\nWarranty'},
      {'icon': Icons.headset_mic_outlined, 'label': 'Register\nComplaint'},
      {'icon': Icons.search, 'label': 'Track\nComplaints'},
      {'icon': Icons.card_giftcard, 'label': 'Earn Reward\nPoints'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('What can you do with Baltra App?'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: _cardDecoration(),
          child: Row(
            children: items
                .map((item) => Expanded(
                        child: Column(children: [
                      Icon(item['icon'] as IconData,
                          size: 31, color: const Color(0xffC81920)),
                      const SizedBox(height: 10),
                      Text(item['label'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, height: 1.35)),
                    ])))
                .toList(),
          ),
        ),
      ],
    );
  }

  // 4. "Getting Started" step cards
  Widget _buildGettingStartedSection() {
    final steps = [
      {'title': 'Buy a Baltra\nProduct', 'image': 'assets/images/loyalty1.png'},
      {'title': 'Scan the\nQR Code', 'image': 'assets/images/loyalty2.png'},
      {'title': 'Add Details\n& Submit', 'image': 'assets/images/loyalty3.png'},
      {'title': 'View in\nMy Products', 'image': 'assets/images/loyalty2.png'},
      {
        'title': 'Register & Track\nComplaints',
        'image': 'assets/images/loyalty3.png'
      },
      {'title': 'Extend\nWarranty', 'image': 'assets/images/loyalty1.png'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Getting Started – It's Easy!"),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: steps.length,
            itemBuilder: (context, i) => Container(
              margin: EdgeInsets.only(
                  left: i == 0 ? 20 : 8, right: i == steps.length - 1 ? 20 : 0),
              width: 120,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xffC81920),
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)))),
                  const SizedBox(height: 7),
                  Expanded(
                      child: Image.asset(steps[i]['image'] as String,
                          fit: BoxFit.contain)),
                  const SizedBox(height: 6),
                  Text(steps[i]['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 1.25)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 5. "My Appliances" horizontal scroll
  Widget _buildMyAppliancesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('My Appliances'),
        SizedBox(
          height: 190,
          child: Obx(() => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: myProductController.myProducts.length + 1,
                itemBuilder: (context, index) {
                  if (index < myProductController.myProducts.length) {
                    final product = myProductController.myProducts[index];
                    return InkWell(
                      onTap: () {
                        Get.to(
                            () => MyProductDetailPage(productId: product.id));
                      },
                      child: Container(
                        width: 140,
                        margin: EdgeInsets.only(left: index == 0 ? 20 : 8),
                        padding: const EdgeInsets.all(12),
                        decoration: _cardDecoration().copyWith(
                          border: Border.all(color: const Color(0xffEEEEEE)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: product.product_image != null &&
                                      product.product_image!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        product.product_image!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.kitchen,
                                                color: Colors.grey),
                                      ),
                                    )
                                  : const Icon(Icons.kitchen,
                                      color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              product.model_name ?? "Appliance",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${product.warranty_expiry ?? "—"} Warranty",
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  // "Add New Product" dashed card
                  return GestureDetector(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const QRScannerScreen();
                        },
                      );
                      myProductController.fetchMyProduct();
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(left: 8, right: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CustomPaint(
                        painter: _DashedBorderPainter(
                            color: Colors.grey.shade400, radius: 16),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline,
                                  color: Colors.grey.shade400, size: 34),
                              const SizedBox(height: 8),
                              Text("Add New\nProduct",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )),
        ),
      ],
    );
  }

  // 6. bottom promo banner
  Widget _buildBottomPromotion() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffD32F2F), Color(0xff8B1014)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: 100,
            bottom: -15,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.card_giftcard,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("More Products. More Rewards.",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.2)),
                      const SizedBox(height: 6),
                      const Text(
                          "Expand more products, extend warranty\n& use our services to earn exciting rewards!",
                          style: TextStyle(
                              color: Colors.white, fontSize: 10, height: 1.3)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          final products = myProductController.myProducts;
                          if (products.isNotEmpty) {
                            Get.to(() => RewardsPage(
                                  stockId: products.first.id,
                                  duration: 0,
                                  price: 0.0,
                                ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please register a product first to view rewards'),
                                backgroundColor: Color(0xffC81920),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xffC81920),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Explore Rewards",
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Medal/coins icon
                Image.asset('assets/images/medal.png', width: 56, height: 56),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// dashed border painter for "Add New Product" card
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  static const double _strokeWidth = 1.5;
  static const double _dashWidth = 6;
  static const double _dashSpace = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
          RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));

    final metrics = path.computeMetrics().first;
    double distance = 0;
    while (distance < metrics.length) {
      final next = distance + _dashWidth;
      canvas.drawPath(
          metrics.extractPath(distance, next.clamp(0, metrics.length)), paint);
      distance = next + _dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      color != old.color || radius != old.radius;
}
