import 'package:np_date_picker/np_date_picker.dart';

class UtilService {
  convertNepaliDateToEnglish(nepaliDate) {
    NepaliDateTime nepaliDateTime = NepaliDateTime.parse(nepaliDate);
    DateTime englishDateTime = nepaliDateTime.toDateTime();
    return englishDateTime;
  }
}
