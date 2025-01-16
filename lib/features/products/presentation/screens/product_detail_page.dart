import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/controller/reviewController.dart';
import 'package:baltra/features/products/models/product.dart';
import 'package:baltra/features/products/models/subcategoryProduct.dart';
import 'package:baltra/features/products/presentation/screens/review_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailPage extends StatefulWidget {
  ProductDetailPage({super.key, this.product, this.relatedProducts});
  Product? product;
  List<Subcategoryproduct>? relatedProducts;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProductController controller = Get.find();
  final ReviewController reviewController = Get.put(ReviewController());

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this); // Initialize the TabController
    // controller.fetchRelatedProducts(widget.product!.id!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, String>> parseDimensionsText(String text) {
    final List<Map<String, String>> items = [];
    final cleanedText = text.replaceAll('&nbsp;', ' ');
    final regex = RegExp(r'(\w+): ([^ ]+ [^ ]+ \(.*?\))\s+([^\.]+)\.');

    for (final match in regex.allMatches(cleanedText)) {
      items.add({
        'label': match.group(1)!,
        'spec': match.group(2)!,
        'description': match.group(3)!,
      });
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items =
        parseDimensionsText(widget.product!.sizing!);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                )),
            Obx(
              () => controller.productDetails.value != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Image(
                            image: NetworkImage(
                              widget.product!.main_image!,
                            ),
                            height: 300,
                            width: double.infinity,
                          ),
                        ),
                        Container(
                          height: 80,
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.product!.images!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey)),
                                  child: Image.network(
                                    widget.product!.images![index].image_url!,
                                    fit: BoxFit.contain,
                                    height: 75,
                                    width: 75,
                                  ),
                                );
                              }),
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        Text(
                          widget.product!.name!,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff202D31)),
                        ),
                        Text(
                          widget.product!.model_num!,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Color(0xff77777E)),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: 12,
                              bottom: 12,
                              right: MediaQuery.of(context).size.width * 0.19),
                          height: 1.5,
                          width: double.infinity,
                          color: const Color(0xffbbbbbb),
                        ),
                        const Text(
                          'Color',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff4d5159)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:
                              widget.product!.color_styles!.map((hexColor) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.5),
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: hexToColor(hexColor),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          'Pricing',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff4d5159)),
                        ),
                        Text(
                          widget.product!.price!.toString(),
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff4d5159)),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          'Reward Point',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff4d5159)),
                        ),
                        Text(
                          widget.product!.reward_points!.toString(),
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff4d5159)),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TabBar(
                          controller: _tabController,
                          isScrollable: false,
                          dividerColor: const Color(0xff201E1E),
                          dividerHeight: 0,
                          indicatorColor: const Color(0xff201E1E),
                          indicatorSize: TabBarIndicatorSize.tab,
                          automaticIndicatorColorAdjustment: true,
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff201E1E)),
                          unselectedLabelStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff797474)),
                          tabs: const [
                            Tab(
                              text: 'DESCRIPTION',
                            ),
                            Tab(text: 'SIZING'),
                            Tab(text: 'USAGE'),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          height: 900,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product!.specification!
                                          .split('Product Specifications')[0],
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Product Specifications',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(widget.product!.specification!),
                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: widget
                                            .product!.sizing_images!.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0),
                                            child: Image.network(
                                              widget
                                                  .product!
                                                  .specification_images![index]
                                                  .image_url!,
                                              height: 180,
                                              width: double.infinity,
                                              fit: BoxFit.contain,
                                            ),
                                          );
                                        }),
                                  ]),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14.0, horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: items.map((item) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                text: '${item['label']!}: ',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                    color: Colors.black),
                                                children: [
                                                  TextSpan(
                                                    text: item['spec']!,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 16.0,
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              item['description']!,
                                              style: const TextStyle(
                                                  fontSize: 16.0),
                                            ),
                                            const SizedBox(height: 8.0),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Expanded(
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: widget
                                              .product!.sizing_images!.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Image.network(
                                                widget
                                                    .product!
                                                    .sizing_images![index]
                                                    .image_url!,
                                                height: 200,
                                                width: double.infinity,
                                                fit: BoxFit.contain,
                                              ),
                                            );
                                          }),
                                    )
                                  ],
                                ),
                              ),
                              Column(children: [
                                Text(
                                  widget.product!.usage!,
                                ),
                                const SizedBox(height: 8.0),
                                widget.product!.usage_images!.length == 1
                                    ? Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: widget.product!
                                                  .usage_images!.length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Image.network(
                                                    widget
                                                        .product!
                                                        .usage_images![index]
                                                        .image_url!,
                                                    width: double.infinity,
                                                    fit: BoxFit.contain,
                                                  ),
                                                );
                                              }),
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: widget
                                            .product!.usage_images!.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Image.network(
                                              widget
                                                  .product!
                                                  .usage_images![index]
                                                  .image_url!,
                                              width: double.infinity,
                                              fit: BoxFit.contain,
                                            ),
                                          );
                                        })
                              ]),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Image(
                          image: NetworkImage(
                            widget.product!.galleryimageone!,
                          ),
                          height: 430,
                          width: double.infinity,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          child: Image(
                            image: NetworkImage(
                              widget.product!.galleryimagetwo!,
                            ),
                            height: 430,
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          width: double.infinity,
                          child: const Text(' Youtube video Here '),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(),
            ),
            const Text(
              'Rating and Reviews',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            const SizedBox(
              height: 20,
            ),
            Obx(() {
              if (reviewController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ReviewsSection(
                reviewController: reviewController,
                productId: widget.product!.id!,
              );
            }),
            const Text(
              'Related Products',
              style: TextStyle(
                  color: Color(0xff101623),
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
                height: 290,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: widget.relatedProducts!.length,
                  itemBuilder: (context, index) {
                    final product = widget.relatedProducts![index];
                    return GestureDetector(
                      onTap: () {
                        controller.fetchProduct(product.id);
                        reviewController.fetchReviewsAndRatings(product.id);

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductDetailPage(
                                      product: controller.productDetails.value,
                                    )));
                      },
                      // child: ProductItem(
                      //   product: product,
                      // ),
                      child: Text(product.name),
                    );
                  },
                )),
            const SizedBox(
              height: 20,
            )
          ]),
        )),
      ),
    );
  }
}
