class PersonModel {
  final int id;
  final String name;
  final String? dateOfBirth;
  final String? placeOfBirth;
  final String? address;
  final String? phoneNumber;
  final String? taxIdentity;
  final String? maritalStatus;
  final String? religion;
  final String? gender;

  PersonModel({
    required this.id,
    required this.name,
    this.dateOfBirth,
    this.placeOfBirth,
    this.address,
    this.phoneNumber,
    this.taxIdentity,
    this.maritalStatus,
    this.religion,
    this.gender,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phone_number'] as String?,
      taxIdentity: json['tax_identity'] as String?,
      maritalStatus: json['marital_status'] as String?,
      religion: json['religion'] as String?,
      gender: json['gender'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date_of_birth': dateOfBirth,
      'place_of_birth': placeOfBirth,
      'address': address,
      'phone_number': phoneNumber,
      'tax_identity': taxIdentity,
      'marital_status': maritalStatus,
      'religion': religion,
      'gender': gender,
    };
  }
}
