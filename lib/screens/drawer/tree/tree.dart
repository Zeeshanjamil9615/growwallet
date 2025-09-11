import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gcoin/main.dart';
import 'package:gcoin/screens/homescreen/homescreen.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import 'tree_controller.dart';
import 'tree_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../utils/ad_helper.dart'; // Make sure this file exists
import 'package:cloud_firestore/cloud_firestore.dart';

class NetworkTreeScreen extends StatefulWidget {
  @override
  _NetworkTreeScreenState createState() => _NetworkTreeScreenState();
}

class _NetworkTreeScreenState extends State<NetworkTreeScreen> {
  final TreeController controller = Get.put(TreeController());
  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;
  // bool _shouldShowAds = false; // Add this variable
  StreamSubscription? _adSettingsSubscription; // Add this


  @override
  void initState() {
    super.initState();
    // _listenToAdSettings(); // Use listener instead

if(myAds['BannerTeamTree'] == true){
  _loadBottomBannerAd();
}
  }

// Replace _checkAdSettings with this listener approach
  // void _listenToAdSettings() {
  //   print("Setting up Firestore listener...");

  //   _adSettingsSubscription = FirebaseFirestore.instance
  //       .collection('app_settings')
  //       .doc('TREE')
  //       .snapshots()
  //       .listen(
  //         (DocumentSnapshot doc) {
  //       print("Listener triggered - Document exists: ${doc.exists}");
  //       print("Listener - Document data: ${doc.data()}");

  //       if (doc.exists) {
  //         Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
  //         bool showAds = data?['team_tree'] ?? false;

  //         print("Listener - show_ads value: $showAds");

  //         setState(() {
  //           _shouldShowAds = showAds;
  //         });

  //         if (_shouldShowAds && _bottomBannerAd == null) {
  //           print("Listener - Loading ads...");
  //           _loadBottomBannerAd();
  //         } else if (!_shouldShowAds && _bottomBannerAd != null) {
  //           print("Listener - Disposing ads...");
  //           _bottomBannerAd?.dispose();
  //           _bottomBannerAd = null;
  //           setState(() {
  //             _isBottomBannerAdLoaded = false;
  //           });
  //         }
  //       } else {
  //         print("Listener - Document does not exist, creating it...");
  //         _createDefaultAdSettings();
  //       }
  //     },
  //     onError: (error) {
  //       print("Listener error: $error");
  //       setState(() {
  //         _shouldShowAds = false;
  //       });
  //     },
  //   );
  // }

  // // Method to create default settings if document doesn't exist
  // Future<void> _createDefaultAdSettings() async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('app_settings')
  //         .doc('TREE')
  //         .set({
  //       'team_tree': true, // Default value
  //     });
  //     print("Default ad settings created");
  //   } catch (e) {
  //     print("Error creating default ad settings: $e");
  //   }
  // }

  @override
  void dispose() {
    _adSettingsSubscription?.cancel(); // Cancel the listener
    _bottomBannerAd?.dispose();
    super.dispose();
  }
  void _loadBottomBannerAd() {
    // Only load if we should show ads
    if (_bottomBannerAd != null) {
      return;
    }
String id = myAds['BannerTeamTreeVID'] ?? 'ca-app-pub-9756236136807053/6741317878';
// String id = 'ca-app-pub-3940256099942544/6300978111';
    _bottomBannerAd = BannerAd(
      // adUnitId: kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : AdHelper.bannerNewAdUnitId,
      adUnitId:id,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (kDebugMode) {
            print('BannerAd loaded.');
          }
          setState(() {
            _isBottomBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          if (kDebugMode) {
            print('BannerAd failed to load: $error');
          }
          ad.dispose();
          setState(() {
            _isBottomBannerAdLoaded = false;
          });
        },
      ),
    );
    _bottomBannerAd!.load();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody()),
      bottomNavigationBar:  _buildBottomBannerAd(), // Conditional rendering
    );
  }

  Widget _buildBottomBannerAd() {
    // Only show if ads are enabled and loaded
    // if (!_shouldShowAds) return SizedBox.shrink();
    // myAds['BannerTeamTree'] == false ? return SizedBox.shrink() : null;

    return _isBottomBannerAdLoaded
        ? Container(
      width: _bottomBannerAd!.size.width.toDouble(),
      height: _bottomBannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bottomBannerAd!),
    )
        :   myAds['BannerTeamTree'] == false?
         SizedBox.shrink() : Container( width: _bottomBannerAd!.size.width.toDouble(),
      height: _bottomBannerAd!.size.height.toDouble(),child: Center(child: Text("Loading Ads..."),),);
    //     : Container(
    //   width: AdSize.banner.width.toDouble(),
    //   height: AdSize.banner.height.toDouble(),
    //   // color: Colors.red,
    //   child: Center(
    //     child: Text('loading advertisement'),
    //   ),
    // );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MyColor.getAppbarBgColor(),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: MyColor.getAppbarTitleColor()),
        onPressed: () => Get.off(PiNetworkHomeScreen()),
      ),
      title: Obx(
            () =>
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network Tree',
                  style: TextStyle(
                    color: MyColor.getAppbarTitleColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (controller.getCurrentNodeUsername().isNotEmpty)
                  Text(
                    '@${controller.getCurrentNodeUsername()}',
                    style: TextStyle(
                      color: MyColor.getAppbarTitleColor().withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
      ),
      actions: [
        Obx(
              () =>
          controller.canNavigateBack()
              ? IconButton(
            icon: Icon(
              Icons.refresh,
              color: MyColor.getAppbarTitleColor(),
            ),
            onPressed: controller.resetToRoot,
          )
              : SizedBox(),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return _buildLoadingState();
    }

    return Column(
      children: [
        _buildSearchBar(),
        SizedBox(height: 8),
        Expanded(
          child: AnimatedBuilder(
            animation: controller.fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: controller.fadeAnimation,
                child: SlideTransition(
                  position: controller.slideAnimation,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildSearchResults(),
                        SizedBox(height: 12),
                        _buildTreeStructure(),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }



  Widget _buildSearchBar() {
    // Existing search bar widget...
    final searchController = TextEditingController();
    final hasText = RxBool(false);
    final FocusNode searchFocusNode = FocusNode();

    searchController.addListener(() {
      hasText.value = searchController.text.isNotEmpty;
    });

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: MyColor.getCardBg(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MyColor.getGCoinDividerColor(),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinShadowColor(),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search by username...',
                hintStyle: TextStyle(
                  color: MyColor.getTextColor().withOpacity(0.5),
                ),
                border: InputBorder.none,
                icon: Icon(Icons.search,
                    color: MyColor.getPrimaryColor()),
              ),
              style: TextStyle(color: MyColor.getTextColor()),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  controller.searchUser(value);
                  searchFocusNode.unfocus();
                }
              },
            ),
          ),
          Obx(() {
            if (controller.isSearching.value) {
              return Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        MyColor.getPrimaryColor()),
                  ),
                ),
              );
            } else {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => hasText.value
                      ? IconButton(
                    icon: Icon(Icons.done_outline,
                        color: MyColor.getPrimaryColor()),
                    onPressed: () {
                      searchFocusNode.unfocus();
                      controller.searchUser(searchController.text);
                    },
                  )
                      : SizedBox.shrink()),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: MyColor.getTextColor().withOpacity(0.5)),
                    onPressed: () {
                      searchFocusNode.unfocus();
                      searchController.clear();
                      controller.clearSearch();
                    },
                  ),
                ],
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // Existing search results widget...
    return Obx(() {
      if (controller.searchResult.value != null) {
        final user = controller.searchResult.value!['user'];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MyColor.getCardBg(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: MyColor.getPrimaryColor().withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: MyColor.getGCoinShadowColor(),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Result',
                style: TextStyle(
                  color: MyColor.getPrimaryColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: MyColor.getPrimaryColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: MyColor.getPrimaryColor().withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user['name']
                            .toString()
                            .split(' ')
                            .map((n) => n[0])
                            .take(2)
                            .join(),
                        style: TextStyle(
                          color: MyColor.getPrimaryColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'],
                          style: TextStyle(
                            color: MyColor.getTextColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${user['username']}',
                          style: TextStyle(
                            color: MyColor.getTextColor().withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSearchResultItem(
                    'Location',
                    controller.searchResult.value!['location'],
                  ),
                  _buildSearchResultItem('Position', user['position']),
                  _buildSearchResultItem(
                    'Downline',
                    user['downline_count'].toString(),
                  ),
                ],
              ),
            ],
          ),
        );
      } else if (controller.searchError.isNotEmpty) {
        final isWarning = controller.searchError.value.contains('not in your tree');
        final errorColor = isWarning ? Colors.orange : Colors.red;

        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isWarning ? Icons.warning_amber : Icons.error_outline,
                color: errorColor,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.searchError.value,
                  style: TextStyle(
                    color: errorColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox();
    });
  }

  Widget _buildSearchResultItem(String label, String value) {
    // Existing search result item widget...
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: MyColor.getTextColor().withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: MyColor.getTextColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    // Existing loading state widget...
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              MyColor.getPrimaryColor(),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading network tree...',
            style: TextStyle(color: MyColor.getTextColor(), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeStructure() {
    // Existing tree structure widget...
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildCurrentNode(),
          SizedBox(height: 10),
          _buildTreeConnections(),
          SizedBox(height: 20),
          _buildChildNodes(),
          SizedBox(height: 20),
          Obx(() {
            if (controller.treeResponse.value?.downline == true) {
              return _buildBusinessMatrix();
            }
            return SizedBox();
          }),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCurrentNode() {
    // Existing current node widget...
    return Obx(() {
      final current = controller.currentNode.value;
      if (current == null) return SizedBox();

      return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            _buildNodeCard(node: current, isCurrentNode: true, onTap: null),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: MyColor.getPrimaryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: MyColor.getPrimaryColor().withOpacity(0.3),
                ),
              ),
              child: Text(
                'Current Node',
                style: TextStyle(
                  color: MyColor.getPrimaryColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTreeConnections() {
    // Existing tree connections widget...
    return Obx(() {
      if (controller.treeNodes.isEmpty) {
        return _buildEmptyState();
      }

      return SizedBox(
        height: 60,
        child: CustomPaint(
          painter: TreeConnectionPainter(
            nodeCount: controller.treeNodes.length,
            color: MyColor.getPrimaryColor(),
          ),
          size: Size(double.infinity, 60),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    // Existing empty state widget...
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 64,
            color: MyColor.getTextColor().withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            'No downline members',
            style: TextStyle(
              color: MyColor.getTextColor().withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This member hasn\'t referred anyone yet',
            style: TextStyle(
              color: MyColor.getTextColor().withOpacity(0.4),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChildNodes() {
    // Existing child nodes widget...
    return Obx(() {
      if (controller.treeNodes.isEmpty) return _buildEmptyState();

      final nodesByPosition = {
        'left': controller.treeNodes.firstWhereOrNull((node) => node.position == 'left'),
        'middle': controller.treeNodes.firstWhereOrNull((node) => node.position == 'middle'),
        'right': controller.treeNodes.firstWhereOrNull((node) => node.position == 'right'),
      };

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: nodesByPosition['left'] != null
                ? _buildNodeCard(
              node: nodesByPosition['left']!,
              isCurrentNode: false,
              onTap: () => controller.navigateToNode(nodesByPosition['left']!),
            )
                : _buildPlaceholderNode(),
          ),
          SizedBox(width: 16),
          Expanded(
            child: nodesByPosition['middle'] != null
                ? _buildNodeCard(
              node: nodesByPosition['middle']!,
              isCurrentNode: false,
              onTap: () => controller.navigateToNode(nodesByPosition['middle']!),
            )
                : _buildPlaceholderNode(),
          ),
          SizedBox(width: 16),
          Expanded(
            child: nodesByPosition['right'] != null
                ? _buildNodeCard(
              node: nodesByPosition['right']!,
              isCurrentNode: false,
              onTap: () => controller.navigateToNode(nodesByPosition['right']!),
            )
                : _buildPlaceholderNode(),
          ),
        ],
      );
    });
  }

  Widget _buildNodeCard({
    required TreeNode node,
    required bool isCurrentNode,
    VoidCallback? onTap,
  }) {
    // Existing node card widget...
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient:
          isCurrentNode
              ? MyColor.getGCoinPrimaryGradient()
              : LinearGradient(
            colors: [MyColor.getCardBg(), MyColor.getGCoinCardColor()],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
            isCurrentNode
                ? MyColor.getPrimaryColor()
                : MyColor.getGCoinDividerColor(),
            width: isCurrentNode ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: MyColor.getGCoinShadowColor(),
              blurRadius: isCurrentNode ? 12 : 8,
              offset: Offset(0, isCurrentNode ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isCurrentNode ? 80 : 60,
              height: isCurrentNode ? 80 : 60,
              decoration: BoxDecoration(
                color:
                isCurrentNode
                    ? Colors.white.withOpacity(0.2)
                    : MyColor.getPrimaryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(isCurrentNode ? 40 : 30),
                border: Border.all(
                  color:
                  isCurrentNode
                      ? Colors.white.withOpacity(0.3)
                      : MyColor.getPrimaryColor().withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  color:
                  isCurrentNode
                      ? Colors.white
                      : MyColor.getPrimaryColor(),
                  size: isCurrentNode ? 24 : 20,
                ),
              ),
            ),
            SizedBox(height: 12),
            if (isCurrentNode) ...[
              Text(
                node.name,
                style: TextStyle(
                  color: isCurrentNode ? Colors.white : MyColor.getTextColor(),
                  fontSize: isCurrentNode ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
            ],
            Text(
              '@${node.username}',
              style: TextStyle(
                color:
                isCurrentNode
                    ? Colors.white.withOpacity(0.8)
                    : MyColor.getTextColor().withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                isCurrentNode
                    ? Colors.white.withOpacity(0.2)
                    : MyColor.getPrimaryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                node.position.toUpperCase(),
                style: TextStyle(
                  color:
                  isCurrentNode ? Colors.white : MyColor.getPrimaryColor(),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 8),
            if (isCurrentNode) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color:
                    isCurrentNode
                        ? Colors.white.withOpacity(0.8)
                        : MyColor.getTextColor().withOpacity(0.6),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${node.downlineCount}',
                    style: TextStyle(
                      color:
                      isCurrentNode
                          ? Colors.white.withOpacity(0.8)
                          : MyColor.getTextColor().withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderNode() {
    // Existing placeholder node widget...
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColor.getCardBg().withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MyColor.getGCoinDividerColor().withOpacity(0.3),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: MyColor.getTextColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: MyColor.getTextColor().withOpacity(0.2),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Icon(
              Icons.person_add_outlined,
              color: MyColor.getTextColor().withOpacity(0.3),
              size: 24,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Available Slot',
            style: TextStyle(
              color: MyColor.getTextColor().withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessMatrix() {
    // Existing business matrix widget...
    return Obx(() {
      if (controller.treeNodes.isEmpty) return SizedBox();

      return Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MyColor.getCardBg(),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MyColor.getPrimaryColor().withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MyColor.getGCoinShadowColor(),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Business Matrix',
                  style: TextStyle(
                    color: MyColor.getPrimaryColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Column(
                  children: [
                    _buildMatrixRow('Left', controller.treeResponse.value?.left ?? 0),
                    SizedBox(height: 12),
                    _buildMatrixRow('Middle', controller.treeResponse.value?.middle ?? 0),
                    SizedBox(height: 12),
                    _buildMatrixRow('Right', controller.treeResponse.value?.right ?? 0),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      );
    });
  }

  Widget _buildMatrixRow(String position, int count) {
  // Calculate random percentage between 10-15%
  final random = Random();
  final percentage = 10 + random.nextInt(6); // 10 to 15
  final dividedValue = (count * percentage / 100).round();
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Position ',
              style: TextStyle(
                color: MyColor.getTextColor().withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: '($position)',
              style: TextStyle(
                color: MyColor.getPrimaryColor(),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: MyColor.getPrimaryColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MyColor.getPrimaryColor().withOpacity(0.3),
          ),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: count.toString(),
                style: TextStyle(
                  color: MyColor.getPrimaryColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' / ',
                style: TextStyle(
                  color: MyColor.getTextColor().withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: dividedValue.toString(),
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}}

class TreeConnectionPainter extends CustomPainter {
  final int nodeCount;
  final Color color;

  TreeConnectionPainter({required this.nodeCount, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Existing paint logic...
    final paint =
    Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final topY = 0.0;
    final bottomY = size.height;
    final middleY = size.height / 2;

    canvas.drawLine(Offset(centerX, topY), Offset(centerX, middleY), paint);

    if (nodeCount > 0) {
      final leftX = size.width * 0.17;
      final rightX = size.width * 0.83;

      canvas.drawLine(Offset(leftX, middleY), Offset(rightX, middleY), paint);

      final childPositions = [
        size.width * 0.17,
        centerX,
        size.width * 0.83,
      ];

      for (int i = 0; i < nodeCount && i < 3; i++) {
        canvas.drawLine(
          Offset(childPositions[i], middleY),
          Offset(childPositions[i], bottomY),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}