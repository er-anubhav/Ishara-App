// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import '../contstants/app_colors.dart';
// import '../main.dart';
// import '../services/base_client.dart';
// import 'camera_screen.dart';
// import 'files_screen.dart';

// class HospitalManagement extends StatefulWidget {
//   const HospitalManagement({Key? key}) : super(key: key);

//   @override
//   State<HospitalManagement> createState() => _HospitalManagementState();
// }

// class _HospitalManagementState extends State<HospitalManagement> {
//   bool isLoading = true;
//   BaseClient baseClient = BaseClient();
//   List folders = [];
//   List files = [];

//   getData(context) async {
//     final resp =
//         await baseClient.get('folder/get?category=HOSPITAL_BILLS', true);
//     final response =
//         await baseClient.get('file/get?category=HOSPITAL_BILLS', true);
//     if (resp['success']) {
//       folders = resp['data'];
//     } else {
//       folders = [];
//     }
//     if (response['success']) {
//       files = response['data'];
//     } else {
//       files = [];
//     }
//     isLoading = false;
//     setState(() {});
//   }

//   @override
//   void initState() {
//     getData(context);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryColor,
//         title: Text(
//           "Hospital Management",
//           style: TextStyle(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.bold,
//             color: AppColors.whiteTextColor,
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColors.primaryColor,
//         onPressed: () {
//           Get.to(CameraScreen(cameras: cameras));
//         },
//         child: const Icon(
//           Icons.add,
//           size: 40,
//         ),
//       ),
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : (folders.isEmpty && files.isEmpty)
//               ? Center(
//                   child: Text(
//                     'Nothing to show',
//                     style: TextStyle(
//                       fontSize: 20.sp,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.lightGreyTextColor,
//                     ),
//                   ),
//                 )
//               : SafeArea(
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.all(10.r),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 decoration: InputDecoration(
//                                   prefixIcon: Icon(
//                                     Icons.search,
//                                     color: AppColors.selectedIconColor,
//                                   ),
//                                   hintText: "Search",
//                                   hintStyle: TextStyle(
//                                     fontSize: 18.sp,
//                                     color: AppColors.lightGreyTextColor,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                   contentPadding: EdgeInsets.symmetric(
//                                       horizontal: 20.w, vertical: 10.h),
//                                   border: OutlineInputBorder(
//                                     borderSide: BorderSide(
//                                         color: AppColors.selectedIconColor,
//                                         width: 2.w),
//                                     borderRadius: BorderRadius.circular(30.r),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             PopupMenuButton(
//                               icon: const Icon(
//                                 Icons.filter_list,
//                               ),
//                               itemBuilder: (BuildContext context) =>
//                                   <PopupMenuEntry>[
//                                 const PopupMenuItem(
//                                   value: 1,
//                                   child: Text('Working a lot harder'),
//                                 ),
//                                 const PopupMenuItem(
//                                   value: 2,
//                                   child: Text('Being a lot smarter'),
//                                 ),
//                                 const PopupMenuItem(
//                                   value: 3,
//                                   child: Text('Being a self-starter'),
//                                 ),
//                                 const PopupMenuItem(
//                                   value: 4,
//                                   child: Text(
//                                       'Placed in charge of trading charter'),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: folders.length,
//                         itemBuilder: (_, i) {
//                           return Card(
//                             color: AppColors.whitebgColor,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.r),
//                             ),
//                             child: ListTile(
//                               onTap: () => Get.to(FilesScreen(
//                                 title: folders[i]['name'],
//                                 folderId: folders[i]['id'],
//                                 category: folders[i]['belongs_to'],
//                               )),
//                               leading: Container(
//                                 height: 50.h,
//                                 width: 50.w,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(15.r),
//                                   image: const DecorationImage(
//                                     image: AssetImage(
//                                         'assets/icons/blood-pressure-file.png'),
//                                   ),
//                                 ),
//                               ),
//                               title: Text(
//                                 folders[i]['name'],
//                                 style: TextStyle(
//                                   fontSize: 16.sp,
//                                   fontWeight: FontWeight.w400,
//                                   color: AppColors.darkGreyTextColor,
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 folders[i]['created_at'],
//                                 style: TextStyle(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w400,
//                                   color: AppColors.primaryColor,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: files.length,
//                         itemBuilder: (_, i) {
//                           return Card(
//                             color: AppColors.whitebgColor,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.r),
//                             ),
//                             child: ListTile(
//                               leading: Container(
//                                 height: 50.h,
//                                 width: 50.w,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(15.r),
//                                   image: const DecorationImage(
//                                     image: AssetImage(
//                                       'assets/icons/hospital-icon.png',
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               title: Text(
//                                 files[i]['name'],
//                                 style: TextStyle(
//                                   fontSize: 16.sp,
//                                   fontWeight: FontWeight.w400,
//                                   color: AppColors.darkGreyTextColor,
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 files[i]['created_at'],
//                                 style: TextStyle(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w400,
//                                   color: AppColors.primaryColor,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//       // body:
//       // SafeArea(
//       //     child: Column(
//       //   children: [
//       //     Padding(
//       //       padding: EdgeInsets.all(10.r),
//       //       child: Row(
//       //         children: [
//       //           Expanded(
//       //             child: TextFormField(
//       //               decoration: InputDecoration(
//       //                 prefixIcon: Icon(
//       //                   Icons.search,
//       //                   color: AppColors.selectedIconColor,
//       //                 ),
//       //                 hintText: "Search",
//       //                 hintStyle: TextStyle(
//       //                   fontSize: 18.sp,
//       //                   color: AppColors.lightGreyTextColor,
//       //                   fontWeight: FontWeight.w600,
//       //                 ),
//       //                 contentPadding: EdgeInsets.symmetric(
//       //                     horizontal: 20.w, vertical: 10.h),
//       //                 border: OutlineInputBorder(
//       //                   borderSide: BorderSide(
//       //                       color: AppColors.selectedIconColor, width: 2.w),
//       //                   borderRadius: BorderRadius.circular(30.r),
//       //                 ),
//       //               ),
//       //             ),
//       //           ),
//       //           PopupMenuButton(
//       //             icon: const Icon(
//       //               Icons.filter_list,
//       //             ),
//       //             itemBuilder: (BuildContext context) => <PopupMenuEntry>[
//       //               const PopupMenuItem(
//       //                 value: 1,
//       //                 child: Text('Working a lot harder'),
//       //               ),
//       //               const PopupMenuItem(
//       //                 value: 2,
//       //                 child: Text('Being a lot smarter'),
//       //               ),
//       //               const PopupMenuItem(
//       //                 value: 3,
//       //                 child: Text('Being a self-starter'),
//       //               ),
//       //               const PopupMenuItem(
//       //                 value: 4,
//       //                 child: Text('Placed in charge of trading charter'),
//       //               ),
//       //             ],
//       //           ),
//       //         ],
//       //       ),
//       //     ),
//       //     ListView.builder(
//       //       shrinkWrap: true,
//       //       physics: const NeverScrollableScrollPhysics(),
//       //       itemCount: 3,
//       //       itemBuilder: (_, i) {
//       //         return InkWell(
//       //           onTap: () {
//       //             Get.to(const DoctorWiseDocuments(title: "Richard Son"));
//       //           },
//       //           child: Card(
//       //             shape: RoundedRectangleBorder(
//       //               borderRadius: BorderRadius.circular(20.r),
//       //               side: BorderSide(color: AppColors.primaryColor, width: 1),
//       //             ),
//       //             margin:
//       //                 EdgeInsets.only(left: 15.w, right: 15.w, bottom: 12.h),
//       //             child: Padding(
//       //               padding: EdgeInsets.all(15.r),
//       //               child: Row(
//       //                 children: [
//       //                   Container(
//       //                     height: 70.h,
//       //                     width: 70.w,
//       //                     decoration: BoxDecoration(
//       //                       borderRadius: BorderRadius.circular(15.r),
//       //                       image: const DecorationImage(
//       //                         image:
//       //                             AssetImage('assets/icons/hospital-icon.png'),
//       //                       ),
//       //                     ),
//       //                   ),
//       //                   Expanded(
//       //                     child: Padding(
//       //                       padding: EdgeInsets.only(left: 10.w),
//       //                       child: Column(
//       //                         crossAxisAlignment: CrossAxisAlignment.start,
//       //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       //                         children: [
//       //                           Text(
//       //                             "Hospital 1",
//       //                             style: TextStyle(
//       //                               fontSize: 16.sp,
//       //                               fontWeight: FontWeight.w400,
//       //                               color: AppColors.darkGreyTextColor,
//       //                             ),
//       //                           ),
//       //                           Text(
//       //                             "Bone Specialist",
//       //                             style: TextStyle(
//       //                               fontSize: 14.sp,
//       //                               fontWeight: FontWeight.w600,
//       //                               color: AppColors.primaryColor,
//       //                             ),
//       //                           ),
//       //                           Text(
//       //                             "See the bill management",
//       //                             style: TextStyle(
//       //                               fontSize: 12.sp,
//       //                               fontWeight: FontWeight.w400,
//       //                               color: Colors.blue,
//       //                             ),
//       //                           ),
//       //                         ],
//       //                       ),
//       //                     ),
//       //                   ),
//       //                   const Icon(Icons.arrow_forward)
//       //                 ],
//       //               ),
//       //             ),
//       //           ),
//       //         );
//       //       },
//       //     ),
//       //     ListView.builder(
//       //       shrinkWrap: true,
//       //       physics: const NeverScrollableScrollPhysics(),
//       //       itemCount: 3,
//       //       itemBuilder: (_, i) {
//       //         return Card(
//       //           color: AppColors.primarybgColor,
//       //           shape: RoundedRectangleBorder(
//       //             borderRadius: BorderRadius.circular(10.r),
//       //           ),
//       //           margin: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 12.h),
//       //           child: Padding(
//       //             padding: EdgeInsets.symmetric(vertical: 15.h),
//       //             child: ListTile(
//       //               leading: SizedBox(
//       //                 height: 40.h,
//       //                 width: 40.w,
//       //                 child: Image.asset('assets/icons/document-icon.png'),
//       //               ),
//       //               title: Text(
//       //                 'Mar 23,2022',
//       //                 style: TextStyle(
//       //                   fontSize: 16.sp,
//       //                   fontWeight: FontWeight.bold,
//       //                   color: AppColors.primaryColor,
//       //                 ),
//       //               ),
//       //               subtitle: Padding(
//       //                 padding: EdgeInsets.only(top: 5.h),
//       //                 child: Text(
//       //                   'at 01:20 PM in spring Hill Hospital Allergy shot',
//       //                   textAlign: TextAlign.justify,
//       //                   style: TextStyle(
//       //                     fontSize: 12.sp,
//       //                     fontWeight: FontWeight.bold,
//       //                     color: AppColors.darkGreyTextColor,
//       //                   ),
//       //                 ),
//       //               ),
//       //               trailing: PopupMenuButton(
//       //                 itemBuilder: (BuildContext context) => <PopupMenuEntry>[
//       //                   const PopupMenuItem(
//       //                     value: 1,
//       //                     child: Text('Working a lot harder'),
//       //                   ),
//       //                   const PopupMenuItem(
//       //                     value: 2,
//       //                     child: Text('Being a lot smarter'),
//       //                   ),
//       //                   const PopupMenuItem(
//       //                     value: 3,
//       //                     child: Text('Being a self-starter'),
//       //                   ),
//       //                   const PopupMenuItem(
//       //                     value: 4,
//       //                     child: Text('Placed in charge of trading charter'),
//       //                   ),
//       //                 ],
//       //               ),
//       //             ),
//       //           ),
//       //         );
//       //       },
//       //     )
//       //   ],
//       // )),
//     );
//   }
// }
