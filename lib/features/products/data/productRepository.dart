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
  Future<Either<Exception, List<Category>>> fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('$URL/products/publiccategory'));

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

  Future<Either<Exception, List<Subcategory>>> fetchSubCategories(
      int id) async {
    try {
      final response =
          await http.get(Uri.parse('$URL/products/subcategorybycategory/$id'));

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      log("***********subcategorybycategory RESPONSE:${response.body}");

      if (jsonResponse['success']) {
        final List<dynamic> data = jsonResponse['data'];

        final List<Subcategory> subCategories =
            data.map((json) => Subcategory.fromJson(json)).toList();
        return Right(subCategories);
      } else {
        return const Left(HttpException("Failed to fetch categories"));
      }
    } on SocketException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception("Unknown error occurred: $e"));
    }
  }

  Future<Either<Exception, List<Subcategoryproduct>>> fetchSubCategoryProducts(
      int id) async {
    try {
      final response =
          await http.get(Uri.parse('$URL/products/productsbysubcategory/$id'));

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      log("***********productsbysubcategory RESPONSE:${response.body}");
      if (jsonResponse['success']) {
        final List<dynamic> data = jsonResponse['data'];

        final List<Subcategoryproduct> subCategoryProducts =
            data.map((json) => Subcategoryproduct.fromJson(json)).toList();
        return Right(subCategoryProducts);
      } else {
        return const Left(HttpException("Failed to fetch categories"));
      }
    } on SocketException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception("Unknown error occurred: $e"));
    }
  }

  Future<Either<Exception, List<Subcategoryproduct>>> fetcRelatedProducts(
      int id) async {
    try {
      final response =
          await http.get(Uri.parse('$URL/products/relatedproducts/$id'));

      log(response.body);
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      log('Json Response: ${jsonResponse['related_products']}');
      if (jsonResponse['success']) {
        log("Hello");
        final List<dynamic> data = jsonResponse['related_products'];

        final List<Subcategoryproduct> relatedProducts =
            data.map((json) => Subcategoryproduct.fromJson(json)).toList();
        return Right(relatedProducts);
      } else {
        return const Left(HttpException("Failed to fetch categories"));
      }
    } on SocketException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception("Unknown error occurred: $e"));
    }
  }

  Future<Either<Exception, Product>> fetchProduct(int id) async {
    try {
      final response =
          await http.get(Uri.parse('$URL/products/getdatabyidpublic/$id'));

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        final Product product = Product.fromJson(jsonResponse['data']);

        log("***********getdatabyidpublic RESPONSE:${response.body}");

        return Right(product);
      } else {
        return Left(
            Exception(jsonResponse['message'] ?? "Failed to fetch products"));
      }
    } on SocketException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception("Unknown error occurred: $e"));
    }
  }

  Future<Either<Exception, List<Product>>> fetchAllProduct() async {
    try {
      final response = await http.get(Uri.parse('$URL/products/getdataapp'));
      log("RESPONSE:${response.body}");
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        // final Product product = Product.fromJson(jsonResponse['data']);

        log("***********getdatabyidpublic RESPONSE:${response.body}");
        final List<dynamic> data = jsonResponse['data'];

        final List<Product> allProducts =
            data.map((json) => Product.fromJson(json)).toList();
        return Right(allProducts);
      } else {
        return Left(
            Exception(jsonResponse['message'] ?? "Failed to fetch products"));
      }
    } on SocketException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception("Unknown error occurred: $e"));
    }
  }
}

// products/productsbysubcategory/10