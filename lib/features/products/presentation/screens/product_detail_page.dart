import 'dart:async';
import 'dart:developer';
import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/applicationCare/presentation/widgets/myproduct_details_skeletion.dart';
import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/controller/reviewController.dart';
import 'package:baltra/features/products/models/product.dart';
import 'package:baltra/features/products/models/subcategoryProduct.dart';
import 'package:baltra/features/products/presentation/screens/review_section.dart';
import 'package:baltra/features/products/presentation/widgets/function.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_rich_text/easy_rich_text.dart';
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
  String? currentMainImage;
  int _selectedThumbnailIndex = 0;
  List<String> thumbnailUrls = [];
  int? _lastProductId;
  int _currentTabIndex = 0;
  int _selectedColorIndex = 0; // Still needed to track the selected color for the tick mark

  @override
  void initState() {
    super.initState();
    currentMainImage = widget.product?.main_image?.isNotEmpty == true
        ? widget.product!.main_image
        : '';
    final product = widget.product ?? controller.productDetails.value;
    if (product != null) {
      _lastProductId = product.id;
      thumbnailUrls.clear();
      if (product.main_image != null && product.main_image!.isNotEmpty) {
        thumbnailUrls.add(product.main_image!);
      }
      if (product.images != null) {
        for (var img in product.images!) {
          if (img.image_url != null &&
              img.image_url!.isNotEmpty &&
              img.image_url != product.main_image) {
            thumbnailUrls.add(img.image_url!);
          }
        }
      }
      print("Initial Thumbnail URLs in initState: $thumbnailUrls");
    }

    initializeVideo();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });

    final initialProductId =
        widget.product?.id ?? controller.productDetails.value?.id;
    if (initialProductId != null) {
      reviewController.fetchReviewsAndRatings(initialProductId);
      controller.relatedProductsList.clear();
      if (widget.relatedProducts == null || widget.relatedProducts!.isEmpty) {
        controller.fetchRelatedProducts(initialProductId);
      }
    }
  }

  void navigateToProductDetails(int productId) async {
    controller.productDetails.value = null;
    controller.isLoading(true);
    await controller.fetchSelectedProduct(productId);
    reviewController.fetchReviewsAndRatings(productId);
    await controller.fetchRelatedProducts(productId);
    controller.isLoading(false);
    if (controller.productDetails.value != null) {
      _scrollController.jumpTo(0);
      Get.off(() => ProductDetailPage(
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
    print("Attempting to initialize video with URL: $productVideoUrl");

    if (productVideoUrl != null && productVideoUrl.isNotEmpty) {
      try {
        final Uri? uri = Uri.tryParse(productVideoUrl);
        if (uri == null) {
          print("Invalid video URL format");
          setState(() => _isVideoInitialized = false);
          return;
        }

        _videoPlayerController?.dispose();
        _videoPlayerController = VideoPlayerController.network(
          productVideoUrl,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          httpHeaders: {
            'Access-Control-Allow-Origin': '*',
            'Accept': '*/*',
            'Connection': 'keep-alive',
          },
        );

        _videoPlayerController!.addListener(() {
          if (!mounted) return;

          final player = _videoPlayerController!;
          if (player.value.hasError) {
            print("Video player error: ${player.value.errorDescription}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      "Error playing video: ${player.value.errorDescription}")),
            );
          }

          if (_isPlaying != player.value.isPlaying) {
            setState(() => _isPlaying = player.value.isPlaying);
          }
        });

        print("Initializing video player...");
        _videoPlayerController!.initialize().then((_) {
          print("Video player initialized successfully");
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
              _videoPlayerController!.setLooping(true);
              _isPlaying = false;
              _showPlayPauseButton = true;
            });
          }
        }).catchError((error) {
          print("Video initialization error: $error");
          if (mounted) {
            setState(() => _isVideoInitialized = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading video: ${error.toString()}'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      } catch (e) {
        print("Exception during video controller creation: $e");
        if (mounted) {
          setState(() => _isVideoInitialized = false);
        }
      }
    } else {
      print("No video URL provided");
      setState(() => _isVideoInitialized = false);
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
    if (_videoPlayerController == null) return;

    if (info.visibleFraction > 0.5) {
      if (!_isPlaying && mounted) {
        _videoPlayerController!.play();
        setState(() {
          _isPlaying = true;
        });
      }
    } else {
      if (_isPlaying && mounted) {
        _videoPlayerController!.pause();
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  String removeListContent(String htmlText) {
    var document = parse(htmlText);
    document.body?.getElementsByTagName("ul").forEach((element) {
      element.remove();
    });
    return document.body?.text.trim() ?? '';
  }

  List<Map<String, String>> parseDimensionsText(String text) {
    final List<Map<String, String>> items = [];
    final cleanedText = text.replaceAll(' ', ' ');
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
  void dispose() {
    _tabController.dispose();
    _videoPlayerController?.dispose();
    _hidePlayPauseTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildDescriptionTab(
      List<String> specifications, List<Map<String, String>> specImages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        for (var spec in specifications)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '• ',
                style: TextStyle(fontSize: 18),
              ),
              Expanded(
                child: Text(
                  spec,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        for (var i = 0; i < specImages.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CachedNetworkImage(
              imageUrl: specImages[i]['image_url'] ?? '',
              width: double.infinity,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: 120,
                color: Colors.grey[300],
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/pp.png',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSizingTab(
      String sizing, List<Map<String, String>> sizingImages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sizing",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: EasyRichText(
            removeListContent(sizing),
            defaultStyle: const TextStyle(fontSize: 14),
            patternList: [
              EasyRichTextPattern(
                targetString: r'\bimportant\b',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),
              EasyRichTextPattern(
                targetString: r'\d+',
                style: const TextStyle(color: Colors.black),
              ),
            ],
            textAlign: TextAlign.justify,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Center(
            child: Text(
              "Box Dimension: ",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        for (var i = 0; i < sizingImages.length; i++)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CachedNetworkImage(
              imageUrl: sizingImages[i]['image_url'] ?? '',
              width: MediaQuery.of(context).size.width * 0.95,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: 120,
                color: Colors.grey[300],
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/pp.png',
                width: MediaQuery.of(context).size.width * 0.95,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUsageTab(
      String usage,
      List<String> usageItems,
      List<Map<String, String>> extraItems,
      List<Map<String, String>> usageImages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Usage",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
        if (usage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Text(
              removeListContent(usage),
              style: const TextStyle(fontSize: 14, height: 1.0),
              textAlign: TextAlign.justify,
            ),
          ),
        if (usageItems.isNotEmpty)
          for (var i = 0; i < usageItems.length; i++)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 2.0,
              ).copyWith(top: i == 0 ? 0.0 : 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontSize: 18, height: 1.0),
                  ),
                  Expanded(
                    child: Text(
                      usageItems[i],
                      style: const TextStyle(fontSize: 14, height: 1.0),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
        if (extraItems.isNotEmpty)
          for (var map in extraItems)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontSize: 18, height: 1.0),
                  ),
                  Expanded(
                    child: Text(
                      map.values.first,
                      style: const TextStyle(fontSize: 14, height: 1.0),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
        if (usageImages.isNotEmpty)
          for (var i = 0; i < usageImages.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CachedNetworkImage(
                imageUrl: usageImages[i]['image_url'] ?? '',
                width: double.infinity,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  width: double.infinity,
                  height: 120,
                  color: Colors.grey[300],
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/pp.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
      ],
    );
  }

  Widget buildTabSection(
      BuildContext context, {
        required TabController tabController,
        required List<String> specifications,
        required List<Map<String, String>> specImages,
        required String sizing,
        required List<Map<String, String>> sizingImages,
        required String usage,
        required List<String> usageItems,
        required List<Map<String, String>> extraItems,
        required List<Map<String, String>> usageImages,
      }) {
    final List<String> tabTitles = ['DESCRIPTION', 'SIZING', 'USAGE'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(tabTitles.length, (index) {
              final isSelected = _currentTabIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTabIndex = index;
                    tabController.index = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tabTitles[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : const Color(0xFF757575),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          height: 2.0,
                          width: tabTitles[index].length * 8.0,
                          color: Colors.black,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: _currentTabIndex == 0
              ? _buildDescriptionTab(specifications, specImages)
              : _currentTabIndex == 1
              ? _buildSizingTab(sizing, sizingImages)
              : _buildUsageTab(usage, usageItems, extraItems, usageImages),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final product = controller.productDetails.value ?? widget.product;
          if (controller.isLoading.value || product == null) {
            return const ProductDetailSkeleton();
          }
          if (product.id != _lastProductId) {
            _lastProductId = product.id;
            currentMainImage = product.main_image?.isNotEmpty == true
                ? product.main_image
                : '';
            _selectedThumbnailIndex = 0;
            thumbnailUrls.clear();
            if (product.main_image != null && product.main_image!.isNotEmpty) {
              thumbnailUrls.add(product.main_image!);
            }
            if (product.images != null) {
              for (var img in product.images!) {
                if (img.image_url != null &&
                    img.image_url!.isNotEmpty &&
                    img.image_url != product.main_image) {
                  thumbnailUrls.add(img.image_url!);
                }
              }
            }
            print("Thumbnail URLs updated due to product change: $thumbnailUrls");
          }

          final displayRelatedProducts = controller.relatedProductsList;
          List<Map<String, String>> items =
          parseDimensionsText(product.sizing ?? '');
          List<String> specifications =
          extractSpecifications(product.specification ?? '');
          List<String> usageItems = extractUsageItems(product.usage ?? '');
          List<Map<String, String>> specImages = [];
          if (product.specification_images != null) {
            for (var img in product.specification_images!.take(3)) {
              specImages.add({'image_url': img.image_url ?? ''});
            }
          }
          List<Map<String, String>> sizingImages = [];
          if (product.sizing_images != null) {
            for (var img in product.sizing_images!) {
              sizingImages.add({'image_url': img.image_url ?? ''});
            }
          }
          List<Map<String, String>> usageImageList = [];
          if (product.usage_images != null) {
            for (var img in product.usage_images!) {
              usageImageList.add({'image_url': img.image_url ?? ''});
            }
          }
          return SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 8.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          product.category?['category_name'] ?? 'Category',
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                        ),
                        Text(
                          product.sub_category?['sub_category_name'] ?? 'Subcategory',
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.0),
                          child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                        ),
                        Text(
                          product.name ?? 'Product',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: currentMainImage == null || currentMainImage!.isEmpty
                              ? Image.asset(
                            'assets/images/pp.png',
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                              : CachedNetworkImage( // Removed ColorFiltered widget
                            imageUrl: currentMainImage!,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.fitHeight,
                            placeholder: (context, url) => Container(
                              height: 300,
                              width: double.infinity,
                              color: Colors.grey[300],
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/pp.png',
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (product.warranty_icon != null && product.warranty_icon!.isNotEmpty)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: CachedNetworkImage(
                              imageUrl: product.warranty_icon ?? '',
                              height: 50,
                              width: 50,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Container(
                                height: 50,
                                width: 50,
                                color: Colors.grey[300],
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/pp.png',
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    height: 80,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: thumbnailUrls.isEmpty
                        ? const Center(child: Text("No images available"))
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: thumbnailUrls.length > 0 ? thumbnailUrls.length - 1 : 0,
                      itemBuilder: (context, index) {
                        final actualIndex = index + 1;
                        final imageUrl = thumbnailUrls[actualIndex];
                        final isSelected = _selectedThumbnailIndex == actualIndex;
                        return GestureDetector(
                          onTap: () {
                            if (imageUrl.isNotEmpty && currentMainImage != null && currentMainImage!.isNotEmpty) {
                              setState(() {
                                final previousMainImage = currentMainImage!;
                                currentMainImage = imageUrl;
                                thumbnailUrls[actualIndex] = previousMainImage;
                                _selectedThumbnailIndex = actualIndex;
                              });
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey,
                                width: isSelected ? 2 : 1,
                              ),
                              color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              height: 75,
                              width: 75,
                              placeholder: (context, url) => Container(
                                height: 75,
                                width: 75,
                                color: Colors.grey[300],
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/pp.png',
                                height: 75,
                                width: 75,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      product.name ?? 'Product Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff202D31),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      product.model_num ?? 'Model Number',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Color(0xff77777E),
                      ),
                    ),
                  ),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff47494c),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      height: 40,
                      child: (product.color_styles == null || product.color_styles!.isEmpty)
                          ? const Text(
                        'No colors available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      )
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: product.color_styles!.length,
                        itemBuilder: (context, index) {
                          final hexColor = product.color_styles![index];
                          final isSelected = _selectedColorIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColorIndex = index;
                              });
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: hexToColor(hexColor),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Pricing',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff47494c),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'MRP. ${product.price?.toString() ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff4d5159),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child: buildTabSection(
                      context,
                      tabController: _tabController,
                      specifications: specifications,
                      specImages: specImages,
                      sizing: product.sizing ?? '',
                      sizingImages: sizingImages,
                      usage: product.usage ?? '',
                      usageItems: usageItems,
                      extraItems: items,
                      usageImages: usageImageList,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: CachedNetworkImage(
                      imageUrl: product.warranty_icon ?? '',
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) => Image.asset(
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
                    child: CachedNetworkImage(
                      imageUrl: product.galleryimageone ?? '',
                      height: 430,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 430,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) => Image.asset(
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
                    child: CachedNetworkImage(
                      imageUrl: product.galleryimagetwo ?? '',
                      height: 430,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 430,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/pp.png',
                        height: 430,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (product.product_video != null && product.product_video!.isNotEmpty)
                    VisibilityDetector(
                      key: const Key('video-player'),
                      onVisibilityChanged: _onVisibilityChanged,
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.black,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_isVideoInitialized && _videoPlayerController != null)
                                AspectRatio(
                                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                                  child: VideoPlayer(_videoPlayerController!),
                                ),
                              if (!_isVideoInitialized)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(color: Colors.white),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Loading video...',
                                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                    ),
                                  ],
                                ),
                              if (_videoPlayerController?.value.hasError ?? false)
                                Center(
                                  child: Text(
                                    'Error loading video\nTap to retry',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                  ),
                                ),
                              if (_showPlayPauseButton || !_isPlaying)
                                IconButton(
                                  onPressed: _togglePlayPause,
                                  icon: Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    size: 50,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Rating and Reviews',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    if (reviewController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    reviewController.reviews.sort((a, b) => b.reviewDate.compareTo(a.reviewDate));
                    return ReviewsSection(
                      reviewController: reviewController,
                      productId: product.id ?? 0,
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
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
                                childAspectRatio: 0.3,
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
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                          child: CachedNetworkImage(
                                            imageUrl: relatedProduct.main_image_url ?? '',
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              height: 180,
                                              width: double.infinity,
                                              color: Colors.grey[300],
                                            ),
                                            errorWidget: (context, url, error) => Image.asset(
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
                                            mainAxisSize: MainAxisSize.min,
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
                                                'Sub Category: ${relatedProduct.sub_category ?? 'N/A'}',
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Warranty: ${relatedProduct.warranty ?? 'N/A'}',
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Price: Rs. ${relatedProduct.price ?? 'N/A'}',
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Power: ${relatedProduct.power ?? 'N/A'}',
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                              ),
                                              const SizedBox(height: 6),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}