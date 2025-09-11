import 'package:gcoin/utils/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../api_service/api_service.dart';
import '../../api_service/local_stroge.dart';
import '../../routes/route.dart';
import 'maintenance_screen.dart';

class MaintenanceController extends GetxController {
  // Observable variables for maintenance data
  final _isMaintenanceMode = false.obs;
  final _heading = 'We\'ll be back soon!'.obs;
  final _description = 'We\'re currently performing scheduled maintenance. Please check back in a while.'.obs;
  final _estimatedTime = 'A few minutes'.obs;
  final _isLoading = false.obs;

  // Getters
  bool get isMaintenanceMode => _isMaintenanceMode.value;
  String get heading => _heading.value;
  String get description => _description.value;
  String get estimatedTime => _estimatedTime.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    checkMaintenanceStatus();
  }

  /// Check maintenance status from API
  Future<void> checkMaintenanceStatus() async {
    try {
      _isLoading.value = true;

      // Simulate API call - replace with your actual API service
      final response = await _fetchMaintenanceStatus();

      if (response['success'] == true) {
        _isMaintenanceMode.value = response['maintance_mode'] == '1';
        _heading.value = response['heading'] ?? 'We\'ll be back soon!';
        _description.value = response['description'] ?? 'We\'re currently performing scheduled maintenance. Please check back in a while.';
        _estimatedTime.value = response['estimated_time'] ?? 'A few minutes';
      }
    } catch (e) {
      print('Error checking maintenance status: $e');
      // Handle error appropriately
    } finally {
      _isLoading.value = false;
    }
  }

  /// Simulate API call - replace with your actual API service
  Future<Map<String, dynamic>> _fetchMaintenanceStatus() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // This should be replaced with your actual API call
    // Example response structure:
    return {
      "success": true,
      "message": "Maintenance mode fetched successfully",
      "maintance_mode": "0", // "1" for maintenance mode, "0" for normal mode
      "heading": "We'll be back soon!",
      "description": "We're currently performing scheduled maintenance. Please check back in a while.",
      "estimated_time": "2 hours"
    };
  }

  Future<void> retry() async {
    _isLoading.value = true;

    try {
      final apiService = ApiService();
      final maintenanceResponse = await apiService.checkMaintenanceMode();

      if (maintenanceResponse.isInMaintenance && maintenanceResponse.success) {
        updateMaintenanceData(
          heading: maintenanceResponse.heading,
          description: maintenanceResponse.description,
          estimatedTime: maintenanceResponse.estimatedTime,
        );
        CustomSnackBar.error("We're still working on improvements. Please try again later.", title: "Still in Maintenance");
      } else {
        // If maintenance is over, navigate to onboard screen
        final hasValidToken = LocalStorage.getToken() != null;
        Get.offAllNamed(hasValidToken ? RouteHelper.homeScreen : RouteHelper.onboardScreen);
      }
    } finally {
      _isLoading.value = false;
    }
  }
  /// Navigate to maintenance screen
  void showMaintenanceScreen() {
    Get.offAll(
          () => MaintenanceScreen(
        heading: heading,
        description: description,
        estimatedTime: estimatedTime,
        onRetry: retry,
      ),
    );
  }

  /// Check if app should show maintenance screen
  bool shouldShowMaintenanceScreen() {
    return isMaintenanceMode;
  }

  // Add this method to MaintenanceController
  void updateMaintenanceData({
    required String heading,
    required String description,
    required String estimatedTime,
  }) {
    _heading.value = heading;
    _description.value = description;
    _estimatedTime.value = estimatedTime;
    _isMaintenanceMode.value = true;
  }
}

// Add this extension to easily access the controller
extension MaintenanceControllerExtension on GetInterface {
  MaintenanceController get maintenanceController => Get.find<MaintenanceController>();
}