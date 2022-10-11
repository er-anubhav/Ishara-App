import 'dart:io';
import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/helper/get_storage_helper.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:docuhealth/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class MyProfileEdit extends StatefulWidget {
  const MyProfileEdit({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MyProfileEdit>
    with SingleTickerProviderStateMixin {
  bool _status = true;
  bool isUploading = false;
  bool isLoading = true;
  BaseClient baseClient = BaseClient();
  final FocusNode myFocusNode = FocusNode();
  File? profilePick;
  String profileUrl = '';
  bool isShowselfEdit = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  TextEditingController relationController = TextEditingController();
  String? dropdownvalue;
  var items = [
    'Brother',
    'Daughter',
    'Father',
    'Friend',
    'Grand Father',
    'Grand Mother',
    'Husband',
    'Mother',
    'Sister',
    'Son',
    'Wife',
  ];

  getProfile(context) async {
    final resp = await baseClient.get('profile/get', true);
    if (resp['success']) {
      nameController.text = resp['data']['profile']['name'];
      emailController.text = resp['data']['user']['email'] ?? "";
      phoneController.text = resp['data']['user']['phone'] ?? "";
      profileUrl = resp['data']['profile']['icon'];
      relationController.text = resp['data']['profile']['relation'] ?? "";
      isShowselfEdit = resp['data']['profile']['type'] != "Add-On";
      dropdownvalue = resp['data']['profile']['relation'];
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> updateProfile(context) async {
    var data = !isShowselfEdit
        ? {
            "relation": relationController.text,
            "name": nameController.text,
          }
        : {
            "name": nameController.text,
            "email": emailController.text,
            "phone": phoneController.text,
          };
    // print(data);
    final resp = await baseClient.post('profile/update', data, true);
    if (resp['success']) {
      box.write('username', nameController.text);
      box.write('email', emailController.text);
      box.write('mobileno', phoneController.text);
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    getProfile(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isUploading,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColors.primaryColor,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
          ),
          backgroundColor: AppColors.primaryColor,
          title: const Text(
            "Profile",
            style: TextStyle(color: Colors.white),
          ),
          actions: const <Widget>[],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        height: 200.0,
                        color: AppColors.primaryColor,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child:
                                  Stack(fit: StackFit.loose, children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      child: profilePick != null
                                          ? CircleAvatar(
                                              radius: 70.r,
                                              backgroundImage: FileImage(
                                                File(profilePick!.path),
                                              ),
                                            )
                                          : CircleAvatar(
                                              radius: 70.r,
                                              backgroundImage:
                                                  NetworkImage(profileUrl),
                                            ),
                                    ),
                                  ],
                                ),
                                // Padding(
                                //     padding: const EdgeInsets.only(
                                //         top: 90.0, right: 100.0),
                                //     child: Row(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.center,
                                //       children: <Widget>[
                                //         CircleAvatar(
                                //           backgroundColor: Colors.red,
                                //           radius: 25.0,
                                //           child: IconButton(
                                //             icon: const Icon(
                                //               Icons.camera_alt_outlined,
                                //             ),
                                //             color: Colors.white,
                                //             onPressed: () {
                                //               _settingModalBottomSheet(context);
                                //             },
                                //           ),
                                //         )
                                //       ],
                                //     )),
                              ]),
                            )
                          ],
                        ),
                      ),
                      Container(
                        color: const Color(0xffFFFFFF),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: isShowselfEdit
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, right: 16.0, top: 16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: const <Widget>[
                                                Text(
                                                  'Personal Information',
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                _status
                                                    ? _getEditIcon()
                                                    : Container(),
                                              ],
                                            )
                                          ],
                                        )),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, right: 16.0, top: 16.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: const <Widget>[
                                                Text(
                                                  'Name',
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, right: 16.0, top: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Flexible(
                                              child: TextField(
                                                decoration: AppTheme
                                                    .defaultDescriptionInputFieldDecoration(
                                                  'Enter user name',
                                                  Icons.person,
                                                ),
                                                enabled: !_status,
                                                autofocus: !_status,
                                                controller: nameController,
                                              ),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, right: 16.0, top: 16.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: const <Widget>[
                                                Text(
                                                  'Emergency Contact',
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, right: 16.0, top: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Flexible(
                                              child: TextField(
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                decoration: AppTheme
                                                    .defaultDescriptionInputFieldDecoration(
                                                  'Enter emergency contact',
                                                  Icons.person,
                                                ),
                                                enabled: !_status,
                                                controller: emailController,
                                              ),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, right: 16.0, top: 16.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: const <Widget>[
                                                Text(
                                                  'Phone number',
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, right: 16.0, top: 10.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Flexible(
                                            child: TextField(
                                              maxLength: 10,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: AppTheme
                                                  .defaultDescriptionInputFieldDecoration(
                                                'Enter phone number',
                                                Icons.person,
                                              ),
                                              enabled: !_status,
                                              controller: phoneController,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _status == false
                                        ? Container(
                                            child: _getActionButtons(),
                                          )
                                        : const SizedBox(height: 60),
                                  ],
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0,
                                              right: 16.0,
                                              bottom: 16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: const <Widget>[
                                                  Text(
                                                    'Personal Information',
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  _status
                                                      ? _getEditIcon()
                                                      : Container(),
                                                ],
                                              )
                                            ],
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0,
                                        ),
                                        child: Text(
                                          "Name",
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15.h,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0,
                                        ),
                                        child: TextFormField(
                                          controller: nameController,
                                          enabled: !_status,
                                          decoration: AppTheme
                                              .defaultInputFieldDecoration(
                                            "Enter full name",
                                            Icons.person,
                                          ),
                                          validator: (v) {
                                            if (v!.isEmpty) {
                                              return "Name is required";
                                            }
                                          },
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp("[ a-zA-Z]")),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15.h,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0,
                                        ),
                                        child: Text(
                                          "Relation",
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15.h,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0,
                                        ),
                                        child: DropdownButtonFormField(
                                          decoration: AppTheme
                                              .defaultInputFieldDecoration(
                                            "Select relation",
                                            Icons.group,
                                          ),
                                          value: dropdownvalue,
                                          validator: (v) {
                                            if (relationController
                                                .text.isEmpty) {
                                              return "Relation is required";
                                            }
                                          },
                                          icon: const Icon(
                                              Icons.keyboard_arrow_down),
                                          items: items.map((String items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Text(items),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              dropdownvalue = newValue!;
                                              relationController.text =
                                                  dropdownvalue!;
                                            });
                                          },
                                        ),
                                      ),
                                      _status == false
                                          ? Container(
                                              child: _getActionButtons(),
                                            )
                                          : const SizedBox(height: 60),
                                    ],
                                  ),
                                ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Future getImage(bool gallery) async {
    ImagePicker _picker = ImagePicker();
    dynamic pickedFile;

    if (gallery) {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    } else {
      pickedFile = await _picker.pickImage(source: ImageSource.camera);
    }

    setState(() {
      if (pickedFile != null) {
        profilePick = File(pickedFile.path);
        Get.back();
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 40.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SizedBox(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Cancel"),
                ),
                onPressed: () async {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
              )),
            ),
            flex: 2,
          ),
          SizedBox(
            width: 10.w,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Save"),
                ),
                onPressed: () async {
                  final editProfile = await showDialog(
                    context: context,
                    builder: (context) => FutureProgressDialog(
                      updateProfile(context),
                    ),
                  );
                  print(editProfile);
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: CircleAvatar(
        backgroundColor: AppColors.primaryColor,
        radius: 14.0,
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.white,
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.image_outlined,
                  color: AppColors.primaryColor,
                ),
                title: Text(
                  'Gallery',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
                onTap: () async {
                  getImage(true);
                },
              ),
              ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primaryColor,
                  ),
                  title: Text(
                    'Camera',
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                  onTap: () async {
                    getImage(false);
                  }),
            ],
          ),
        );
      },
    );
  }
}
