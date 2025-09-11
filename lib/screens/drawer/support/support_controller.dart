// support_controller.dart
import 'package:get/get.dart';
import '../../../api_service/api_service.dart';

class SupportController extends GetxController {
  final ApiService _apiService = Get.put(ApiService());
  var isLoading = true.obs;
  var supportArticles = <dynamic>[].obs;
  var filteredArticles = <dynamic>[].obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSupportArticles();
  }

  Future<void> fetchSupportArticles() async {
    try {
      isLoading(true);
      final response = await _apiService.getSupportArticles();
      if (response != null && response.data['success'] == true) {
        supportArticles.value = response.data['faqs'];
        filteredArticles.value = supportArticles;
      }
    } finally {
      isLoading(false);
    }
  }

  void filterArticles(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredArticles.value = supportArticles;
    } else {
      filteredArticles.value = supportArticles.where((article) {
        return article['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
            article['summary'].toString().toLowerCase().contains(query.toLowerCase()) ||
            article['category'].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }
}