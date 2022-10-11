import 'package:cached_network_image/cached_network_image.dart';
import 'package:calender_picker/calender_picker.dart';
import 'package:docuhealth/components/image_preview_screen.dart';
import 'package:docuhealth/controllers/daily_measurement_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../contstants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../../model/daily_measurement/graph_data.dart';
import '../../model/daily_measurement/measurement_data.dart';
import 'add_measurement.dart';

class DailyMeasurements extends StatefulWidget {
  final String title;
  const DailyMeasurements({Key? key, required this.title}) : super(key: key);

  @override
  State<DailyMeasurements> createState() => _DailyMeasurementsState();
}

class _DailyMeasurementsState extends State<DailyMeasurements> {
  String selectedTimeFilter = "Daily";
  String selectedCategoryFilter = "BP";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<DailyMeasurementController>(context, listen: false)
          .getMeasurementsData(selectedDate, selectedCategoryFilter);
      Provider.of<DailyMeasurementController>(context, listen: false)
          .getAnalyticsData(selectedTimeFilter, selectedCategoryFilter);
    });

    super.initState();
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DailyMeasurementController dailyMeasurementController =
        Provider.of<DailyMeasurementController>(context);
    List<MeasurementData>? measurementData =
        dailyMeasurementController.measurementData ?? [];
    List<GraphData> graphValue = dailyMeasurementController.graphValue;
    List<GraphData> upperBond = dailyMeasurementController.upperBond;
    List<GraphData> lowerBond = dailyMeasurementController.lowerBond;

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
                            builder: (context) => FutureProgressDialog(
                                dailyMeasurementController.getAnalyticsData(
                                    selectedTimeFilter,
                                    selectedCategoryFilter)),
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
                            builder: (context) => FutureProgressDialog(
                              dailyMeasurementController.getAnalyticsData(
                                  selectedTimeFilter, selectedCategoryFilter),
                            ),
                          );
                          Provider.of<DailyMeasurementController>(context,
                                  listen: false)
                              .getMeasurementsData(
                                  selectedDate, selectedCategoryFilter);
                          Provider.of<DailyMeasurementController>(context,
                                  listen: false)
                              .getAnalyticsData(
                                  selectedTimeFilter, selectedCategoryFilter);
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
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          Get.to(AddMeasurement(
            category: selectedCategoryFilter,
          ));
        }),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            graphValue.isEmpty && upperBond.isEmpty && lowerBond.isEmpty
                ? const SizedBox()
                : Padding(
                    padding: EdgeInsets.all(10.r),
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(
                          autoScrollingMode: AutoScrollingMode.start),
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePinching: true,
                      ),
                      series: <CartesianSeries>[
                        ColumnSeries<GraphData, String>(
                          dataSource: upperBond,
                          xValueMapper: (GraphData sales, _) => sales.year,
                          yValueMapper: (GraphData sales, _) => sales.sales,
                        ),
                        ColumnSeries<GraphData, String>(
                          dataSource: lowerBond,
                          xValueMapper: (GraphData sales, _) => sales.year,
                          yValueMapper: (GraphData sales, _) => sales.sales,
                        ),
                        ColumnSeries<GraphData, String>(
                          dataSource: graphValue,
                          xValueMapper: (GraphData sales, _) => sales.year,
                          yValueMapper: (GraphData sales, _) => sales.sales,
                        ),
                      ],
                    ),
                  ),
            Row(
              children: [
                Container(
                  width: 55.w,
                  height: 65.h,
                  margin: EdgeInsets.only(left: 5.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      await _selectDate(context);
                    },
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                Expanded(
                  child: CalenderPicker(
                    selectedDate.subtract(const Duration(days: 4)),
                    daysCount: 5,
                    initialSelectedDate: selectedDate,
                    selectionColor: AppColors.primaryColor,
                    selectedTextColor: AppColors.whiteTextColor,
                    onDateChange: (date) async {
                      showDialog(
                        context: context,
                        builder: (context) => FutureProgressDialog(
                          dailyMeasurementController.getMeasurementsData(
                            date,
                            selectedCategoryFilter,
                          ),
                          message: const Text('Please wait...'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 60.0),
              itemCount: measurementData.length,
              itemBuilder: (_, i) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    side: BorderSide(color: AppColors.primaryColor, width: 1),
                  ),
                  margin:
                      EdgeInsets.only(left: 10.w, right: 10.w, bottom: 12.h),
                  child: Padding(
                    padding: EdgeInsets.all(15.r),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: (() {
                            Get.to(
                              ImagePreviewScreen(
                                imageUrl: measurementData[i].attachment!,
                                fileId: 0,
                                fileName: "",
                                remarks: "",
                              ),
                            );
                          }),
                          child: Container(
                            height: 50.h,
                            width: 50.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              image: measurementData[i].attachment == null
                                  ? const DecorationImage(
                                      image:
                                          AssetImage('assets/icons/blood.png'),
                                      fit: BoxFit.cover)
                                  : DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          measurementData[i].attachment!),
                                      fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  showDataByCategory(measurementData[i]),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.darkGreyTextColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Text(
                                  '${measurementData[i].date ?? ''} (${measurementData[i].time ?? ''})',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Text(
                                  measurementData[i].comment ?? '',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Get.defaultDialog(
                              title: "Warning !",
                              middleText:
                                  "Are you sure you want to delete this record ?",
                              confirm: SizedBox(
                                height: 35.h,
                                width: Get.width / 3,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Get.back();
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          FutureProgressDialog(
                                        dailyMeasurementController
                                            .onDeleteButtonPress(
                                                measurementData[i].id!),
                                        message: const Text(
                                            'Please wait deleting record...'),
                                      ),
                                    ).whenComplete(() => showDialog(
                                          context: context,
                                          builder: (context) =>
                                              FutureProgressDialog(
                                            dailyMeasurementController
                                                .getMeasurementsData(
                                              selectedDate,
                                              selectedCategoryFilter,
                                            ),
                                            message:
                                                const Text('Please wait...'),
                                          ),
                                        ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                  ),
                                  child: const Text('Continue'),
                                ),
                              ),
                              cancel: SizedBox(
                                height: 35.h,
                                width: Get.width / 3,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade400,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              radius: 10,
                            );
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String showDataByCategory(MeasurementData measurementData) {
    switch (measurementData.category) {
      case "BP":
        return "${measurementData.category}(Upper Bound: ${measurementData.datas?.upperBound} Lower Bound: ${measurementData.datas?.lowerBound})";
      case "Pulse":
        return "Pulse rate: ${measurementData.datas?.pulseRate}";
      case "Sugar":
        return "Sugar level: ${measurementData.datas?.sugarLavel ?? ''}";
      case "Weight":
        return "Weight: ${measurementData.datas?.weight ?? ''}";
      default:
        return "${measurementData.category}(Upper Bound: ${measurementData.datas?.upperBound} Lower Bound: ${measurementData.datas?.lowerBound})";
    }
  }
}
