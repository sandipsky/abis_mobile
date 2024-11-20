import 'package:flutter/material.dart' hide CalendarDatePicker;
import 'package:np_date_picker/np_date_picker.dart';

class NpDatePicker extends StatefulWidget {
  final Function(dynamic) onChanged;
  final TextEditingController controller;
  final String placeholder;
  final readonly;

  const NpDatePicker({
    required this.onChanged,
    required this.controller,
    required this.placeholder,
    this.readonly,
    super.key,
  });

  @override
  State<NpDatePicker> createState() => _NpDatePickerState();
}

class _NpDatePickerState extends State<NpDatePicker> {
  bool showPicker = false;
  var selectedDate = NepaliDateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            TextFormField(
              controller: widget.controller,
              readOnly: true, // Make the field read-only
              decoration: const InputDecoration(
                hintText: 'Tap to select a date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => {
                setState(() {
                  if (widget.readonly == true) {
                    showPicker = false;
                  } else {
                    showPicker = !showPicker;
                  }
                })
              }, // Open date picker on tap
            ),
            showPicker == false
                ? const SizedBox(
                    height: 0,
                  )
                : CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: NepaliDateTime(2070),
                    lastDate: NepaliDateTime(2090),
                    onDateChanged: (date) {
                      setState(() {
                        showPicker = false;
                        selectedDate = date;
                        widget.controller.text = date.toString().split(' ')[0];
                      });
                      widget.onChanged(date);
                    },
                    dayBuilder: (dayToBuild) {
                      return Center(
                        child: Text(
                          dayToBuild.day.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    },
                    selectedDayDecoration: const BoxDecoration(
                      color: Color.fromRGBO(54, 135, 147, 1),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: const BoxDecoration(
                      color: Color.fromRGBO(54, 135, 147, 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}
