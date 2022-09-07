import 'package:docuhealth/components/default_button.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import '../../contstants/app_colors.dart';
import '../../services/base_client.dart';
import '../../theme.dart';

class CreateFolderDialog extends StatefulWidget {
  final String? categoryName;
  const CreateFolderDialog({Key? key, this.categoryName}) : super(key: key);

  @override
  _CreateFolderDialogState createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  BaseClient baseClient = BaseClient();
  TextEditingController folderNameController = TextEditingController();
  String? dropdownvalue;
  var items = [
    {"title": "Test Reports", "category_name": "TEST_REPORTS"},
    {"title": "Doctor Prescription", "category_name": "DOCTOR_PRESCRIPTION"},
    {"title": "Daily Measurements", "category_name": "DAILY_MEASUREMENTS"},
    {"title": "Hospital Bills", "category_name": "HOSPITAL_BILLS"},
    {"title": "Pharmacy Records", "category_name": "PHARMACY_RECORDS"},
    {"title": "Remainders", "category_name": "REMAINDERS"},
    {"title": "My Docs", "category_name": "MY_DOCS"},
    {"title": "Genral Docs", "category_name": "GENRAL_DOCS"},
  ];

  Future<bool> createNewFolderPress(context) async {
    var data = {"name": folderNameController.text, "belongs_to": dropdownvalue};
    final response = await showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(
        baseClient.post('folder/create', data, true),
        message: const Text('Creating folder...'),
      ),
    );
    if (response['success']) {
      return true;
    } else {
      Get.snackbar("Failed", response['message'],
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getName();
    super.initState();
  }

  getName() {
    for (var i = 0; i < items.length; i++) {
      if (items[i]['category_name'] == widget.categoryName) {
        dropdownvalue = widget.categoryName;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: MediaQuery.of(context).size.height / 3 + 20,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          gradient: AppColors.primaryLinearGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.categoryName == "DOCTOR_PRESCRIPTION"
                  ? "Create new doctor"
                  : widget.categoryName == "HOSPITAL_BILLS"
                      ? "Create new hospital"
                      : "Create new folder",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: folderNameController,
              decoration: AppTheme.defaultInputFieldDecoration(
                widget.categoryName == "DOCTOR_PRESCRIPTION"
                    ? "Enter doctor name"
                    : widget.categoryName == "HOSPITAL_BILLS"
                        ? "Enter hospital name"
                        : "Enter folder name",
                Icons.folder,
              ),
              validator: (v) {
                if (v!.isEmpty) {
                  return widget.categoryName == "DOCTOR_PRESCRIPTION"
                      ? "Doctor name is required"
                      : widget.categoryName == "HOSPITAL_BILLS"
                          ? "Hospital name is required"
                          : "Folder name is required";
                }
              },
            ),
            const SizedBox(
              height: 15,
            ),
            DropdownButtonFormField(
              decoration: AppTheme.defaultInputFieldDecoration(
                  "Select category", Icons.category),
              value: dropdownvalue,
              validator: (v) {
                if (dropdownvalue == null) {
                  return "Category is required";
                }
              },
              icon: const Icon(Icons.keyboard_arrow_down),
              items: items.map((items) {
                return DropdownMenuItem(
                  value: items['category_name'],
                  child: Text(items['title']!),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownvalue = newValue!;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            DefaultButton(
              buttonText: "Create",
              onPress: () async {
                final bool isCreated = await createNewFolderPress(context);
                if (isCreated) {
                  Get.back();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
