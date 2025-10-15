import 'dart:math';

import 'package:cpanal/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:cpanal/constants/app_colors.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/constants/string_convert.dart';
import 'package:cpanal/general_services/localization.service.dart';
import 'package:cpanal/modules/cpanel/logic/auto_response_provider.dart';
import 'package:cpanal/modules/cpanel/logic/email_account_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditEmailBottomSheet extends StatefulWidget {
  var dominId;
  var dominName;
  var email;
  var index;
  bool? multi = false;
  EditEmailBottomSheet({this.dominId, this.dominName, this.multi, this.email, this.index});

  @override
  State<EditEmailBottomSheet> createState() => _EditEmailBottomSheetState();
}

class _EditEmailBottomSheetState extends State<EditEmailBottomSheet> {
  TextEditingController emailController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  TextEditingController intervalController = TextEditingController();
  TextEditingController startController = TextEditingController();
  TextEditingController stopController = TextEditingController();
  bool isContainsHtml = true;
  String generateRandomPassword({int length = 12}) {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()-_=+[]{};:,.<>?/|';
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final autoResponseProvider = Provider.of<AutoResponseProvider>(context, listen: false);
      autoResponseProvider.getOneAutoRes(
        context,
        email: widget.email,
        DomainId: widget.dominId.toString(),
      );

    });
    stopController.clear();
    startController.clear();
    emailController.clear();
    subjectController.clear();
    fromController.clear();
    intervalController.clear();
    bodyController.clear();
    emailController.text = widget.index['email'] ?? "";
    subjectController.text = widget.index['subject'] ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Consumer<AutoResponseProvider>(
      builder: (context, value, child) {
        if(value.getOneAuto != null && value.controllersFilled == false){
          value.controllersFilled = true;
          int? timestampStop = value.getOneAuto?.res?.stop;
          if (timestampStop != null) {
            stopController.text = DateTime.fromMillisecondsSinceEpoch(timestampStop * 1000)
                .toIso8601String().split('T')[0];
          } else {
            stopController.text = "";
          }
          int? timestampStart = value.getOneAuto?.res?.start;
          if (timestampStart != null) {
            startController.text = DateTime.fromMillisecondsSinceEpoch(timestampStart * 1000)
                .toIso8601String().split('T')[0];
          } else {
            startController.text = "";
          }
          fromController.text = value.getOneAuto!.res!.from ?? "";
          intervalController.text = value.getOneAuto!.res!.interval?.toString() ?? "";
          bodyController.text = value.getOneAuto!.res!.body ?? "";
          if(value.getOneAuto!.res!.isHtml == 1){isContainsHtml = true;}else{isContainsHtml = false;}
        }
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) {
            return (value.getOneAuto != null)?Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      "${AppStrings.update.tr().toUpperCase()} ${AppStrings.autoresponders.tr().toUpperCase()}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(AppColors.primary),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: Text(
                      AppStrings.autoResponseMessage.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(AppColors.dark),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  if (widget.email == null)
                    _buildInputWithSuffix(AppStrings.email.tr().toUpperCase(),
                        "@${widget.dominName}", 120.0,
                        onChanged: (String? value){
                          setState(() {
                            emailController.text = widget.dominName;
                          });
                        },
                        controller: emailController),
                  if (widget.email == null) const SizedBox(height: 15),
                  TextFormField(
                    controller: fromController,
                    decoration: InputDecoration(
                      hintText: AppStrings.from.tr().toUpperCase(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      hintText: AppStrings.subject.tr().toUpperCase(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: intervalController,
                    decoration: InputDecoration(
                      hintText: AppStrings.interval.tr().toUpperCase(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    readOnly: true,
                    controller: startController,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2101),
                        locale: Locale(
                            LocalizationService.isArabic(context: context)
                                ? 'ar'
                                : 'en'),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.blue, // لون الرأس والأزرار
                                onPrimary: Colors.white, // لون النص على الأزرار
                                onSurface: Colors.black, // لون النص في باقي الأماكن
                              ),
                              dialogBackgroundColor: Colors.white, // خلفية النافذة نفسها
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        final outputFormat = DateFormat('yyyy-MM-dd',LocalizationService.isArabic(context: context)
                            ? 'ar'
                            : 'en');
                        final outputDate = outputFormat.format(picked);
                        startController.text =
                            outputDate;
                      }
                    },
                    decoration:
                    InputDecoration(hintText: AppStrings.startDate.tr()),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return AppStrings.dataIsRequired.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    readOnly: true,
                    controller: stopController,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2101),
                        locale: Locale(
                            LocalizationService.isArabic(context: context)
                                ? 'ar'
                                : 'en'),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.blue, // لون الرأس والأزرار
                                onPrimary: Colors.white, // لون النص على الأزرار
                                onSurface: Colors.black, // لون النص في باقي الأماكن
                              ),
                              dialogBackgroundColor: Colors.white, // خلفية النافذة نفسها
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        final outputFormat = DateFormat('yyyy-MM-dd',LocalizationService.isArabic(context: context)
                            ? 'ar'
                            : 'en');
                        final outputDate = outputFormat.format(picked);
                        stopController.text =
                            outputDate;
                      }
                    },
                    decoration:
                    InputDecoration(hintText: AppStrings.stopDate.tr(), ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return AppStrings.dataIsRequired.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: bodyController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: AppStrings.body.tr().toUpperCase(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.withoutHtml.tr().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff1B1B1B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isContainsHtml = !isContainsHtml;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: 60,
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isContainsHtml
                                  ? Color(0xFFE91E63)
                                  : Colors.grey[400],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: AnimatedAlign(
                              duration: Duration(milliseconds: 200),
                              alignment: isContainsHtml
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppStrings.containsHtml.tr().toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff1B1B1B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomElevatedButton(
                          width: null,
                          backgroundColor: const Color(0xffD10A11),
                          title: AppStrings.cancel.tr().toUpperCase(),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          isPrimaryBackground: false,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          child: value.isLoading == false?CustomElevatedButton(
                            width: null,
                            backgroundColor: const Color(AppColors.dark),
                            title: AppStrings.update.tr().toUpperCase(),
                            onPressed: () async {
                              value.editAutoRes(context,
                                  start: StringConvert.sanitizeDateString(startController.text),
                                  stop: StringConvert.sanitizeDateString(stopController.text),
                                  interval: StringConvert.sanitizeDateString(intervalController.text),
                                  domainId: widget.dominId.toString(),
                                  domain: widget.dominName.toString(),
                                  subject: subjectController.text,
                                  from: fromController.text,
                                  body: bodyController.text,
                                  email: widget.email ?? emailController.text,
                                  html: isContainsHtml
                              );
                            },
                            isPrimaryBackground: false,
                          ): const Center(child: CircularProgressIndicator()))
                      ,
                    ],
                  )
                ],
              ),
            ) : const Center(child: CircularProgressIndicator(),);
          },
        );
      },
    );
  }

  Widget _buildInputWithSuffix(
      String label,
      String suffixText,
      double width, {
        TextEditingController? controller,
        onChanged,
        bool isNumber = false, // باراميتر جديد
      }) {
    return IgnorePointer(
      child: TextFormField(
        controller: controller,
        enabled: false,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
        decoration: InputDecoration(
          fillColor: Colors.white,
          labelText: label,
          suffixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: width,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xffDFDFDF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                suffixText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(AppColors.dark),
                ),
              ),
            ),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
