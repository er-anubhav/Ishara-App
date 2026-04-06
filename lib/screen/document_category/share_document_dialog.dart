import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:docuhealth/components/default_button.dart';
import 'package:docuhealth/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../app_config.dart';
import '../../contstants/app_colors.dart';
import '../../services/base_client.dart';

enum ShareType { family, otherMember }

class ShareDocumentDialog extends StatefulWidget {
  final int itemID;
  final String itemType;
  const ShareDocumentDialog(
      {super.key, required this.itemID, required this.itemType});

  @override
  State<ShareDocumentDialog> createState() => _ShareDocumentDialogState();
}

class _ShareDocumentDialogState extends State<ShareDocumentDialog> {
  BaseClient baseClient = BaseClient();
  List profiles = [];
  bool isLoading = false;
  String fileName = "";
  ShareType? documentShareType;
  String chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random();
  Directory? externalDir;
  int progress = 0;
  TextEditingController searchController = TextEditingController();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

  Future<void> getFamilyMember() async {
    final response = await baseClient.get('profiles', true);
    if (response['success']) {
      profiles = response['data']['profiles'];
      setState(() {});
    }
  }

  ReceivePort receivePort = ReceivePort();

  @pragma('vm:entry-point')
  static void downloadingCallback(String id, int status, int progress) {
    SendPort? sendPort = IsolateNameServer.lookupPortByName("downloading");

    sendPort!.send([id, status, progress]);
  }

  Future<void> downloaproductdpdf() async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      externalDir = await getExternalStorageDirectory();
      fileName = "docuhealth_${getRandomString(10)}";

      await FlutterDownloader.enqueue(
        url: "${baseUrl}file/${widget.itemID}/download",
        savedDir: externalDir!.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
    } else {
      debugPrint("Permission denied");
    }
  }

  Future<bool> shareWithFamilyMember(int profileId, String url) async {
    var data = {
      "profile_id": '$profileId',
      "item_id": "${widget.itemID}",
      "item_type": widget.itemType
    };
    final response = await baseClient.post(url, data, true);
    if (response['success']) {
      Get.snackbar("Success", response['message']);
      return true;
    } else {
      Get.snackbar("Failed", response['message']);
      return false;
    }
  }

  Future<bool> sharwWithPhoneNumber(String phoneNumber) async {
    final response =
        await baseClient.get('members/check-phone/$phoneNumber', true);
    if (response['success']) {
      final resp = await shareWithFamilyMember(response['data']['id'], 'share');
      return resp;
    } else {
      SharePlus.instance.share(ShareParams(
          text: 'check out this amazing app https://play.google.com/store/apps/details?id=com.arun.docuhealth'));
      return true;
    }
  }

  @override
  void initState() {
    getFamilyMember();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, "downloading");

    receivePort.listen((message) {
      setState(() {
        progress = message[2];
      });

      if (progress == 100) {
        setState(() {
          isLoading = false;
          SharePlus.instance.share(ShareParams(files: [XFile('${externalDir!.path}/$fileName')]));
        });
      }

      debugPrint('Download progress: $progress');
    });

    FlutterDownloader.registerCallback(downloadingCallback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Padding(
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
          child: documentShareType == ShareType.family
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Share Document",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: profiles.length,
                          shrinkWrap: true,
                          itemBuilder: (_, i) {
                            return Card(
                              child: ListTile(
                                onTap: () async {
                                  final resp = await showDialog(
                                    context: context,
                                    builder: (context) => FutureProgressDialog(
                                        shareWithFamilyMember(profiles[i]['id'],
                                            'share-to-family'),
                                        message: const Text(
                                            'Sharing please wait...')),
                                  );
                                  debugPrint('Share response: $resp');
                                  if (resp) {
                                    Get.back();
                                    Get.snackbar(
                                      'Success',
                                      'Shared Successfully',
                                    );
                                  }
                                },
                                leading: const Icon(Icons.person),
                                title: Text('${profiles[i]['name']}'),
                                subtitle: Text('${profiles[i]['type']}'),
                                trailing: const Icon(Icons.share),
                              ),
                            );
                          }),
                    ),
                  ],
                )
              : documentShareType == ShareType.otherMember
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Share Document",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        TextFormField(
                          controller: searchController,
                          maxLength: 10,
                          keyboardType: TextInputType.number,
                          decoration: AppTheme.defaultInputFieldDecoration(
                            "Enter phone number",
                            Icons.phone,
                          ),
                          validator: (v) {
                            if (v!.isEmpty) {
                              return "Phone number is required";
                            }
                            return null;
                          },
                        ),
                        DefaultButton(
                          buttonText: "Share",
                          onPress: () async {
                            final resp = await showDialog(
                              context: context,
                              builder: (context) => FutureProgressDialog(
                                  sharwWithPhoneNumber(searchController.text),
                                  message:
                                      const Text('Sharing please wait...')),
                            );
                            debugPrint('Share response: $resp');
                            if (resp) {
                              Get.back();
                              Get.snackbar(
                                'Success',
                                'Shared Successfully',
                              );
                            }
                          },
                        )
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Share Document",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        Card(
                          child: ListTile(
                            onTap: () {
                              documentShareType = ShareType.family;
                              setState(() {});
                            },
                            leading: const Icon(Icons.person),
                            title: Text(
                              'Share with family member',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            trailing: const Icon(Icons.share),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            onTap: () {
                              documentShareType = ShareType.otherMember;
                              setState(() {});
                            },
                            leading: const Icon(Icons.group),
                            title: Text(
                              'Share with other member',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            trailing: const Icon(Icons.share),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            onTap: () async {
                              downloaproductdpdf();
                              // documentShareType = ShareType.otherMember;
                              // setState(() {});
                              // await FlutterShare.shareFile(
                              //     title: 'Compartilhar comprovante',
                              //     filePath: localPath,
                              //     fileType: 'image/png');

                              // Share.shareFiles(['${directory.path}/image.jpg'],
                              //     text: 'Great picture');
                            },
                            leading: const Icon(Icons.ios_share_outlined),
                            title: Text(
                              'Direct share',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            trailing: const Icon(Icons.share),
                          ),
                        )
                      ],
                    ),
        ),
      ),
    );
  }
}
