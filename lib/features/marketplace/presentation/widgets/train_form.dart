import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../providers/marketplace_providers.dart';

class TrainForm extends ConsumerStatefulWidget {
  const TrainForm({super.key});

  @override
  ConsumerState<TrainForm> createState() => _TrainFormState();
}

class _TrainFormState extends ConsumerState<TrainForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _travellersCtrl = TextEditingController();
  final _luxuryCtrl = TextEditingController();
  final _superLuxuryCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _brandCtrl.dispose();
    _travellersCtrl.dispose();
    _luxuryCtrl.dispose();
    _superLuxuryCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(marketplaceDatasourceProvider).submitTrainEnquiry({
        'fname': _firstNameCtrl.text.trim(),
        'lname': _lastNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'brandOfVehicle': _brandCtrl.text.trim(),
        'numberOfTravellers': _travellersCtrl.text.trim(),
        'luxury': _luxuryCtrl.text.trim(),
        'superLuxury': _superLuxuryCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
      });
      if (mounted) {
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Train enquiry submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {
      // Fallback: open the web form if the API endpoint fails
      if (mounted) {
        final launched = await launchUrl(
          Uri.parse(
            'https://travelworldonline.in/travelvideojson/b2b/transport/Default.aspx',
          ),
          mode: LaunchMode.externalApplication,
        );
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enquiry submitted!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clearForm() {
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _phoneCtrl.clear();
    _brandCtrl.clear();
    _travellersCtrl.clear();
    _luxuryCtrl.clear();
    _superLuxuryCtrl.clear();
    _locationCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(title: 'Luxury Train Enquiry', colors: colors),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _firstNameCtrl,
                    label: 'First Name',
                    colors: colors,
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _lastNameCtrl,
                    label: 'Last Name',
                    colors: colors,
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _phoneCtrl,
              label: 'Phone Number',
              colors: colors,
              keyboardType: TextInputType.phone,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _brandCtrl,
              label: 'Brand of Vehicle',
              colors: colors,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _travellersCtrl,
              label: 'Number of Travellers',
              colors: colors,
              keyboardType: TextInputType.number,
              validator: _required,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _luxuryCtrl,
                    label: 'Luxury (seats)',
                    colors: colors,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _superLuxuryCtrl,
                    label: 'Super Luxury (seats)',
                    colors: colors,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _locationCtrl,
              label: 'Where do you need this vehicle?',
              colors: colors,
              maxLines: 2,
              validator: _required,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: colors.goldPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Submit Enquiry',
                      style: AppTypography.heading
                          .copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}

class CabForm extends ConsumerStatefulWidget {
  const CabForm({super.key});

  @override
  ConsumerState<CabForm> createState() => _CabFormState();
}

class _CabFormState extends ConsumerState<CabForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String? _selectedCountry;
  String? _selectedVehicleType;
  String? _selectedState;
  bool _loading = false;

  static const _countries = [
    'INDIA', 'THAILAND', 'EGYPT', 'DUBAI', 'SINGAPORE', 'MALAYSIA',
    'INDONESIA', 'SRI LANKA', 'NEPAL', 'BHUTAN', 'MALDIVES', 'MAURITIUS',
    'KENYA', 'SOUTH AFRICA', 'FRANCE', 'ITALY',
  ];

  static const _vehicleTypes = [
    'Mini', 'Prime Sedan', 'Prime Play', 'Compact SUV', 'Spacious SUV', 'Luxury',
  ];

  static const _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal', 'Delhi', 'Jammu & Kashmir', 'Ladakh',
  ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _pincodeCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(marketplaceDatasourceProvider).submitCabEnquiry({
        'country': _selectedCountry,
        'fname': _firstNameCtrl.text.trim(),
        'lname': _lastNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'vehicle_type': _selectedVehicleType,
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'pincode': _pincodeCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        if (_selectedCountry == 'INDIA') 'state': _selectedState,
      });
      if (mounted) {
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cab enquiry submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clearForm() {
    setState(() {
      _selectedCountry = null;
      _selectedVehicleType = null;
      _selectedState = null;
    });
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _phoneCtrl.clear();
    _emailCtrl.clear();
    _addressCtrl.clear();
    _cityCtrl.clear();
    _pincodeCtrl.clear();
    _locationCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(title: 'Cab Booking Enquiry', colors: colors),
            const SizedBox(height: 16),
            _Dropdown(
              label: 'Country',
              value: _selectedCountry,
              items: _countries,
              colors: colors,
              onChanged: (v) => setState(() {
                _selectedCountry = v;
                _selectedState = null;
              }),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _firstNameCtrl,
                    label: 'First Name',
                    colors: colors,
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _lastNameCtrl,
                    label: 'Last Name',
                    colors: colors,
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _phoneCtrl,
              label: 'Phone',
              colors: colors,
              keyboardType: TextInputType.phone,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _emailCtrl,
              label: 'Email',
              colors: colors,
              keyboardType: TextInputType.emailAddress,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Dropdown(
              label: 'Vehicle Type',
              value: _selectedVehicleType,
              items: _vehicleTypes,
              colors: colors,
              onChanged: (v) => setState(() => _selectedVehicleType = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _addressCtrl,
              label: 'Address',
              colors: colors,
              validator: _required,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _cityCtrl,
                    label: 'City',
                    colors: colors,
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _pincodeCtrl,
                    label: 'Pincode',
                    colors: colors,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _locationCtrl,
              label: 'Location / Pickup Point',
              colors: colors,
              validator: _required,
            ),
            if (_selectedCountry == 'INDIA') ...[
              const SizedBox(height: 12),
              _Dropdown(
                label: 'State',
                value: _selectedState,
                items: _indianStates,
                colors: colors,
                onChanged: (v) => setState(() => _selectedState = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: colors.goldPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Submit Cab Enquiry',
                      style: AppTypography.heading
                          .copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}

class FlightForm extends ConsumerStatefulWidget {
  const FlightForm({super.key});

  @override
  ConsumerState<FlightForm> createState() => _FlightFormState();
}

class _FlightFormState extends ConsumerState<FlightForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _departureCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _passengersCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _destinationCtrl.dispose();
    _departureCtrl.dispose();
    _countryCtrl.dispose();
    _companyCtrl.dispose();
    _passengersCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(marketplaceDatasourceProvider).submitFlightEnquiry({
        'fname': _firstNameCtrl.text.trim(),
        'lname': _lastNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'destination': _destinationCtrl.text.trim(),
        'departure': _departureCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'companyName': _companyCtrl.text.trim(),
        'numberOfPassengers': int.tryParse(_passengersCtrl.text.trim()) ?? 1,
        'inquiryDetails': _detailsCtrl.text.trim(),
      });
      if (mounted) {
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flight enquiry submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clearForm() {
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _phoneCtrl.clear();
    _emailCtrl.clear();
    _destinationCtrl.clear();
    _departureCtrl.clear();
    _countryCtrl.clear();
    _companyCtrl.clear();
    _passengersCtrl.clear();
    _detailsCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(title: 'Charter Flight Enquiry', colors: colors),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _firstNameCtrl,
                    label: 'First Name',
                    colors: colors,
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: _lastNameCtrl,
                    label: 'Last Name',
                    colors: colors,
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _phoneCtrl,
              label: 'Phone',
              colors: colors,
              keyboardType: TextInputType.phone,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _emailCtrl,
              label: 'Email',
              colors: colors,
              keyboardType: TextInputType.emailAddress,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _destinationCtrl,
              label: 'Destination',
              colors: colors,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _departureCtrl,
              label: 'Departure City',
              colors: colors,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _countryCtrl,
              label: 'Country',
              colors: colors,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _companyCtrl,
              label: 'Company Name',
              colors: colors,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _passengersCtrl,
              label: 'Number of Passengers',
              colors: colors,
              keyboardType: TextInputType.number,
              validator: _required,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _detailsCtrl,
              label: 'Inquiry Details',
              colors: colors,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: colors.goldPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Submit Flight Enquiry',
                      style: AppTypography.heading
                          .copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}

// ── Shared form primitives ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.colors});
  final String title;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.heading.copyWith(color: colors.ink900),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.colors,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final AppColorScheme colors;
  final TextInputType? keyboardType;
  final int maxLines;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: AppTypography.body.copyWith(color: colors.ink900),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.caption.copyWith(color: colors.ink400),
        filled: true,
        fillColor: colors.surfaceCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.lineSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.lineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.goldPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
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
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value, // ignore: deprecated_member_use
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.caption.copyWith(color: colors.ink400),
        filled: true,
        fillColor: colors.surfaceCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.lineSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.lineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.goldPrimary, width: 1.5),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
      style: AppTypography.body.copyWith(color: colors.ink900),
      items: items
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
    );
  }
}
