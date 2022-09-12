import 'package:docuhealth/controllers/daily_measurement_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:provider/provider.dart';

import '../../contstants/app_colors.dart';
import '../../data/dummy_data.dart';

class DailyMeasurements extends StatefulWidget {
  final String title;
  const DailyMeasurements({Key? key, required this.title}) : super(key: key);

  @override
  State<DailyMeasurements> createState() => _DailyMeasurementsState();
}

class _DailyMeasurementsState extends State<DailyMeasurements> {
  String selectedTimeFilter = "Daily";
  String selectedCategoryFilter = "BP";

  @override
  Widget build(BuildContext context) {
    DailyMeasurementController dailyMeasurementController =
        Provider<DailyMeasurementController>.of(context);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text(widget.title),
        bottom: PreferredSize(
            child: Padding(
              padding: EdgeInsets.all(5.r),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.r)),
                      child: DropdownButton(
                        isExpanded: true,
                        value: selectedTimeFilter,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: timeFilter.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? newValue) async {
                          setState(() {
                            selectedTimeFilter = newValue!;
                          });

                          await showDialog(
                            context: context,
                            builder: (context) =>
                                FutureProgressDialog(getAnalytics()),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.r)),
                      child: DropdownButton(
                        value: selectedCategoryFilter,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: categoryFilter.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? newValue) async {
                          setState(() {
                            selectedCategoryFilter = newValue!;
                          });
                          await showDialog(
                            context: context,
                            builder: (context) =>
                                FutureProgressDialog(getAnalytics()),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            preferredSize: Size(double.infinity, 50.h)),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }
}

// import 'package:calender_picker/calender_picker.dart';
// import 'package:docuhealth/contstants/app_colors.dart';
// import 'package:docuhealth/screen/document_category/add_measurement.dart';
// import 'package:docuhealth/services/base_client.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:future_progress_dialog/future_progress_dialog.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// import '../../data/dummy_data.dart';

// class DailyMeasurements extends StatefulWidget {
//   final String title;
//   const DailyMeasurements({Key? key, required this.title}) : super(key: key);

//   @override
//   State<DailyMeasurements> createState() => _DailyMeasurementsState();
// }

// class _DailyMeasurementsState extends State<DailyMeasurements> {
//   BaseClient baseClient = BaseClient();
//   DateTime selectedDate = DateTime.now();
//   DateTime selectedPickerDate = DateTime.now();
//   bool isLoading = true;
//   List measurements = [];
//   List<_SalesData> bgUpperBond = [];
//   List<_SalesData> bgLowerBond = [];
//   List<_SalesData> sugarLavel = [];
//   List<_SalesData> pulse = [];
//   List<_SalesData> weight = [];
//   List<CartesianSeries> cartesianSeries = [];
//   String selectedTimeFilter = "Daily";
//   String selectedCategoryFilter = "BP";

//   getMeasurements() async {
//     final response = await baseClient.get(
//       'measurements?date=${DateFormat('dd-MM-yyyy').format(selectedPickerDate)}',
//       true,
//     );
//     if (response['success']) {
//       measurements = response['data'];
//       isLoading = false;
//       setState(() {});
//     } else {
//       measurements = [];
//     }
//   }

//   getAnalytics() async {
//     final response = await baseClient.get(
//       'measurements/analytics?date=$selectedTimeFilter&category=$selectedCategoryFilter',
//       true,
//     );
//     if (response['success']) {
//       bgUpperBond = [];
//       bgLowerBond = [];
//       sugarLavel = [];
//       pulse = [];
//       weight = [];
//       if (selectedCategoryFilter == "BP") {
//         for (var i = 0; i < response['data'].length; i++) {
//           for (var j = 0; j < response['data'][i]['values'].length; j++) {
//             bgUpperBond.add(
//               _SalesData(
//                 '${response['data'][i]['label']} ${response['data'][i]['values'][j]['time']}',
//                 double.parse(
//                     response['data'][i]['values'][j]['datas']['upper_bound']),
//               ),
//             );
//             bgLowerBond.add(
//               _SalesData(
//                 '${response['data'][i]['label']} ${response['data'][i]['values'][j]['time']}',
//                 double.parse(
//                     response['data'][i]['values'][j]['datas']['lower_bound']),
//               ),
//             );
//           }
//         }
//       } else if (selectedCategoryFilter == "Pulse") {
//         for (var i = 0; i < response['data'].length; i++) {
//           for (var j = 0; j < response['data'][i]['values'].length; j++) {
//             pulse.add(
//               _SalesData(
//                 '${response['data'][i]['label']} ${response['data'][i]['values'][j]['time']}',
//                 double.parse(
//                     response['data'][i]['values'][j]['datas']['pulse_rate']),
//               ),
//             );
//             print(response['data'][i]['values'][j]['datas']['pulse_rate']);
//           }
//         }
//       } else if (selectedCategoryFilter == "Weight") {
//         for (var i = 0; i < response['data'].length; i++) {
//           for (var j = 0; j < response['data'][i]['values'].length; j++) {
//             pulse.add(
//               _SalesData(
//                 '${response['data'][i]['label']} ${response['data'][i]['values'][j]['time']}',
//                 double.parse(
//                     response['data'][i]['values'][j]['datas']['weight']),
//               ),
//             );
//           }
//         }
//       } else if (selectedCategoryFilter == "Sugar") {
//         for (var i = 0; i < response['data'].length; i++) {
//           for (var j = 0; j < response['data'][i]['values'].length; j++) {
//             pulse.add(
//               _SalesData(
//                 '${response['data'][i]['label']} ${response['data'][i]['values'][j]['time']}',
//                 double.parse(
//                     response['data'][i]['values'][j]['datas']['sugar_lavel']),
//               ),
//             );
//           }
//         }
//       }
//     }

//     setState(() {});
//   }

//   onDeleteButtonPress(int recordId) async {
//     final response =
//         await baseClient.get('measurements/delete/$recordId', true);
//     return response['success'];
//   }

//   _selectDate(BuildContext context) async {
//     final DateTime? selected = await showDatePicker(
//       context: context,
//       initialDate: selectedPickerDate,
//       firstDate: DateTime(2010),
//       lastDate: DateTime(2025),
//     );
//     if (selected != null && selected != selectedPickerDate) {
//       setState(() {
//         selectedPickerDate = selected;
//       });
//     }
//   }

//   @override
//   void initState() {
//     getMeasurements();
//     getAnalytics();
//     super.initState();
//   }

//   Widget bottomSheet() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(15.r), topRight: Radius.circular(15.r)),
//         color: AppColors.whitebgColor,
//       ),
//       child: Wrap(
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(vertical: 10.h),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Choose the category',
//                   style: TextStyle(
//                     fontSize: 20.sp,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.selectedIconColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ListTile(
//             onTap: (() {
//               Get.back();
//               Get.to(const AddMeasurement(
//                 category: "BP",
//               ));
//             }),
//             leading: Image.asset(
//               'assets/icons/blood-pressure.png',
//               height: 30.h,
//               width: 30.w,
//             ),
//             title: Text(
//               'Blood pressure',
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.darkGreyTextColor,
//               ),
//             ),
//           ),
//           ListTile(
//             onTap: (() {
//               Get.back();
//               Get.to(const AddMeasurement(
//                 category: "Pulse",
//               ));
//             }),
//             leading: Image.asset(
//               'assets/icons/pulse-oximeter.png',
//               height: 30.h,
//               width: 30.w,
//             ),
//             title: Text(
//               'Pulse',
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.darkGreyTextColor,
//               ),
//             ),
//           ),
//           ListTile(
//             onTap: (() {
//               Get.back();
//               Get.to(const AddMeasurement(
//                 category: "Sugar",
//               ));
//             }),
//             leading: Image.asset(
//               'assets/icons/sugar-blood-level.png',
//               height: 30.h,
//               width: 30.w,
//             ),
//             title: Text(
//               'Sugar',
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.darkGreyTextColor,
//               ),
//             ),
//           ),
//           ListTile(
//             onTap: (() {
//               Get.back();
//               Get.to(const AddMeasurement(
//                 category: "Weight",
//               ));
//             }),
//             leading: Image.asset(
//               'assets/icons/weight.png',
//               height: 30.h,
//               width: 30.w,
//             ),
//             title: Text(
//               'Weight',
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.darkGreyTextColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   showDataByCategory(i) {
//     switch (measurements[i]['category']) {
//       case "BP":
//         return "${measurements[i]['category']} (UB:- ${measurements[i]['datas']['upper_bound']} LB:-${measurements[i]['datas']['lower_bound']})";
//       case "Pulse":
//         return "${measurements[i]['category']} (Pulse rate:- ${measurements[i]['datas']['pulse_rate']})";
//       case "Sugar":
//         return "${measurements[i]['category']} (Sugar lavel:- ${measurements[i]['datas']['sugar_lavel']})";
//       case "Weight":
//         return "${measurements[i]['category']} (Weight:- ${measurements[i]['datas']['weight']})";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarColor: AppColors.primaryColor,
//           statusBarBrightness: Brightness.light,
//           statusBarIconBrightness: Brightness.light,
//         ),
//         title: Text(widget.title),
//         bottom: PreferredSize(
//             child: Padding(
//               padding: EdgeInsets.all(5.r),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 10.w),
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(5.r)),
//                       child: DropdownButton(
//                         isExpanded: true,
//                         value: selectedTimeFilter,
//                         icon: const Icon(Icons.keyboard_arrow_down),
//                         items: timeFilter.map((String items) {
//                           return DropdownMenuItem(
//                             value: items,
//                             child: Text(items),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) async {
//                           setState(() {
//                             selectedTimeFilter = newValue!;
//                           });

//                           await showDialog(
//                             context: context,
//                             builder: (context) =>
//                                 FutureProgressDialog(getAnalytics()),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 5.w,
//                   ),
//                   Expanded(
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 10.w),
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(5.r)),
//                       child: DropdownButton(
//                         value: selectedCategoryFilter,
//                         isExpanded: true,
//                         icon: const Icon(Icons.keyboard_arrow_down),
//                         items: categoryFilter.map((String items) {
//                           return DropdownMenuItem(
//                             value: items,
//                             child: Text(items),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) async {
//                           setState(() {
//                             selectedCategoryFilter = newValue!;
//                           });
//                           await showDialog(
//                             context: context,
//                             builder: (context) =>
//                                 FutureProgressDialog(getAnalytics()),
//                           );
//                         },
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             preferredSize: Size(double.infinity, 50.h)),
//         backgroundColor: AppColors.primaryColor,
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: (() {
//           showModalBottomSheet<void>(
//             context: context,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(15.r),
//                   topRight: Radius.circular(15.r)),
//             ),
//             builder: (BuildContext context) {
//               return bottomSheet();
//             },
//           ).whenComplete(() {
//             getMeasurements();
//             getAnalytics();
//           });
//         }),
//         backgroundColor: AppColors.primaryColor,
//         child: const Icon(Icons.add),
//       ),
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : SingleChildScrollView(
//               child: Column(
//                 children: [
//                   bgUpperBond.isEmpty &&
//                           bgLowerBond.isEmpty &&
//                           weight.isEmpty &&
//                           pulse.isEmpty &&
//                           sugarLavel.isEmpty
//                       ? const SizedBox()
//                       : Padding(
//                           padding: EdgeInsets.all(10.r),
//                           child: SfCartesianChart(
//                             primaryXAxis: CategoryAxis(),
//                             primaryYAxis: NumericAxis(
//                                 autoScrollingMode: AutoScrollingMode.start),
//                             zoomPanBehavior: ZoomPanBehavior(
//                               enablePinching: true,
//                             ),
//                             series: <CartesianSeries>[
//                               ColumnSeries<_SalesData, String>(
//                                   dataSource: bgUpperBond,
//                                   xValueMapper: (_SalesData sales, _) =>
//                                       sales.year,
//                                   yValueMapper: (_SalesData sales, _) =>
//                                       sales.sales),
//                               ColumnSeries<_SalesData, String>(
//                                   dataSource: bgLowerBond,
//                                   xValueMapper: (_SalesData sales, _) =>
//                                       sales.year,
//                                   yValueMapper: (_SalesData sales, _) =>
//                                       sales.sales),
//                               ColumnSeries<_SalesData, String>(
//                                   dataSource: pulse,
//                                   xValueMapper: (_SalesData sales, _) =>
//                                       sales.year,
//                                   yValueMapper: (_SalesData sales, _) =>
//                                       sales.sales),
//                               ColumnSeries<_SalesData, String>(
//                                   dataSource: weight,
//                                   xValueMapper: (_SalesData sales, _) =>
//                                       sales.year,
//                                   yValueMapper: (_SalesData sales, _) =>
//                                       sales.sales),
//                               ColumnSeries<_SalesData, String>(
//                                   dataSource: sugarLavel,
//                                   xValueMapper: (_SalesData sales, _) =>
//                                       sales.year,
//                                   yValueMapper: (_SalesData sales, _) =>
//                                       sales.sales),
//                             ],
//                           ),
//                         ),
//                   Row(
//                     children: [
//                       Container(
//                         width: 55.w,
//                         height: 65.h,
//                         margin: EdgeInsets.only(left: 5.w),
//                         decoration: BoxDecoration(
//                           color: AppColors.primaryColor,
//                           borderRadius: BorderRadius.circular(22.r),
//                         ),
//                         child: IconButton(
//                           onPressed: () async {
//                             await _selectDate(context);
//                             getAnalytics();
//                             getMeasurements();
//                           },
//                           icon: const Icon(
//                             Icons.calendar_month,
//                             color: Colors.white,
//                             size: 30,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: CalenderPicker(
//                           selectedPickerDate,
//                           daysCount: 7,
//                           initialSelectedDate: selectedPickerDate,
//                           selectionColor: AppColors.primaryColor,
//                           selectedTextColor: AppColors.whiteTextColor,
//                           onDateChange: (date) async {
//                             selectedDate = date;

//                             await showDialog(
//                               context: context,
//                               builder: (context) =>
//                                   FutureProgressDialog(getMeasurements()),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10.h,
//                   ),
//                   measurements.isEmpty
//                       ? SizedBox(
//                           child: Center(
//                             child: Text(
//                               'Nothing to show',
//                               style: TextStyle(
//                                 fontSize: 18.sp,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         )
//                       : ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: measurements.length,
//                           itemBuilder: (_, i) {
//                             return Card(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.r),
//                                 side: BorderSide(
//                                     color: AppColors.primaryColor, width: 1),
//                               ),
//                               margin: EdgeInsets.only(
//                                   left: 10.w, right: 10.w, bottom: 12.h),
//                               child: Padding(
//                                 padding: EdgeInsets.all(15.r),
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       height: 50.h,
//                                       width: 50.w,
//                                       decoration: BoxDecoration(
//                                         borderRadius:
//                                             BorderRadius.circular(15.r),
//                                         image: const DecorationImage(
//                                           image: AssetImage(
//                                               'assets/icons/blood.png'),
//                                         ),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Padding(
//                                         padding: EdgeInsets.only(left: 10.w),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               showDataByCategory(i),
//                                               style: TextStyle(
//                                                 fontSize: 16.sp,
//                                                 fontWeight: FontWeight.w400,
//                                                 color:
//                                                     AppColors.darkGreyTextColor,
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               height: 2.h,
//                                             ),
//                                             Text(
//                                               '${measurements[i]["date"]} (${measurements[i]['time']})',
//                                               style: TextStyle(
//                                                 fontSize: 13.sp,
//                                                 fontWeight: FontWeight.w400,
//                                                 color: AppColors.primaryColor,
//                                               ),
//                                             ),
//                                             SizedBox(
//                                               height: 2.h,
//                                             ),
//                                             Text(
//                                               measurements[i]["comment"] ?? '',
//                                               style: TextStyle(
//                                                 fontSize: 11.sp,
//                                                 color: Colors.blue,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     IconButton(
//                                       onPressed: () {
//                                         Get.defaultDialog(
//                                           title: "Warning !",
//                                           middleText:
//                                               "Are you sure you want to delete this record ?",
//                                           confirm: SizedBox(
//                                             height: 35.h,
//                                             width: Get.width / 3,
//                                             child: ElevatedButton(
//                                               onPressed: () async {
//                                                 Get.back();
//                                                 showDialog(
//                                                   context: context,
//                                                   builder: (context) =>
//                                                       FutureProgressDialog(
//                                                     onDeleteButtonPress(
//                                                         measurements[i]['id']),
//                                                     message: const Text(
//                                                         'Please wait deleting record...'),
//                                                   ),
//                                                 ).whenComplete(() => showDialog(
//                                                       context: context,
//                                                       builder: (context) =>
//                                                           FutureProgressDialog(
//                                                         getMeasurements(),
//                                                         message: const Text(
//                                                             'Please wait...'),
//                                                       ),
//                                                     ));
//                                               },
//                                               style: ElevatedButton.styleFrom(
//                                                 primary: AppColors.primaryColor,
//                                               ),
//                                               child: const Text('Continue'),
//                                             ),
//                                           ),
//                                           cancel: SizedBox(
//                                             height: 35.h,
//                                             width: Get.width / 3,
//                                             child: ElevatedButton(
//                                               onPressed: () {
//                                                 Get.back();
//                                               },
//                                               style: ElevatedButton.styleFrom(
//                                                 primary: Colors.grey.shade400,
//                                               ),
//                                               child: const Text('Cancel'),
//                                             ),
//                                           ),
//                                           radius: 10,
//                                         );
//                                       },
//                                       icon: const Icon(
//                                         Icons.delete,
//                                         color: Colors.red,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// class _SalesData {
//   _SalesData(this.year, this.sales);

//   final String year;
//   final double sales;
// }
