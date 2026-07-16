class AssociationCircularModel {
  const AssociationCircularModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.isNew = false,
  });

  final String id;
  final String title;
  final String content; // HTML string
  final String date;
  final bool isNew;

  factory AssociationCircularModel.fromJson(Map<String, dynamic> j) {
    final dateStr = j['date'] as String? ?? j['createdAt'] as String? ?? '';
    final isNew = _isToday(dateStr) || (j['isNew'] as bool? ?? false);
    return AssociationCircularModel(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      title: j['title'] as String? ?? '',
      content: j['content'] as String? ?? j['description'] as String? ?? '',
      date: dateStr,
      isNew: isNew,
    );
  }

  static bool _isToday(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      final now = DateTime.now();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    } catch (_) {
      return false;
    }
  }
}

class AssociationUpdateModel {
  const AssociationUpdateModel({
    required this.id,
    required this.text,
    required this.from,
    required this.postedAt,
    this.content = '',
    this.imageUrl,
  });

  final String id;
  final String text; // title
  final String from;
  final String postedAt;
  final String content; // description body
  final String? imageUrl;

  factory AssociationUpdateModel.fromJson(Map<String, dynamic> j) {
    return AssociationUpdateModel(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      // Backend returns 'title' (same structure as Circular); 'text'/'message' are fallbacks
      text: j['text'] as String? ?? j['message'] as String? ?? j['title'] as String? ?? '',
      from: j['from'] as String? ?? j['postedBy'] as String? ?? 'Association',
      postedAt: j['createdAt'] as String? ?? j['date'] as String? ?? '',
      content: j['content'] as String? ?? j['description'] as String? ?? '',
      imageUrl: j['imageUrl'] as String? ?? j['image'] as String?,
    );
  }
}

class AssociationMemberModel {
  const AssociationMemberModel({
    required this.id,
    required this.name,
    this.role,
    this.city,
    this.phone,
    this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? role;
  final String? city;
  final String? phone;
  final String? email;
  final String? avatarUrl;

  factory AssociationMemberModel.fromJson(Map<String, dynamic> j) {
    return AssociationMemberModel(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      name: j['name'] as String? ?? '',
      role: j['role'] as String? ?? j['designation'] as String?,
      city: j['city'] as String?,
      phone: j['phone'] as String? ?? j['mobile'] as String?,
      email: j['email'] as String?,
      avatarUrl: j['avatar'] as String? ?? j['profileImage'] as String?,
    );
  }
}

class AssociationJobModel {
  const AssociationJobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.postedAt,
    this.description,
    this.salary,
    this.website,
  });

  final String id;
  final String title;
  final String company;
  final String location;
  final String postedAt;
  final String? description;
  final String? salary;
  final String? website;

  factory AssociationJobModel.fromJson(Map<String, dynamic> j) {
    return AssociationJobModel(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      title: j['title'] as String? ?? j['jobTitle'] as String? ?? '',
      company: j['company'] as String? ?? j['companyName'] as String? ?? '',
      location: j['location'] as String? ?? j['city'] as String? ?? '',
      postedAt: j['createdAt'] as String? ?? '',
      description: j['description'] as String? ?? j['jobDescription'] as String?,
      salary: j['salary'] as String?,
      website: j['companyWebsite'] as String?,
    );
  }
}

class AssociationJobApplicantModel {
  const AssociationJobApplicantModel({
    required this.id,
    required this.fullname,
    required this.email,
    required this.mobile,
    required this.currentCtc,
    required this.expectedCtc,
    required this.cvUrls,
    required this.appliedAt,
  });

  final String id;
  final String fullname;
  final String email;
  final String mobile;
  final String currentCtc;
  final String expectedCtc;
  final List<String> cvUrls;
  final String appliedAt;

  factory AssociationJobApplicantModel.fromJson(Map<String, dynamic> j) {
    return AssociationJobApplicantModel(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      fullname: j['fullname'] as String? ?? '',
      email: j['email'] as String? ?? '',
      mobile: j['mobile'] as String? ?? '',
      currentCtc: j['currentCTC']?.toString() ?? '',
      expectedCtc: j['expectedCTC']?.toString() ?? '',
      cvUrls: (j['cvFile'] as List?)?.map((e) => e.toString()).toList() ?? [],
      appliedAt: j['createdAt'] as String? ?? '',
    );
  }
}

class AssociationChatModel {
  const AssociationChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.avatarColor,
  });

  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String? avatarColor;

  factory AssociationChatModel.fromJson(Map<String, dynamic> j) {
    return AssociationChatModel(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      name: j['name'] as String? ?? '',
      lastMessage: j['lastMessage'] as String? ?? '',
      time: j['updatedAt'] as String? ?? j['time'] as String? ?? '',
      unreadCount: (j['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class AssociationCabModel {
  const AssociationCabModel({
    required this.id,
    required this.driverName,
    required this.vehicleType,
    required this.location,
    this.status = 'available',
    this.phone,
  });

  final String id;
  final String driverName;
  final String vehicleType;
  final String location;
  final String status;
  final String? phone;

  factory AssociationCabModel.fromJson(Map<String, dynamic> j) {
    // Cab Network API returns fname/lname separately
    final fname = j['fname'] as String? ?? '';
    final lname = j['lname'] as String? ?? '';
    final fullName = [fname, lname].where((s) => s.isNotEmpty).join(' ');
    return AssociationCabModel(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      driverName: j['driverName'] as String? ?? j['name'] as String? ?? fullName,
      vehicleType: j['vehicleType'] as String? ?? j['vehicle'] as String? ?? j['vehicle_type'] as String? ?? '',
      location: j['location'] as String? ?? j['city'] as String? ?? '',
      status: j['status'] as String? ?? ((j['isBooked'] as bool? ?? false) ? 'booked' : 'available'),
      phone: j['phone'] as String?,
    );
  }
}

/// Admin Cab vehicle — matches old app's /api/vehicles document shape.
class AssociationVehicleModel {
  const AssociationVehicleModel({
    required this.id,
    required this.associationId,
    required this.memberId,
    required this.name,
    required this.type,
    required this.year,
    this.images = const [],
    this.isAvailable = false,
  });

  final String id;
  final String associationId;
  final String memberId;
  final String name;
  final String type;
  final String year;
  final List<String> images;
  final bool isAvailable;

  factory AssociationVehicleModel.fromJson(Map<String, dynamic> j) =>
      AssociationVehicleModel(
        id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
        associationId: j['associationId']?.toString() ?? '',
        memberId: j['memberId']?.toString() ?? '',
        name: j['name'] as String? ?? '',
        type: j['type'] as String? ?? '',
        year: j['year']?.toString() ?? '',
        images:
            (j['image'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        isAvailable: j['isAvailable'] as bool? ?? false,
      );
}
