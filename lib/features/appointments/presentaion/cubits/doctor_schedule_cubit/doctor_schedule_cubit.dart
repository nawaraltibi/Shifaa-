import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:shifaa/features/appointments/data/models/doctor_schedule_model.dart';
import 'package:shifaa/features/appointments/domain/usecases/get_doctor_schedule_use_case.dart';
import 'doctor_schedule_state.dart';

class DoctorScheduleCubit extends Cubit<DoctorScheduleState> {
  final GetDoctorScheduleUseCase getDoctorScheduleUseCase;

  DoctorScheduleCubit(this.getDoctorScheduleUseCase)
    : super(DoctorScheduleInitial());

  // Private fields
  List<DoctorScheduleModel> _schedules = [];
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  final DateTime _today = DateTime.now();

  // Getters
  List<DoctorScheduleModel> get schedules => _schedules;
  DateTime get currentMonth => _currentMonth;
  DateTime get selectedDate => _selectedDate;

  /// تحميل المواعيد (من مصدر خارجي أو جاهزة)
  void loadSchedules(List<DoctorScheduleModel> schedules) {
    _schedules = schedules;
    _resetToToday();
    emit(DoctorScheduleSuccess(_schedules, _currentMonth, _selectedDate));
  }

  /// الانتقال للشهر التالي
  void nextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    emit(DoctorScheduleSuccess(_schedules, _currentMonth, _selectedDate));
  }

  /// الرجوع للشهر السابق (ما بيرجع قبل الشهر الحالي)
  void previousMonth() {
    final DateTime prev = DateTime(_currentMonth.year, _currentMonth.month - 1);

    if (prev.isBefore(DateTime(_today.year, _today.month))) return;

    _currentMonth = prev;
    emit(DoctorScheduleSuccess(_schedules, _currentMonth, _selectedDate));
  }

  /// جلب جدول المواعيد بدون تحديد تاريخ
  Future<void> fetchDoctorSchedule(String doctorId) async {
    emit(DoctorScheduleLoading());

    final result = await getDoctorScheduleUseCase(doctorId: doctorId);

    result.fold((failure) => emit(DoctorScheduleError(failure.message)), (
      schedule,
    ) {
      _schedules = schedule;
      _resetToToday();
      emit(DoctorScheduleSuccess(_schedules, _currentMonth, _selectedDate));
    });
  }

  /// تحديد تاريخ جديد + جلب المواعيد الخاصة فيه
  Future<void> selectDateAndFetchSchedule(
    String doctorId,
    DateTime newSelectedDate,
  ) async {
    _selectedDate = newSelectedDate;
    _currentMonth = DateTime(newSelectedDate.year, newSelectedDate.month);

    emit(DoctorScheduleDateLoading(_selectedDate));

    final formattedDate = DateFormat('yyyy-MM-dd').format(newSelectedDate);

    final result = await getDoctorScheduleUseCase(
      doctorId: doctorId,
      date: formattedDate,
    );

    result.fold((failure) => emit(DoctorScheduleError(failure.message)), (
      daySchedule,
    ) {
      // 👇 بدل ما تمسح كل الـ schedules، حدّث بس اليوم المختار
      final updatedSchedules = List<DoctorScheduleModel>.from(_schedules);

      final dayName = DateFormat('EEEE').format(newSelectedDate).toLowerCase();

      final index = updatedSchedules.indexWhere(
        (s) => s.dayOfWeek.toLowerCase() == dayName,
      );

      if (index != -1) {
        updatedSchedules[index] = daySchedule.first; // حدّث اليوم الحالي
      } else {
        updatedSchedules.add(daySchedule.first); // ضيفه إذا مش موجود
      }

      emit(
        DoctorScheduleSuccess(updatedSchedules, _currentMonth, _selectedDate),
      );
    });
  }

  /// جلب جدول المواعيد بتاريخ محدد (String)
  Future<void> fetchDoctorScheduleForDate(
    String doctorId,
    String dateString,
  ) async {
    final selectedDate = DateTime.parse(dateString);
    await selectDateAndFetchSchedule(doctorId, selectedDate);
  }

  /// إعادة التواريخ لليوم الحالي
  void _resetToToday() {
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();
  }
}
