 import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcoin/screens/homescreen/home_controller.dart';
import 'package:gcoin/screens/maintenance/controller.dart';
import 'package:gcoin/utils/app_open_add.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'api_service/api_service.dart';
import 'api_service/local_stroge.dart';
import 'routes/route.dart';
import 'theme_controller.dart';
import 'screens/maintenance/maintenance_screen.dart';
import 'utils/my_strings.dart';
import 'theme/dark.dart';
import 'theme/light.dart';

Map<String, dynamic> myAds = {
  'AppOpen': false,
  'AppOpenVID': "",
  'BannerHome': false,
  'BannerHomeVID': "",
  'BannerNode': false,
  'BannerNodeVID': "",         
  'BannerRateNetwork': false,
  'BannerRateNetworkVID': "",
  'BannerTeamTree': false,
  'BannerTeamTreeVID': "",
  'BannerWallet': false,
  'BannerWalletVID': "",
  'IntRateN': false,
  'IntRateNVID': "",
  'IntTeamTree': false,
  'IntTeamTreeVID': "",
  'IntWallet': false,
  'IntWalletVID': "",
  'NatActiveS': false,
  'NatActiveSID': "",
  'NatRafTeam': false,
  'NatRafTeamVID': "",
};
// Declare a global instance of the AppOpenAdManager
late AppOpenAdManager appOpenAdManager;

// Global variable to control ad display
bool shouldShowAppOpenAds = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ Initialize Firebase first
  await Firebase.initializeApp();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize SharedPreferences
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  // Initialize ThemeController
  Get.put(ThemeController(sharedPreferences: sharedPreferences));

  // Initialize HomeController
  Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  Get.put(MaintenanceController());

  // Configure AdMob for test devices in debug mode
  if (kDebugMode) {
    final List<String> testDeviceIds = [
      // Add your specific test device IDs here
    ];

    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: testDeviceIds,
      ),
    );
    print('AdMob: Test devices configured for debug mode.');
  }

  // Initialize MobileAds
  MobileAds.instance.initialize();

  // Initialize the AppOpenAdManager with a test ad unit ID
  // appOpenAdManager = AppOpenAdManager(
  //   adUnitId: kDebugMode ? 'ca-app-pub-3940256099942544/9257395921' : AdHelper.appOpenAdUnitId,
  // );
    bool isConnected = await checkInternetConnection();
    await getAdValues();
//  if (isConnected) {
//     try {
//       var fetchedAds = await getAdValues();
//       print('Fetched Ads: $fetchedAds');
//       myAds = fetchedAds.isNotEmpty
//           ? fetchedAds
//           : {
//               "AppOpen": false,
//               "Int": false,
//               "Nat": false,
//               "Ban": false,
//             };
//     } catch (e) {
//       print("Error fetching ads: $e");
//       myAds = {
//         "AppOpen": false,
//         "Int": false,
//         "Nat": false,
//         "Ban": false,
//       };
//       print(myAds);
//     }
//   } else {
//     print('enternig  in else state');
//     myAds = {
//       "AppOpen": false,
//       "Int": false,
//       "Ban": false,
//       "Nat": false,
//     };
//   }
   final appOpenAdManager = AppOpenAdManager();
  appOpenAdManager.initialize();
  // Check internet connectivity first
  final connectivityResult = await Connectivity().checkConnectivity();
  final bool hasInternet = connectivityResult != ConnectivityResult.none;

  String initialRoute;

  if (!hasInternet) {
    // If no internet, proceed with normal app flow
    final hasValidToken = LocalStorage.getToken() != null;
    initialRoute = hasValidToken ? RouteHelper.homeScreen : RouteHelper.onboardScreen;
  } else {
    final apiService = ApiService();
    // If internet is available, check maintenance mode
    final maintenanceResponse = await apiService.checkMaintenanceMode();

    if (maintenanceResponse.isInMaintenance && maintenanceResponse.success) {
      // Get the controller and update it with maintenance data
      final maintenanceController = Get.find<MaintenanceController>();
      maintenanceController.updateMaintenanceData(
        heading: maintenanceResponse.heading,
        description: maintenanceResponse.description,
        estimatedTime: maintenanceResponse.estimatedTime,
      );
      initialRoute = '/maintenance';
    } else {
      final hasValidToken = LocalStorage.getToken() != null;
      initialRoute = hasValidToken ? RouteHelper.homeScreen : RouteHelper.onboardScreen;
    }
  }

  runApp(MainApp(initialRoute: initialRoute));
}

class MainApp extends StatefulWidget {
  final String initialRoute;
  const MainApp({super.key, required this.initialRoute});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  StreamSubscription? _adSettingsSubscription;
  final AppOpenAdManager _appOpenAdManager = AppOpenAdManager();
  bool _appOpenAdShown = false;
  bool _isShowingAppOpenAd = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAppOpenAd();
  }

  void _initializeAppOpenAd() {
    // Check if app open ad should be shown
    if (myAds['AppOpen'] == true && !_appOpenAdShown) {
      _loadAndShowAppOpenAd();
    }
  }

  void _loadAndShowAppOpenAd() {
    setState(() {
      _isShowingAppOpenAd = true;
    });

    // Check if ad is already loaded and available
    if (_appOpenAdManager.isAdAvailable) {
      print('App Open Ad already loaded, showing immediately');
      _showAppOpenAdNow();
      return;
    }

    // Load the app open ad
    _appOpenAdManager.loadAd();
    
    // Check periodically if ad becomes available
    _checkAdAvailability();

    // Timeout after 8 seconds if ad doesn't load or show
    Future.delayed(const Duration(seconds: 8), () {
      if (_isShowingAppOpenAd && !_appOpenAdShown) {
        print('App Open Ad timeout - proceeding without ad');
        setState(() {
          _appOpenAdShown = true;
          _isShowingAppOpenAd = false;
        });
      }
    });
  }

  void _checkAdAvailability() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_appOpenAdManager.isAdAvailable) {
        timer.cancel();
        print('App Open Ad loaded, showing now');
        _showAppOpenAdNow();
      } else if (_appOpenAdShown || !_isShowingAppOpenAd) {
        timer.cancel();
      }
    });
  }

  void _showAppOpenAdNow() {
    // Temporarily set app as backgrounded so the ad will show
    _appOpenAdManager.onAppPaused();
    _appOpenAdManager.onAppResumed();
    
    // Check if ad is showing after a brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_appOpenAdManager.isShowingAd) {
        // Ad didn't show, proceed with normal flow
        setState(() {
          _appOpenAdShown = true;
          _isShowingAppOpenAd = false;
        });
      } else {
        // Ad is showing, wait for it to be dismissed
        _waitForAdDismissal();
      }
    });
  }

  void _waitForAdDismissal() {
    // Poll to check if ad is still showing
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_appOpenAdManager.isShowingAd) {
        timer.cancel();
        setState(() {
          _appOpenAdShown = true;
          _isShowingAppOpenAd = false;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adSettingsSubscription?.cancel();
    _appOpenAdManager.dispose();
    super.dispose();
  }

  // Listen to Firebase ad settings
  // void _listenToAdSettings() {
  //   if (kDebugMode) {
  //     print("Setting up Firestore listener for app open ads...");
  //   }

  //   _adSettingsSubscription = FirebaseFirestore.instance
  //       .collection('app_settings')
  //       .doc('APP_OPEN')
  //       .snapshots()
  //       .listen(
  //         (DocumentSnapshot doc) {
  //       if (kDebugMode) {
  //         print("App Open Ad Listener triggered - Document exists: ${doc.exists}");
  //         print("App Open Ad Listener - Document data: ${doc.data()}");
  //       }

  //       if (doc.exists) {
  //         Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
  //         bool showAds = data?['appOpenAdd'] ?? true;

  //         if (kDebugMode) {
  //           print("App Open Ad Listener - appOpenAdd value: $showAds");
  //         }

  //         setState(() {
  //           shouldShowAppOpenAds = showAds;
  //         });

  //         // if (shouldShowAppOpenAds) {
  //         if ( myAds["appOpen"]== true) {
  //           if (kDebugMode) {
  //             print("App Open Ad - Loading ads...");
  //           }
  //           // if (myAds["appOpen"])
  //           appOpenAdManager.loadAd();
  //         }
  //       } else {
  //         if (kDebugMode) {
  //           print("App Open Ad Listener - Document does not exist, creating it...");
  //         }
  //         _createDefaultAdSettings();
  //       }
  //     },
  //     onError: (error) {
  //       if (kDebugMode) {
  //         print("App Open Ad Listener error: $error");
  //       }
  //       setState(() {
  //         shouldShowAppOpenAds = false;
  //       });
  //     },
  //   );
  // }

  // Method to create default settings if document doesn't exist
  // Future<void> _createDefaultAdSettings() async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('app_settings')
  //         .doc('ads_config')
  //         .set({
  //       'appOpenAdd': true, // Default value
  //     });
  //     if (kDebugMode) {
  //       print("Default ad settings created for app open ads");
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error creating default ad settings: $e");
  //     }
  //   }
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     if (kDebugMode) {
  //       print("App is in Resumed state");
  //     }

  //     // Only show app open ad if Firebase setting allows it
  //     // if (shouldShowAppOpenAds) {
  //     if (myAds["appOpen"]==true) {
  //       if (kDebugMode) {
  //         print("Showing app open ad (Firebase allows)");
  //       }
  //       appOpenAdManager.showAdIfAvailable();
  //     } else {
  //       if (kDebugMode) {
  //         print("App open ad disabled via Firebase");
  //       }
  //     }
  //   }
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        // App goes to background
        _appOpenAdManager.onAppPaused();
        break;
      case AppLifecycleState.resumed:
        // App resumes from background - show app open ad if enabled
        _appOpenAdManager.onAppResumed();
        break;
      default:
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (theme) {
      return GetMaterialApp(
        title: MyStrings.appName,
        initialRoute: widget.initialRoute,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        getPages: _buildRoutes(),
        navigatorKey: Get.key,
        theme: theme.darkTheme ? dark : light,
        debugShowCheckedModeBanner: false,
        // Set system UI overlay style
        builder: (context, child) {
          // Show loading screen while app open ad is being shown
          if (_isShowingAppOpenAd && !_appOpenAdShown) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 20),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: theme.darkTheme
                ? SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: Colors.black,
                    systemNavigationBarIconBrightness: Brightness.light,
                  )
                : SystemUiOverlayStyle.dark.copyWith(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: Colors.white,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  ),
            child: child!,
          );
      },
      );
    });
  }

  List<GetPage> _buildRoutes() {
    // Add maintenance route to existing routes
    final routes = List<GetPage>.from(RouteHelper.routes);

    // Add maintenance screen route
    routes.add(
      GetPage(
        name: '/maintenance',
        page: () => const MaintenanceScreen(),
        transition: Transition.fadeIn,
      ),
    );

    return routes;
  }
}

// Optional: Create a splash screen with maintenance check
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkMaintenanceAndNavigate();
  }

  Future<void> _checkMaintenanceAndNavigate() async {
    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 1500));

    // Check internet connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool hasInternet = connectivityResult != ConnectivityResult.none;

    if (!hasInternet) {
      // If no internet, proceed with normal app flow
      final hasValidToken = LocalStorage.getToken() != null;
      if (hasValidToken) {
        Get.offAllNamed(RouteHelper.homeScreen);
      } else {
        Get.offAllNamed(RouteHelper.onboardScreen);
      }
      return;
    }

    final apiService = ApiService();
    final maintenanceResponse = await apiService.checkMaintenanceMode();

    if (maintenanceResponse.isInMaintenance && maintenanceResponse.success) {
      // Navigate to maintenance screen only if we successfully got a maintenance response
      Get.offAllNamed('/maintenance');
    } else {
      // Check authentication and navigate accordingly
      final hasValidToken = LocalStorage.getToken() != null;
      if (hasValidToken) {
        Get.offAllNamed(RouteHelper.homeScreen);
      } else {
        Get.offAllNamed(RouteHelper.onboardScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7ED321),
              Color(0xFF4CAF50),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.monetization_on,
                  size: 50,
                  color: Color(0xFF7ED321),
                ),
              ),

              const SizedBox(height: 30),

              // App name
              Text(
                MyStrings.appName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),

              const SizedBox(height: 20),

              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


///  **Improved Internet Check**
Future<bool> checkInternetConnection() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  print("Connectivity Result: $connectivityResult");

  if (connectivityResult == ConnectivityResult.none) {
    return false;
  }

  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (e) {
    print("No internet access: $e");
    return false;
  }
}

Future<void> getAdValues() async {
  try {
    DatabaseReference ref = FirebaseDatabase.instance.ref("AdmobAds");
    DatabaseEvent de = await ref.once();

    if (de.snapshot.value != null) {
      final data = Map<String, dynamic>.from(de.snapshot.value as Map);
      print('the data object $data');

      // ✅ Use the correct Firebase keys from your database
     myAds = {
        // 🔹 App Open Ads
        'AppOpen': data["AppOpen"] as bool? ?? false,
        'AppOpenVID': data["AppOpenV"]?.toString() ?? "",

        // 🔹 Banner Ads
        'BannerHome': data["BannerHome"] as bool? ?? false,
        'BannerHomeVID': data["BannerHomeV"]?.toString() ?? "",
        'BannerNode': data["BannerNode"] as bool? ?? false,
        'BannerNodeVID': data["BannerNodeV"]?.toString() ?? "",
        'BannerRateNetwork': data["BannerRateNetwork"] as bool? ?? false,
        'BannerRateNetworkVID': data["BannerRateNetworkV"]?.toString() ?? "",
        'BannerTeamTree': data["BannerTeamTree"] as bool? ?? false,
        'BannerTeamTreeVID': data["BannerTeamTreeV"]?.toString() ?? "",
        'BannerWallet': data["BannerWallet"] as bool? ?? false,
        'BannerWalletVID': data["BannerWalletV"]?.toString() ?? "",

        // 🔹 Interstitial Ads
        'IntRateN': data["IntRateN"] as bool? ?? false,
        'IntRateNVID': data["IntRateNV"]?.toString() ?? "",
        'IntTeamTree': data["IntTeamTree"] as bool? ?? false,
        'IntTeamTreeVID': data["IntTeamTreeV"]?.toString() ?? "",
        'IntWallet': data["IntWallet"] as bool? ?? false,
        'IntWalletVID': data["IntWalletV"]?.toString() ?? "",

        // 🔹 Native Ads
        'NatActiveS': data["NatActiveS"] as bool? ?? false,
        'NatActiveSID': data["NatActiveSV"]?.toString() ?? "",
        'NatRafTeam': data["NatRafTeam"] as bool? ?? false,
        'NatRafTeamVID': data["NatRafTeamV"]?.toString() ?? "",
      };
      // ✅ Print the values
      debugPrint("Fetched myad: $myAds");
    } else {
      print("No ad data available, using default values.");
      // Keep default values from initialization
    }
  } catch (e) {
    print("Error fetching ad values: $e");
    // Keep default values from initialization
  }
}
