import 'dart:convert';
import 'dart:io';
import 'package:docuhealth/components/default_button.dart';
import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/daily_measurement_controller.dart';

class AddMeasurement extends StatefulWidget {
  final String category;
  const AddMeasurement({super.key, required this.category});

  @override
  State<AddMeasurement> createState() => _AddMeasurementState();
}

class _AddMeasurementState extends State<AddMeasurement> {
  BaseClient baseClient = BaseClient();
  TextEditingController timeController =
      TextEditingController(text: DateFormat('hh:mm a').format(DateTime.now()));
  TextEditingController dateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
  TextEditingController upperBondController = TextEditingController();
  TextEditingController lowerBondController = TextEditingController();
  TextEditingController commentControllerController = TextEditingController();
  TextEditingController datasController = TextEditingController();
  XFile? attachment;

  List<String> weightUnit = ["Kg", "Pound"];
  String selectedWeightUnit = "Kg";
  List<String> temperatureUnit = ["°C", "°F"];
  String selectedTemperatureUnit = "°C";
  final ImagePicker picker = ImagePicker();

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay selectedTime = TimeOfDay.now();
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null) {
      if (!mounted) return;
      setState(() {
        timeController.text = timeOfDay.format(context);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (selected != null && selected != selectedDate) {
      if (!mounted) return;
      setState(() {
        selectedDate = selected;
        dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  Future<Map<String, dynamic>> onSubmitMeasurementPress({bool isAutoFetched = false}) async {
    var datas = widget.category == "BP"
        ? {
            "upper_bound": upperBondController.text,
            "lower_bound": lowerBondController.text
          }
        : widget.category == "Pulse"
            ? {"pulse_rate": datasController.text}
            : widget.category == "Sugar"
                ? {"sugar_lavel": datasController.text}
                : widget.category == "Temperature"
                    ? {"temperature": "${datasController.text} $selectedTemperatureUnit"}
                    : widget.category == "SpO2"
                        ? {"spo2": "${datasController.text}%"}
                        : {'weight': "${datasController.text} $selectedWeightUnit"};

    String encodedData = json.encode(datas);
    var data = {
      'date': dateController.text,
      'time': timeController.text,
      'category': widget.category,
      'datas': encodedData,
      'comment': commentControllerController.text,
      'is_auto_fetched': isAutoFetched,
    };
    final response = attachment == null
        ? await baseClient.post('measurements', data, true)
        : await baseClient.dataWithAttachment(
            'measurements', data, attachment!.path, true);

    debugPrint('AddMeasurement response: $response');

    if (response['success']) {
      if (!mounted) return {'success': false, 'message': 'Widget not mounted'};
      Provider.of<DailyMeasurementController>(context, listen: false)
          .getMeasurementsData(DateTime.now(), widget.category);
      Provider.of<DailyMeasurementController>(context, listen: false)
          .getAnalyticsData("Daily", widget.category);
      return {'success': true, 'message': response['message'] ?? 'Saved'};
    } else {
      return {'success': false, 'message': response['message'] ?? 'Failed to save measurement'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.calendar_month),
                title: Text('Date and Time'),
                trailing: Icon(Icons.check_circle_outline),
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: IgnorePointer(
                          child: TextField(
                        controller: dateController,
                        decoration: InputDecoration(
                          hintText: 'Select date',
                          filled: true,
                          fillColor: AppColors.whitebgColor,
                          border: const OutlineInputBorder(),
                        ),
                      )),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: (() => _selectTime(context)),
                      child: IgnorePointer(
                          child: TextField(
                        controller: timeController,
                        decoration: InputDecoration(
                          hintText: 'Select Time',
                          filled: true,
                          fillColor: AppColors.whitebgColor,
                          border: const OutlineInputBorder(),
                        ),
                      )),
                    ),
                  ),
                ],
              ),
              const ListTile(
                leading: Icon(Icons.file_copy),
                title: Text('Information'),
                trailing: Icon(Icons.check_circle_outline),
              ),
              widget.category == "BP"
                  ? TextField(
                      controller: upperBondController,
                      maxLength: 3,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Upperbond',
                        filled: true,
                        counterText: "",
                        fillColor: AppColors.whitebgColor,
                        border: const OutlineInputBorder(),
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                height: 10.w,
              ),
              widget.category == "BP"
                  ? TextField(
                      controller: lowerBondController,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      decoration: InputDecoration(
                        hintText: 'Lowerbond',
                        filled: true,
                        counterText: "",
                        fillColor: AppColors.whitebgColor,
                        border: const OutlineInputBorder(),
                      ),
                    )
                  : const SizedBox(),
              widget.category != "BP"
                  ? (widget.category == "Weight" || widget.category == "Temperature")
                      ? Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: datasController,
                                maxLength: widget.category == "Temperature" ? 5 : 3,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  counterText: "",
                                  hintText: 'Enter ${widget.category}',
                                  filled: true,
                                  fillColor: AppColors.whitebgColor,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: const EdgeInsets.only(left: 10.0),
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    isExpanded: true,
                                    value: widget.category == "Temperature" 
                                        ? selectedTemperatureUnit 
                                        : selectedWeightUnit,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items: (widget.category == "Temperature" 
                                            ? temperatureUnit 
                                            : weightUnit)
                                        .map((String items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) async {
                                      setState(() {
                                        if (widget.category == "Temperature") {
                                          selectedTemperatureUnit = newValue!;
                                        } else {
                                          selectedWeightUnit = newValue!;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : TextField(
                          controller: datasController,
                          maxLength: 3,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            counterText: "",
                            hintText: 'Enter ${widget.category}',
                            filled: true,
                            fillColor: AppColors.whitebgColor,
                            border: const OutlineInputBorder(),
                          ),
                        )
                  : const SizedBox(),
              SizedBox(
                height: 10.w,
              ),
              TextField(
                controller: commentControllerController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Comment',
                  filled: true,
                  fillColor: AppColors.whitebgColor,
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              DottedBorder(
                options: const RoundedRectDottedBorderOptions(
                  radius: Radius.circular(12),
                  padding: EdgeInsets.all(6),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: InkWell(
                    onTap: () async {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext bc) {
                          return Container(
                            color: Colors.white,
                            child: Wrap(
                              children: <Widget>[
                                ListTile(
                                  leading: const Icon(
                                    Icons.image_outlined,
                                    color: Colors.grey,
                                  ),
                                  title: const Text(
                                    'Gallery',
                                  ),
                                  onTap: () async {
                                    Get.back();
                                    attachment = await ImagePicker()
                                        .pickImage(source: ImageSource.gallery);
                                    setState(() {});
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.grey,
                                  ),
                                  title: const Text(
                                    'Camera',
                                  ),
                                  onTap: () async {
                                    Get.back();
                                    attachment = await ImagePicker()
                                        .pickImage(source: ImageSource.camera);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryLinearGradient,
                      ),
                      child: attachment != null
                          ? Image.file(
                              File(attachment!.path),
                              fit: BoxFit.cover,
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload),
                                Text('Upload Document')
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              DefaultButton(
                buttonText: 'Save',
                onPress: () async {
                  final resp = await showDialog(
                    context: context,
                    builder: (context) => FutureProgressDialog(
                        onSubmitMeasurementPress(),
                        message: const Text('Please wait...')),
                  );
                  if (resp['success'] == true) {
                    Get.back();
                    Get.snackbar(
                      'Success',
                      resp['message'] ?? 'Measurement saved',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } else {
                    Get.snackbar(
                      'Error',
                      resp['message'] ?? 'Failed to save measurement',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 4),
                    );
                  }
                },
              ),
            ],
          ),
        )),
      ),
    );
  }
}
