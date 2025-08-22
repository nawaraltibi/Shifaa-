// device_model.dart
class DeviceModel {
  final int id;
  final String publicKey;
  final String fingerprint;
  final String deviceName;

  DeviceModel({
    required this.id,
    required this.publicKey,
    required this.fingerprint,
    required this.deviceName,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] ?? 0,
      publicKey: json['public_key'] ?? '',
      fingerprint: json['fingerprint'] ?? '',
      deviceName: json['device_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'public_key': publicKey,
    'fingerprint': fingerprint,
    'device_name': deviceName,
  };
}
