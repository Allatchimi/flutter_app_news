import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/onboarding_util/topics.dart';
import 'package:app_news/widgets/capsule_widget.dart';
import 'package:app_news/screens/home/sub_widgets/home_section_country.dart';
import 'package:app_news/screens/home/sub_widgets/home_section_geo.dart';
import 'package:app_news/screens/home/sub_widgets/home_section_tab.dart';
import 'package:flutter/material.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int _selectedItemIndex = 0;
  String _tabName = "ManaraTv";

  void _onTabChanged(String newTab) {
    setState(() => _tabName = newTab);
  }

  void _onTabIndexChanged(int index) {
    setState(() {
      _selectedItemIndex = _selectedItemIndex == index ? -1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTopicSelector(context),
          HomeSectionTab(topic: _tabName),
          const HomeSectionCountry(),
          const HomeSectionGeo(),
        ],
      ),
    );
  }

  Widget _buildTopicSelector(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.98,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: topicList.length,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        itemBuilder: (context, index) {
          return CapsuleWidget(
            name: topicList[index].value,
            border: AppColors.primaryColor,
            background: _selectedItemIndex == index
                ? AppColors.primaryColor.withOpacity(0.8)
                : Colors.white,
            currentIndex: index,
            onTapCallback: _onTabChanged,
            onTapIndex: _onTabIndexChanged,
          );
        },
      ),
    );
  }
}