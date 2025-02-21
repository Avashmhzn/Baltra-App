import 'dart:async';
import 'dart:developer';
import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/controller/reviewController.dart';
import 'package:baltra/features/products/models/product.dart';
import 'package:baltra/features/products/models/subcategoryProduct.dart';
import 'package:baltra/features/products/presentation/screens/review_section.dart';
import 'package:baltra/features/products/presentation/widgets/function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:html/parser.dart';

class ProductDetailPage extends StatefulWidget {
  ProductDetailPage({super.key, this.product, this.relatedProducts});
  Product? product;
  final List<Subcategoryproduct>? relatedProducts;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProductController controller = Get.find();
  final ReviewController reviewController = Get.put(ReviewController());
  VideoPlayerController? _videoPlayerController;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;
  bool _showPlayPauseButton = false;
  Timer? _hidePlayPauseTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initializeVideo();
    _tabController = TabController(length: 3, vsync: this);

    // Log to see which product is initially loaded
    print("NEW ProductDetailPage initState: product id = ${widget.product?.id}");

    // If a product is provided (or in the controller), fetch its reviews & related products.
    final initialProductId = widget.product?.id ?? controller.productDetails.value?.id;
    if (initialProductId != null) {
      reviewController.fetchReviewsAndRatings(initialProductId);
      if (widget.relatedProducts == null || widget.relatedProducts!.isEmpty) {
        controller.fetchRelatedProducts(initialProductId);
      } else {
        print("Using passed related products: ${widget.relatedProducts}");
      }
    }
  }

  void navigateToProductDetails(int productId) async {
    controller.isLoading(true);
    await controller.fetchSelectedProduct(productId);
    reviewController.fetchReviewsAndRatings(productId);

    await controller.fetchRelatedProducts(productId);

    controller.isLoading(false);

    if (controller.productDetails.value != null) {
      _scrollController.jumpTo(0);
      Get.to(() => ProductDetailPage(
        key: UniqueKey(),
        product: controller.productDetails.value!,
        relatedProducts: controller.relatedProductsList,
      ));
    } else {
      Get.snackbar("Error", "Failed to load product details",
          snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  void initializeVideo() {
    String? productVideoUrl = widget.product?.product_video;
    if (productVideoUrl != null && productVideoUrl.isNotEmpty) {
      _videoPlayerController = VideoPlayerController.network(productVideoUrl)
        ..addListener(() {
          if (_videoPlayerController!.value.hasError) {
            log("Error playing video: ${_videoPlayerController!.value.errorDescription}");
          }
          if (_videoPlayerController!.value.isInitialized) {
            setState(() {
              _isVideoInitialized = true;
            });
          }
        })
        ..initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
            _videoPlayerController!.setLooping(true);
            log("Video initialized successfully");
          });
        }).catchError((error) {
          log("Error initializing video: $error");
        });
    } else {
      log("No video URL available");
    }
  }

  void _togglePlayPause() {
    if (_videoPlayerController == null) return;
    setState(() {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
        _isPlaying = false;
      } else {
        _videoPlayerController!.play();
        _isPlaying = true;
      }
      _showPlayPauseButton = true;
      _startHidePlayPauseTimer();
    });
  }

  void _startHidePlayPauseTimer() {
    _hidePlayPauseTimer?.cancel();
    _hidePlayPauseTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _showPlayPauseButton = false;
      });
    });
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // Auto-play/pause the video based on visibility
    if (info.visibleFraction > 0.5) {
      if (!_isPlaying) {
        _videoPlayerController!.play();
        setState(() {
          _isPlaying = true;
        });
      }
    } else {
      if (_isPlaying) {
        _videoPlayerController!.pause();
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  String removeListContent(String htmlText) {
    // Removes <ul> items from HTML and returns the cleaned text
    var document = parse(htmlText);
    document.body?.getElementsByTagName("ul").forEach((element) {
      element.remove();
    });
    return document.body?.text.trim() ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoPlayerController?.dispose();
    _hidePlayPauseTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, String>> parseDimensionsText(String text) {
    final List<Map<String, String>> items = [];
    final cleanedText = text.replaceAll('&nbsp;', ' ');
    final regex = RegExp(r'(\w+): ([^ ]+ [^ ]+ \(.*?\))\s+([^\.]+)\.');
    for (final match in regex.allMatches(cleanedText)) {
      items.add({
        'label': match.group(1) ?? 'Label',
        'spec': match.group(2) ?? 'Spec',
        'description': match.group(3) ?? 'Description',
      });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Obx(() {
              // If there's no product in the controller, fallback to the widget's product
              final product = controller.productDetails.value ?? widget.product;
              if (product == null) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filter out the currently displayed product from related list
              final displayRelatedProducts = controller.relatedProductsList;
              print("Total Related Products: ${displayRelatedProducts.length}");
              for (var product in displayRelatedProducts) {
                print("Related Product ID: ${product.id}, Name: ${product.name}");
              }



              // Parse any dimension text, specification text, etc.
              List<Map<String, String>> items = parseDimensionsText(product.sizing ?? '');
              List<String> specifications = extractSpecifications(product.specification ?? '');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),

                  // Main Image
                  Container(
                    child: Image.network(
                      product.main_image ?? '',
                      height: 300,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/pp.png',
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Image Gallery
                  Container(
                    height: 80,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: product.images?.length ?? 0,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Image.network(
                            product.images?[index].image_url ?? '',
                            fit: BoxFit.contain,
                            height: 75,
                            width: 75,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/pp.png',
                              height: 75,
                              width: 75,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Product Name and Model
                  Text(
                    product.name ?? 'Product Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff202D31),
                    ),
                  ),
                  Text(
                    product.model_num ?? 'Model Number',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Color(0xff77777E),
                    ),
                  ),

                  // Divider
                  Container(
                    margin: EdgeInsets.only(
                      top: 12,
                      bottom: 12,
                      right: MediaQuery.of(context).size.width * 0.19,
                    ),
                    height: 1.5,
                    width: double.infinity,
                    color: const Color(0xffbbbbbb),
                  ),

                  // Color Options
                  const Text(
                    'Color',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff4d5159),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: (product.color_styles ?? []).map((hexColor) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: hexToColor(hexColor),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),

                  // Pricing
                  const Text(
                    'Pricing',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff4d5159),
                    ),
                  ),
                  Text(
                    'MRP. ${product.price?.toString() ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff4d5159),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                  ),

                  // Tab Bar
                  PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: TabBar(
                      dividerColor: Colors.white,
                      controller: _tabController,
                      isScrollable: false,
                      indicatorColor: Colors.black,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorWeight: 2.5,
                      labelColor: const Color(0xff201E1E),
                      unselectedLabelColor: const Color(0xff797474),
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff201E1E),
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff797474),
                      ),
                      tabs: const [
                        Tab(text: 'DESCRIPTION'),
                        Tab(text: 'SIZING'),
                        Tab(text: 'USAGE'),
                      ],
                    ),
                  ),
                  Container(
                    height: 1200,
                    padding: const EdgeInsets.only(top: 10),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Description Tab
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            const Text(
                              'Product Specifications',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: specifications.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    const Text(
                                      '• ',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Expanded(
                                      child: Text(
                                        specifications[index],
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: product.specification_images?.take(3).length ?? 0,
                              itemBuilder: (context, index) {
                                if (index >= (product.specification_images?.length ?? 0)) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Image.network(
                                    product.specification_images?[index].image_url ?? '',
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                      'assets/images/pp.png',
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        // Sizing Tab
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.usage != null && product.usage!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    removeListContent(product.usage!),
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              if (specifications.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: specifications.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '• ',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Expanded(
                                            child: Text(
                                              specifications[index],
                                              style: const TextStyle(fontSize: 14),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),

                        // Usage Tab
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: product.sizing_images?.length ?? 0,
                              itemBuilder: (context, index) {
                                double screenWidth = MediaQuery.of(context).size.width;
                                double screenHeight = MediaQuery.of(context).size.height;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Image.network(
                                    product.sizing_images?[index].image_url ?? '',
                                    width: screenWidth * 0.95,
                                    height: screenHeight * 0.3,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                      'assets/images/pp.png',
                                      width: screenWidth * 0.95,
                                      height: screenHeight * 0.3,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                removeListContent(product.usage ?? ''),
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            (product.usage_images?.take(3).length ?? 0) == 1
                                ? Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: product.usage_images?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Image.network(
                                        product.usage_images?[index].image_url ?? '',
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => Image.asset(
                                          'assets/images/pp.png',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                                : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: product.usage_images?.length ?? 0,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Image.network(
                                    product.usage_images?[index].image_url ?? '',
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                      'assets/images/pp.png',
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Additional images / icons
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Image(
                      image: NetworkImage(product.warranty_icon ?? ''),
                      height: 300,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/pp.png',
                        height: 430,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Image(
                      image: NetworkImage(product.galleryimageone ?? ''),
                      height: 430,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/pp.png',
                        height: 430,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Image(
                      image: NetworkImage(product.galleryimagetwo ?? ''),
                      height: 430,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/pp.png',
                        height: 430,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Video Player
                  VisibilityDetector(
                    key: const Key('video-player'),
                    onVisibilityChanged: _onVisibilityChanged,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showPlayPauseButton = true;
                          _startHidePlayPauseTimer();
                        });
                      },
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                        width: double.infinity,
                        child: _isVideoInitialized
                            ? Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: _videoPlayerController!.value.aspectRatio,
                              child: VideoPlayer(_videoPlayerController!),
                            ),
                            if (_showPlayPauseButton)
                              IconButton(
                                onPressed: _togglePlayPause,
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 50,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                          ],
                        )
                            : const Center(
                          child: Text(
                            'No video available or loading...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Rating and Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reviews Section
                  Obx(() {
                    if (reviewController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ReviewsSection(
                      reviewController: reviewController,
                      productId: product.id ?? 0,
                    );
                  }),

                  // Related Products Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Related Products',
                        style: TextStyle(
                          color: Color(0xff101623),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (displayRelatedProducts.isEmpty) {
                          return const Center(child: Text("No related products available"));
                        }
                        return Container(
                          height: 400,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.3
                            ),
                            itemCount: displayRelatedProducts.length,
                            itemBuilder: (context, index) {
                              final relatedProduct = displayRelatedProducts[index];
                              return GestureDetector(
                                  onTap: () => navigateToProductDetails(relatedProduct.id ?? 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            blurRadius: 5,
                                            spreadRadius: 2
                                        )
                                      ],
                                    ),
                                    child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                        child: Image.network(
                                          relatedProduct.main_image_url ?? '',
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Image.asset(
                                            'assets/images/pp.png',
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min, // Let the text take only the space it needs.
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Model Name: ${relatedProduct.name ?? 'No Name'}',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Model No: ${relatedProduct.model_no ?? 'N/A'}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Sub Category: ${relatedProduct.sub_category ?? 'N/A'}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Warranty: ${relatedProduct.warranty ?? 'N/A'}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Price: Rs. ${relatedProduct.price ?? 'N/A'}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Power: ${relatedProduct.power ?? 'N/A'}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                              )
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  )
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
