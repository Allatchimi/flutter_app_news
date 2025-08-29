import 'package:app_news/screens/article/widgets/section_country.dart';
import 'package:app_news/screens/article/widgets/section_geo.dart';
import 'package:app_news/screens/article/widgets/section_tab.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/onboarding_util/topics.dart';
import 'package:app_news/widgets/capsule_widget.dart';
import 'package:flutter/material.dart';


class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  int _selectedItemIndex = 0;
  String _tabName = "ManaraTv";

  @override
  void initState() {
    super.initState();
  }

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
          SectionTab(topic: _tabName),
          const SectionCountry(),
          const SectionGeo(),
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