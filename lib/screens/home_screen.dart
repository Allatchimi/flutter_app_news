import 'package:app_news/screens/profil_sceen.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/onboarding_util/topics.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:app_news/widgets/capsule_widget.dart';
import 'package:app_news/widgets/sub_widgets/home_section_country.dart';
import 'package:app_news/widgets/sub_widgets/home_section_geo.dart';
import 'package:app_news/widgets/sub_widgets/home_section_tab.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedItemIndex = 0;
  String tabName = "World";


  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: AppText(
            text: "Home Screen",
            color: AppColors.blackColor,
            fontSize: 18.0,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: AppColors.primaryColor,
          leading: const Text(""),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.account_circle_outlined,
                color: AppColors.blackColor,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
                // Handle settings action
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.98,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: topicList.length,
                //physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                itemBuilder: (context, index){
                  return CapsuleWidget(
                    name:topicList[index].value,
                    border:AppColors.primaryColor,
                    background: _selectedItemIndex == index
                          ? AppColors.primaryColor.withOpacity(0.8)
                          : Colors.white,
                    currentIndex: index,
                    onTapCallback: (String isTapped) {
                      print('Widget tapped: $isTapped');
                      setState(() {
                        tabName = isTapped;
                      });
                    },

                    onTapIndex: (int index) {
                      setState(() {
                        if (_selectedItemIndex == index) {
                          _selectedItemIndex = -1; // Deselect if tapped again
                        } else {
                          _selectedItemIndex = index;
                        }
                      });
                    },
                  );
                }
              ),
            ),
            HomeSectionTab(topic: "$tabName",),
            const HomeSectionCountry(),
            const HomeSectionGeo(),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
