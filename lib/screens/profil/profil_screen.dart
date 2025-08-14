import 'package:app_news/screens/splash_screen.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/app_constants.dart';
import 'package:app_news/utils/helper/data_functions.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:app_news/widgets/expanded_button.dart';
import 'package:app_news/widgets/profil_card_widget.dart';
import 'package:flutter/material.dart';





class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DataHandler dataHandler = DataHandler();


  String lang = "";
  String setLang = "";

  String langCode = "";
  String setLangCode = "";


  String country = "";
  String setCountry = "";

  String countryCode = "";
  String setCountryCode = "";



  @override
  void initState() {
  
    super.initState();
    readData();
  }



  void readData() async {
    country = await dataHandler.getStringValue(AppConstants.countryName);
    countryCode = await dataHandler.getStringValue(AppConstants.countryCode);

    lang = await dataHandler.getStringValue(AppConstants.langName);
    langCode = await dataHandler.getStringValue(AppConstants.langCode);


    setState(() {
      setCountry = country;
      setCountryCode = countryCode;

      setLang = lang;
      setLangCode = langCode;
    });


  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left), onPressed: () {
          Navigator.pop(context);
        },
        ),
        title: const AppText(
          text: "P r o f i l e",
          fontSize: 18.0,
          color: AppColors.blackColor,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body:  Column(
        children: [
          const SizedBox(height: 20,),
          const ProfileCard(),
          const SizedBox(height: 20,),
          const Divider(),
           ListTile(
            title: AppText(
              text: "Country",
              fontSize: 14.0,
              color: AppColors.blackColor.withOpacity(0.6),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: AppText(
              text: "${setCountry} (${setCountryCode})",
              fontSize: 20.0,
              color: AppColors.blackColor,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.normal,
            ),

          ),
           ListTile(
            title: AppText(
              text: "Language",
              fontSize: 14.0,
              color: AppColors.blackColor.withOpacity(0.6),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: AppText(
              text: "$setLang ($setLangCode)",
              fontSize: 20.0,
              color: AppColors.blackColor,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.normal,
            ),

          ),

          const Spacer(),
          const AppText(
            text: "1.0.0 Version",
            fontSize: 12.0,
            color: AppColors.blackColor,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.normal,
          ),


          const SizedBox(height: 20,),
          const Divider(),
          const SizedBox(height: 20,),


          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpandedButton(
              buttonColor: AppColors.primaryColor.withOpacity(1),
              onPressed: () async {
                // print('Button Pressed!');
                await dataHandler.clearAllPreferences();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  const SplashScreen()),
                );
              },
              child: const AppText(
                text: "Wipe Data",
                fontSize: 18.0,
                color: AppColors.blackColor,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 30,),
        ],
      )
    );
  }
}