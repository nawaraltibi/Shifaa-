import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shifaa/features/appointments/data/models/doctor_schedule_model.dart';
import 'package:shifaa/features/appointments/presentaion/widgets/time_slot.dart';
import 'package:shifaa/generated/l10n.dart';

class TimeSlotsList extends StatefulWidget {
  final DateTime selectedDate;
  final List<DoctorScheduleModel> schedule;
  final Function(String fullDateTime)? onSlotSelected;

  const TimeSlotsList({
    super.key,
    required this.selectedDate,
    required this.schedule,
    this.onSlotSelected,
  });

  @override
  State<TimeSlotsList> createState() => _TimeSlotsListState();
}

class _TimeSlotsListState extends State<TimeSlotsList> {
  String? selectedSlot;

  @override
  Widget build(BuildContext context) {
    final selectedDay = DateFormat(
      'EEEE',
    ).format(widget.selectedDate).toLowerCase();

    final filteredSchedules = widget.schedule
        .where((s) => s.dayOfWeek.toLowerCase() == selectedDay)
        .toList();

    final slots = [
      for (final s in filteredSchedules)
        if (s.availableSlots != null) ...s.availableSlots!,
    ];

    if (slots.isEmpty) {
      return Text(S.of(context).no_slots);
    }

    // صيغة التاريخ لليوم المحدد
    final formattedDate = DateFormat(
      'EEE, MMM d, yyyy',
    ).format(widget.selectedDate);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FF),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Wrap(
        spacing: 15.w,
        runSpacing: 10.h,
        children: slots.map((slot) {
          // صيغة الوقت
          final displayTime = DateFormat.jm().format(
            DateFormat("HH:mm").parse(slot),
          );

          // نجمع التاريخ + الوقت
          final fullDateTime = "$formattedDate - $displayTime";

          return TimeSlot(
            time: displayTime, // بيضل الوقت لحالو بالكارت
            isSelected: selectedSlot == slot,
            onTap: () {
              setState(() => selectedSlot = slot);
              widget.onSlotSelected?.call(
                fullDateTime,
              ); // بيرجع التاريخ + الوقت
            },
          );
        }).toList(),
      ),
    );
  }
}
