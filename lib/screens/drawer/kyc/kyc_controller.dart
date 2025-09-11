import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import '../../../api_service/api_service.dart';
import '../../../utils/app_colors.dart';
// Add this import

class KYCField {
  final String label;
  final String type;
  final bool required;

  KYCField({
    required this.label,
    required this.type,
    required this.required,
  });

  factory KYCField.fromMap(Map<String, dynamic> map) {
    return KYCField(
      label: map['label'] ?? '',
      type: map['type'] ?? 'text',
      required: map['required'] == '1' || map['required'] == 1 || map['required'] == true,
    );
  }
}

class KYCController extends GetxController with GetTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  // Observable variables
  final _isLoading = true.obs;
  final _isSubmitting = false.obs;
  final _message = ''.obs;
  final _formTitle = ''.obs;
  final _fields = <KYCField>[].obs;
  final _selectedFiles = <String, File?>{}.obs;
  final _controllers = <String, TextEditingController>{}.obs;

  // Animation
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSubmitting => _isSubmitting.value;
  String get message => _message.value;
  String get formTitle => _formTitle.value;
  List<KYCField> get fields => _fields;
  Map<String, File?> get selectedFiles => _selectedFiles;
  Map<String, TextEditingController> get controllers => _controllers;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    loadKYCForm();
  }

  @override
  void onClose() {
    animationController.dispose();
    _controllers.values.forEach((controller) => controller.dispose());
    super.onClose();
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic));
  }

  void skipKYC() {
    // Get.off(() => PiNetworkHomeScreen());
    Get.back();
  }

  Future<void> loadKYCForm() async {
    try {
      _isLoading.value = true;

      final response = await _apiService.getKYCForm();

      if (response != null) {
        print("123");
        final data = response.data as Map<String, dynamic>;

        _message.value = data['message'] ?? '';

        if (data['kyc'] != null) {
          final kycData = data['kyc'] as Map<String, dynamic>;
          _formTitle.value = kycData['name'] ?? 'KYC Verification';

          // Handle fields as Map instead of List
          _fields.clear();
          if (kycData['fields'] != null) {
            final fieldsData = kycData['fields'] as Map<String, dynamic>;

            // Convert Map to List of KYCField objects
            fieldsData.forEach((key, value) {
              if (value is Map<String, dynamic>) {
                final field = KYCField.fromMap(value);
                _fields.add(field);
              }
            });
          }

          // Initialize controllers for text fields
          _controllers.clear();
          for (var field in _fields) {
            if (field.type != 'file') {
              _controllers[field.label] = TextEditingController();
            }
          }
        }

        _isLoading.value = false;

        // Comment out the message snackbar as requested
        // if (_message.value.isNotEmpty) {
        //   _showSnackbar(
        //     'Info',
        //     _message.value,
        //     MyColor.getGCoinInfoColor(),
        //     duration: 4,
        //   );
        // }

        // Show success message for form loading
        if (_fields.isNotEmpty) {
          _showSnackbar(
            'Success',
            'KYC form loaded successfully',
            MyColor.getGCoinSuccessColor(),
            duration: 2,
          );
        } else {
          _showSnackbar(
            'Warning',
            'No KYC fields available at the moment',
            Colors.orange,
            duration: 3,
          );
        }

        animationController.forward();
      } else {
        _isLoading.value = false;
        _showSnackbar(
          'Error',
          'Failed to load KYC form. Please try again.',
          MyColor.getErrorColor(),
          duration: 3,
        );
      }
    } catch (e) {
      _isLoading.value = false;
      _showSnackbar(
        'Error',
        'Failed to load KYC form: ${e.toString()}',
        MyColor.getErrorColor(),
        duration: 4,
      );
    }
  }

  Future<void> pickImage(String fieldLabel) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        _selectedFiles[fieldLabel] = File(image.path);
        _showSnackbar(
          'Success',
          'Image selected for $fieldLabel',
          MyColor.getGCoinSuccessColor(),
          duration: 2,
        );
      }
    } catch (e) {
      _showSnackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        MyColor.getErrorColor(),
        duration: 3,
      );
    }
  }

  bool _validateForm() {
    for (var field in _fields) {
      if (field.required) {
        if (field.type == 'file') {
          if (_selectedFiles[field.label] == null) {
            _showSnackbar(
              'Validation Error',
              '${field.label} is required',
              MyColor.getErrorColor(),
              duration: 3,
            );
            return false;
          }
        } else {
          final controller = _controllers[field.label];
          if (controller == null || controller.text.trim().isEmpty) {
            _showSnackbar(
              'Validation Error',
              '${field.label} is required',
              MyColor.getErrorColor(),
              duration: 3,
            );
            return false;
          }
        }
      }
    }
    return true;
  }

  Future<void> submitKYC() async {
    if (!_validateForm()) {
      return;
    }

    _isSubmitting.value = true;

    try {
      final Map<String, dynamic> submitData = {};

      // Add text field data
      for (var field in _fields) {
        if (field.type != 'file') {
          final controller = _controllers[field.label];
          if (controller != null) {
            submitData[field.label.toLowerCase().replaceAll(' ', '_')] = controller.text.trim();
          }
        }
      }

      // Add file data
      for (String key in _selectedFiles.keys) {
        if (_selectedFiles[key] != null) {
          submitData[key.toLowerCase().replaceAll(' ', '_')] = await dio.MultipartFile.fromFile(
            _selectedFiles[key]!.path,
            filename: _selectedFiles[key]!.path.split('/').last,
          );
        }
      }

      print("submit Data:");
      print(submitData);

      final response = await _apiService.submitKYC(submitData);

      if (response != null && response.statusCode == 200) {
        _showSnackbar(
          'Success',
          'KYC submitted successfully! Your verification is under review.',
          MyColor.getGCoinSuccessColor(),
          duration: 4,
        );


        // Clear form after successful submission
        _controllers.forEach((key, controller) => controller.clear());
        _selectedFiles.clear();
        Get.back();
        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Get.back();
        });
      } else {
        // Handle different response scenarios
        String errorMessage = 'Failed to submit KYC. Please try again.';

        if (response?.data != null && response!.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          errorMessage = responseData['message'] ?? errorMessage;
        }

        _showSnackbar(
          'Error',
          errorMessage,
          MyColor.getErrorColor(),
          duration: 4,
        );
      }
    } catch (e) {
      _showSnackbar(
        'Error',
        'Failed to submit KYC: ${e.toString()}',
        MyColor.getErrorColor(),
        duration: 4,
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  void _showSnackbar(String title, String message, Color backgroundColor, {int duration = 3}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
    );
  }
}