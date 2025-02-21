import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:baltra/core/utils/constants.dart';
import 'package:baltra/features/products/models/category.dart';
import 'package:baltra/features/products/models/product.dart';
import 'package:baltra/features/products/models/subcategory.dart';
import 'package:baltra/features/products/models/subcategoryProduct.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
  /// Fetch all public categories.
  Future<Either<Exception, List<Category>>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$URL/products/publiccategory'));

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['success']) {
        final List<dynamic> data = jsonResponse['data'];
        final List<Category> categories =
        data.map((json) => Category.fromJson(json)).toList();
        return Right(categories);
      } else {
        return const Left(HttpException("Failed to fetch categories"));
      }
    } on SocketException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception("Unknown error occurred: $e"));
    }
  }

  /// Fetch subcategories by a given category ID.
  Future<Either<Exception, List<Subcategory>>> fetchSubCategories(int id) async {
    try {
      final response =
      await http.get(Uri.parse('$URL/products/subcategorybycategory/$id'));

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      log("***********subcategorybycategory RESPONSE: ${response.body}");

      if (jsonResponse['success']) {
        final List<dynamic> data = jsonResponse['data'];
        final List<Subcategory> subCategories =
        data.map((json) => Subcategory.fromJson(json)).toList();
        return Right(subCategories);
      } else {
        return const Left(HttpException("Failed to fetch subcategories"));
      }
    } on SocketException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception("Unknown error occurred: $e"));
    }
  }

  /// Fetch products for a given subcategory ID.
  Future<Either<Exception, List<Subcategoryproduct>>> fetchSubCategoryProducts(int id) async {
    try {
      final response =
      await http.get(Uri.parse('$URL/products/productsbysubcategory/$id'));

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      log("***********productsbysubcategory RESPONSE: ${response.body}");
      if (jsonResponse['success']) {
        final List<dynamic> data = jsonResponse['data'];
        final List<Subcategoryproduct> subCategoryProducts =
        data.map((json) => Subcategoryproduct.fromJson(json)).toList();
        return Right(subCategoryProducts);
      } else {
        return const Left(HttpException("Failed to fetch subcategory products"));
      }
    } on SocketException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception("Unknown error occurred: $e"));
    }
  }

  /// Fetch related products by a given product ID.
  Future<Either<Exception, List<Subcategoryproduct>>> fetcRelatedProducts(int id) async {
    try {
      final response = await http.get(Uri.parse('$URL/products/relatedproducts/$id'));

      log("API Response Body: ${response.body}");

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('success') && jsonResponse['success'] == true) {
        if (jsonResponse.containsKey('related_products') && jsonResponse['related_products'] != null) {

          final List<dynamic> data = jsonResponse['related_products'];

          // Convert API response into list of products
          final List<Subcategoryproduct> relatedProducts = data.map((json) => Subcategoryproduct.fromJson(json)).toList();

          log("Parsed Related Products: $relatedProducts");
          return Right(relatedProducts);
        } else {
          log("Warning: 'related_products' key is missing or null");
          return const Left(HttpException("No related products found"));
        }
      } else {
        log("Error: API returned failure response");
        return const Left(HttpException("Failed to fetch related products"));
      }
    } on SocketException catch (e) {
      log("Network Error: $e");
      return Left(e);
    } catch (e) {
      log("Unknown Error: $e");
      return Left(Exception("Unknown error occurred: $e"));
    }
  }


  /// Fetch a single product by its ID.
  Future<Either<Exception, Product>> fetchProduct(int id) async {
    try {
      final response = await http.get(Uri.parse('$URL/products/getdatabyidpublic/$id'));

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        final Product product = Product.fromJson(jsonResponse['data']);
        log("***********getdatabyidpublic RESPONSE: ${response.body}");
        return Right(product);  // Returns the product wrapped in Right.
      } else {
        return Left(Exception(jsonResponse['message'] ?? "Failed to fetch product"));
      }
    } on SocketException catch (e) {
      return Left(e);  // Error case: network issues.
    } catch (e) {
      return Left(Exception("Unknown error occurred: $e"));
    }
  }


  /// Fetch all products.
  Future<Either<Exception, List<Product>>> fetchAllProduct() async {
    try {
      final response = await http.get(Uri.parse('$URL/products/getdataapp'));
      log("RESPONSE: ${response.body}");
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        final List<dynamic> data = jsonResponse['data'];
        final List<Product> allProducts =
        data.map((json) => Product.fromJson(json)).toList();
        return Right(allProducts);
      } else {
        return Left(Exception(jsonResponse['message'] ?? "Failed to fetch products"));
      }
    } on SocketException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception("Unknown error occurred: $e"));
    }
  }
}
