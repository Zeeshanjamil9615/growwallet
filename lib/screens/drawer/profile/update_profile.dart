import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import '../../../api_service/api_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/custom_snackbar.dart';
import 'profile_controller.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _walletAddressController = TextEditingController();
  final _phoneController = TextEditingController();

  final ApiService _apiService = ApiService();
  final ProfileController profileController = Get.put(ProfileController());

  String selectedWalletType = 'BEP-20'; // Default value
  Country selectedCountry = Country.parse('PK'); // Default to Pakistan

  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _loadUserData() {
    // Load existing user data if available
    String? walletType = profileController.userProfile['wallet_type'];

    // Fix: Ensure selectedWalletType is always a valid option
    if (walletType != null && (walletType == 'BEP-20' || walletType == 'TRC-20')) {
      selectedWalletType = walletType;
    } else {
      selectedWalletType = 'BEP-20'; // Default fallback
    }

    _walletAddressController.text = profileController.userProfile['wallet_address'] ?? "";
    _nameController.text = profileController.userProfile['name'] ?? "";
    
    // Handle phone number and country detection
    String? phoneNumber = profileController.userProfile['phone'];
  if (phoneNumber != null && phoneNumber.isNotEmpty) {
    print('Raw phone number from API: $phoneNumber'); // Add this debug line
    _parsePhoneNumber(phoneNumber);
  } else {
    selectedCountry = Country.parse('PK');
  }
}

  // Function to parse phone number and extract country code
 // Function to parse phone number and extract country code
// Function to parse phone number and extract country code
// Function to parse phone number and extract country code
// Function to parse phone number and extract country code
void _parsePhoneNumber(String fullPhoneNumber) {
  // Remove leading + if present
  if (fullPhoneNumber.startsWith('+')) {
    fullPhoneNumber = fullPhoneNumber.substring(1);
  }

  print('Parsing phone number: $fullPhoneNumber'); // Debug log

  // Extended country codes mapping with more accurate codes
  Map<String, String> phoneCodeToCountry = {
    // 3-digit codes (check first to avoid conflicts)
    '971': 'AE',  // UAE
    '966': 'SA',  // Saudi Arabia  
    '968': 'OM',  // Oman
    '974': 'QA',  // Qatar
    '973': 'BH',  // Bahrain
    '965': 'KW',  // Kuwait
    '962': 'JO',  // Jordan
    '960': 'MV',  // Maldives
    '961': 'LB',  // Lebanon
    '963': 'SY',  // Syria
    '964': 'IQ',  // Iraq
    '967': 'YE',  // Yemen
    '970': 'PS',  // Palestine
    '972': 'IL',  // Israel
    '975': 'BT',  // Bhutan
    '976': 'MN',  // Mongolia
    '977': 'NP',  // Nepal
    '992': 'TJ',  // Tajikistan
    '993': 'TM',  // Turkmenistan
    '994': 'AZ',  // Azerbaijan
    '995': 'GE',  // Georgia
    '996': 'KG',  // Kyrgyzstan
    '998': 'UZ',  // Uzbekistan
    '880': 'BD',  // Bangladesh (3 digits)
    
    // 2-digit codes
    '92': 'PK',   // Pakistan
    '91': 'IN',   // India
    '90': 'TR',   // Turkey
    '86': 'CN',   // China
    '82': 'KR',   // South Korea
    '81': 'JP',   // Japan
    '66': 'TH',   // Thailand
    '65': 'SG',   // Singapore
    '60': 'MY',   // Malaysia
    '63': 'PH',   // Philippines
    '62': 'ID',   // Indonesia
    '84': 'VN',   // Vietnam
    '55': 'BR',   // Brazil
    '54': 'AR',   // Argentina
    '52': 'MX',   // Mexico
    '51': 'PE',   // Peru
    '56': 'CL',   // Chile
    '57': 'CO',   // Colombia
    '58': 'VE',   // Venezuela
    '49': 'DE',   // Germany
    '44': 'GB',   // UK
    '33': 'FR',   // France
    '39': 'IT',   // Italy
    '34': 'ES',   // Spain
    '31': 'NL',   // Netherlands
    '32': 'BE',   // Belgium
    '41': 'CH',   // Switzerland
    '43': 'AT',   // Austria
    '45': 'DK',   // Denmark
    '46': 'SE',   // Sweden
    '47': 'NO',   // Norway
    '48': 'PL',   // Poland
    '30': 'GR',   // Greece
    '36': 'HU',   // Hungary
    '40': 'RO',   // Romania
    '42': 'CZ',   // Czech Republic
    '20': 'EG',   // Egypt
    '27': 'ZA',   // South Africa
    '98': 'IR',   // Iran
    '93': 'AF',   // Afghanistan
    '95': 'MM',   // Myanmar
    '94': 'LK',   // Sri Lanka
    
    // 1-digit codes (check last to avoid conflicts)
    '1': 'US',    // USA/Canada
    '7': 'RU',    // Russia/Kazakhstan
  };

  String? matchedCountryCode;
  String remainingNumber = fullPhoneNumber;

  // Special handling for Pakistan numbers that might have incorrect prefixes
  // Check if the number contains Pakistani mobile patterns
  if (fullPhoneNumber.contains('92') && fullPhoneNumber.length >= 5) {
    // Look for Pakistani mobile patterns (923, 924, 925, etc.)
    RegExp pakistanPattern = RegExp(r'92[3-9]\d');
    Match? match = pakistanPattern.firstMatch(fullPhoneNumber);
    
    if (match != null) {
      int startIndex = match.start;
      // Extract from where Pakistan code starts
      String correctedNumber = fullPhoneNumber.substring(startIndex);
      print('Detected Pakistani number pattern: $correctedNumber'); // Debug log
      
      if (correctedNumber.startsWith('92')) {
        setState(() {
          selectedCountry = Country.parse('PK');
          _phoneController.text = _removeLeadingZeros(correctedNumber.substring(2));
        });
        print('Fixed Pakistani number - Country: Pakistan (+92), Phone: ${_phoneController.text}');
        return;
      }
    }
  }

  // Sort codes by length (longest first for accuracy)
  List<String> sortedCodes = phoneCodeToCountry.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  print('Trying to match codes: $sortedCodes'); // Debug log

  // Try to match country codes
  for (String code in sortedCodes) {
    if (fullPhoneNumber.startsWith(code)) {
      matchedCountryCode = phoneCodeToCountry[code];
      remainingNumber = fullPhoneNumber.substring(code.length);
      print('Matched code: $code for country: $matchedCountryCode'); // Debug log
      print('Remaining number: $remainingNumber'); // Debug log
      
      // Additional validation for Pakistani numbers
      if (code == '44' && remainingNumber.startsWith('92')) {
        print('Detected incorrect UK prefix for Pakistani number, correcting...'); // Debug log
        setState(() {
          selectedCountry = Country.parse('PK');
          _phoneController.text = _removeLeadingZeros(remainingNumber.substring(2));
        });
        print('Corrected to Pakistani number - Country: Pakistan (+92), Phone: ${_phoneController.text}');
        return;
      }
      
      break;
    }
  }

  if (matchedCountryCode != null) {
    try {
      setState(() {
        selectedCountry = Country.parse(matchedCountryCode!);
        _phoneController.text = _removeLeadingZeros(remainingNumber);
      });
      print('Successfully set country: ${selectedCountry.name} (+${selectedCountry.phoneCode})'); // Debug log
    } catch (e) {
      print('Error parsing country: $e'); // Debug log
      // Fallback to Pakistan if parsing fails
      setState(() {
        selectedCountry = Country.parse('PK');
        _phoneController.text = _removeLeadingZeros(fullPhoneNumber);
      });
    }
  } else {
    print('No country code matched, defaulting to Pakistan'); // Debug log
    // If no country code matched, assume Pakistan
    setState(() {
      selectedCountry = Country.parse('PK');
      _phoneController.text = _removeLeadingZeros(fullPhoneNumber);
    });
  }
  
  // Final debug log
  print('Final result - Country: ${selectedCountry.name} (+${selectedCountry.phoneCode}), Phone: ${_phoneController.text}');
}

// Enhanced function to remove leading zeros from phone number
String _removeLeadingZeros(String phoneNumber) {
  if (phoneNumber.isEmpty) return phoneNumber;

  // Remove all leading zeros
  String cleaned = phoneNumber.replaceFirst(RegExp(r'^0+'), '');

  // If all digits were zeros or empty after removing zeros, return original or '0'
  if (cleaned.isEmpty) {
    return phoneNumber.isNotEmpty ? '0' : '';
  }

  return cleaned;
} void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _walletAddressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Function to remove leading zeros from phone number

  Future<void> _updateProfile() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
  });

  try {
    // Remove leading zeros from phone number before sending
    String cleanedPhone = _removeLeadingZeros(_phoneController.text);
    final fullPhoneNumber = '${selectedCountry.phoneCode}$cleanedPhone';

    print('=== Profile Update Request ===');
    print('Name: ${_nameController.text.trim()}');
    print('Wallet Address: ${_walletAddressController.text.trim()}');
    print('Phone: $fullPhoneNumber');
    print('Wallet Type: $selectedWalletType');
    print('===============================');

    final response = await _apiService.updateProfile(
      name: _nameController.text.trim(),
      walletAddress: _walletAddressController.text.trim(),
      phone: fullPhoneNumber,
      walletType: selectedWalletType,
    );

    print('=== API Response ===');
    print('Response: $response');
    
    if (response != null) {
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        // Check if response data contains success indicator
        final responseData = response.data;
        bool isSuccess = false;
        
        if (responseData is Map<String, dynamic>) {
          // Check various success indicators
          isSuccess = responseData['success'] == true || 
                     responseData['status'] == 'success' ||
                     responseData['message']?.toString().toLowerCase().contains('success') == true ||
                     response.statusCode == 200;
          
          print('Success indicator: $isSuccess');
          print('Response message: ${responseData['message']}');
        } else {
          // If response data is not a map, assume success based on status code
          isSuccess = true;
        }
        
        if (isSuccess) {
          CustomSnackBar.success(
            responseData is Map ? (responseData['message'] ?? 'Profile updated successfully') : 'Profile updated successfully',
            title: 'Success',
          );
          
          // Refresh profile data before navigating back
          await profileController.refreshProfile();
          
          // Navigate back to profile screen
          // Get.back();
        } else {
          print('Request failed with success=false');
          CustomSnackBar.error(
            responseData is Map ? (responseData['message'] ?? 'Failed to update profile') : 'Failed to update profile',
            title: 'Error',
          );
        }
      } else {
        print('HTTP Error - Status Code: ${response.statusCode}');
        CustomSnackBar.error(
          'Server error (${response.statusCode}). Please try again.',
          title: 'Error',
        );
      }
    } else {
      print('Response is null - API call failed');
      CustomSnackBar.error(
        'No response from server. Please check your connection.',
        title: 'Error',
      );
    }
  } catch (e, stackTrace) {
    print('=== Exception occurred ===');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    print('========================');
    
    CustomSnackBar.error(
      'An unexpected error occurred: ${e.toString()}',
      title: 'Error',
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
} @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: AppBar(
        backgroundColor: MyColor.getAppbarBgColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: MyColor.getAppbarTitleColor(),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Update Your Profile',
          style: TextStyle(
            color: MyColor.getAppbarTitleColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 30),
                  _buildNameField(),
                  const SizedBox(height: 20),
                  _buildPhoneField(),
                  const SizedBox(height: 20),
                  _buildWalletAddressField(),
                  const SizedBox(height: 20),
                  _buildWalletTypeDropdown(),
                  const SizedBox(height: 40),
                  _buildUpdateButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: MyColor.getGCoinPrimaryGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinShadowColor(),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update your personal information',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return _buildAnimatedField(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Full Name',
            style: TextStyle(
              color: MyColor.getLabelTextColor(),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: MyColor.getInputTextColor()),
            decoration: _buildInputDecoration(
              hintText: 'Enter your full name',
              prefixIcon: Icons.person_outline,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWalletAddressField() {
    return _buildAnimatedField(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet Address',
            style: TextStyle(
              color: MyColor.getLabelTextColor(),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _walletAddressController,
            style: TextStyle(color: MyColor.getInputTextColor()),
            decoration: _buildInputDecoration(
              hintText: 'Enter your wallet address',
              prefixIcon: Icons.account_balance_wallet_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your wallet address';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return _buildAnimatedField(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phone Number',
            style: TextStyle(
              color: MyColor.getLabelTextColor(),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: MyColor.getTextFieldBg(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MyColor.getFieldEnableBorderColor(),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      countryListTheme: CountryListThemeData(
                        backgroundColor: MyColor.getDialogBg(),
                        textStyle: TextStyle(color: MyColor.getTextColor()),
                      ),
                      onSelect: (Country country) {
                        setState(() {
                          selectedCountry = country;
                        });
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedCountry.flagEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+${selectedCountry.phoneCode}',
                          style: TextStyle(
                            color: MyColor.getTextColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: MyColor.getTextColor(),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    style: TextStyle(color: MyColor.getInputTextColor()),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      // Custom formatter to remove leading zeros
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        if (newValue.text.isEmpty) return newValue;

                        // Remove leading zeros from the new input
                        String cleaned = _removeLeadingZeros(newValue.text);

                        return TextEditingValue(
                          text: cleaned,
                          selection: TextSelection.collapsed(offset: cleaned.length),
                        );
                      }),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter phone number',
                      hintStyle: TextStyle(color: MyColor.getHintTextColor()),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletTypeDropdown() {
    return _buildAnimatedField(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet Type',
            style: TextStyle(
              color: MyColor.getLabelTextColor(),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: MyColor.getTextFieldBg(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MyColor.getFieldEnableBorderColor(),
                width: 1.5,
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedWalletType,
              style: TextStyle(color: MyColor.getInputTextColor()),
              dropdownColor: MyColor.getCardBg(),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.account_balance_wallet,
                  color: MyColor.getGCoinPrimaryColor(),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: ['BEP-20', 'TRC-20']
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(
                  type,
                  style: TextStyle(color: MyColor.getTextColor()),
                ),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedWalletType = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return _buildAnimatedField(
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: MyColor.getGCoinPrimaryGradient(),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MyColor.getGCoinPrimaryColor().withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _updateProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.update,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Update Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedField({required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: MyColor.getCardBg(),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MyColor.getGCoinShadowColor(),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: MyColor.getHintTextColor()),
      prefixIcon: Icon(
        prefixIcon,
        color: MyColor.getGCoinPrimaryColor(),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: MyColor.getFieldEnableBorderColor(),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: MyColor.getFieldEnableBorderColor(),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: MyColor.getGCoinPrimaryColor(),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: MyColor.getErrorColor(),
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: MyColor.getErrorColor(),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: MyColor.getTextFieldBg(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}