import 'package:dental/pages/appointment.dart';
import 'package:dental/pages/calendar.dart';
import 'package:dental/services/appointment.service.dart';
import 'package:dental/services/details.service.dart';
import 'package:dental/services/dropdownService.dart';
import 'package:dental/services/util.services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentForm extends StatefulWidget {
  final appointment;
  final mode;
  const AppointmentForm(this.appointment, this.mode, {super.key});

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  var patientList = [];
  var treatmentList = [];
  var availableDoctorList = [];
  var shiftOfDoctorList = [];
  var bookedSlotsList = [];

  final TextEditingController patient_name = TextEditingController();
  final TextEditingController treatment = TextEditingController();
  final TextEditingController duration = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController treatment_time = TextEditingController();
  final TextEditingController buffer_time = TextEditingController();
  final TextEditingController doctor_name = TextEditingController();
  final TextEditingController appointment_from_time = TextEditingController();
  final TextEditingController patient_reminder_time = TextEditingController();
  final TextEditingController doctor_reminder_time = TextEditingController();
  final TextEditingController appointment_to = TextEditingController();
  final TextEditingController note = TextEditingController();
  TimeOfDay? appointment_from;
  TimeOfDay? patientReminderTime;
  TimeOfDay? doctorReminderTime;
  final dummyNode = FocusNode();

  bool showFormCalendar = false;

  DateTime _focusedFromDay = DateTime.now();
  // DateTime _selectedFromDay = DateTime.now();

  DateTime _selectedDay = DateTime.now();

  var selectedPatient;
  var selectedDoctor;
  var selectedTreatment;

  bool patientSelected = false;
  bool treatmentSelected = false;
  bool doctorSelected = false;

  bool isLoading = false;

  var fromTime = '';
  var toTime = '';

  var periodList = [
    {
      'name': 'Appointment Day',
      'value': '0',
    },
    {
      'name': '1 Day Before',
      'value': '1',
    },
    {
      'name': '2 Day Before',
      'value': '2',
    },
    {
      'name': '3 Day Before',
      'value': '3',
    },
    {
      'name': '4 Day Before',
      'value': '4',
    },
    {
      'name': '5 Day Before',
      'value': '5',
    },
    {
      'name': '6 Day Before',
      'value': '6',
    },
    {
      'name': '7 Day Before',
      'value': '7',
    },
  ];

  Map<String, dynamic> reminderSettings = {
    'send': false,
    'patient': {
      'send_via': {
        'email': false,
        'sms': false,
        'send_period': null,
        'time': '',
      },
    },
    'doctor': {
      'send_via': {
        'email': false,
        'sms': false,
        'mobileApp': false,
        'send_period': null,
        'time': '',
      },
    },
  };

  @override
  void initState() {
    super.initState();

    getPatientList();
    getTreatmentList();
    getAvailableDoctors();

    if (widget.appointment != null) {
      patientSelected = true;
      treatmentSelected = true;
      doctorSelected = true;
      populateForm();
    }
  }

  populateForm() async {
    setState(() {
      patient_name.text = widget.appointment['patient_name'];

      note.text =
          widget.appointment['note'] == null ? '' : widget.appointment['note'];

      var modifiedDay = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS').format(
          DateTime.parse(
              '${widget.appointment['appointment_date']} 00:00:00.000'));

      _selectedDay = DateTime.parse(modifiedDay);

      selectedPatient = {'id': widget.appointment['patient_id']};
      selectedDoctor = {'id': widget.appointment['doctor_id']};
      date.text = widget.appointment['appointment_date'];
      appointment_from_time.text =
          UtilService().timeConverter(widget.appointment['start_time']);
    });

    onTreatmentSelect({
      'name': widget.appointment['treatment_name'],
      'id': widget.appointment['treatment_id']
    });

    var data = await AppointmentService()
            .getReminderOfAppointment(widget.appointment['id']) ??
        null;

    if (data != null) {
      setState(() {
        reminderSettings = {
          'send': data['send_remainder'],
          'patient': {
            'send_via': {
              'email': data['data']['patient']['email'],
              'sms': data['data']['patient']['sms'],
              'send_period': data['data']['patient']['send_day'],
              'time': data['data']['patient']['time'],
            },
          },
          'doctor': {
            'send_via': {
              'email': data['data']['doctor']['email'],
              'sms': data['data']['doctor']['sms'],
              'send_period': data['data']['doctor']['send_day'],
              'time': data['data']['doctor']['time'],
              'mobileApp': false,
            },
          },
        };
        print(reminderSettings);
        patient_reminder_time.text = UtilService()
            .convert24hrsto12hrsFormat(data['data']['patient']['time']);
        doctor_reminder_time.text = UtilService()
            .convert24hrsto12hrsFormat(data['data']['doctor']['time']);
      });
    }
  }

  getPatientList() async {
    var data = await DropDownService().getPatientDropDownList('') ?? [];
    setState(() {
      patientList = data;
    });
  }

  getTreatmentList() async {
    var data = await DropDownService().getTreatmentDropDownList('') ?? [];
    setState(() {
      treatmentList = data;
    });
  }

  getAvailableDoctors() async {
    var modifiedDay = DateFormat('yyyy-MM-dd').format(_selectedDay);
    var data;
    if (widget.appointment == null) {
      data = await DropDownService().getAvailableDoctorByDate(
              date.text.length != 0 ? date.text : modifiedDay) ??
          [];
    } else {
      data = await DropDownService().getAvailableDoctorByDate(
              widget.appointment['appointment_date']) ??
          [];
    }

    availableDoctorList = data;

    if (widget.appointment != null) {
      availableDoctorList.forEach((doctor) {
        if (doctor['id'] == widget.appointment['doctor_id']) {
          onDoctorSelect(doctor);
        }
      });
    }
  }

  onPatientSelect(patient) {
    patientSelected = true;
    selectedPatient = patient;
    patient_name.text =
        '${selectedPatient['name']} (${selectedPatient['registration_no']})';
  }

  onTreatmentSelect(tempTreatment) async {
    treatment.text = '${tempTreatment['name']}';
    treatmentSelected = true;

    var data =
        await DetailService().getTreatmentDetailsById(tempTreatment['id']) ??
            null;

    if (data != null) {
      selectedTreatment = data;
      if (data != null) {
        setState(() {
          buffer_time.text = data['bufferTime'].toString();
          treatment_time.text = (data['duration']).toInt().toString();
          duration.text = '${(data['duration'] + data['bufferTime']).toInt()}';
          final newTime = addMinutesToTimeString(
              appointment_from_time.text, int.tryParse(duration.text));
          this.appointment_to.text = newTime;
        });
      }
    }
  }

  String addMinutesToTimeString(String timeString, var min) {
    // Parse the time string to a DateTime object
    if (timeString.length > 0) {
      final timeFormat = DateFormat("h:mm a");
      final time = timeFormat.parse(timeString);

      // Add 30 minutes to the DateTime object
      final addedTime = time.add(Duration(minutes: min));

      // Format the resulting DateTime object back to a string
      final formattedTime = timeFormat.format(addedTime);

      return formattedTime;
    }
    return '';
  }

  onDoctorSelect(doctor) {
    selectedDoctor = doctor;
    doctorSelected = true;
    doctor_name.text = doctor['name'];
    shiftOfDoctorList = [];
    bookedSlotsList = [];

    setState(() {
      if (doctor['shifts'].length > 0) {
        doctor['shifts'].forEach((var shift) {
          shiftOfDoctorList.add(shift);

          if (shift['booked_slots'].length > 0) {
            shift['booked_slots'].forEach((var slot) {
              bookedSlotsList.add(
                  '${UtilService().timeConverter(slot['start_time'])} - ${UtilService().timeConverter(slot['end_time'])}');
            });
          }
        });
      }
    });

    checkDoctorLeave(doctor['id']);
  }

  checkDoctorLeave(id) async {
    var modifiedDay = DateFormat('yyyy-MM-dd').format(_selectedDay);

    var data = await DetailService().checkUserLeave(modifiedDay, id);

    if (data != '') {
      data['messages'].forEach((message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Info: ${message['message']}!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  goToAppointmentPage() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AppointmentPage()),
    );
  }

  rescheduleAppointment() async {
    if (doctorSelected == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a Doctor!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (appointment_from_time.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment Time is required!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!appointment_from_time.text.contains('PM') &&
        !appointment_from_time.text.contains('AM')) {
      fromTime = await UtilService()
          .convert24hrsto12hrsFormat(appointment_from_time.text);
    }

    var validShift = validateShift();

    if (!validShift) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please Check Shift Time of Appointment!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    var tempSelectedDay = DateFormat('yyyy-MM-dd').format(_selectedDay);
    var temp = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (UtilService()
        .compareDateIfGreaterIncludingToday(tempSelectedDay, temp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Past date selected!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    var tempPatientTime = patient_reminder_time.text == ''
        ? '00:00:00'
        : convert12HourTo24Hour(patient_reminder_time.text);
    var tempDoctorTime = doctor_reminder_time.text == ''
        ? '00:00:00'
        : convert12HourTo24Hour(doctor_reminder_time.text);

    String modifiedStartTime = convert12HourTo24Hour(
        !appointment_to.text.contains('PM') &&
                !appointment_to.text.contains('AM')
            ? fromTime
            : appointment_from_time.text);
    String modifiedEndTime = convert12HourTo24Hour(
        !appointment_to.text.contains('PM') &&
                !appointment_to.text.contains('AM')
            ? toTime
            : appointment_to.text);
    var modifiedDay = DateFormat('yyyy-MM-dd').format(_selectedDay);
    var data = {
      "appointment_date": modifiedDay,
      "start_time": modifiedStartTime,
      "end_time": modifiedEndTime,
      "appointment_status": 'Reschedule',
      "treatment_id": selectedTreatment['id'],
      'doctor_id': selectedDoctor['id'],
      "cancelled_remarks": null,
      "globalAppointementRemainder": {
        "globalAppointmentRemainder": null,
        "id": 1,
        "appointment_remainder": "Remainder for Patients/Doctor",
        "send_remainder": reminderSettings['send'],
        "data": {
          "patient": {
            "email":
                reminderSettings['patient']['email'] == null ? false : true,
            "sms": reminderSettings['patient']['sms'] == null ? false : true,
            "send_day": reminderSettings['patient']['send_period'],
            "time": tempPatientTime.length == 5
                ? tempPatientTime + ':00'
                : tempPatientTime
          },
          "doctor": {
            "email": reminderSettings['doctor']['email'] == null ? false : true,
            "sms": reminderSettings['doctor']['sms'] == null ? false : true,
            "mobile_app":
                reminderSettings['doctor']['mobileApp'] == null ? false : true,
            "send_day": reminderSettings['doctor']['send_period'],
            "time": tempDoctorTime.length == 5
                ? tempDoctorTime + ':00'
                : tempDoctorTime
          }
        },
        "appointmentRemainder": null,
        "appointment": null
      }
    };

    var res = await AppointmentService()
        .cancelCompleteAppointment(data, widget.appointment['id']);

    if (res['title'] == 'Success' && res['http_status'] == 200) {
      res['messages'].forEach((message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${message['message']}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });

      Navigator.of(context).pop();
      goToCalendarPage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to Cancel Appoinrment!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String removeSeconds(String originalTime) {
    List<String> parts = originalTime.split(':');
    if (parts.length == 3) {
      // Remove seconds if present
      parts.removeAt(2);
    }

    return parts.join(':');
  }

  Future<void> _selectTime(BuildContext context) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: appointment_from ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.black),
              hourMinuteShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                side: BorderSide(color: Colors.black, width: 1),
              ),
              dialHandColor: Colors.black,
              dialTextColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.black),
              entryModeIconColor: Colors.black,
            ),
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != appointment_from) {
      setState(() {
        appointment_from = picked;
        appointment_from_time.text = '${picked.format(context)}';

        if (duration.text != '') {
          setState(() {
            TimeOfDay appointmentToTime =
                addMinutesToTime(picked, int.tryParse(duration.text));
            appointment_to.text = appointmentToTime.format(context);
          });
        }
      });
    }

    FocusScope.of(context).requestFocus(dummyNode);
  }

  Future<void> _selectPatientReminderTime(BuildContext context) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: appointment_from ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.black),
              hourMinuteShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                side: BorderSide(color: Colors.black, width: 1),
              ),
              dialHandColor: Colors.black,
              dialTextColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.black),
              entryModeIconColor: Colors.black,
            ),
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != appointment_from) {
      setState(() {
        patientReminderTime = picked;
        patient_reminder_time.text = '${picked.format(context)}';
      });
    }

    FocusScope.of(context).requestFocus(dummyNode);
  }

  goToCalendarPage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CalendarPage()),
    );
  }

  Future<void> _selectDoctorReminderTime(BuildContext context) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: appointment_from ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.black),
              hourMinuteShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                side: BorderSide(color: Colors.black, width: 1),
              ),
              dialHandColor: Colors.black,
              dialTextColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.black),
              entryModeIconColor: Colors.black,
            ),
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != appointment_from) {
      setState(() {
        doctorReminderTime = picked;
        doctor_reminder_time.text = '${picked.format(context)}';
      });
    }

    FocusScope.of(context).requestFocus(dummyNode);
  }

  TimeOfDay addMinutesToTime(originalTime, minutesToAdd) {
    int totalMinutes =
        originalTime.hour * 60 + originalTime.minute + minutesToAdd;
    return TimeOfDay(
      hour: totalMinutes ~/ 60,
      minute: totalMinutes % 60,
    );
  }

  saveAppointment() async {
    if (patientSelected == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a Patient!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (treatmentSelected == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a Treatment!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // var tempSelectedDay = DateFormat('yyyy-MM-dd').format(_selectedDay);
    // var temp = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (date.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a Date!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (UtilService().checkIfPastDate(date.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Past date selected!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (doctorSelected == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a Doctor!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (appointment_from_time.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment Time is required!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!appointment_from_time.text.contains('PM') &&
        !appointment_from_time.text.contains('AM')) {
      fromTime = await UtilService()
          .convert24hrsto12hrsFormat(appointment_from_time.text);
    }

    var validShift = validateShift();

    if (!validShift) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please Check Shift Time of Appointment!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    var validBookedSlots = validateSlots();

    if (!validBookedSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment time falls under booked time!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    validateBreakTime();

    addAppointment();
  }

  addAppointment() async {
    var tempPatientTime = patient_reminder_time.text == ''
        ? '00:00:00'
        : convert12HourTo24Hour(patient_reminder_time.text);
    var tempDoctorTime = doctor_reminder_time.text == ''
        ? '00:00:00'
        : convert12HourTo24Hour(doctor_reminder_time.text);

    String modifiedStartTime = convert12HourTo24Hour(
        !appointment_to.text.contains('PM') &&
                !appointment_to.text.contains('AM')
            ? fromTime
            : appointment_from_time.text);
    String modifiedEndTime = convert12HourTo24Hour(
        !appointment_to.text.contains('PM') &&
                !appointment_to.text.contains('AM')
            ? toTime
            : appointment_to.text);

    var payload = widget.appointment != null
        ? {
            "patient_id": selectedPatient['id'],
            "chief_problem": "",
            "appointment_status": 'Booked',
            "treatment_id": selectedTreatment['id'],
            "treatment_time": int.tryParse(treatment_time.text),
            "buffer_time": int.tryParse(buffer_time.text),
            "note": note.text,
            "appointment_date": date.text,
            "doctor_id": selectedDoctor['id'],
            "start_time": modifiedStartTime,
            "end_time": modifiedEndTime,
            "globalAppointementRemainder": {
              "globalAppointmentRemainder": null,
              "id": 1,
              "appointment_remainder": "Remainder for Patients/Doctor",
              "send_remainder": reminderSettings['send'],
              "data": {
                "patient": {
                  "email": reminderSettings['patient']['email'] == null
                      ? false
                      : true,
                  "sms":
                      reminderSettings['patient']['sms'] == null ? false : true,
                  "send_day": reminderSettings['patient']['send_period'],
                  "time": tempPatientTime.length == 5
                      ? tempPatientTime + ':00'
                      : tempPatientTime
                },
                "doctor": {
                  "email": reminderSettings['doctor']['email'] == null
                      ? false
                      : true,
                  "sms":
                      reminderSettings['doctor']['sms'] == null ? false : true,
                  "mobile_app": reminderSettings['doctor']['mobileApp'] == null
                      ? false
                      : true,
                  "send_day": reminderSettings['doctor']['send_period'],
                  "time": tempDoctorTime.length == 5
                      ? tempDoctorTime + ':00'
                      : tempDoctorTime
                }
              },
              "appointmentRemainder": null,
              "appointment": null
            }
          }
        : {
            "patient_id": selectedPatient['id'],
            "chief_problem": "",
            "treatment_id": selectedTreatment['id'],
            "treatment_time": int.tryParse(treatment_time.text),
            "buffer_time": int.tryParse(buffer_time.text),
            "note": note.text,
            "appointment_date": date.text,
            "doctor_id": selectedDoctor['id'],
            "start_time": modifiedStartTime,
            "end_time": modifiedEndTime,
            "globalAppointementRemainder": {
              "globalAppointmentRemainder": null,
              "id": 1,
              "appointment_remainder": "Remainder for Patients/Doctor",
              "send_remainder": reminderSettings['send'],
              "data": {
                "patient": {
                  "email": reminderSettings['patient']['email'] == null
                      ? false
                      : true,
                  "sms":
                      reminderSettings['patient']['sms'] == null ? false : true,
                  "send_day": reminderSettings['patient']['send_period'],
                  "time": tempPatientTime.length == 5
                      ? tempPatientTime + ':00'
                      : tempPatientTime
                },
                "doctor": {
                  "email": reminderSettings['doctor']['email'] == null
                      ? false
                      : true,
                  "sms":
                      reminderSettings['doctor']['sms'] == null ? false : true,
                  "mobile_app": reminderSettings['doctor']['mobileApp'] == null
                      ? false
                      : true,
                  "send_day": reminderSettings['doctor']['send_period'],
                  "time": tempDoctorTime.length == 5
                      ? tempDoctorTime + ':00'
                      : tempDoctorTime
                }
              },
              "appointmentRemainder": null,
              "appointment": null
            }
          };

    isLoading = true;
    if (widget.appointment == null) {
      var res = await AppointmentService().addAppointment(payload);

      if (res['title'] == 'Success' && res['http_status'] == 200) {
        res['messages'].forEach((message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${message['message']}'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
        goToAppointmentPage();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add Appointment!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      var res = await AppointmentService()
          .editAppointment(payload, widget.appointment['id']);

      if (res['title'] == 'Success' && res['http_status'] == 200) {
        res['messages'].forEach((message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${message['message']}'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
        goToAppointmentPage();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to edit Appointment!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    isLoading = false;
  }

  validateBreakTime() {
    // break time validation

    if (!appointment_from_time.text.contains('PM') &&
        !appointment_from_time.text.contains('AM')) {
      fromTime =
          UtilService().convert24hrsto12hrsFormat(appointment_from_time.text);
    }

    if (!appointment_to.text.contains('PM') &&
        !appointment_to.text.contains('AM')) {
      toTime = UtilService().convert24hrsto12hrsFormat(appointment_to.text);
    }

    for (var shift in shiftOfDoctorList) {
      if (shift['break_start_time'] != null &&
          shift['break_stop_time'] != null) {
        var breakStartTime = convert24HourTo12Hour(shift['break_start_time']);
        var breakEndTime = convert24HourTo12Hour(shift['break_stop_time']);

        var validFromTime = checkSlotRange(
            !appointment_from_time.text.contains('PM') &&
                    !appointment_from_time.text.contains('AM')
                ? fromTime
                : appointment_from_time.text,
            '${breakStartTime} - ${breakEndTime}');

        var validToTime = checkSlotRange(
            !appointment_to.text.contains('PM') &&
                    !appointment_to.text.contains('AM')
                ? toTime
                : appointment_to.text,
            '${breakStartTime} - ${breakEndTime}');

        if (validFromTime == true || validToTime == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Appointment falls under break time!'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
        }
      }
    }
  }

  validateSlots() {
    if (widget.appointment != null) {
      if (widget.appointment["appointment_date"] == date.text) {
        var tempBookedStartTime = widget.appointment['start_time'];
        var tempBookedEndTime = widget.appointment['end_time'];

        bookedSlotsList = bookedSlotsList.where((slot) {
          var startTime = slot.split(' - ')[0];
          // Keep slots that do not match the booked start or end time
          return startTime != tempBookedStartTime &&
              startTime != tempBookedEndTime;
        }).toList();
      }
    }

    var valid = true;

    if (!appointment_from_time.text.contains('PM') &&
        !appointment_from_time.text.contains('AM')) {
      fromTime =
          UtilService().convert24hrsto12hrsFormat(appointment_from_time.text);
    }

    if (!appointment_to.text.contains('PM') &&
        !appointment_to.text.contains('AM')) {
      toTime = UtilService().convert24hrsto12hrsFormat(appointment_to.text);
    }

    for (String slot in bookedSlotsList) {
      var range = ((!appointment_from_time.text.contains('PM') &&
                  !appointment_from_time.text.contains('AM'))
              ? fromTime
              : appointment_from_time.text) +
          ' - ' +
          ((!appointment_to.text.contains('PM') &&
                  !appointment_to.text.contains('AM'))
              ? toTime
              : appointment_to.text);
      var validStartTime = checkSlotRange(slot.split(' - ')[0], range);
      var rangeTo = ((!appointment_from_time.text.contains('PM') &&
                  !appointment_from_time.text.contains('AM'))
              ? fromTime
              : appointment_from_time.text) +
          ' - ' +
          ((!appointment_to.text.contains('PM') &&
                  !appointment_to.text.contains('AM'))
              ? toTime
              : appointment_to.text);
      var validToTime = checkSlotRange(slot.split(' - ')[1], rangeTo);

      if (validStartTime == true || validToTime == true) {
        valid = false;
        break;
      }
    }

    // Checking if same as any booked slot
    var range = ((!appointment_from_time.text.contains('PM') &&
                !appointment_from_time.text.contains('AM'))
            ? fromTime
            : appointment_from_time.text) +
        ' - ' +
        ((!appointment_to.text.contains('PM') &&
                !appointment_to.text.contains('AM'))
            ? toTime
            : appointment_to.text);

    for (String slot in bookedSlotsList) {
      if (slot == range) {
        valid = false;
        break;
      }
    }

    return valid;
  }

  checkSlotRange(inputTime, timeRangeStr) {
    List<String> timeParts = timeRangeStr.split(" - ");
    String startTimeStr = timeParts[0];
    String endTimeStr = timeParts[1];

    // Convert input and range times to DateTime objects
    DateTime inputTimeObj = DateFormat("h:mm a").parse(inputTime);
    DateTime startTimeObj = DateFormat("h:mm a").parse(startTimeStr);
    DateTime endTimeObj = DateFormat("h:mm a").parse(endTimeStr);

    // Check if input time falls within the range
    if ((inputTimeObj.isAfter(startTimeObj) &&
        inputTimeObj.isBefore(endTimeObj))) {
      return true;
    } else {
      return false;
    }
  }

  String convert24HourTo12Hour(String time24Hour) {
    DateFormat inputFormat = DateFormat('HH:mm:ss');
    DateFormat outputFormat = DateFormat('h:mm a');

    try {
      // Trim the input string to remove leading and trailing spaces
      time24Hour = time24Hour.trim();

      DateTime dateTime = inputFormat.parseStrict(time24Hour);
      return outputFormat.format(dateTime);
    } catch (e) {
      return "Invalid Time";
    }
  }

  validateShift() {
    var valid = false;

    if (!appointment_from_time.text.contains('PM') &&
        !appointment_from_time.text.contains('AM')) {
      fromTime =
          UtilService().convert24hrsto12hrsFormat(appointment_from_time.text);
    }

    if (!appointment_to.text.contains('PM') &&
        !appointment_to.text.contains('AM')) {
      toTime = UtilService().convert24hrsto12hrsFormat(appointment_to.text);
    }

    // Shift Validation

    for (var shift in shiftOfDoctorList) {
      var tempShift =
          '${UtilService().timeConverter(shift['start_time'])} - ${UtilService().timeConverter(shift['end_time'])}';

      var validFromTime = checkFromRange(
          !appointment_from_time.text.contains('PM') &&
                  !appointment_from_time.text.contains('AM')
              ? fromTime
              : appointment_from_time.text,
          tempShift);

      var validToTime = checkToRange(
          !appointment_to.text.contains('PM') &&
                  !appointment_to.text.contains('AM')
              ? toTime
              : appointment_to.text,
          tempShift);

      if (validFromTime == true && validToTime == true) {
        valid = true;
        break;
      }
    }

    return valid;
  }

  checkToRange(inputTime, timeRangeStr) {
    List<String> timeParts = timeRangeStr.split(" - ");
    String startTimeStr = timeParts[0];
    String endTimeStr = timeParts[1];

    // Convert input and range times to DateTime objects
    DateTime inputTimeObj = DateFormat("h:mm a").parse(inputTime);
    DateTime startTimeObj = DateFormat("h:mm a").parse(startTimeStr);
    DateTime endTimeObj = DateFormat("h:mm a").parse(endTimeStr);

    // Check if input time falls within the range
    if (inputTimeObj.isAtSameMomentAs(startTimeObj) ||
        (inputTimeObj.isAfter(startTimeObj) &&
                inputTimeObj.isAtSameMomentAs(endTimeObj) ||
            inputTimeObj.isBefore(endTimeObj))) {
      return true;
    } else {
      return false;
    }
  }

  checkFromRange(String inputTime, String timeRangeStr) {
    // Split the time range string into start and end times
    List<String> timeParts = timeRangeStr.split(" - ");
    String startTimeStr = timeParts[0];
    String endTimeStr = timeParts[1];

    // Convert input and range times to DateTime objects
    DateTime inputTimeObj = DateFormat("h:mm a").parse(inputTime);
    DateTime startTimeObj = DateFormat("h:mm a").parse(startTimeStr);
    DateTime endTimeObj = DateFormat("h:mm a").parse(endTimeStr);

    // Check if input time is between start (inclusive) and end (exclusive) times
    return (inputTimeObj.isAtSameMomentAs(startTimeObj) ||
            inputTimeObj.isAfter(startTimeObj)) &&
        inputTimeObj.isBefore(endTimeObj);
  }

  String convert12HourTo24Hour(String time12Hour) {
    DateFormat inputFormat = DateFormat('h:mm a', 'en_US');
    DateFormat outputFormat = DateFormat('HH:mm');
    DateTime dateTime = inputFormat.parse(time12Hour);
    return outputFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(54, 135, 147, 1),
        title: Container(
          margin: EdgeInsets.fromLTRB(0, 0, 30, 0),
          child: Center(
            child: widget.appointment != null && widget.mode != null
                ? Text(
                    'Appointment Reschedule',
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )
                : widget.appointment != null
                    ? Text(
                        'Appointment Edit',
                        style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )
                    : Text(
                        'Appointment Add',
                        style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            height: 12,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(249, 249, 250, 1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient Name',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      ' *',
                      style: TextStyle(color: Colors.red),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TypeAheadField(
                    controller: patient_name,
                    suggestionsCallback: (pattern) {
                      return patientList
                          .where((item) => item['name']
                              .toLowerCase()
                              .contains(pattern.toLowerCase()))
                          .toList();
                    },
                    builder: (context, patient_name, focusNode) {
                      return TextField(
                        onChanged: (value) {
                          setState(() {
                            patientSelected = false;
                          });
                        },
                        enabled:
                            widget.mode != null || widget.appointment != null
                                ? false
                                : true,
                        controller: patient_name,
                        autofocus: false,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: widget.mode != null
                                ? Color.fromRGBO(199, 233, 238, 1)
                                : Colors.white,
                            border: InputBorder.none,
                            suffixIconConstraints:
                                BoxConstraints(minHeight: 16, minWidth: 16),
                            suffixIcon: patient_name.text.isEmpty ||
                                    widget.mode != null ||
                                    widget.appointment != null
                                ? null
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        patient_name.clear();
                                        selectedPatient = null;
                                        patient_name.text = '';
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 11, 0),
                                      child: SvgPicture.asset(
                                        'assets/cross.svg',
                                      ),
                                    ),
                                  )),
                      );
                    },
                    itemBuilder: (context, patient) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: Text(
                              '${patient['name']} (${patient['registration_no']})'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${patient['contact_number']}'),
                              Text('${patient['address'] ?? '-'}'),
                            ],
                          ),
                        ),
                      );
                    },
                    emptyBuilder: (context) {
                      // Customize the message when no suggestions are found
                      return Container(
                          padding: EdgeInsets.all(10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text('Please type to Search'));
                    },
                    onSelected: (patient) {
                      setState(() {
                        patientSelected = true;
                      });
                      onPatientSelect(patient);
                    },
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Treatment',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    ' *',
                                    style: TextStyle(color: Colors.red),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: TypeAheadField(
                                  controller: treatment,
                                  suggestionsCallback: (pattern) {
                                    return treatmentList
                                        .where((item) => item['name']
                                            .toLowerCase()
                                            .contains(pattern.toLowerCase()))
                                        .toList();
                                  },
                                  builder: (context, treatment, focusNode) {
                                    return TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          treatmentSelected = false;
                                        });
                                      },
                                      enabled: (widget.mode == 'reschedule' ||
                                              widget.mode == null)
                                          ? true
                                          : false,
                                      controller: treatment,
                                      focusNode: focusNode,
                                      autofocus: false,
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor:
                                              (widget.mode == 'reschedule' ||
                                                      widget.mode == null)
                                                  ? Colors.white
                                                  : Color.fromRGBO(
                                                      199, 233, 238, 1),
                                          border: InputBorder.none,
                                          suffixIconConstraints: BoxConstraints(
                                              minHeight: 16, minWidth: 16),
                                          suffixIcon: treatment.text.isEmpty
                                              ? null
                                              : GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      treatment.clear();
                                                      selectedTreatment = null;
                                                    });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        0, 0, 11, 0),
                                                    child: SvgPicture.asset(
                                                      'assets/cross.svg',
                                                    ),
                                                  ),
                                                )),
                                    );
                                  },
                                  itemBuilder: (context, treatment) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: ListTile(
                                        title: Text('${treatment['name']}'),
                                      ),
                                    );
                                  },
                                  emptyBuilder: (context) {
                                    // Customize the message when no suggestions are found
                                    return Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        padding: EdgeInsets.all(10),
                                        child: Text('Please type to Search'));
                                  },
                                  onSelected: (treatment) {
                                    setState(() {
                                      treatmentSelected = true;
                                    });
                                    onTreatmentSelect(treatment);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Duration',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: 80,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  if (value != '') {
                                    if (!appointment_from_time.text
                                            .contains('PM') &&
                                        !appointment_from_time.text
                                            .contains('AM')) {
                                      appointment_from_time.text = UtilService()
                                          .convert24hrsto12hrsFormat(
                                              appointment_from_time.text);
                                    }

                                    final newTime = addMinutesToTimeString(
                                        appointment_from_time.text,
                                        int.tryParse(duration.text));
                                    this.appointment_to.text = newTime;
                                  } else {
                                    this.appointment_to.text = '';
                                  }
                                },
                                controller: duration,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(12, 0, 12, 0),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(0))),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          ' *',
                          style: TextStyle(color: Colors.red),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showFormCalendar = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          enabled: false,
                          controller: date,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0))),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),

                // Calendar
                //
                showFormCalendar == false
                    ? SizedBox(
                        height: 0,
                      )
                    : Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white70,
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TableCalendar(
                          onPageChanged: (focusedDay) async {
                            _focusedFromDay = focusedDay;
                            // _selectedFromDay = focusedDay;
                          },
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: _focusedFromDay,
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                          ),
                          calendarStyle: CalendarStyle(
                            markerDecoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2))),
                            selectedDecoration: BoxDecoration(
                              color: Color.fromRGBO(54, 135, 147, 1),
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                                color: Color.fromRGBO(54, 135, 147,
                                    0.6), // Set the color of the today date background
                                shape: BoxShape
                                    .circle // You can use other shapes like BoxShape.rectangle
                                ),
                          ),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              selectedDoctor = null;
                              doctorSelected = false;
                              doctor_name.text = '';
                              shiftOfDoctorList = [];
                              bookedSlotsList = [];
                              appointment_from_time.text = '';
                              appointment_to.text = '';
                              _selectedDay = selectedDay;
                              _focusedFromDay = focusedDay;
                              date.text = UtilService().removeDetailsFromDate(
                                  selectedDay.toString());
                              showFormCalendar = false;
                            });
                            getAvailableDoctors();
                          },
                        ),
                      ),
                // calendar
                //
                showFormCalendar == false
                    ? SizedBox(
                        height: 0,
                      )
                    : SizedBox(
                        height: 12,
                      ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Available Doctor',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          ' *',
                          style: TextStyle(color: Colors.red),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TypeAheadField(
                        controller: doctor_name,
                        suggestionsCallback: (pattern) {
                          return availableDoctorList
                              .where((item) => item['name']
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                              .toList();
                        },
                        builder: (context, doctor_name, focusNode) {
                          return TextField(
                            onChanged: (value) {
                              setState(() {
                                doctorSelected = false;
                              });
                            },
                            controller: doctor_name,
                            enabled: (widget.mode == 'reschedule' ||
                                    widget.mode == null)
                                ? true
                                : false,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: (widget.mode == 'reschedule' ||
                                        widget.mode == null)
                                    ? Colors.white
                                    : Color.fromRGBO(199, 233, 238, 1),
                                border: InputBorder.none,
                                suffixIconConstraints:
                                    BoxConstraints(minHeight: 16, minWidth: 16),
                                suffixIcon: doctor_name.text.isEmpty
                                    ? null
                                    : GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            doctor_name.clear();
                                            selectedDoctor = null;
                                            doctorSelected = false;
                                            shiftOfDoctorList = [];
                                            bookedSlotsList = [];
                                            appointment_from_time.clear();
                                            appointment_to.clear();
                                          });
                                        },
                                        child: Container(
                                          margin:
                                              EdgeInsets.fromLTRB(0, 0, 11, 0),
                                          child: SvgPicture.asset(
                                            'assets/cross.svg',
                                          ),
                                        ),
                                      )),
                          );
                        },
                        itemBuilder: (context, doctor) {
                          return ListTile(
                            tileColor: Colors.white,
                            title: Text('${doctor['name']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${doctor['qualification'] ?? ''} ${doctor['qualification'].length > 0 && doctor['specialization'].length > 0 ? '|' : ''} ${doctor['specialization'] ?? ''}'),
                              ],
                            ),
                          );
                        },
                        emptyBuilder: (context) {
                          // Customize the message when no suggestions are found
                          return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              padding: EdgeInsets.all(10),
                              child: Text('Please type to Search'));
                        },
                        onSelected: (doctor) {
                          setState(() {
                            doctorSelected = true;
                          });
                          onDoctorSelect(doctor);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'Shift time of Doctor',
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  height: 27,
                  margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: shiftOfDoctorList.length,
                      itemBuilder: (context, index) {
                        return Container(
                            width: 160,
                            margin: EdgeInsets.fromLTRB(0, 0, 12, 0),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(246, 247, 248, 1),
                                border: Border.all(
                                    width: 1,
                                    color: Color.fromRGBO(222, 226, 230, 1))),
                            padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                            child: Center(
                              child: Text(
                                UtilService().timeConverter(
                                        shiftOfDoctorList[index]
                                            ['start_time']) +
                                    ' - ' +
                                    UtilService().timeConverter(
                                        shiftOfDoctorList[index]['end_time']),
                                style: TextStyle(
                                    color: Color.fromRGBO(136, 46, 46, 1)),
                              ),
                            ));
                      }),
                ),
                SizedBox(
                  height: 12,
                ),
                bookedSlotsList.length > 0
                    ? Container(
                        height: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booked Slots',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                                height: 27,
                                margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: bookedSlotsList.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                          width: 160,
                                          margin:
                                              EdgeInsets.fromLTRB(0, 0, 12, 0),
                                          decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  255, 193, 7, 1),
                                              border: Border.all(
                                                  width: 1,
                                                  color: Color.fromRGBO(
                                                      222, 226, 230, 1))),
                                          padding:
                                              EdgeInsets.fromLTRB(6, 2, 6, 2),
                                          child: Center(
                                            child: Text(
                                              bookedSlotsList[index],
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ));
                                    }))
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 0,
                      ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appointment Time From',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                            Text(
                              ' *',
                              style: TextStyle(color: Colors.red),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () => _selectTime(context),
                            child: TextField(
                              controller: appointment_from_time,
                              enabled: false,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(12, 0, 12, 0),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  suffixIconConstraints: BoxConstraints(
                                      minHeight: 16, minWidth: 16),
                                  suffixIcon: Container(
                                    margin: EdgeInsets.fromLTRB(0, 0, 12, 0),
                                    child: SvgPicture.asset(
                                      'assets/clock.svg',
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    )),
                    SizedBox(
                      width: 24,
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: appointment_to,
                            enabled: false,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Color.fromRGBO(199, 233, 238, 1),
                                contentPadding:
                                    EdgeInsets.fromLTRB(12, 0, 12, 0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                suffixIconConstraints:
                                    BoxConstraints(minHeight: 16, minWidth: 16),
                                suffixIcon: Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 12, 0),
                                  child: SvgPicture.asset(
                                    'assets/clock.svg',
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ))
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    enabled: widget.mode != null ? false : true,
                    controller: note,
                    maxLines: 5,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: widget.mode != null
                          ? Color.fromRGBO(199, 233, 238, 1)
                          : Colors.white,
                      contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                    obscureText: false,
                  ),
                ),

                SizedBox(
                  height: 12,
                ),
                Container(
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        reminderSettings['send'] = !reminderSettings['send'];
                      });
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/bell.svg',
                        ),
                        Text(
                          ' Send reminder',
                          style:
                              TextStyle(color: Color.fromRGBO(54, 135, 147, 1)),
                        ),
                      ],
                    ),
                  ),
                ),
                reminderSettings['send']
                    ? Container(
                        height: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'For Patient',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              height: 30,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Send via'),
                                  // Checkbox(
                                  //   activeColor:
                                  //       Color.fromRGBO(54, 135, 147, 1),
                                  //   value: reminderSettings['patient']
                                  //       ['send_via']['email'],
                                  //   onChanged: (value) {
                                  //     setState(() {
                                  //       reminderSettings['patient']['send_via']
                                  //               ['email'] =
                                  //           !reminderSettings['patient']
                                  //               ['send_via']['email'];
                                  //     });
                                  //   },
                                  // ),
                                  // Text('Email'),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Checkbox(
                                    activeColor:
                                        Color.fromRGBO(54, 135, 147, 1),
                                    value: reminderSettings['patient']
                                        ['send_via']['sms'],
                                    onChanged: (value) {
                                      setState(() {
                                        reminderSettings['patient']['send_via']
                                                ['sms'] =
                                            !reminderSettings['patient']
                                                ['send_via']['sms'];
                                      });
                                    },
                                  ),
                                  Text('SMS'),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text('Send'),
                            SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 47,
                                    padding: EdgeInsets.fromLTRB(14, 6, 6, 0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: DropdownButton<String>(
                                      hint: Text('Select Day'),
                                      dropdownColor: Colors.white,
                                      underline: Container(
                                        height:
                                            0, // Set height to 0 to remove underline
                                        color: Colors
                                            .transparent, // Set color to transparent
                                      ),
                                      isExpanded: true,
                                      value: reminderSettings['patient']
                                              ['send_via'][
                                          'send_period'], // Currently selected item
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          reminderSettings['patient']
                                                  ['send_via']['send_period'] =
                                              newValue!; // Update selected item
                                        });
                                      },
                                      items: periodList
                                          .map<DropdownMenuItem<String>>(
                                              (Map<String, String> period) {
                                        return DropdownMenuItem<String>(
                                          value: period[
                                              'value'], // Get the value from the map
                                          child: Text(period[
                                              'name']!), // Get the name from the map
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: GestureDetector(
                                        onTap: () =>
                                            _selectPatientReminderTime(context),
                                        child: TextField(
                                          controller: patient_reminder_time,
                                          enabled: false,
                                          decoration: InputDecoration(
                                              hintText: 'Select Time',
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      12, 0, 12, 0),
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5))),
                                              suffixIconConstraints:
                                                  BoxConstraints(
                                                      minHeight: 16,
                                                      minWidth: 16),
                                              suffixIcon: Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 0, 12, 0),
                                                child: SvgPicture.asset(
                                                  'assets/clock.svg',
                                                ),
                                              )),
                                        ),
                                      )),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Text(
                              'For Doctor',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              height: 30,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Send via'),
                                  Checkbox(
                                    activeColor:
                                        Color.fromRGBO(54, 135, 147, 1),
                                    value: reminderSettings['doctor']
                                        ['send_via']['sms'],
                                    onChanged: (value) {
                                      setState(() {
                                        reminderSettings['doctor']['send_via']
                                                ['sms'] =
                                            !reminderSettings['doctor']
                                                ['send_via']['sms'];
                                      });
                                    },
                                  ),
                                  Text('SMS'),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Checkbox(
                                    activeColor:
                                        Color.fromRGBO(54, 135, 147, 1),
                                    value: reminderSettings['doctor']
                                        ['send_via']['mobileApp'],
                                    onChanged: (value) {
                                      setState(() {
                                        reminderSettings['doctor']['send_via']
                                                ['mobileApp'] =
                                            !reminderSettings['doctor']
                                                ['send_via']['mobileApp'];
                                      });
                                    },
                                  ),
                                  Text('Mobile App'),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text('Send'),
                            SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 47,
                                    padding: EdgeInsets.fromLTRB(14, 6, 6, 0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: DropdownButton<String>(
                                      hint: Text('Select Day'),
                                      dropdownColor: Colors.white,
                                      underline: Container(
                                        height:
                                            0, // Set height to 0 to remove underline
                                        color: Colors
                                            .transparent, // Set color to transparent
                                      ),
                                      isExpanded: true,
                                      value: reminderSettings['patient']
                                              ['send_via'][
                                          'send_period'], // Currently selected item
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          reminderSettings['patient']
                                                  ['send_via']['send_period'] =
                                              newValue!; // Update selected item
                                        });
                                      },
                                      items: periodList
                                          .map<DropdownMenuItem<String>>(
                                              (Map<String, String> period) {
                                        return DropdownMenuItem<String>(
                                          value: period[
                                              'value'], // Get the value from the map
                                          child: Text(period[
                                              'name']!), // Get the name from the map
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: GestureDetector(
                                        onTap: () =>
                                            _selectDoctorReminderTime(context),
                                        child: TextField(
                                          controller: doctor_reminder_time,
                                          enabled: false,
                                          decoration: InputDecoration(
                                              hintText: 'Select Time',
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      12, 0, 12, 0),
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5))),
                                              suffixIconConstraints:
                                                  BoxConstraints(
                                                      minHeight: 16,
                                                      minWidth: 16),
                                              suffixIcon: Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 0, 12, 0),
                                                child: SvgPicture.asset(
                                                  'assets/clock.svg',
                                                ),
                                              )),
                                        ),
                                      )),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 0,
                      )
              ],
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => goToCalendarPage(),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: Color.fromRGBO(37, 94, 102, 1)),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        fontSize: 14, color: Color.fromRGBO(37, 94, 102, 1)),
                  ),
                ),
              ),
              SizedBox(
                width: 24,
              ),
              widget.mode != null
                  ? GestureDetector(
                      onTap: () {
                        rescheduleAppointment();
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(37, 94, 102, 1),
                            border: Border.all(
                                width: 1,
                                color: Color.fromRGBO(37, 94, 102, 1)),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          'Reschedule',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        if (isLoading == false) {
                          saveAppointment();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(37, 94, 102, 1),
                            border: Border.all(
                                width: 1,
                                color: Color.fromRGBO(37, 94, 102, 1)),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Text(
                          'Save',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    )
            ],
          ),
          SizedBox(
            height: 400,
          )
        ],
      ),
    );
  }
}
