import 'package:cpanal/common_modules_widgets/success_send_complain.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/general_services/alert_service/alerts.service.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmailFilterProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;
  bool hasMore = true;
  int pageNumber = 1;
  final int expectedPageSize = 9;
  List emailFilter = [];
  String? selectFrom;
  String? selectContain;
  String? selectDiscardMassage;
  List fromList = [
    {
      "key" : AppStrings.from.tr(),
      "value" : "\$header_from:"
    },    {
      "key" : AppStrings.subject.tr(),
      "value" : "\$header_subject:"
    },    {
      "key" : AppStrings.to.tr(),
      "value" : "\$header_to:"
    },    {
      "key" : AppStrings.anyRecipient.tr(),
      "value" : "foranyaddress \$h_to:,\$h_cc:"
    },    {
      "key" : AppStrings.reply.tr(),
      "value" : "\$reply_address:"
    },    {
      "key" : AppStrings.body.tr(),
      "value" : "\$message_body"
    },    {
      "key" : AppStrings.anyHeader.tr(),
      "value" : "\$message_headers"
    },    {
      "key" : AppStrings.hasNotBeenPreviously.tr(),
      "value" : "not delivered"
    },    {
      "key" : AppStrings.isAnErrorMessage.tr(),
      "value" : "error_message"
    },    {
      "key" : AppStrings.listID.tr(),
      "value" : "\$h_List-Id:"
    },    {
      "key" : AppStrings.spamStatus.tr(),
      "value" : "\$h_X-Spam-Status:"
    },    {
      "key" : AppStrings.spamBar.tr(),
      "value" : "\$h_X-Spam-Bar:"
    },
    {
      "key" : AppStrings.spamScore.tr(),
      "value" : "\$h_X-Spam-Score:"
    },
  ];
  List andList = [
    {
      "key" : AppStrings.and.tr(),
      "value" : "and"
    },
    {
      "key" : AppStrings.or.tr(),
      "value" : "or"
    },
  ];
  List containList = [
    {
      "key" : AppStrings.matchesRegex.tr(),
      "value" : "matches"
    },    {
      "key" : AppStrings.contains.tr(),
      "value" : "contains"
    },    {
      "key" : AppStrings.doesNotContain.tr(),
      "value" : "does not contain"
    },    {
      "key" : AppStrings.equals.tr(),
      "value" : "is"
    },    {
      "key" : AppStrings.beginsWith.tr(),
      "value" : "begins"
    },    {
      "key" : AppStrings.endsWith.tr(),
      "value" : "ends"
    },    {
      "key" : AppStrings.doesNotBegin.tr(),
      "value" : "does not begin"
    },    {
      "key" : AppStrings.doesNotEndWith.tr(),
      "value" : "does not end"
    },    {
      "key" : AppStrings.doesNotMatch.tr(),
      "value" : "does not match"
    },    {
      "key" : "${AppStrings.isAbove.tr()} (${AppStrings.numbersOnly.tr()})",
      "value" : "is above"
    },    {
      "key" : "${AppStrings.isNotAbove.tr()} (${AppStrings.numbersOnly.tr()})",
      "value" : "is not above"
    },    {
      "key" : "${AppStrings.isBelow.tr()} (${AppStrings.numbersOnly.tr()})",
      "value" : "is below"
    },
    {
      "key" : "${AppStrings.isNotBelow.tr()} (${AppStrings.numbersOnly.tr()})",
      "value" : "is not below"
    },
  ];
  List actionList = [
    {
      "key" : AppStrings.discardMassage.tr(),
      "value" : "save \"/dev/null\""
    },    {
      "key" : AppStrings.redirectToEmail.tr(),
      "value" : "deliver"
    },    {
      "key" : AppStrings.failWithMessage.tr(),
      "value" : "fail"
    },    {
      "key" : AppStrings.stopProcessingRules.tr(),
      "value" : "finish"
    },    {
      "key" : AppStrings.deliverToFolder.tr(),
      "value" : "save"
    },    {
      "key" : AppStrings.pipeToAProgram.tr(),
      "value" : "pipe"
    },

  ];
  List actionList2 = [
    {
      "key" : AppStrings.inbox.tr(),
      "value" : "INBOX"
    },    {
      "key" : AppStrings.drafts.tr(),
      "value" : "/.Drafts"
    },    {
      "key" : AppStrings.junk.tr(),
      "value" : "/.Junk"
    },    {
      "key" : AppStrings.sent.tr(),
      "value" : "/.Sent"
    },    {
      "key" : AppStrings.spam.tr(),
      "value" : "/.spam"
    },    {
      "key" : AppStrings.trash.tr(),
      "value" : "/.Trash"
    },

  ];
  bool hasMoreData(int length) {
    if (length < expectedPageSize) {
      return false; // No more data available if we received less than expected
    } else {
      pageNumber += 1; // Increment for the next page
      return true; // More data available
    }
  }
  Future<void> getEmailFilter(
      context, {
        required dynamic domainId,actionType,
        bool isNewPage = false,
        username
      }) async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await DioHelper.getData(
        url: "/rm_cpanel/v1/emails_filter/get",
        query: {
          'page': pageNumber,
          "action_type" : "email",
         "username" : username.toString(),
          "domain_id": domainId,
        },
        context: context,
      );

      if (response.data['status'] == true) {
        List newEmails = response.data['res'];

        if (isNewPage) {
          emailFilter.addAll(newEmails);
        } else {
          emailFilter = newEmails;
        }

        hasMore = newEmails.length == expectedPageSize;
        if (hasMore) pageNumber++;

        isLoading = false;
        notifyListeners();
      }else{
        isLoading = false;
        AlertsService.error(
            context: context,
            message: response.data['message'],
            title: AppStrings.failed.tr());
        notifyListeners();
      }
    } catch (error) {
      isLoading = false;
      notifyListeners();
      errorMessage = error is DioError
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
    }
  }

  addEmailFilter(context, {email, domainId, filtername, match, actions}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_cpanel/v1/emails_filter/add",
        data: {
          if(email.isNotEmpty) "username" : email,
          "filtername" : filtername,
          "domain_id" : domainId,
          "action_type" : "email",
          "actions" :actions,
          "match" :match
        },
        context: context,
      );
      if(response.data['status'] == true){
        Navigator.pop(context);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          builder: (context) {
            return SuccessfulSendCpanalBottomsheet(response.data['message']);
          },
        );
      }else{
        showToast(
          response.data['message'],
          context: context,
          backgroundColor: Colors.red,
          textStyle: const TextStyle(color: Colors.white),
          duration: const Duration(seconds: 5),
          position: StyledToastPosition.bottom,
        );
      }
      isLoading = false;
      notifyListeners();
    } catch (error) {
      isLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    }
  }
  deleteEmailFilter(context, {
    domainId,
    username,
    actionType, filtername}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_cpanel/v1/emails_filter/delete",
        data: {
        if(username != null && username.toString().isNotEmpty)  "username" : username,
          "domain_id" : domainId,
          "action_type" : "emails",
          "filtername" : filtername,
        },
        context: context,
      );
      if(response.data['status'] == true){
        Navigator.pop(context);
        AlertsService.success(
            context: context,
            message: response.data['message'],
            title: AppStrings.success.tr());
      }else{
        showToast(
          response.data['message'],
          context: context,
          backgroundColor: Colors.red,
          textStyle: const TextStyle(color: Colors.white),
          duration: const Duration(seconds: 5),
          position: StyledToastPosition.bottom,
        );
      }
      isLoading = false;
      notifyListeners();
    } catch (error) {
      isLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    }
  }
}
