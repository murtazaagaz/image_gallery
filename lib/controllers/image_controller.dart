import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/image_model.dart';

class ImageController extends GetxController {
  var images = <ImageModel>[].obs;
  var isLoading = false.obs;
  var currentPage = 1;
  var searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  static const String _apiKey = '24951598-1c2e099d3de4e27d2d5867166';
  static const String _baseUrl = 'https://pixabay.com/api/';

  @override
  void onInit() {
    super.onInit();
    fetchImages();
    debounce(searchQuery, (_) => fetchImages(),
        time: const Duration(milliseconds: 800));
  }

  Future<void> fetchImages({bool isLoadMore = false}) async {
    if (isLoading.value) return;

    if (!isLoadMore) {
      images.clear();
      currentPage = 1;
    }

    isLoading.value = true;
    final url =
        '$_baseUrl?key=$_apiKey&q=${searchQuery.value}&image_type=photo&page=$currentPage&per_page=40';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<ImageModel> newImages = (data['hits'] as List)
            .map((json) => ImageModel.fromJson(json))
            .toList();
        images.addAll(newImages);
        currentPage++;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void loadMoreImages() {
    if (!isLoading.value) {
      fetchImages(isLoadMore: true);
    }
  }
}
