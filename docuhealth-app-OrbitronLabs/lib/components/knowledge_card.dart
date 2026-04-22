import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KnowledgeCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String node;
  final String node1;
  final String path;
  final VoidCallback onPress;

  const KnowledgeCard(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.node,
      required this.node1,
      required this.onPress,
      required this.path});

  @override
  State<KnowledgeCard> createState() => _KnowledgeCardState();
}

class _KnowledgeCardState extends State<KnowledgeCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPress,
      child: Card(
          elevation: 3,
          margin: EdgeInsets.only(top: 10.h, left: 10.w, right: 10.w),
          child: Container(
            padding: EdgeInsets.all(15.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 190,
                      child: Column(
                        children: [
                          Text(
                            widget.title,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            widget.subtitle,
                            textAlign: TextAlign.left,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Hero(
                          tag: widget.path,
                          child: Image(
                            image: NetworkImage(widget.path),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Text(
                          widget.node,
                          style: TextStyle(fontSize: 11.sp),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.node1,
                          style: TextStyle(fontSize: 11.sp),
                        ),
                      ]),
                      // Row(children: [
                      //   Icon(
                      //     Icons.share,
                      //     color: AppColors.primaryColor,
                      //     size: 20,
                      //   ),
                      // ])
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
