import 'package:baltra/features/products/controller/productController.dart';
import 'package:baltra/features/products/presentation/screens/product_page.dart';
import 'package:baltra/features/products/presentation/screens/subcategory_page.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard(
      {super.key,
      required this.image_url,
      required this.name,
      required this.controller,
      required this.where,
      required this.id});

  final String image_url;
  final String name;
  final int id;
  final String where;
  final ProductController controller;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: where == "category"
          ? () {
              controller.fetchSubCategories(id);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubcategoryPage(),
                  ));
            }
          : () {
              controller.fetchSubCategoryProducts(id);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductPage(),
                  ));
            },
      child: Container(
        height: 180,
        width: 175,
        color: const Color.fromRGBO(13, 13, 13, 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              image_url,
              height: 100,
              width: 135,
              fit: BoxFit.contain,
            ),
            Text(
              name.toUpperCase(),
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: 2,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff0D0D0D)),
            ),
          ],
        ),
      ),
    );
  }
}
