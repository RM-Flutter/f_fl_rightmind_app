import 'dart:math';

import 'package:cpanal/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:cpanal/constants/app_colors.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/modules/cpanel/logic/auto_response_provider.dart';
import 'package:cpanal/modules/cpanel/logic/dns_provider.dart';
import 'package:cpanal/modules/cpanel/logic/email_account_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/componentes/general_components/all_text_field.dart';

class CreateEmailBottomSheet extends StatefulWidget {
  var dominId;
  var dominName;
  bool? multi = false;
  CreateEmailBottomSheet({this.dominId,this.dominName,this.multi});

  @override
  State<CreateEmailBottomSheet> createState() => _CreateEmailBottomSheetState();
}

class _CreateEmailBottomSheetState extends State<CreateEmailBottomSheet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ipAddressController = TextEditingController();
  TextEditingController ttlController = TextEditingController();
  TextEditingController priorityController = TextEditingController();
  bool isContainsHtml = true;
  String? selectType;
  String generateRandomPassword({int length = 12}) {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()-_=+[]{};:,.<>?/|';
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }
  @override
  void initState() {
    priorityController.text = "0";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<DNSProvider>(
        builder: (context, value, child) {
          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            builder: (_, controller) {
              return Container(
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
                        AppStrings.create.tr().toUpperCase(),
                        style: const TextStyle(
                          color: Color(AppColors.primary),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    defaultDropdownField(
                      value: selectType,
                      title: selectType ?? AppStrings.type.tr(),
                      items: value.types.map((e) => DropdownMenuItem(
                        value: e.toString(),
                        child: Text(e.toString(),  style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff000000)),),
                      )).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          selectType = newVal;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: AppStrings.name.tr().toUpperCase(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    if(selectType != null)TextFormField(
                      controller: ipAddressController,
                      decoration: InputDecoration(
                        hintText: selectType == "A"? AppStrings.ipAddress.tr().toUpperCase():
                        selectType == "AAAA"? AppStrings.ip6Address.tr().toUpperCase():
                        selectType == "TXT"? AppStrings.freeText.tr().toUpperCase():
                        selectType == "CNAME" || selectType == "MX"? AppStrings.domainOrSubdomain.tr().toUpperCase():
                        "",
                      ),
                    ),
                    if(selectType != null) const SizedBox(height: 15),
                    if(selectType != null && selectType == "MX")TextFormField(
                      controller: priorityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: AppStrings.priority.tr().toUpperCase(),
                      ),
                    ),
                    if(selectType != null && selectType == "MX") const SizedBox(height: 15),
                    TextFormField(
                      controller: ttlController,
                      decoration: InputDecoration(
                        hintText: "${AppStrings.ttl.tr().toUpperCase()} (${AppStrings.optional.tr()})",
                      ),
                    ),
                    if(selectType != null && selectType != "TXT" && selectType != "MX")  const SizedBox(height: 15),
                    if(selectType != null && selectType != "TXT" && selectType != "MX")Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("",),
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
                                color: isContainsHtml ? Color(0xFFE91E63) : Colors.grey[400],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: AnimatedAlign(
                                duration: Duration(milliseconds: 200),
                                alignment: isContainsHtml ? Alignment.centerRight : Alignment.centerLeft,
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
                            AppStrings.proxyStatus.tr().toUpperCase(),
                            style: const TextStyle(
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
                        const SizedBox(width: 20,),
                        Expanded(
                          child: CustomElevatedButton(
                            width: null,
                            backgroundColor: const Color(AppColors.dark),
                            title: AppStrings.send.tr().toUpperCase(),
                            onPressed: () async {
                              value.addDNS(context,
                              domainId: widget.dominId.toString(),
                                name: nameController.text,
                                priority: priorityController.text,
                                proxied: selectType != "TXT" && selectType != "MX" ?isContainsHtml : null,
                                ttl: ttlController.text,
                                type: selectType,
                                content: ipAddressController.text
                              );
                            },
                            isPrimaryBackground: false,
                          )
                        ),
                      ],
                    )
                  ],
                ),
              );
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
        bool isNumber = false, // باراميتر جديد
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
    );
  }

}
