// faq_controller.dart
import 'package:get/get.dart';

import '../../../api_service/api_service.dart';
import 'faq_model.dart';

class FAQController extends GetxController {
  final ApiService _apiService = ApiService();
  var isLoading = false.obs;
  var faqs = <FAQItem>[].obs;
  var filteredFAQs = <FAQItem>[].obs;
  var expandedIndex = (-1).obs; // Changed: Only one item can be expanded at a time
  var selectedCategory = 'All'.obs;
  var currentSearchQuery = ''.obs; // Added: Track current search query

  @override
  void onInit() {
    super.onInit();
    fetchFAQs();
  }

  Future<void> fetchFAQs() async {
    try {
      isLoading(true);
      final response = await _apiService.getFAQs();
      if (response != null && response.data['success'] == true) {
        faqs.assignAll((response.data['faqs'] as List)
            .map((item) => FAQItem.fromJson(item))
            .toList());
        filteredFAQs.assignAll(faqs);
      }
    } finally {
      isLoading(false);
    }
  }

  void filterFAQs(String query) {
    currentSearchQuery.value = query; // Store the current search query
    _applyFilters();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    selectedCategory.refresh(); // Force UI update immediately
    _applyFilters(); // Apply filters with current search query
  }

  void _applyFilters() {
    List<FAQItem> filtered = faqs.toList();

    // Apply category filter first
    if (selectedCategory.value != 'All') {
      filtered = filtered.where((faq) => faq.category == selectedCategory.value).toList();
    }

    // Apply search filter
    if (currentSearchQuery.value.isNotEmpty) {
      filtered = filtered.where((faq) =>
      faq.question.toLowerCase().contains(currentSearchQuery.value.toLowerCase()) ||
          faq.answer.toLowerCase().contains(currentSearchQuery.value.toLowerCase()) ||
          faq.category.toLowerCase().contains(currentSearchQuery.value.toLowerCase())).toList();
    }

    filteredFAQs.assignAll(filtered);
    expandedIndex.value = -1; // Close any expanded item when filtering
  }

  void toggleExpansion(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1; // Close if already open
    } else {
      expandedIndex.value = index; // Open new one, close others
    }
  }

  void clearSearch() {
    currentSearchQuery.value = '';
    selectedCategory.value = 'All';
    filteredFAQs.assignAll(faqs);
    expandedIndex.value = -1;
  }

  List<String> get categories {
    return ['All', ...faqs.map((faq) => faq.category).toSet()];
  }
}