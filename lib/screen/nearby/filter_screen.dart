import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../contstants/app_colors.dart';

class FilterScreen extends StatefulWidget {
  final List filterListData;
  const FilterScreen({super.key, required this.filterListData});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List filter = [];
  int? selectedfilterIndex;
  int selectedfilterVarIndex = 0;
  String selectedFilter = "";
  String selectedFilterVar = "";
  @override
  void initState() {
    filter = widget.filterListData[0]['data'];
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Filter',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteTextColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              var data = {
                "filter_var": selectedFilterVar,
                "filter_data": selectedFilter
              };
              Navigator.pop(context, data);
            },
            icon: const Icon(Icons.check),
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.cancel_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey.shade200,
                child: ListView.builder(
                  itemCount: widget.filterListData.length,
                  itemBuilder: (_, i) {
                    return ListTile(
                      selected: selectedfilterVarIndex == i,
                      onTap: () {
                        filter = widget.filterListData[i]['data'];
                        selectedFilterVar =
                            widget.filterListData[i]['filter_var'];
                        selectedfilterVarIndex = i;
                        setState(() {});
                      },
                      title: Text(
                        '${widget.filterListData[i]['name']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              width: 2,
            ),
            Expanded(
              flex: 2,
              child: ListView.builder(
                  itemCount: filter.length,
                  itemBuilder: (_, i) {
                    return ListTile(
                      selected: selectedfilterIndex == i,
                      onTap: () {
                        if (selectedfilterIndex == i) {
                          selectedFilter = "";
                          selectedfilterIndex = null;
                          setState(() {});
                        } else {
                          selectedFilter = filter[i]['name'];
                          selectedfilterIndex = i;
                          setState(() {});
                        }
                      },
                      leading: Checkbox(
                          value: (selectedfilterIndex == i),
                          onChanged: (v) {
                            if (selectedfilterIndex == i) {
                              selectedFilter = "";
                              selectedfilterIndex = null;
                              setState(() {});
                            } else {
                              selectedFilter = filter[i]['name'];
                              selectedfilterIndex = i;
                              setState(() {});
                            }
                          }),
                      title: Text(
                        '${filter[i]['name']}',
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w400),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
