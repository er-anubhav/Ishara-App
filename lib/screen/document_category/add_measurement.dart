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

class AddMeasurement extends StatefulWidget {
  final String category;
  const AddMeasurement({Key? key, required this.category}) : super(key: key);

  @override
  State<AddMeasurement> createState() => _AddMeasurementState();
}

class _AddMeasurementState extends State<AddMeasurement> {
  BaseClient baseClient = BaseClient();
  TextEditingController timeController = TextEditingController(
      text:
          '${TimeOfDay.now().hour}:${TimeOfDay.now().minute} ${TimeOfDay.now().period.toString().split('.')[1]}');
  TextEditingController dateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
  TextEditingController upperBondController = TextEditingController();
  TextEditingController lowerBondController = TextEditingController();
  TextEditingController commentControllerController = TextEditingController();
  TextEditingController datasController = TextEditingController();
  XFile? attachment;
  final ImagePicker picker = ImagePicker();

  _selectTime(BuildContext context) async {
    TimeOfDay selectedTime = TimeOfDay.now();
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null) {
      setState(() {
        timeController.text =
            '${timeOfDay.hour}:${timeOfDay.minute} ${timeOfDay.period.toString().split('.')[1]}';
      });
    }
  }

  _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
        dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  Future<bool> onSubmitMeasurementPress() async {
    var datas = widget.category == "BP"
        ? {
            "upper_bound": upperBondController.text,
            "lower_bound": lowerBondController.text
          }
        : widget.category == "Pulse"
            ? {"pulse_rate": datasController.text}
            : widget.category == "Sugar"
                ? {"sugar_lavel": datasController.text}
                : {'weight': datasController.text};

    String encodedData = json.encode(datas);
    var data = {
      'date': dateController.text,
      'time': timeController.text,
      'category': widget.category,
      'datas': encodedData,
      'comment': commentControllerController.text
    };
    final response = attachment == null
        ? await baseClient.post('measurements', data, true)
        : await baseClient.dataWithAttachment(
            'measurements', data, attachment!.path, true);

    print(response);

    if (response['success']) {
      return true;
    } else {
      return false;
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
                      decoration: InputDecoration(
                        hintText: 'Upperbond',
                        filled: true,
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
                      decoration: InputDecoration(
                        hintText: 'Lowerbond',
                        filled: true,
                        fillColor: AppColors.whitebgColor,
                        border: const OutlineInputBorder(),
                      ),
                    )
                  : const SizedBox(),
              widget.category != "BP"
                  ? TextField(
                      controller: datasController,
                      decoration: InputDecoration(
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
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                padding: const EdgeInsets.all(6),
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
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
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
                  if (resp) {
                    Get.back();
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
