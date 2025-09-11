
// referral_team.dart (updated version)
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gcoin/main.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../utils/ad_helper.dart';
import '../../../utils/app_colors.dart';
import 'refferal_controller.dart';

class ReferralTeamPage extends StatefulWidget {
  const ReferralTeamPage({super.key});

  @override
  _ReferralTeamPageState createState() => _ReferralTeamPageState();
}

class _ReferralTeamPageState extends State<ReferralTeamPage> {
  final ReferralTeamController _controller = Get.put(ReferralTeamController());
  final Map<int, bool> _expandedStates = {}; // Track expansion states by ID

  // Native Ad variables
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;
  @override
  void initState() {
    super.initState();
    // _listenToAdSettings(); // Load the native ad when the screen initializes
    if(myAds['NatRafTeam'] == true){
      _loadNativeAd();
    }
  }

  bool _shouldShowAds = false; // Add this variable

  StreamSubscription? _adSettingsSubscription; // Add this

  // Replace _checkAdSettings with this listener approach
  // void _listenToAdSettings() {
  //   print("Setting up Firestore listener...");

  //   _adSettingsSubscription = FirebaseFirestore.instance
  //       .collection('app_settings')
  //       .doc('REFERRAL_TEAM')
  //       .snapshots()
  //       .listen(
  //         (DocumentSnapshot doc) {
  //       print("Listener triggered - Document exists: ${doc.exists}");
  //       print("Listener - Document data: ${doc.data()}");

  //       if (doc.exists) {
  //         Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
  //         bool showAds = data?['referral_team'] ?? false;

  //         print("Listener - show_ads value: $showAds");

  //         setState(() {
  //           _shouldShowAds = showAds;
  //         });

  //         if (_shouldShowAds && _nativeAd == null) {
  //           print("Listener - Loading ads...");
  //           _loadNativeAd();
  //         } else if (!_shouldShowAds && _nativeAd != null) {
  //           print("Listener - Disposing ads...");
  //           _nativeAd?.dispose();
  //           _nativeAd = null;

  //           setState(() {
  //             _isNativeAdLoaded = false;
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
  //         .doc('REFERRAL_TEAM')
  //         .set({
  //       'referral_team': true, // Default value
  //     });
  //     print("Default ad settings created");
  //   } catch (e) {
  //     print("Error creating default ad settings: $e");
  //   }
  // }
  void _loadNativeAd() {
  String id = myAds['NatRafTeamVID'] ?? 'ca-app-pub-9756236136807053/8158341325';
  // String id = 'ca-app-pub-3940256099942544/2247696110';
    _nativeAd = NativeAd(
      // adUnitId: kDebugMode ? "ca-app-pub-3940256099942544/2247696110":AdHelper.nativeAdUnitId,
      adUnitId: id,
      factoryId: 'listTile', // Make sure you have a NativeAdFactory configured
      request: const AdRequest(),
      listener: NativeAdListener(
        
        onAdLoaded: (Ad ad) {
          if (kDebugMode) {
            print('NativeAd loaded successfully.');
          }
          setState(() {
            _nativeAd = ad as NativeAd;
            _isNativeAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          if (kDebugMode) {
            print('NativeAd failed to load: $error');
          }
          ad.dispose();
          setState(() {
            _isNativeAdLoaded = false;
          });
        },
      ),
    );
    _nativeAd!.load();
  }
  @override
  void dispose() {
    _nativeAd?.dispose(); // Dispose the ad when the screen is removed
    _adSettingsSubscription?.cancel(); // Cancel the listener
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReferralStatsCard(),
              SizedBox(height: 20),
              // Add the native ad here
              _buildNativeAd(),
              SizedBox(height: 20),
              if (_controller.referrals.isEmpty) _buildEmptyState(),
              if (_controller.referrals.isNotEmpty) ...[
                // _buildWarningCard(),
                // SizedBox(height: 24),
                _buildMembersSection(),
                SizedBox(height: 16),
                _buildReferralList(),
                SizedBox(height: 20),
              ],
              _buildActionButtons(),
              SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }

  // New widget to display the native ad
  Widget _buildNativeAd() {
    if (_isNativeAdLoaded && _nativeAd != null) {
      return Container(
        height: 150, // Adjust the height as needed for your native ad format
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green,width: 2, style: BorderStyle.solid)),
        child: AdWidget(ad: _nativeAd!),
      );
    } else if(myAds['NatRafTeam'] == false) {
      return SizedBox.shrink();
    }
    else{
      return Container(
         decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green,width: 2, style: BorderStyle.solid)),
        height: 150,width: Get.width,child: Center(child: Text("Loading Ads...")),); // Show an empty box if ad is not loaded
    }
  }
  Widget _buildReferralList() {
    return Column(
      children: _controller.referrals.map((referral) =>
          _buildReferralCardWithChildren(referral)
      ).toList(),
    );
  }

  Widget _buildReferralCardWithChildren(Map<String, dynamic> referral) {
    final hasChildren = (referral['referrals'] as List).isNotEmpty;
    final isExpanded = _expandedStates[referral['id']] ?? false;

    return Column(
      children: [
        Card(
          margin: EdgeInsets.only(bottom: 8),
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: hasChildren ? () {
              setState(() {
                _expandedStates[referral['id']] = !isExpanded;
              });
            } : null,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMemberRow(referral),
                  if (hasChildren) SizedBox(height: 8),
                  if (hasChildren) Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${referral['referrals'].length} ${referral['referrals'].length == 1 ? 'member' : 'members'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: MyColor.getSecondaryTextColor(),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: MyColor.getGCoinPrimaryColor(),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasChildren && isExpanded)
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Column(
              children: (referral['referrals'] as List).map((child) =>
                  _buildReferralCardWithChildren(child)
              ).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildMemberRow(Map<String, dynamic> referral) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: MyColor.getGCoinPrimaryColor(),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.person_rounded,
            color: MyColor.getGCoinPrimaryColor(),
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                referral['name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MyColor.getHeadingTextColor(),
                ),
              ),
              SizedBox(height: 4),
              Text(
                '@${referral['username'] ?? 'username'} • Joined ${referral['created_at'] ?? 'recently'}',
                style: TextStyle(
                  fontSize: 13,
                  color: MyColor.getSecondaryTextColor(),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _controller.getStatusColor(referral['mine_status'] ?? 0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _controller.getStatusIcon(referral['mine_status'] ?? 0),
                color: _controller.getStatusColor(referral['mine_status'] ?? 0),
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                _controller.getStatusText(referral['mine_status'] ?? 0),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _controller.getStatusColor(referral['mine_status'] ?? 0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MyColor.getAppbarBgColor(),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: MyColor.getAppbarTitleColor(),
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Obx(() => Text(
            '${_controller.referrals.length}',
            style: TextStyle(
              color: MyColor.getAppbarTitleColor(),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )),
          Text(
            'Referrals',
            style: TextStyle(
              color: MyColor.getAppbarTitleColor(),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: MyColor.getGCoinPrimaryColor().withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'EN',
                style: TextStyle(
                  color: MyColor.getGCoinPrimaryColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.language_rounded,
                color: MyColor.getGCoinPrimaryColor(),
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferralStatsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: MyColor.getGCoinPrimaryGradient(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinPrimaryColor().withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Referral Team',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Obx(() => RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(text: 'You have invited '),
                        TextSpan(
                          text: '${_controller.referrals.length} ${_controller.referrals.length == 1 ? 'Team Member' : 'Team Members'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' so far.'),
                      ],
                    ),
                  )),
                  SizedBox(height: 4),
                  Obx(() => Text(
                    'Your Referral Team has ${_controller.referrals.length} members.\n${_controller.totalMining.value} of ${_controller.referrals.length} are currently mining.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  )),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Ping Inactive',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_controller.totalMining.value}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Mining',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MyColor.getGCoinCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinShadowColor(),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.group_add,
            size: 60,
            color: MyColor.getGCoinPrimaryColor().withOpacity(0.5),
          ),
          SizedBox(height: 20),
          Text(
            'No Referrals Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: MyColor.getTextColor(),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Invite friends to join your referral team and boost your gaming rate!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: MyColor.getSecondaryTextColor(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Members',
              style: TextStyle(
                color: MyColor.getHeadingTextColor(),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: MyColor.getCardBg(),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: MyColor.getGCoinPrimaryColor().withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'All',
                    style: TextStyle(
                      color: MyColor.getGCoinPrimaryColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: MyColor.getGCoinPrimaryColor(),
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          'Invite new Team Members to join your Referral Team!\nBoost your mining rate for every actively mining Member.',
          style: TextStyle(
            color: MyColor.getTextColor1(),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: MyColor.getGCoinPrimaryColor(),
                width: 1.5,
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Referral Team',
              style: TextStyle(
                color: MyColor.getGCoinPrimaryColor(),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _controller.shareReferralCode();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.getGCoinPrimaryColor(),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Invite More',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}