import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/ppp_remote_datasource.dart';
import '../../../../core/network/dio_client.dart';

const _kTypes = [
  'Tour operator',
  'Travel Agent',
  'Hotel',
  'Service Provider',
  'Guide',
];

class PPPRegisterScreen extends ConsumerStatefulWidget {
  const PPPRegisterScreen({super.key, required this.pppId});
  final String pppId;

  @override
  ConsumerState<PPPRegisterScreen> createState() => _PPPRegisterScreenState();
}

class _PPPRegisterScreenState extends ConsumerState<PPPRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedType;
  String? _imagePath;
  bool _privacyAccepted = false;
  bool _submitting = false;

  final _fnameCtrl = TextEditingController();
  final _lnameCtrl = TextEditingController();
  final _cnameCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _fnameCtrl.dispose();
    _lnameCtrl.dispose();
    _cnameCtrl.dispose();
    _websiteCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    _pinCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      setState(() => _imagePath = file.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_privacyAccepted) {
      _showSnack('Please accept the privacy policy to continue.');
      return;
    }

    setState(() => _submitting = true);

    try {
      final ds = PppRemoteDatasource(ref.read(dioProvider));
      final ok = await ds.submitRegistration(
        {
          'pppId': widget.pppId,
          'type': _selectedType!,
          'fname': _fnameCtrl.text.trim(),
          'lname': _lnameCtrl.text.trim(),
          'cname': _cnameCtrl.text.trim(),
          'website': _websiteCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'state': _stateCtrl.text.trim(),
          'City': _cityCtrl.text.trim(),
          'pincode': _pinCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
        },
        imagePath: _imagePath,
      );

      if (!mounted) return;

      if (ok) {
        _showSnack('Registration submitted successfully!');
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) context.pop();
      } else {
        _showSnack('Submission failed. Please try again.');
      }
    } catch (_) {
      if (mounted) _showSnack('An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'DMSans')),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: colors.surfacePrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.ink900),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Stakeholder Registration',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: colors.ink900,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            _sectionHeader('Basic Information', colors),
            // Type dropdown
            _DropdownField(
              label: 'Stakeholder Type',
              value: _selectedType,
              items: _kTypes,
              colors: colors,
              onChanged: (v) => setState(() => _selectedType = v),
              validator: (v) =>
                  v == null ? 'Please select a stakeholder type' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TextField(
                    ctrl: _fnameCtrl,
                    label: 'First Name',
                    colors: colors,
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TextField(
                    ctrl: _lnameCtrl,
                    label: 'Last Name',
                    colors: colors,
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TextField(
              ctrl: _cnameCtrl,
              label: 'Company / Firm Name',
              colors: colors,
              validator: _required,
            ),
            const SizedBox(height: 24),
            _sectionHeader('Contact Details', colors),
            _TextField(
              ctrl: _emailCtrl,
              label: 'Email',
              colors: colors,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _TextField(
              ctrl: _phoneCtrl,
              label: 'Phone',
              colors: colors,
              keyboardType: TextInputType.phone,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _TextField(
              ctrl: _websiteCtrl,
              label: 'Website (optional)',
              colors: colors,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            _sectionHeader('Location', colors),
            _TextField(
              ctrl: _addressCtrl,
              label: 'Address',
              colors: colors,
              maxLines: 2,
              validator: _required,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TextField(
                    ctrl: _stateCtrl,
                    label: 'State / Country',
                    colors: colors,
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TextField(
                    ctrl: _cityCtrl,
                    label: 'City',
                    colors: colors,
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TextField(
              ctrl: _pinCtrl,
              label: 'Pin Code',
              colors: colors,
              keyboardType: TextInputType.number,
              validator: _required,
            ),
            const SizedBox(height: 24),
            _sectionHeader('About', colors),
            _TextField(
              ctrl: _descCtrl,
              label: 'Description (optional)',
              colors: colors,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            _sectionHeader('ID Proof (optional)', colors),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: colors.lineSoft, style: BorderStyle.solid),
                ),
                child: _imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file_outlined,
                              color: colors.ink400),
                          const SizedBox(width: 8),
                          Text(
                            'Tap to select from gallery',
                            style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 13,
                                color: colors.ink400),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            // Privacy checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _privacyAccepted,
                    activeColor: colors.goldPrimary,
                    onChanged: (v) =>
                        setState(() => _privacyAccepted = v ?? false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'I agree to the privacy policy and consent to my data being '
                    'used for stakeholder directory purposes.',
                    style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        color: colors.ink600,
                        height: 1.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Submit button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.goldPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Registration',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  Widget _sectionHeader(String title, AppColorScheme colors) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: colors.ink900,
          ),
        ),
      );
}

// ── Shared form field widgets ─────────────────────────────────────────────────

class _TextField extends StatelessWidget {
  const _TextField({
    required this.ctrl,
    required this.label,
    required this.colors,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController ctrl;
  final String label;
  final AppColorScheme colors;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(fontFamily: 'DMSans', fontSize: 14, color: colors.ink900),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(fontFamily: 'DMSans', fontSize: 13, color: colors.ink400),
        filled: true,
        fillColor: colors.surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.lineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.goldPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.colors,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final String? value;
  final List<String> items;
  final AppColorScheme colors;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: value,
      items: items
          .map((t) => DropdownMenuItem(
                value: t,
                child: Text(t,
                    style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        color: colors.ink900)),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(fontFamily: 'DMSans', fontSize: 13, color: colors.ink400),
        filled: true,
        fillColor: colors.surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.lineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.goldPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dropdownColor: colors.surfaceCard,
      style: TextStyle(fontFamily: 'DMSans', color: colors.ink900),
    );
  }
}
