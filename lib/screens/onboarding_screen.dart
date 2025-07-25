import 'package:app_news/screens/home_screen.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/app_constants.dart';
import 'package:app_news/utils/helper/data_functions.dart';
import 'package:app_news/utils/onboarding_util/country_codes.dart';
import 'package:app_news/utils/onboarding_util/languages.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:app_news/widgets/expanded_button.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final DataHandler dataHandler = DataHandler();
  final _formKey = GlobalKey<FormState>();

  String name = '';
  CountryCodes? selectedCountry;
  Language? selectedLanguage;
  String? gender;
  
  final List<String> genders = ['Male', 'Female', 'Other'];

  bool get isFormValid {
    return name.isNotEmpty && 
           gender != null && 
           selectedCountry != null && 
           selectedLanguage != null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primaryColor,
          title: const AppText(
            text: "O n b o a r d i n g",
            fontSize: 18.0,
            color: AppColors.blackColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Name Field
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: AppColors.blackColor),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.blackColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primaryColor),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          onChanged: (value) => setState(() => name = value),
                        ),

                        const SizedBox(height: 20),

                        // Gender Selection
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              text: "Gender",
                              fontSize: 12.0,
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.normal,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: AppColors.blackColor.withOpacity(0.7),
                            ),
                            color: Colors.white,
                          ),
                          child: DropdownButton<String>(
                            value: gender,
                            hint: const AppText(
                              text: "Select Gender",
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                            items: genders.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: AppText(
                                  text: value,
                                  fontSize: 16.0,
                                  color: AppColors.blackColor,
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() => gender = newValue);
                            },
                            underline: Container(),
                            isExpanded: true,
                            dropdownColor: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Country Selection
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              text: "Country",
                              fontSize: 12.0,
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.normal,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: AppColors.blackColor.withOpacity(0.7),
                            ),
                            color: Colors.white,
                          ),
                          child: DropdownButton<CountryCodes>(
                            value: selectedCountry,
                            hint: const AppText(
                              text: "Select Country",
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                            items: countries.map((CountryCodes country) {
                              return DropdownMenuItem<CountryCodes>(
                                value: country,
                                child: AppText(
                                  text: country.name,
                                  fontSize: 16.0,
                                  color: AppColors.blackColor,
                                ),
                              );
                            }).toList(),
                            onChanged: (CountryCodes? newValue) {
                              setState(() => selectedCountry = newValue);
                            },
                            underline: Container(),
                            isExpanded: true,
                            dropdownColor: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Language Selection
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              text: "Language",
                              fontSize: 12.0,
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.normal,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: AppColors.blackColor.withOpacity(0.7),
                            ),
                            color: Colors.white,
                          ),
                          child: DropdownButton<Language>(
                            value: selectedLanguage,
                            hint: const AppText(
                              text: "Select Language",
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                            items: languages.map((Language language) {
                              return DropdownMenuItem<Language>(
                                value: language,
                                child: AppText(
                                  text: language.name,
                                  fontSize: 16.0,
                                  color: AppColors.blackColor,
                                ),
                              );
                            }).toList(),
                            onChanged: (Language? newValue) {
                              setState(() => selectedLanguage = newValue);
                            },
                            underline: Container(),
                            isExpanded: true,
                            dropdownColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Submit Button
                ExpandedButton(
                  buttonColor: isFormValid
                      ? AppColors.primaryColor
                      : AppColors.primaryColor.withOpacity(0.5),
                  onPressed: isFormValid ? () => _submitForm() : null,
                  child: const AppText(
                    text: "Submit data",
                    color: AppColors.blackColor,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await dataHandler.setStringValue(AppConstants.userName, name);
        await dataHandler.setStringValue(AppConstants.genderValue, gender!);
        await dataHandler.setStringValue(
            AppConstants.countryCode, selectedCountry!.code);
        await dataHandler.setStringValue(
            AppConstants.countryName, selectedCountry!.name);
        await dataHandler.setStringValue(
            AppConstants.langCode, selectedLanguage!.code);
        await dataHandler.setStringValue(
            AppConstants.langName, selectedLanguage!.name);
        await dataHandler.setStringValue(AppConstants.doneOnboarding, "YES");

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: ${e.toString()}')),
        );
      }
    }
  }
}