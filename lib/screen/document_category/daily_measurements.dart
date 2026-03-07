import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:table_calendar/table_calendar.dart';
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
import '../../services/ble_service.dart';
import '../device_connection_screen.dart'; // Added for BLE status icon navigation
import 'add_measurement.dart';

class DailyMeasurements extends StatefulWidget {
  final String title;
  const DailyMeasurements({super.key, required this.title});

  @override
  State<DailyMeasurements> createState() => _DailyMeasurementsState();
}

class _DailyMeasurementsState extends State<DailyMeasurements> {
  String selectedTimeFilter = "Daily";
  String selectedCategoryFilter = "BP";
  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();
  
  // BLE auto-refresh
  final BleService _bleService = BleService();
  StreamSubscription<String>? _measurementSavedSubscription;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      Provider.of<DailyMeasurementController>(context, listen: false)
          .getMeasurementsData(selectedDate, selectedCategoryFilter);
      Provider.of<DailyMeasurementController>(context, listen: false)
          .getAnalyticsData(selectedTimeFilter, selectedCategoryFilter);
    });
    
    // Listen for BLE auto-saved measurements
    _measurementSavedSubscription = _bleService.measurementSavedStream.listen((category) {
      debugPrint('Measurement saved notification: $category, current filter: $selectedCategoryFilter');
      // Refresh if saved category matches current filter
      if (category == selectedCategoryFilter) {
        _refreshData();
      }
    });
  }
  
  @override
  void dispose() {
    _measurementSavedSubscription?.cancel();
    super.dispose();
  }
  
  // Refresh data from backend
  Future<void> _refreshData() async {
    if (_isRefreshing || !mounted) return;
    
    setState(() => _isRefreshing = true);
    
    try {
      await Provider.of<DailyMeasurementController>(context, listen: false)
          .getMeasurementsData(selectedDate, selectedCategoryFilter);
      await Provider.of<DailyMeasurementController>(context, listen: false)
          .getAnalyticsData(selectedTimeFilter, selectedCategoryFilter);
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
        focusedDay = selected;
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
    
    debugPrint('BUILD: graphValue.length=${graphValue.length}, upperBond=${upperBond.length}, lowerBond=${lowerBond.length}');
    debugPrint('BUILD: category=$selectedCategoryFilter, showing chart: ${!(graphValue.isEmpty && upperBond.isEmpty && lowerBond.isEmpty)}');

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text(widget.title),
        actions: [
          // Refresh button
          IconButton(
            onPressed: _isRefreshing ? null : _refreshData,
            icon: _isRefreshing
                ? SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Icon(Icons.refresh),
            tooltip: 'Refresh data',
          ),
          // Live BLE Status Indicator
          StreamBuilder<BleDeviceStatus>(
            stream: _bleService.statusStream,
            initialData: _bleService.deviceStatus,
            builder: (context, snapshot) {
              final status = snapshot.data ?? BleDeviceStatus.disconnected;
              final isConnected = status != BleDeviceStatus.disconnected;
              
              return IconButton(
                icon: Icon(
                  isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: isConnected ? Colors.white : Colors.redAccent.shade100,
                  size: 24.r,
                ),
                tooltip: isConnected ? 'Device Connected' : 'Device Disconnected',
                onPressed: () {
                  Get.to(() => DeviceConnectionScreen());
                },
              );
            },
          ),
        ],
        bottom: PreferredSize(
            preferredSize: Size(double.infinity, 50.h),
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
                          if (!mounted) return;
                          // ignore: use_build_context_synchronously
                          Provider.of<DailyMeasurementController>(context,
                                  listen: false)
                              .getMeasurementsData(
                                  selectedDate, selectedCategoryFilter);
                          // ignore: use_build_context_synchronously
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
            )),
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Live Status Banner for BLE "No Finger" state
              StreamBuilder<BleDeviceStatus>(
                stream: _bleService.statusStream,
                initialData: _bleService.deviceStatus,
                builder: (context, snapshot) {
                  final status = snapshot.data;
                  if (status == BleDeviceStatus.noFinger && selectedCategoryFilter == "SpO2") {
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(10.r),
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'No finger detected',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (status != BleDeviceStatus.disconnected && status != BleDeviceStatus.measuring && selectedCategoryFilter == "BP") {
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(10.r),
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Please wear the cuff properly to record BP',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (status != BleDeviceStatus.disconnected && status != BleDeviceStatus.measuring && selectedCategoryFilter == "Temperature") {
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(10.r),
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.thermostat_outlined, color: Colors.red.shade700),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Please handle the probe properly to record Temperature',
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              graphValue.isEmpty && upperBond.isEmpty && lowerBond.isEmpty
                  ? Container(
                      padding: EdgeInsets.all(16.r),
                      child: Text(
                        'No graph data available for $selectedCategoryFilter',
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.all(10.r),
                      child: Column(
                        children: [
                          Text('Graph data: ${graphValue.length} points', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                          SizedBox(height: 5.h),
                        _buildChart(
                          selectedCategoryFilter,
                          graphValue,
                          upperBond,
                          lowerBond,
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
                  child: TableCalendar(
                    firstDay: DateTime.utc(2010, 1, 1),
                    lastDay: DateTime.now(),
                    focusedDay: focusedDay,
                    calendarFormat: CalendarFormat.week,
                    availableCalendarFormats: const {
                      CalendarFormat.week: 'Week',
                    },
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      leftChevronVisible: false,
                      rightChevronVisible: false,
                    ),
                    selectedDayPredicate: (day) {
                      return isSameDay(selectedDate, day);
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        color: AppColors.whiteTextColor,
                      ),
                    ),
                    onDaySelected: (selected, focused) async {
                      setState(() {
                        selectedDate = selected;
                        focusedDay = focused;
                      });
                      showDialog(
                        context: context,
                        builder: (context) => FutureProgressDialog(
                          dailyMeasurementController.getMeasurementsData(
                            selected,
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
            // Separate auto-fetched and manual entries
            Builder(
              builder: (context) {
                // Get auto-fetched entries
                final autoFetchedEntries = measurementData
                    .where((m) => m.isAutoFetched == true)
                    .toList();
                // Sort by date and time descending to get latest first
                autoFetchedEntries.sort((a, b) {
                  final dateTimeA = DateTime.tryParse('${a.date ?? ''} ${a.time ?? ''}') ?? DateTime(1970);
                  final dateTimeB = DateTime.tryParse('${b.date ?? ''} ${b.time ?? ''}') ?? DateTime(1970);
                  return dateTimeB.compareTo(dateTimeA); // Descending order
                });
                
                // Get manual entries only
                final manualEntries = measurementData
                    .where((m) => m.isAutoFetched != true)
                    .toList();
                
                return Column(
                  children: [
                    // Auto-fetched BLE entries section (show only latest)
                    if (autoFetchedEntries.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        child: Row(
                          children: [
                            Icon(Icons.bluetooth, size: 18.sp, color: Colors.teal),
                            SizedBox(width: 6.w),
                            Text(
                              'BLE Auto-Fetched (Latest)',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGreyTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildManualEntryCard(
                        autoFetchedEntries.first,
                        dailyMeasurementController,
                        showDelete: false,
                      ),
                    ],
                    
                    // Manual entries section
                    if (manualEntries.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        child: Row(
                          children: [
                            Icon(Icons.edit_note, size: 18.sp, color: AppColors.primaryColor),
                            SizedBox(width: 6.w),
                            Text(
                              'Manual Entries',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGreyTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 60.0),
                        itemCount: manualEntries.length,
                        itemBuilder: (_, i) {
                          return _buildManualEntryCard(
                            manualEntries[i],
                            dailyMeasurementController,
                          );
                        },
                      ),
                    ] else if (autoFetchedEntries.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(20.r),
                        child: Text(
                          'No measurements recorded yet',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  // Build manual entry card
  Widget _buildManualEntryCard(
    MeasurementData data,
    DailyMeasurementController controller, {
    bool showDelete = true,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(color: AppColors.primaryColor, width: 1),
      ),
      margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(15.r),
        child: Row(
          children: [
            InkWell(
              onTap: data.attachment != null
                  ? () => Get.to(ImagePreviewScreen(
                        imageUrl: data.attachment!,
                        fileId: 0,
                        fileName: "",
                        remarks: "",
                      ))
                  : null,
              child: Container(
                height: 50.h,
                width: 50.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  image: data.attachment == null
                      ? const DecorationImage(
                          image: AssetImage('assets/icons/blood.png'),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: CachedNetworkImageProvider(data.attachment!),
                          fit: BoxFit.cover,
                        ),
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
                      showDataByCategory(data),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkGreyTextColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${_formatDate(data.date)} (${data.time ?? ''})',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      data.comment ?? '',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showDelete)
              IconButton(
                onPressed: () => _showDeleteConfirmation(data.id!, controller),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(int recordId, DailyMeasurementController controller) {
    Get.defaultDialog(
      title: "Warning !",
      middleText: "Are you sure you want to delete this record ?",
      confirm: SizedBox(
        height: 35.h,
        width: Get.width / 3,
        child: ElevatedButton(
          onPressed: () async {
            Get.back();
            showDialog(
              context: context,
              builder: (context) => FutureProgressDialog(
                controller.onDeleteButtonPress(recordId),
                message: const Text('Please wait deleting record...'),
              ),
            ).whenComplete(() {
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (context) => FutureProgressDialog(
                  controller.getMeasurementsData(selectedDate, selectedCategoryFilter),
                  message: const Text('Please wait...'),
                ),
              );
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
          child: const Text('Continue'),
        ),
      ),
      cancel: SizedBox(
        height: 35.h,
        width: Get.width / 3,
        child: ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade400),
          child: const Text('Cancel'),
        ),
      ),
      radius: 10,
    );
  }

  // Build appropriate chart based on category
  Widget _buildChart(
    String category,
    List<GraphData> graphValue,
    List<GraphData> upperBond,
    List<GraphData> lowerBond,
  ) {
    if (category == "BP") {
      // Column/Bar chart for Blood Pressure (upper and lower bounds)
      return SfCartesianChart(
        title: ChartTitle(
          text: 'Blood Pressure',
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          alignment: ChartAlignment.near, // Left align title
        ),
        legend: const Legend(isVisible: true, position: LegendPosition.bottom),
        primaryXAxis: CategoryAxis(
          labelRotation: 90, // Vertical labels
          labelStyle: TextStyle(fontSize: 9.sp),
          labelAlignment: LabelAlignment.center,
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'mmHg'),
          axisLine: const AxisLine(width: 1),
          labelStyle: TextStyle(fontSize: 10.sp),
        ),
        plotAreaBorderWidth: 0,
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enablePanning: true,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          LineSeries<GraphData, String>(
            name: 'Systolic',
            dataSource: upperBond,
            xValueMapper: (GraphData data, _) => data.year,
            yValueMapper: (GraphData data, _) => data.sales,
            color: Colors.red.shade400,
            width: 3,
            markerSettings: MarkerSettings(
              isVisible: true,
              shape: DataMarkerType.circle,
              borderWidth: 2,
              borderColor: Colors.red.shade400,
              color: Colors.white,
            ),
            dataLabelSettings: DataLabelSettings(
              isVisible: upperBond.length <= 10,
              textStyle: TextStyle(fontSize: 10.sp),
            ),
          ),
          LineSeries<GraphData, String>(
            name: 'Diastolic',
            dataSource: lowerBond,
            xValueMapper: (GraphData data, _) => data.year,
            yValueMapper: (GraphData data, _) => data.sales,
            color: Colors.blue.shade400,
            width: 3,
            markerSettings: MarkerSettings(
              isVisible: true,
              shape: DataMarkerType.circle,
              borderWidth: 2,
              borderColor: Colors.blue.shade400,
              color: Colors.white,
            ),
            dataLabelSettings: DataLabelSettings(
              isVisible: lowerBond.length <= 10,
              textStyle: TextStyle(fontSize: 10.sp),
            ),
          ),
        ],
      );
    } else {
      // Line chart for all other categories
      String yAxisTitle = _getYAxisTitle(category);
      Color lineColor = _getCategoryColor(category);
      
      return SfCartesianChart(
        title: ChartTitle(
          text: category,
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          alignment: ChartAlignment.near, // Left align title
        ),
        primaryXAxis: CategoryAxis(
          labelRotation: 90, // Vertical labels
          labelStyle: TextStyle(fontSize: 9.sp),
          labelAlignment: LabelAlignment.center,
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: yAxisTitle),
          axisLine: const AxisLine(width: 1),
          labelStyle: TextStyle(fontSize: 10.sp),
        ),
        plotAreaBorderWidth: 0,
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enablePanning: true,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          LineSeries<GraphData, String>(
            name: category,
            dataSource: graphValue,
            xValueMapper: (GraphData data, _) => data.year,
            yValueMapper: (GraphData data, _) => data.sales,
            color: lineColor,
            width: 3,
            markerSettings: MarkerSettings(
              isVisible: true,
              shape: DataMarkerType.circle,
              borderWidth: 2,
              borderColor: lineColor,
              color: Colors.white,
            ),
            dataLabelSettings: DataLabelSettings(
              isVisible: graphValue.length <= 10,
              textStyle: TextStyle(fontSize: 10.sp),
            ),
          ),
        ],
      );
    }
  }

  String _getYAxisTitle(String category) {
    switch (category) {
      case "Pulse":
        return "BPM";
      case "Sugar":
        return "mg/dL";
      case "Weight":
        return "kg";
      case "Temperature":
        return "°F";
      case "SpO2":
        return "%";
      default:
        return "";
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Pulse":
        return Colors.orange;
      case "Sugar":
        return Colors.purple;
      case "Weight":
        return Colors.green;
      case "Temperature":
        return Colors.red;
      case "SpO2":
        return Colors.teal;
      default:
        return AppColors.primaryColor;
    }
  }

  // Format date from yyyy-mm-dd to dd/mm/yyyy
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      // Handle yyyy-mm-dd format
      if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          return '${parts[2]}/${parts[1]}/${parts[0]}';
        }
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
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
      case "Temperature":
        final tempRaw = measurementData.datas?.temperature ?? '';
        // If it lacks C or F, assume it's BLE auto-fetched (which is in °F)
        if (tempRaw.isNotEmpty && !tempRaw.toLowerCase().contains('c') && !tempRaw.toLowerCase().contains('f')) {
          return "Temperature: $tempRaw °F";
        }
        return "Temperature: $tempRaw";
      case "SpO2":
        return "SpO2: ${measurementData.datas?.spo2 ?? ''}";
      default:
        return "${measurementData.category}(Upper Bound: ${measurementData.datas?.upperBound} Lower Bound: ${measurementData.datas?.lowerBound})";
    }
  }
}
