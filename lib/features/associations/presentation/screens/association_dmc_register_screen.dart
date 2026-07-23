import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/datasources/dmc_datasource.dart';

/// DMC Supplier Registration — multi-step form (port of the old app's flow).
///
/// Steps: Company Info → Destinations → Services → Contact → Documents →
/// Payment & Terms. Same Razorpay order-then-pay-then-submit flow, same
/// validation rules; restyled to the new app's design system.
class AssociationDmcRegisterScreen extends ConsumerStatefulWidget {
  const AssociationDmcRegisterScreen({super.key});

  @override
  ConsumerState<AssociationDmcRegisterScreen> createState() =>
      _AssociationDmcRegisterScreenState();
}

class _AssociationDmcRegisterScreenState
    extends ConsumerState<AssociationDmcRegisterScreen> {
  late final DmcDatasource _ds;

  int _currentStep = 0;
  static const int _totalSteps = 6;
  static const _stepLabels = [
    'Company Info',
    'Destinations',
    'Services',
    'Contact',
    'Documents',
    'Payment & Terms',
  ];

  // ── Step 0 — Company Info ──
  final _step0Key = GlobalKey<FormState>();
  final _companyNameCtrl = TextEditingController();
  String? _supplierType;
  static const List<String> _supplierTypes = [
    'Indian Supplier (DMC) – Registration Fee: ₹1,000',
    'International Supplier (DMC) – Registration Fee: USD 25',
  ];
  final _websiteCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();

  // ── Step 1 — Destinations ──
  final _step1Key = GlobalKey<FormState>();
  final _destinationsCtrl = TextEditingController();

  // ── Step 2 — Services ──
  final Set<String> _selectedServices = {};
  static const List<String> _availableServices = [
    'Hotel Contracting',
    'Sightseeing',
    'Transfers',
    'Guides',
    'FIT Packages',
    'Group Tours',
    'MICE',
  ];

  // ── Step 3 — Contact ──
  final _step3Key = GlobalKey<FormState>();
  final _contactNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // ── Step 4 — Documents ──
  final Set<String> _selectedDocTypes = {};
  static const List<String> _documentTypes = [
    'Registration Certificate',
    'GST Certificate',
    'Aadhaar Card',
  ];
  final Map<String, PlatformFile?> _uploadedFiles = {};

  // ── Step 5 — Payment & Terms ──
  final _couponCtrl = TextEditingController();
  bool _agreedToTerms = false;

  // ── Razorpay ──
  final Razorpay _razorpay = Razorpay();
  bool _isSubmitting = false;

  String get _rawSupplierType {
    if (_supplierType == null) return '';
    return _supplierType!.split(' – ').first;
  }

  @override
  void initState() {
    super.initState();
    _ds = DmcDatasource(ref.read(dioProvider));
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _companyNameCtrl.dispose();
    _websiteCtrl.dispose();
    _countryCtrl.dispose();
    _stateCtrl.dispose();
    _destinationsCtrl.dispose();
    _contactNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────
  //  API 1: Create Razorpay order
  // ────────────────────────────────────────
  Future<void> _createOrderAndPay() async {
    setState(() => _isSubmitting = true);
    try {
      final data = await _ds.createSupplierOrder(
        supplierType: _rawSupplierType,
        couponCode: _couponCtrl.text.trim(),
      );
      if (data['success'] == true) {
        final order = data['order'] as Map<String, dynamic>;
        _openRazorpay(
          orderId: order['id'] as String,
          amount: order['amount'] as int,
          currency: order['currency'] as String? ?? 'INR',
        );
      } else {
        _showError(data['message']?.toString() ?? 'Failed to create order');
      }
    } catch (e) {
      log('Order creation error: $e');
      _showError('Failed to create order. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _openRazorpay({
    required String orderId,
    required int amount,
    required String currency,
  }) {
    final options = {
      'key': 'rzp_live_SJyy6qt0I2DKtU',
      'amount': amount,
      'currency': currency,
      'name': 'Travel World Online',
      'description': 'DMC Supplier Registration Fee',
      'order_id': orderId,
      'prefill': {
        'contact': _phoneCtrl.text,
        'email': _emailCtrl.text,
      },
      'external': {
        'wallets': ['paytm'],
      },
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log('Payment Success: ${response.paymentId}');
    _submitRegistration(
      razorpayPaymentId: response.paymentId!,
      razorpayOrderId: response.orderId!,
      razorpaySignature: response.signature!,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log('Payment Error: ${response.message}');
    _showError('Payment failed: ${response.message ?? 'Unknown error'}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External Wallet: ${response.walletName}');
  }

  // ────────────────────────────────────────
  //  API 2: Submit registration (multipart)
  // ────────────────────────────────────────
  Future<void> _submitRegistration({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    setState(() => _isSubmitting = true);
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('companyName', _companyNameCtrl.text.trim()),
        MapEntry('supplierType', _rawSupplierType),
        MapEntry('website', _websiteCtrl.text.trim()),
        MapEntry('country', _countryCtrl.text.trim()),
        MapEntry('state', _stateCtrl.text.trim()),
        MapEntry('destinations', _destinationsCtrl.text.trim()),
        MapEntry('contactName', _contactNameCtrl.text.trim()),
        MapEntry('email', _emailCtrl.text.trim()),
        MapEntry('phone', _phoneCtrl.text.trim()),
        MapEntry('razorpay_order_id', razorpayOrderId),
        MapEntry('razorpay_payment_id', razorpayPaymentId),
        MapEntry('razorpay_signature', razorpaySignature),
        MapEntry('agreedToTerms', 'true'),
      ]);

      if (_couponCtrl.text.trim().isNotEmpty) {
        formData.fields.add(MapEntry('couponCode', _couponCtrl.text.trim()));
      }
      for (final service in _selectedServices) {
        formData.fields.add(MapEntry('services', service));
      }
      for (final docType in _selectedDocTypes) {
        final file = _uploadedFiles[docType];
        if (file == null) continue;
        formData.fields.add(MapEntry('documentList', docType));
        if (file.path != null) {
          formData.files.add(MapEntry(
            docType,
            await MultipartFile.fromFile(file.path!, filename: file.name),
          ));
        }
      }

      final data = await _ds.submitSupplierRegistration(formData);
      if (data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful! Registration submitted.'),
              backgroundColor: Color(0xFF2D7A4F),
            ),
          );
          context.pop();
        }
      } else {
        _showError(data['message']?.toString() ?? 'Registration failed');
      }
    } catch (e) {
      log('Registration error: $e');
      _showError('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickFile(String docType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _uploadedFiles[docType] = result.files.first);
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (!(_step0Key.currentState?.validate() ?? false)) return false;
        if (_supplierType == null) {
          _showError('Please select a supplier type');
          return false;
        }
        return true;
      case 1:
        return _step1Key.currentState?.validate() ?? false;
      case 2:
        if (_selectedServices.isEmpty) {
          _showError('Please select at least one service');
          return false;
        }
        return true;
      case 3:
        return _step3Key.currentState?.validate() ?? false;
      case 4:
        if (_selectedDocTypes.length < 2) {
          _showError('Please select at least 2 documents');
          return false;
        }
        for (final doc in _selectedDocTypes) {
          if (_uploadedFiles[doc] == null) {
            _showError('Please upload $doc');
            return false;
          }
        }
        return true;
      case 5:
        if (!_agreedToTerms) {
          _showError('Please agree to the terms and conditions');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _next() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < _totalSteps - 1) setState(() => _currentStep++);
  }

  void _back() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _onSubmit() {
    if (!_validateCurrentStep()) return;
    _createOrderAndPay();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFC0392B)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: topPad + 64),
              _buildProgressBar(colors),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: _buildStep(colors),
                ),
              ),
              _buildBottomBar(colors),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: colors.surfacePrimary,
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.surfaceCard,
                        border: Border.all(color: colors.lineSoft),
                      ),
                      child: Icon(Icons.arrow_back, size: 18, color: colors.ink900),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Supplier Registration',
                    style: AppTypography.displayMd.copyWith(
                        color: colors.ink900, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(AppColorScheme colors) {
    return Container(
      color: colors.surfaceTertiary,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: List.generate(_stepLabels.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (i > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isDone || isActive ? colors.goldPrimary : colors.lineSoft,
                        ),
                      ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone || isActive ? colors.goldPrimary : colors.lineSoft,
                      ),
                      child: Center(
                        child: isDone
                            ? Icon(Icons.check, size: 13, color: colors.ink900)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? colors.ink900 : colors.ink600,
                                ),
                              ),
                      ),
                    ),
                    if (i < _stepLabels.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isDone ? colors.goldPrimary : colors.lineSoft,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _stepLabels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive || isDone ? colors.ink900 : colors.ink400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar(AppColorScheme colors) {
    final isLast = _currentStep == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border(top: BorderSide(color: colors.lineSoft)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _back,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.lineSoft),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Back',
                      style: AppTypography.label
                          .copyWith(color: colors.ink600, fontWeight: FontWeight.w700)),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _isSubmitting ? null : (isLast ? _onSubmit : _next),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.goldPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.ink900),
                          )
                        : Text(
                            isLast ? 'Pay & Submit' : 'Next',
                            style: AppTypography.label.copyWith(
                                color: colors.ink900, fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(AppColorScheme colors) {
    switch (_currentStep) {
      case 0:
        return _buildCompanyInfoStep(colors);
      case 1:
        return _buildDestinationsStep(colors);
      case 2:
        return _buildServicesStep(colors);
      case 3:
        return _buildContactStep(colors);
      case 4:
        return _buildDocumentsStep(colors);
      case 5:
        return _buildPaymentTermsStep(colors);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCompanyInfoStep(AppColorScheme colors) {
    return Form(
      key: _step0Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(colors, 'Supplier Registration',
              'Register as a Destination Management Company (DMC)'),
          const SizedBox(height: 20),
          _field(colors,
              controller: _companyNameCtrl,
              label: 'Company Name',
              hint: 'Company Name',
              validator: _required('Company name is required')),
          Text('Supplier Type',
              style: AppTypography.label
                  .copyWith(color: colors.ink900, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.lineSoft),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _supplierType,
                isExpanded: true,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Select Supplier Type',
                      style: AppTypography.body.copyWith(color: colors.ink400, fontSize: 13)),
                ),
                items: _supplierTypes
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(t,
                                style:
                                    AppTypography.body.copyWith(color: colors.ink900, fontSize: 13)),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _supplierType = v),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _field(colors,
              controller: _websiteCtrl,
              label: 'Website',
              hint: 'Website URL',
              keyboard: TextInputType.url),
          _field(colors,
              controller: _countryCtrl,
              label: 'Country',
              hint: 'Country',
              validator: _required('Country is required')),
          _field(colors,
              controller: _stateCtrl,
              label: 'State',
              hint: 'State / Region',
              validator: _required('State is required')),
        ],
      ),
    );
  }

  Widget _buildDestinationsStep(AppColorScheme colors) {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(colors, 'Destinations Covered',
              'Register as a Destination Management Company (DMC)'),
          const SizedBox(height: 20),
          _field(colors,
              controller: _destinationsCtrl,
              label: 'Destinations Covered',
              hint: 'Country / City / Region',
              maxLines: 2,
              validator: _required('Destinations are required')),
        ],
      ),
    );
  }

  Widget _buildServicesStep(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader(
            colors, 'Services Offered', 'Register as a Destination Management Company (DMC)'),
        const SizedBox(height: 20),
        ...List.generate((_availableServices.length / 2).ceil(), (rowIndex) {
          final i1 = rowIndex * 2;
          final i2 = i1 + 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(child: _pillCheckbox(colors, _availableServices[i1], _selectedServices)),
                const SizedBox(width: 8),
                if (i2 < _availableServices.length)
                  Expanded(child: _pillCheckbox(colors, _availableServices[i2], _selectedServices))
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildContactStep(AppColorScheme colors) {
    return Form(
      key: _step3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeader(
              colors, 'Contact Information', 'Register as a Destination Management Company (DMC)'),
          const SizedBox(height: 20),
          _field(colors,
              controller: _contactNameCtrl,
              label: 'Contact Name',
              hint: 'Contact Name',
              validator: _required('Contact name is required')),
          _field(colors,
              controller: _emailCtrl,
              label: 'Email',
              hint: 'Email Address',
              keyboard: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                return null;
              }),
          _field(colors,
              controller: _phoneCtrl,
              label: 'Phone',
              hint: 'Phone Number',
              keyboard: TextInputType.phone,
              validator: _required('Phone number is required')),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader(colors, 'Documents', 'Register as a Destination Management Company (DMC)'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.warning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: colors.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Note',
                        style: AppTypography.label
                            .copyWith(color: colors.ink900, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Submission of any two of the following documents is mandatory.',
                        style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Please Select document',
            style: AppTypography.label
                .copyWith(color: colors.ink900, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _docTypeCheckbox(colors, _documentTypes[0])),
            const SizedBox(width: 8),
            Expanded(child: _docTypeCheckbox(colors, _documentTypes[1])),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _docTypeCheckbox(colors, _documentTypes[2])),
            const Expanded(child: SizedBox()),
          ],
        ),
        const SizedBox(height: 16),
        ..._selectedDocTypes.map((doc) => _buildFileUploadSection(colors, doc)),
      ],
    );
  }

  Widget _docTypeCheckbox(AppColorScheme colors, String docType) {
    final selected = _selectedDocTypes.contains(docType);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedDocTypes.remove(docType);
            _uploadedFiles.remove(docType);
          } else {
            _selectedDocTypes.add(docType);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? colors.goldPrimary.withValues(alpha: 0.08) : colors.surfaceCard,
          border: Border.all(color: selected ? colors.goldPrimary : colors.lineSoft),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18,
              color: selected ? colors.goldPrimary : colors.ink400,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(docType,
                  style: AppTypography.caption.copyWith(color: colors.ink900, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadSection(AppColorScheme colors, String docType) {
    final file = _uploadedFiles[docType];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(docType,
              style: AppTypography.label
                  .copyWith(color: colors.ink900, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: colors.lineSoft),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _pickFile(docType),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: colors.surfaceTertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Choose File',
                        style: AppTypography.caption
                            .copyWith(color: colors.ink900, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    file?.name ?? 'No file chosen',
                    style: AppTypography.caption.copyWith(
                        color: file != null ? colors.ink900 : colors.ink400, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTermsStep(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader(colors, 'Payment & Terms', 'Register as a Destination Management Company (DMC)'),
        const SizedBox(height: 20),
        _field(colors, controller: _couponCtrl, label: 'Coupon Code (Optional)', hint: 'Enter coupon code'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.warning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: colors.warning, size: 20),
                  const SizedBox(width: 8),
                  Text('Payment Disclaimer',
                      style: AppTypography.label
                          .copyWith(color: colors.ink900, fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '• Supplier registration fees are non-refundable and payable at the time of application.\n'
                '• Registration approval is subject to document verification and internal compliance checks.\n'
                '• Submission of payment does not guarantee automatic approval of supplier registration.',
                style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.goldPrimary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.goldPrimary.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📜 ', style: TextStyle(fontSize: 15)),
                  Text('Supplier Terms & Conditions',
                      style: AppTypography.label
                          .copyWith(color: colors.ink900, fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              Text('Supplier Registration – Terms & Conditions:',
                  style: AppTypography.caption
                      .copyWith(color: colors.ink900, fontWeight: FontWeight.w600, fontSize: 11)),
              const SizedBox(height: 6),
              Text(
                '• By registering as a supplier, you confirm that all information and documents submitted are true, valid, and legally compliant.\n\n'
                '• The platform reserves the right to approve, reject, suspend, or cancel any supplier registration without prior notice if discrepancies, misrepresentation, or non-compliance are found.\n\n'
                '• The platform shall not be liable for any business loss arising from suspension or termination of supplier access.',
                style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 11, height: 1.4),
              ),
              const SizedBox(height: 10),
              Text('Refund Policy:',
                  style: AppTypography.caption
                      .copyWith(color: colors.ink900, fontWeight: FontWeight.w600, fontSize: 11)),
              const SizedBox(height: 6),
              Text(
                '• If the supplier registration is rejected due to verification failure, the registration fee will be refunded to the original payment source within 7-10 working days.\n\n'
                '• No refund shall be applicable in cases of false, misleading, or incomplete information submitted by the supplier.',
                style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 11, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _agreedToTerms ? Icons.check_box : Icons.check_box_outline_blank,
                size: 22,
                color: _agreedToTerms ? colors.goldPrimary : colors.ink400,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12.5),
                    children: [
                      const TextSpan(text: 'I have read and agree to the '),
                      TextSpan(
                        text: 'Payment Disclaimer',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.ink900,
                            decoration: TextDecoration.underline),
                      ),
                      const TextSpan(text: ', '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.ink900,
                            decoration: TextDecoration.underline),
                      ),
                      const TextSpan(text: ', and '),
                      TextSpan(
                        text: 'Refund Policy',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.ink900,
                            decoration: TextDecoration.underline),
                      ),
                      const TextSpan(text: ' outlined above.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepHeader(AppColorScheme colors, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTypography.displayMd
                .copyWith(color: colors.ink900, fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTypography.caption.copyWith(color: colors.ink600, fontSize: 12)),
      ],
    );
  }

  Widget _field(
    AppColorScheme colors, {
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.label
                  .copyWith(color: colors.ink900, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            validator: validator,
            style: AppTypography.body.copyWith(color: colors.ink900, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.body.copyWith(color: colors.ink400, fontSize: 13),
              filled: true,
              fillColor: colors.surfaceCard,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.lineSoft)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.lineSoft)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.goldPrimary, width: 1.5)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colors.error)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillCheckbox(AppColorScheme colors, String label, Set<String> group) {
    final selected = group.contains(label);
    return GestureDetector(
      onTap: () => setState(() => selected ? group.remove(label) : group.add(label)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? colors.goldPrimary.withValues(alpha: 0.08) : colors.surfaceCard,
          border: Border.all(color: selected ? colors.goldPrimary : colors.lineSoft),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18,
              color: selected ? colors.goldPrimary : colors.ink400,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: AppTypography.caption.copyWith(color: colors.ink900, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  String? Function(String?) _required(String msg) {
    return (v) => (v == null || v.trim().isEmpty) ? msg : null;
  }
}
