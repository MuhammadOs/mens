class Address {
  final int? id;
  final String city;
  final String street;
  final String buildingNo;
  final String floorNo;
  final String flatNo;
  final String? notes;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Address({
    this.id,
    required this.city,
    required this.street,
    required this.buildingNo,
    required this.floorNo,
    required this.flatNo,
    this.notes,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: _parseInt(json['id']),
      city: json['city']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      buildingNo: json['buildingNo']?.toString() ?? json['building_no']?.toString() ?? '',
      floorNo: json['floorNo']?.toString() ?? json['floor_no']?.toString() ?? '',
      flatNo: json['flatNo']?.toString() ?? json['flat_no']?.toString() ?? '',
      notes: json['notes']?.toString(),
      isDefault: json['isDefault'] == true || json['is_default'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? json['updated_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'city': city,
      'street': street,
      'buildingNo': buildingNo,
      'floorNo': floorNo,
      'flatNo': flatNo,
      'notes': notes,
      'isDefault': isDefault,
    };
  }

  Address copyWith({
    int? id,
    String? city,
    String? street,
    String? buildingNo,
    String? floorNo,
    String? flatNo,
    String? notes,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      city: city ?? this.city,
      street: street ?? this.street,
      buildingNo: buildingNo ?? this.buildingNo,
      floorNo: floorNo ?? this.floorNo,
      flatNo: flatNo ?? this.flatNo,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
