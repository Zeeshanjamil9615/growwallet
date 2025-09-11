import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api_service/api_service.dart';
import '../../../utils/custom_snackbar.dart';
import '../../homescreen/home_controller.dart';
import 'tree_model.dart';

class TreeController extends GetxController with GetTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final HomeController _homeController = Get.find<HomeController>();

  var isLoading = false.obs;
  var currentNode = Rxn<TreeNode>();
  var treeNodes = <TreeNode>[].obs;
  var navigationHistory = <TreeNode>[].obs;
  var treeResponse = Rxn<TreeResponse>(); // Add this to store the full response

  // Animation controllers
  late AnimationController slideAnimationController;
  late AnimationController fadeAnimationController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  var isSearching = false.obs;
  var searchResult = Rxn<Map<String, dynamic>>();
  var searchError = RxString('');

  @override
  Future<void> onInit() async {
    super.onInit();
    _initializeAnimations();
    _loadInitialTree();
    // await _homeController.fetchDashboardData();
  }

  void _initializeAnimations() {
    slideAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    fadeAnimationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fadeAnimationController,
      curve: Curves.easeInOut,
    ));
  }
// In the fetchTreeData method, update the root node creation:
  void _loadInitialTree() {
    final userData = _homeController.userData;
    if (userData.isNotEmpty) {
      final rootNode = TreeNode(
        id: userData['id'] ?? 0,
        name: userData['name'] ?? 'Unknown',
        username: userData['username'] ?? '',
        position: 'root',
        downlineCount: 0, // This will be updated when we fetch the tree data
      );

      currentNode.value = rootNode;
      fetchTreeData(rootNode.id);
    }
  }

// Update the fetchTreeData method to handle the new response:
  Future<void> fetchTreeData(int userId) async {
    try {
      isLoading.value = true;
      treeResponse.value = null;

      final response = await _apiService.getDownlineTree(userId);

      if (response?.statusCode == 200) {
        final treeData = TreeResponse.fromJson(response!.data);
        treeResponse.value = treeData;

        if (treeData.success) {
          // Update current node's downline count if it exists
          if (currentNode.value != null) {
            currentNode.value = TreeNode(
              id: currentNode.value!.id,
              name: currentNode.value!.name,
              username: currentNode.value!.username,
              position: currentNode.value!.position,
              downlineCount: treeData.teamCount ?? 0,
            );
          }

          treeNodes.clear();
          treeNodes.addAll(treeData.tree);

          fadeAnimationController.reset();
          slideAnimationController.reset();
          fadeAnimationController.forward();
          slideAnimationController.forward();
        } else {
          CustomSnackBar.error(treeData.message);
        }
      } else {
        CustomSnackBar.error('Failed to load tree data');
      }
    } catch (e) {
      CustomSnackBar.error('Error loading tree: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  // Rest of the methods remain the same...
  Future<void> searchUser(String username) async {
    try {
      isSearching.value = true;
      searchError.value = '';
      searchResult.value = null;

      if (username.isEmpty) {
        searchError.value = 'Please enter a username';
        return;
      }

      final response = await _apiService.searchUserByUsername(username);

      if (response == null) {
        searchError.value = 'User Not Found!';
        return;
      }

      // Handle different status codes
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          searchResult.value = data;
        } else {
          searchError.value = data['message'] ?? 'User not found';
        }
      }
      else if (response.statusCode == 403) {
        searchError.value = response.data['message'] ?? 'User is not in your network';
      }
      else if (response.statusCode == 404) {
        searchError.value = response.data['message'] ?? 'User not found';
      }
      else {
        searchError.value = 'Failed to search user (Error ${response.statusCode})';
      }
    } catch (e) {
      searchError.value = 'Error searching user: ${e.toString()}';
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() {
    searchResult.value = null;
    searchError.value = '';
  }

  void navigateToNode(TreeNode node) {
    if (currentNode.value != null) {
      navigationHistory.add(currentNode.value!);
    }

    currentNode.value = node;
    fetchTreeData(node.id);
  }

  void navigateBack() {
    if (navigationHistory.isNotEmpty) {
      final previousNode = navigationHistory.removeLast();
      currentNode.value = previousNode;
      fetchTreeData(previousNode.id);
    }
  }

  void resetToRoot() {
    navigationHistory.clear();
    _loadInitialTree();
  }

  bool canNavigateBack() {
    return navigationHistory.isNotEmpty;
  }

  String getCurrentNodeTitle() {
    return currentNode.value?.name ?? 'Network Tree';
  }

  String getCurrentNodeUsername() {
    return currentNode.value?.username ?? '';
  }

  @override
  void onClose() {
    slideAnimationController.dispose();
    fadeAnimationController.dispose();
    super.onClose();
  }
}