import 'package:shifaa/features/chat/data/models/device_model.dart';

// Doctor Model
class DoctorModel {
  final int id;
  final String firstName;
  final String lastName;
  final String bio;
  final String avatar;
  final int consultationFee;
  final String gender;
  final List<DeviceModel> devices;
  final DateTime createdAt;

  DoctorModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.avatar,
    required this.consultationFee,
    required this.gender,
    this.devices = const [],
    required this.createdAt,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json["id"] ?? 0,
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      bio: json["bio"] ?? "",
      avatar: json["avatar"] ?? "",
      consultationFee: json["consultation_fee"] ?? 0,
      gender: json["gender"] ?? "",
      devices:
          (json["devices"] as List<dynamic>?)
              ?.map((e) => DeviceModel.fromJson(e))
              .toList() ??
          [],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : DateTime.now(),
    );
  }
}

// Patient Model
class PatientModel {
  final int id;
  final int? age;
  final double? weight;
  final double? height;
  final List<DeviceModel> devices;
  final DateTime? dateOfBirth;
  final DateTime createdAt;

  PatientModel({
    required this.id,
    this.age,
    this.weight,
    this.height,
    this.devices = const [],
    this.dateOfBirth,
    required this.createdAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json["id"] ?? 0,
      age: json["age"] != null ? json["age"] as int : null,
      weight: json["weight"]?.toDouble(),
      height: json["height"]?.toDouble(),
      devices:
          (json["devices"] as List<dynamic>?)
              ?.map((e) => DeviceModel.fromJson(e))
              .toList() ??
          [],
      dateOfBirth: json["date_of_birth"] != null
          ? DateTime.tryParse(json["date_of_birth"])
          : null,
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : DateTime.now(),
    );
  }
}
