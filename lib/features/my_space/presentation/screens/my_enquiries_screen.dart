import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../widgets/space_sub_appbar.dart';

enum _EnquiryStatus { pending, responded, closed }

class _Enquiry {
  const _Enquiry({
    required this.dealName,
    required this.detail,
    required this.imageUrl,
    required this.status,
    required this.date,
  });
  final String dealName;
  final String detail;
  final String imageUrl;
  final _EnquiryStatus status;
  final String date;
}

const _kEnquiries = [
  _Enquiry(
    dealName: 'Luxury Goa Getaway',
    detail: '5★ Resort · 3D/2N\n2 Adults · 24 May 2025',
    imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=300&q=80',
    status: _EnquiryStatus.pending,
    date: 'Sent 20 May',
  ),
  _Enquiry(
    dealName: 'Dubai Holiday Package',
    detail: '4★ Hotel · 5D/4N\n2 Adults · 10 Jun 2025',
    imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=300&q=80',
    status: _EnquiryStatus.responded,
    date: 'Sent 18 May',
  ),
  _Enquiry(
    dealName: 'Kerala Backwaters',
    detail: 'Houseboat · 3D/2N\n2 Adults · 05 Jun 2025',
    imageUrl: 'https://images.unsplash.com/photo-1602002418082-a4443e081dd1?w=300&q=80',
    status: _EnquiryStatus.closed,
    date: 'Sent 15 May',
  ),
  _Enquiry(
    dealName: 'Bali Paradise',
    detail: '5★ Villa · 6D/5N\n2 Adults · 12 Sep 2025',
    imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=300&q=80',
    status: _EnquiryStatus.responded,
    date: 'Sent 12 May',
  ),
  _Enquiry(
    dealName: 'Manali Adventure',
    detail: '3★ Resort · 4D/3N\n4 Adults · 15 Jun 2025',
    imageUrl: 'https://images.unsplash.com/photo-1545158535-c3f7168c28b6?w=300&q=80',
    status: _EnquiryStatus.pending,
    date: 'Sent 10 May',
  ),
];

class MyEnquiriesScreen extends StatefulWidget {
  const MyEnquiriesScreen({super.key});

  @override
  State<MyEnquiriesScreen> createState() => _MyEnquiriesScreenState();
}

class _MyEnquiriesScreenState extends State<MyEnquiriesScreen> {
  int _filterIndex = 0;

  List<_Enquiry> get _filtered {
    switch (_filterIndex) {
      case 1:
        return _kEnquiries.where((e) => e.status == _EnquiryStatus.pending).toList();
      case 2:
        return _kEnquiries.where((e) => e.status == _EnquiryStatus.responded).toList();
      case 3:
        return _kEnquiries.where((e) => e.status == _EnquiryStatus.closed).toList();
      default:
        return _kEnquiries;
    }
  }

  SpaceChipStyle _chipStyle(_EnquiryStatus status) {
    switch (status) {
      case _EnquiryStatus.pending:
        return SpaceChipStyle.warning;
      case _EnquiryStatus.responded:
        return SpaceChipStyle.success;
      case _EnquiryStatus.closed:
        return SpaceChipStyle.info;
    }
  }

  String _chipLabel(_EnquiryStatus status) {
    switch (status) {
      case _EnquiryStatus.pending:
        return 'Pending';
      case _EnquiryStatus.responded:
        return 'Responded';
      case _EnquiryStatus.closed:
        return 'Closed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, topPad + 76, 0, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                SpaceFilterPills(
                  filters: const ['All', 'Pending', 'Responded', 'Closed'],
                  selectedIndex: _filterIndex,
                  onSelected: (i) => setState(() => _filterIndex = i),
                  colors: colors,
                ),
                const SizedBox(height: 16),
                ..._filtered.map((e) => _EnquiryCard(
                      enquiry: e,
                      chipStyle: _chipStyle(e.status),
                      chipLabel: _chipLabel(e.status),
                      colors: colors,
                    )),
              ],
            ),
          ),
          SpaceSubAppBar(
            title: 'My Enquiries',
            topPad: topPad,
            colors: colors,
            actionIcon: Icons.search_rounded,
          ),
        ],
      ),
    );
  }
}

class _EnquiryCard extends StatelessWidget {
  const _EnquiryCard({
    required this.enquiry,
    required this.chipStyle,
    required this.chipLabel,
    required this.colors,
  });

  final _Enquiry enquiry;
  final SpaceChipStyle chipStyle;
  final String chipLabel;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border.all(color: colors.lineSoft),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: enquiry.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 72,
                height: 72,
                color: colors.surfaceTertiary,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: colors.surfaceTertiary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enquiry.dealName,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.ink900,
                    height: 1.29,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  enquiry.detail,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    color: colors.ink600,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SpaceStatusChip(
                      label: chipLabel,
                      style: chipStyle,
                      colors: colors,
                    ),
                    Text(
                      enquiry.date,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 11,
                        color: colors.ink400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
