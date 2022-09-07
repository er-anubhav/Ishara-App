import 'dart:async';
import 'dart:convert';

import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:weekday_selector/weekday_selector.dart';

import '../../common.dart';

class NewAddedReminderScreen extends StatefulWidget {
  const NewAddedReminderScreen({Key? key}) : super(key: key);

  @override
  _NewAddedReminderScreenState createState() => _NewAddedReminderScreenState();
}

class _NewAddedReminderScreenState extends State<NewAddedReminderScreen> {
  late DateTime _time;
  PersistentBottomSheetController? controller;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedSnoozIndex = 3;
  int selectedrepeatIndex = 2;
  BaseClient baseClient = BaseClient();
  String fromDate = '', toDate = '';
  int durationDays = 0;
  String? selectedDay;
  List<String> nameSuggestions = [];
  List<bool> weekDayList = List.generate(7, (index) => false);
  String selectSnooz = "5";
  String selectedRepeat = "3";
  bool snooz = false;
  bool allDays = false;
  String eventType = "";
  List<String> eventat = [];

  List snoozTime = [
    {'id': '1', 'value': '1 minute'},
    {'id': '2', 'value': '2 minute'},
    {'id': '5', 'value': '5 minute'},
    {'id': '10', 'value': '10 minute'},
    {'id': '15', 'value': '15 minute'},
    {'id': '20', 'value': '20 minute'},
    {'id': '30', 'value': '30 minute'}
  ];

  List<String> weekDaysName = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  List<String> selectedWeekDaysNameList = [];
  TextEditingController alarmController = TextEditingController();
  FocusNode alarmFocusNode = FocusNode();

  getNameSuggestions() async {
    final response = await baseClient.get('reminders/suggetions', true);
    if (response['success']) {
      nameSuggestions = [];
      var data = response['data'];
      for (var i = 0; i < data.length; i++) {
        nameSuggestions.add(data[i]);
      }
    }
    setState(() {});
  }

  Future<bool> setAlarm() async {
    var data = {
      "name": alarmController.text,
      "time": DateFormat.jm().format(_time),
      "event_type": eventType,
      "event_at": jsonEncode(eventat),
      "interval": selectSnooz,
      "snooze": snooz.toString(),
      "repeat": selectedRepeat
    };
    final response = await baseClient.post('reminders', data, true);
    if (response["success"]) {
      Get.snackbar("Success", response['message'],
          duration: const Duration(seconds: 1));
      Timer(const Duration(seconds: 3), () {
        Get.back();
      });
      return true;
    } else {
      Get.snackbar("Failed", response['message']);
      return false;
    }
  }

  formatDescide() {
    if (selectedWeekDaysNameList.isEmpty && fromDate == "") {
      eventType = "Once";
      eventat.add(convertIntoWeekFormat(DateTime.now()));
    } else if ((selectedWeekDaysNameList.length == 7) &&
        (fromDate == '' || toDate == '')) {
      eventType = "Daily";
      eventat = [];
    } else if ((selectedWeekDaysNameList.length != 7 &&
            selectedWeekDaysNameList.isNotEmpty) &&
        (fromDate == '' || toDate == '')) {
      eventType = "Weekly";
      eventat = selectedWeekDaysNameList;
    } else {
      eventType = "Date Range";
      eventat = ["$fromDate", "$toDate"];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text("Add alarm"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey.shade100,
                  padding: EdgeInsets.all(15.r),
                  child: TimePickerSpinner(
                    is24HourMode: false,
                    normalTextStyle:
                        const TextStyle(fontSize: 24, color: Colors.grey),
                    highlightedTextStyle:
                        const TextStyle(fontSize: 24, color: Colors.black),
                    spacing: 50,
                    itemHeight: 80,
                    onTimeChange: (time) {
                      setState(() {
                        _time = time;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 15,
                          ),
                          selectedWeekDaysNameList.isEmpty
                              ? Text(
                                  fromDate == ''
                                      ? convertIntoWeekFormat(DateTime.now())
                                      : fromDate +
                                          (toDate == '' ? '' : ' - ' + toDate),
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14.sp),
                                )
                              : (fromDate == '' || toDate == ''
                                  ? selectedWeekDaysNameList.length == 7
                                      ? Text(
                                          'Every Day',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.sp),
                                        )
                                      : Expanded(
                                          child: Wrap(
                                            children: selectedWeekDaysNameList
                                                .map((e) => Text(
                                                      e + ', ',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14.sp),
                                                    ))
                                                .toList(),
                                          ),
                                        )
                                  : Text(
                                      fromDate == ''
                                          ? convertIntoWeekFormat(
                                              DateTime.now())
                                          : fromDate +
                                              (toDate == ''
                                                  ? ''
                                                  : ' - ' + toDate),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14.sp),
                                    )),
                          const Spacer(),
                          (fromDate != '')
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedDay = null;
                                      fromDate = '';
                                      toDate = '';
                                    });
                                  },
                                  child: const Text('Reset'))
                              : InkWell(
                                  onTap: () async {
                                    var dateRange = await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2050),
                                    );

                                    setState(() {
                                      durationDays =
                                          dateRange?.duration.inDays ?? 0;

                                      fromDate = convertDateToApiFormat(
                                          dateRange?.start ?? DateTime.now());
                                      if (dateRange?.end == null) {
                                        toDate = '';
                                      } else {
                                        toDate = convertDateToApiFormat(
                                            dateRange?.end ?? DateTime.now());
                                      }
                                      if (dateRange?.start == dateRange?.end) {
                                        toDate = '';
                                      }
                                    });
                                  },
                                  child: const Icon(Icons.calendar_today)),
                          const SizedBox(
                            width: 15,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      fromDate != ''
                          ? const Offstage()
                          : Column(
                              children: [
                                WeekdaySelector(
                                  onChanged: (int day) {
                                    final index = day % 7;

                                    setState(() {
                                      selectedDay = weekDaysName[index];

                                      weekDayList[index] = !weekDayList[index];
                                      if (weekDayList[index]) {
                                        selectedWeekDaysNameList
                                            .add(selectedDay!);
                                      } else {
                                        selectedWeekDaysNameList
                                            .remove(selectedDay);
                                      }

                                      if (selectedWeekDaysNameList.length ==
                                          7) {
                                        allDays = true;
                                        setState(() {});
                                      } else {
                                        allDays = false;
                                        setState(() {});
                                      }
                                    });
                                  },
                                  values: weekDayList,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text('All Days'),
                                      CupertinoSwitch(
                                        onChanged: (bool value) {
                                          if (value) {
                                            toggleWeekDays(true);
                                          } else {
                                            toggleWeekDays();
                                          }
                                          allDays = value;
                                          setState(() {});
                                        },
                                        activeColor: AppColors.primaryColor,
                                        value: allDays,
                                        // value: reminderController.allDaysSwitch,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        onTap: () {
                          bottomSheetForAlarmNames(context);
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: IgnorePointer(
                            ignoring: true,
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Alarm Name',
                                label: Text('Alarm Name'),
                              ),
                              controller: alarmController,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Card(
                        elevation: 3,
                        child: ListTile(
                          onTap: () async {
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                builder: (BuildContext context) {
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter _setState) {
                                      return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20.r),
                                              topRight: Radius.circular(20.r),
                                            ),
                                          ),
                                          child: Wrap(
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.w, top: 15.h),
                                                    child: Text(
                                                      "Snooze",
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: snoozTime.length,
                                                itemBuilder: (_, i) {
                                                  return ListTile(
                                                    onTap: (() {
                                                      _setState(() {
                                                        selectedSnoozIndex = i;
                                                        selectSnooz =
                                                            snoozTime[i]['id']
                                                                .toString();
                                                      });
                                                    }),
                                                    selected:
                                                        i == selectedSnoozIndex,
                                                    title: Text(
                                                        snoozTime[i]['value']),
                                                  );
                                                },
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.w, top: 15.h),
                                                    child: Text(
                                                      "Repeat",
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: 5,
                                                itemBuilder: (_, i) {
                                                  return ListTile(
                                                    onTap: (() {
                                                      _setState(() {
                                                        selectedrepeatIndex = i;
                                                        selectedRepeat =
                                                            "${i + 1}";
                                                      });
                                                    }),
                                                    selected: i ==
                                                        selectedrepeatIndex,
                                                    title: Text("${i + 1}"),
                                                  );
                                                },
                                              )
                                            ],
                                          ));
                                    },
                                  );
                                });
                          },
                          leading: const Icon(Icons.snooze_outlined),
                          title: const Text('Snooze'),
                          trailing: CupertinoSwitch(
                            activeColor: AppColors.primaryColor,
                            value: snooz,
                            onChanged: (bool value) {
                              snooz = value;
                              setState(() {});
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Container(
          margin: EdgeInsets.all(15.r),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style:
                      ElevatedButton.styleFrom(primary: Colors.grey.shade600),
                  child: Padding(
                    padding: EdgeInsets.all(5.r),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    formatDescide();
                    final response = await showDialog(
                      context: context,
                      builder: (context) => FutureProgressDialog(
                        setAlarm(),
                        message: const Text('Setting alarm ...'),
                      ),
                    );
                    print(response);
                    // if (response) {

                    // }
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                  child: Padding(
                    padding: EdgeInsets.all(5.r),
                    child: Text(
                      'Save',
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bottomSheetForAlarmNames(BuildContext context) {
    alarmController.clear();
    getNameSuggestions();
    Get.bottomSheet(
      Container(
        height: 350,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: FittedBox(
                    child: Text(
                      'Type Alarm Name',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          height: 2.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff646B71)),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              RawAutocomplete<String>(
                focusNode: alarmFocusNode,
                textEditingController: alarmController,
                onSelected: (String? selectedName) {
                  alarmController.text = selectedName ?? '';
                },
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return nameSuggestions;
                  // return reminderController.alarmListSuggestionsList!.data!
                  //     .where((String? continent) => continent!
                  //         .toLowerCase()
                  //         .startsWith(textEditingValue.text.toLowerCase()))
                  //     .toList();
                },
                displayStringForOption: (String option) => option,
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  return Row(
                    children: [
                      const SizedBox(
                        width: 15,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextField(
                          decoration: const InputDecoration(
                              hintText: 'Alarm Name',
                              hintStyle: TextStyle(color: Colors.grey)),
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('Ok'),
                      ),
                    ],
                  );
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      child: SizedBox(
                        height: 200.h,
                        width: 200.w,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(10.0),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                onSelected(option);
                              },
                              child: ListTile(
                                title: Text(option,
                                    style: const TextStyle(color: Colors.grey)),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100.0),
      ),
    );
  }

  toggleWeekDays([bool select = false]) {
    selectedWeekDaysNameList.clear();
    for (int i = 0; i < 7; i++) {
      setState(() {
        if (select) {
          selectedWeekDaysNameList.add(weekDaysName[i]);
        }
        weekDayList[i] = select;
      });
    }
  }

  computeWeekDaysNames() {
    selectedWeekDaysNameList.clear();
    weekDayList.asMap().forEach((index, value) {
      if (value) {
        selectedWeekDaysNameList.add(weekDaysName[index]);
      }
    });
    print(selectedWeekDaysNameList);
  }
}
