import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class DealEnquiryScreen extends StatefulWidget {
  const DealEnquiryScreen({super.key});

  @override
  State<DealEnquiryScreen> createState() => _DealEnquiryScreenState();
}

class _DealEnquiryScreenState extends State<DealEnquiryScreen> {
  String _enquiryFor = 'My Client';
  String _travellers = '2 Adults';
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final botPad = MediaQuery.paddingOf(context).bottom;

    const bg = Color(0xFFFAF8F3);
    const ink900 = Color(0xFF1A1A1A);
    const ink600 = Color(0xFF5E5E5E);
    const lineSoft = Color(0xFFE8E5DC);
    const gold = Color(0xFFC9A84C);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // — Scrollable form body
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, topPad + 80, 20, botPad + 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deal summary card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: lineSoft),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=200&q=80',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                                AppColors.navyDeep,
                                Color(0xFF1A3550)
                              ]),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Luxury Goa Getaway',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: ink900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '5★ Resort · 3D/2N · Goa',
                              style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 11,
                                  color: ink600),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: const [
                                Text(
                                  '₹16,999',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: gold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '/ person',
                                  style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10,
                                      color: ink600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Enquiry For
                _EnqLabel(label: 'Enquiry For'),
                const SizedBox(height: 8),
                _EnqDropdown(
                  value: _enquiryFor,
                  items: const ['My Client', 'Self'],
                  onChanged: (v) => setState(() => _enquiryFor = v!),
                  lineSoft: lineSoft,
                  ink900: ink900,
                ),
                const SizedBox(height: 18),

                // Travel Date
                _EnqLabel(label: 'Travel Date'),
                const SizedBox(height: 8),
                _DateField(lineSoft: lineSoft, ink900: ink900, ink600: ink600),
                const SizedBox(height: 18),

                // Travellers
                _EnqLabel(label: 'Travellers'),
                const SizedBox(height: 8),
                _EnqDropdown(
                  value: _travellers,
                  items: const [
                    '2 Adults',
                    '2 Adults, 1 Child',
                    '1 Adult',
                  ],
                  onChanged: (v) => setState(() => _travellers = v!),
                  lineSoft: lineSoft,
                  ink900: ink900,
                ),
                const SizedBox(height: 18),

                // Message
                _EnqLabel(label: 'Your Message'),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  style: const TextStyle(
                      fontFamily: 'DMSans', fontSize: 14, color: ink900),
                  decoration: InputDecoration(
                    hintText: 'Any specific requirements?',
                    hintStyle: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        color: Color(0xFF9E9E9E)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: lineSoft),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: lineSoft),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: gold, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // — Fixed header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: bg,
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: lineSoft),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_rounded,
                            size: 18, color: ink900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Deal Enquiry',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: ink900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // — Fixed bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding:
                  EdgeInsets.fromLTRB(20, 14, 20, botPad + 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: lineSoft)),
              ),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Enquiry sent! The seller will contact you soon.')),
                  );
                  context.pop();
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Send Enquiry',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.2,
                          color: ink900,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.send_rounded, size: 16, color: ink900),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnqLabel extends StatelessWidget {
  const _EnqLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: Color(0xFF5E5E5E),
      ),
    );
  }
}

class _EnqDropdown extends StatelessWidget {
  const _EnqDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.lineSoft,
    required this.ink900,
  });
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Color lineSoft;
  final Color ink900;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lineSoft),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF5E5E5E), size: 18),
          style: TextStyle(
              fontFamily: 'DMSans', fontSize: 14, color: ink900),
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.lineSoft,
    required this.ink900,
    required this.ink600,
  });
  final Color lineSoft;
  final Color ink900;
  final Color ink600;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lineSoft),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '24 May 2025',
              style: TextStyle(
                  fontFamily: 'DMSans', fontSize: 14, color: ink900),
            ),
          ),
          Icon(Icons.calendar_month_outlined, size: 18, color: ink600),
        ],
      ),
    );
  }
}
