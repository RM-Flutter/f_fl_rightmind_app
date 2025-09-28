import 'package:cpanal/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:cpanal/constants/app_colors.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/modules/cpanel/logic/email_account_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CreateMultiEmailBottomSheet extends StatefulWidget {
  final dynamic dominId;
  final dynamic dominName;
  const CreateMultiEmailBottomSheet({super.key, this.dominId, this.dominName});

  @override
  State<CreateMultiEmailBottomSheet> createState() => _CreateMultiEmailBottomSheetState();
}

class _CreateMultiEmailBottomSheetState extends State<CreateMultiEmailBottomSheet> {
  List<EmailInputData> emailAccounts = [EmailInputData()];

  @override
  Widget build(BuildContext context) {
    return Consumer<EmailAccountProvider>(
      builder: (context, values, child) {
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
                      AppStrings.createEmails.tr().toUpperCase(),
                      style: const TextStyle(
                        color: Color(AppColors.primary),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      AppStrings.createEmailMessage.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 25),

                  ...emailAccounts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final acc = entry.value;
                    return _buildAccountFields(acc, index);
                  }),

                  const SizedBox(height: 10),

                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        emailAccounts.add(EmailInputData());
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: Text(AppStrings.addEmail.tr()),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: CustomElevatedButton(
                          title: AppStrings.cancel.tr().toUpperCase(),
                          backgroundColor: const Color(0xffD10A11),
                          onPressed: ()async => Navigator.pop(context),
                          isPrimaryBackground: false,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: CustomElevatedButton(
                          title: AppStrings.addEmail.tr().toUpperCase(),
                          backgroundColor: const Color(AppColors.dark),
                          onPressed: ()async {
                            print("TAPED");
                            List<Map<String, dynamic>> accounts = emailAccounts.map((e) {
                              return {
                                "username": "${e.usernameController.text.trim()}@labx.r-m.dev",
                                "password": e.passwordController.text.trim(),
                                "quota": int.tryParse(e.quotaController.text.trim()) ?? 0,
                              };
                            }).toList();
                            await values.addMultiEmails(
                              context,
                              domainId: widget.dominId.toString(),
                              accounts: accounts,
                            );
                            print("TAPED");
                          },
                          isPrimaryBackground: false,
                        ),
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

  Widget _buildAccountFields(EmailInputData acc, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (emailAccounts.length > 1)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    emailAccounts.removeAt(index);
                  });
                },
              )
          ],
        ),
        const SizedBox(height: 5),
        _buildInputWithSuffix(AppStrings.email.tr().toUpperCase(),
            "${widget.dominName}", 120.0, controller: acc.usernameController, isNumber: false),
        const SizedBox(height: 10),
        _buildPasswordField(acc.passwordController),
        const SizedBox(height: 10),
        _buildInputWithSuffix(AppStrings.storage.tr().toUpperCase(), "MB", 60.0, controller: acc.quotaController,
            isNumber: true),
        const Divider(height: 30),
      ],
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
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.digitsOnly] // يمنع أي حاجة غير الأرقام
          : [],
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

  Widget _buildPasswordField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: false,
      decoration: InputDecoration(
        labelText: AppStrings.password.tr().toUpperCase(),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF2C154D),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() {
                controller.text = "154df654sd6f";
              });
            },
            child: Text(
              AppStrings.generate.tr().toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class EmailInputData {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController quotaController = TextEditingController();
}
