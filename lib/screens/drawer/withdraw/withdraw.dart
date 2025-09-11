import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../api_service/api_service.dart';
import '../../../utils/app_colors.dart';

class WithdrawScreen extends StatefulWidget {
  final double? currentBalance;
  final double? miningBalance;
  final double? referralBalance;

  const WithdrawScreen({
    Key? key,
    this.currentBalance,
    this.miningBalance,
    this.referralBalance
  }) : super(key: key);

  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _successController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _successAnimation;

  final ApiService _apiService = ApiService();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isSuccess = false;
  double _miningBalance = 0.0;
  double _referralBalance = 0.0;
  String _responseMessage = '';
  bool _showResponseMessage = false;

  // Wallet selection
  String _selectedWallet = 'mining'; // 'mining' or 'referral'


  // Quick amount options
  final List<double> _quickAmounts = [3000, 5000, 10000, 25000, 50000];

  @override
  void initState() {
    super.initState();
    _miningBalance = widget.miningBalance ?? 0.0;
    _referralBalance = widget.referralBalance ?? 0.0;
    _initializeAnimations();
    _loadCurrentBalance();

  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _successController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
  }

  Future<void> _loadCurrentBalance() async {
    if (_miningBalance == 0.0 && _referralBalance == 0.0) {
      try {
        final response = await _apiService.getWalletData();
        if (response != null && response.statusCode == 200) {
          final data = response.data;
          setState(() {
            _miningBalance = double.parse(data['user']['mining_balance']);
            _referralBalance = double.parse(data['user']['referal_balance']);
          });
        }
      } catch (e) {
        // Handle error silently or show message
      }
    }
  }

  Future<void> _processWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if referral wallet is selected
    if (_selectedWallet == 'referral') {
      _showReferralMessage();
      return;
    }

    setState(() {
      _isLoading = true;
      _showResponseMessage = false;
    });

    try {
      final response = await _apiService.withdrawGCoin(
        amount: _amountController.text.trim(),
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;

        setState(() {
          _isLoading = false;
          _responseMessage = data['message'];
          _showResponseMessage = true;
          _isSuccess = data['success'] == true;
        });

        if (_isSuccess) {
          // Update balance if provided in response
          if (data.containsKey('new_balance')) {
            setState(() {
              _miningBalance = double.parse(data['new_balance'].toString());
            });
          }

          // Start success animation
          _successController.forward();

          // Clear form after successful withdrawal
          _amountController.clear();

          // Show success message
          Get.snackbar(
            'Success',
            _responseMessage,
            backgroundColor: MyColor.getGCoinSuccessColor(),
            colorText: Colors.white,
            duration: Duration(seconds: 3),
            snackPosition: SnackPosition.TOP,
          );
        } else {
          // Show error message
          Get.snackbar(
            'Error',
            _responseMessage,
            backgroundColor: MyColor.getGCoinLossColor(),
            colorText: Colors.white,
            duration: Duration(seconds: 3),
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _responseMessage = 'An unexpected error occurred. Please try again.';
        _showResponseMessage = true;
        _isSuccess = false;
      });

      Get.snackbar(
        'Error',
        _responseMessage,
        backgroundColor: MyColor.getGCoinLossColor(),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _showReferralMessage() {
    Get.dialog(
      Dialog(
        backgroundColor: MyColor.getCardBg(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: MyColor.getGCoinSecondaryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.people,
                  color: MyColor.getGCoinSecondaryColor(),
                  size: 40,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Referral Balance',
                style: TextStyle(
                  color: MyColor.getTextColor(),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                '${_referralBalance.toStringAsFixed(2)} G',
                style: TextStyle(
                  color: MyColor.getGCoinSecondaryColor(),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'You must hold this coin for exchange — referral mining income will be withdrawn on the exchange',
                style: TextStyle(
                  color: MyColor.getTextColor().withOpacity(0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.getGCoinSecondaryColor(),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Understood',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectQuickAmount(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(0);
    });
  }

  double get _selectedBalance {
    return _selectedWallet == 'mining' ? _miningBalance : _referralBalance;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount < 3000) {
      return 'Minimum withdrawal amount is 3000 G';
    }

    if (amount > _selectedBalance) {
      return 'Insufficient balance';
    }

    return null;
  }


  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _successController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [


              _buildWalletSelection(),
              SizedBox(height: 20),
              _buildBalanceCard(),

              // Only show withdrawal form and related sections for mining wallet
              if (_selectedWallet == 'mining') ...[
                SizedBox(height: 30),
                _buildWithdrawForm(),
                SizedBox(height: 30),
                _buildQuickAmountSection(),
                SizedBox(height: 40),
                _buildWithdrawButton(),
                if (_showResponseMessage) ...[
                  SizedBox(height: 20),
                  _buildResponseMessage(),
                ],
                if (_isSuccess) ...[
                  SizedBox(height: 30),
                  _buildSuccessAnimation(),
                ],
              ] else ...[
                // Show message for referral wallet
                SizedBox(height: 30),
                _buildReferralMessage(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MyColor.getAppbarBgColor(),
      elevation: 0,
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          'Withdraw G Coins',
          style: TextStyle(
            color: MyColor.getAppbarTitleColor(),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: MyColor.getAppbarTitleColor(),
        ),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildWalletSelection() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MyColor.getCardBg(),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: MyColor.getGCoinShadowColor(),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Wallet',
                style: TextStyle(
                  color: MyColor.getTextColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildWalletOption(
                      'mining',
                      'Mining Balance',
                      Icons.diamond,
                      MyColor.getGCoinPrimaryColor(),
                      _miningBalance,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildWalletOption(
                      'referral',
                      'Referral Balance',
                      Icons.people,
                      MyColor.getGCoinSecondaryColor(),
                      _referralBalance,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletOption(String walletType, String title, IconData icon, Color color, double balance) {
    bool isSelected = _selectedWallet == walletType;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWallet = walletType;
          _amountController.clear(); // Clear amount when switching wallets
          _showResponseMessage = false; // Clear any previous messages
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : MyColor.getScreenBgColor(),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? color : MyColor.getGCoinDividerColor(),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: MyColor.getTextColor(),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              '${balance.toStringAsFixed(2)} G',
              style: TextStyle(
                color: isSelected ? color : MyColor.getTextColor().withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: _selectedWallet == 'mining'
                ? MyColor.getGCoinPrimaryGradient()
                : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MyColor.getGCoinSecondaryColor(),
                MyColor.getGCoinSecondaryColor().withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: (_selectedWallet == 'mining'
                    ? MyColor.getGCoinPrimaryColor()
                    : MyColor.getGCoinSecondaryColor()).withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                _selectedWallet == 'mining' ? Icons.diamond : Icons.people,
                color: Colors.white,
                size: 40,
              ),
              SizedBox(height: 15),
              Text(
                '${_selectedWallet == 'mining' ? 'Mining' : 'Referral'} Balance',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${_selectedBalance.toStringAsFixed(2)} G',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_selectedWallet == 'referral') ...[
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Hold for Exchange',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferralMessage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: MyColor.getCardBg(),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: MyColor.getGCoinShadowColor(),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MyColor.getGCoinSecondaryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.info,
                color: MyColor.getGCoinSecondaryColor(),
                size: 50,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Referral Balance Information',
              style: TextStyle(
                color: MyColor.getTextColor(),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Text(
              'You must hold this coin for exchange — referral mining income will be withdrawn on the exchange',
              style: TextStyle(
                color: MyColor.getTextColor().withOpacity(0.7),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawForm() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: MyColor.getCardBg(),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: MyColor.getGCoinShadowColor(),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Withdrawal Amount',
                style: TextStyle(
                  color: MyColor.getTextColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: _validateAmount,
                style: TextStyle(
                  color: MyColor.getTextColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter amount to withdraw',
                  hintStyle: TextStyle(
                    color: MyColor.getTextFieldHintColor(),
                  ),
                  prefixIcon: Container(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'G',
                      style: TextStyle(
                        color: MyColor.getGCoinPrimaryColor(),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  filled: true,
                  fillColor: MyColor.getTextFieldBg(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: MyColor.getFieldDisableBorderColor(),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: MyColor.getFieldEnableBorderColor(),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: MyColor.getFieldDisableBorderColor(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Minimum withdrawal: 3000 G',
                style: TextStyle(
                  color: MyColor.getTextColor().withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Amount',
            style: TextStyle(
              color: MyColor.getTextColor(),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _quickAmounts.map((amount) {
              bool isSelected = _amountController.text == amount.toStringAsFixed(0);
              Color selectedColor = MyColor.getGCoinPrimaryColor();

              return GestureDetector(
                onTap: () => _selectQuickAmount(amount),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedColor : MyColor.getCardBg(),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: selectedColor.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MyColor.getGCoinShadowColor(),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${amount.toStringAsFixed(0)} G',
                    style: TextStyle(
                      color: isSelected ? Colors.white : MyColor.getTextColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton() {
    Color buttonColor = MyColor.getGCoinPrimaryColor();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _processWithdrawal,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            shadowColor: buttonColor.withOpacity(0.3),
          ),
          child: _isLoading
              ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          )
              : Text(
            'Withdraw G Coins',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponseMessage() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isSuccess
            ? MyColor.getGCoinSuccessColor().withOpacity(0.1)
            : MyColor.getGCoinLossColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _isSuccess
              ? MyColor.getGCoinSuccessColor()
              : MyColor.getGCoinLossColor(),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isSuccess ? Icons.check_circle : Icons.error,
            color: _isSuccess
                ? MyColor.getGCoinSuccessColor()
                : MyColor.getGCoinLossColor(),
            size: 24,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              _responseMessage,
              style: TextStyle(
                color: _isSuccess
                    ? MyColor.getGCoinSuccessColor()
                    : MyColor.getGCoinLossColor(),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return AnimatedBuilder(
      animation: _successAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _successAnimation.value,
          child: Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: MyColor.getGCoinSuccessColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MyColor.getGCoinSuccessColor(),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: MyColor.getGCoinSuccessColor(),
                  size: 60,
                ),
                SizedBox(height: 15),
                Text(
                  'Withdrawal Successful!',
                  style: TextStyle(
                    color: MyColor.getGCoinSuccessColor(),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Your G Coins have been successfully withdrawn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: MyColor.getTextColor().withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}