import 'package:flutter/cupertino.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:intl/intl.dart';
import 'package:docuhealth/contstants/app_colors.dart';
import 'package:docuhealth/screen/reminder/add_reminder_scrren.dart';
import 'package:docuhealth/services/base_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class DailyReminder extends StatefulWidget {
  final String title;
  const DailyReminder({Key? key, required this.title}) : super(key: key);

  @override
  State<DailyReminder> createState() => _DailyReminderState();
}

class _DailyReminderState extends State<DailyReminder> {
  List allReminders = [];
  List datewiseReminders = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  bool snooz = false;

  getDailyReminder() async {
    final response = await BaseClient().get('reminders', true);
    if (response['success']) {
      allReminders = response['data'];
    } else {
      allReminders = [];
    }
    isLoading = false;
    setState(() {});
  }

  getDateWiseReminder() async {
    isLoading = true;
    setState(() {});
    final response = await BaseClient().get(
        'reminders?date=${DateFormat('dd-MM-yyyy').format(selectedDate)}',
        true);
    if (response['success']) {
      datewiseReminders = response['data'];
    } else {
      datewiseReminders = [];
    }
    isLoading = false;
    setState(() {});
  }

  onSwitchPress(int id, bool status) async {
    final response = await BaseClient()
        .post('reminders/status', {"id": "$id", "status": status}, true);
    print(response);
    if (response['success']) {
      getDailyReminder();
    }
  }

  onDeleteButtonPress(int id) async {
    final response = await BaseClient().get('reminders/delete/$id', true);
    print(response);
    if (response['success']) {
      getDailyReminder();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getDailyReminder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColors.primaryColor,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
          ),
          title: const Text(
            'Daily Reminder',
          ),
          backgroundColor: AppColors.primaryColor,
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  children: [
                    const Icon(
                      Icons.alarm_on,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      "Filter reminders",
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    )
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    const Icon(
                      Icons.alarm_rounded,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      "All reminders",
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          onPressed: () {
            Get.to(const NewAddedReminderScreen());
          },
          child: const Icon(Icons.add),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                children: [
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          width: Get.width,
                          child: TableCalendar(
                            firstDay: DateTime.utc(2010, 10, 16),
                            lastDay: DateTime.utc(2030, 3, 14),
                            focusedDay: selectedDate,
                            onDaySelected: (fromDate, toDate) {
                              selectedDate = fromDate;
                              getDateWiseReminder();
                              setState(() {});
                            },
                            calendarStyle: CalendarStyle(
                                rangeHighlightColor: AppColors.primaryColor),
                            selectedDayPredicate: (day) {
                              return isSameDay(selectedDate, day);
                            },
                            headerStyle: const HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: datewiseReminders.length,
                          itemBuilder: (_, i) {
                            return InkWell(
                              onTap: () {},
                              child: Card(
                                color: Colors.grey.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                margin: EdgeInsets.only(
                                    left: 10.w, right: 10.w, top: 10.h),
                                child: Padding(
                                  padding: EdgeInsets.all(15.r),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 50.h,
                                        width: 50.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.r),
                                          image: const DecorationImage(
                                            image: AssetImage(
                                              'assets/icons/remainder-icon.png',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.w),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${datewiseReminders[i]['time']}",
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              Text(
                                                "${datewiseReminders[i]['name']} (${datewiseReminders[i]['event_type']})",
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: !allReminders[i]['status']
                                              ? Colors.red
                                              : AppColors.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                        ),
                                        child: allReminders[i]['status']
                                            ? Text(
                                                "Running",
                                                style: TextStyle(
                                                  color:
                                                      AppColors.whiteTextColor,
                                                ),
                                              )
                                            : Text(
                                                "Closed",
                                                style: TextStyle(
                                                  color:
                                                      AppColors.whiteTextColor,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: allReminders.length,
                          itemBuilder: (_, i) {
                            return InkWell(
                              onTap: () {},
                              child: Card(
                                color: Colors.grey.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                margin: EdgeInsets.only(
                                    left: 10.w, right: 10.w, top: 10.h),
                                child: Padding(
                                  padding: EdgeInsets.all(15.r),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 50.h,
                                        width: 50.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.r),
                                          image: const DecorationImage(
                                            image: AssetImage(
                                              'assets/icons/remainder-icon.png',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 10.w),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${allReminders[i]['time']}",
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              Text(
                                                "${allReminders[i]['name']} (${allReminders[i]['event_type']})",
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          CupertinoSwitch(
                                            activeColor: AppColors.primaryColor,
                                            value: allReminders[i]['status'],
                                            onChanged: (bool value) {
                                              snooz = value;
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    FutureProgressDialog(
                                                  onSwitchPress(
                                                      allReminders[i]['id'],
                                                      !allReminders[i]
                                                          ['status']),
                                                  message: const Text(
                                                      'Deleting please wait ...'),
                                                ),
                                              );
                                              setState(() {});
                                            },
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    FutureProgressDialog(
                                                  onDeleteButtonPress(
                                                      allReminders[i]['id']),
                                                  message: const Text(
                                                      'Deleting please wait ...'),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
