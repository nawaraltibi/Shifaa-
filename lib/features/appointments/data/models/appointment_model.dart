import 'package:intl/intl.dart';
import 'package:shifaa/features/appointments/domain/entities/appointment_entity.dart';
// import 'package:shifaa/features/appointments/domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.doctorName,
    required super.specialty,
    required super.imageUrl,
    required super.date,
    required super.time,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // تنسيق التاريخ والوقت من الـ API
    final startTime = DateTime.parse(json['start_time'] ?? DateTime.now().toIso8601String());
    final date = DateFormat('d MMMM, EEEE').format(startTime);
    final time = DateFormat('h:mm a').format(startTime);

    // استخراج بيانات الطبيب الحقيقية من الكائن المتداخل
    final doctorJson = json['doctor'] as Map<String, dynamic>?;
    final firstName = doctorJson?['first_name'] ?? 'Unknown';
    final lastName = doctorJson?['last_name'] ?? 'Doctor';
    final fullName = '$firstName $lastName'.trim();
    final imageUrl = doctorJson?['avatar'] as String?;
    
    // استخراج التخصص الحقيقي من داخل بيانات الطبيب
    final specialtyJson = doctorJson?['specialty'] as Map<String, dynamic>?;
    final specialtyName = specialtyJson?['name'] ?? 'N/A';

    return AppointmentModel(
      id: json['id'] ?? 0,
      doctorName: fullName,
      specialty: specialtyName,
      imageUrl: imageUrl,
      date: date,
      time: time,
    );
  }
}
