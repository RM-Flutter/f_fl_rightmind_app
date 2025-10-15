import 'package:cpanal/common_modules_widgets/success_send_complain.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/general_services/alert_service/alerts.service.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmailForwardProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;
  bool hasMore = true;
  int pageNumber = 1;
  final int expectedPageSize = 9;
  List emailForward = [];
  List domainForward = [];
  bool hasMoreData(int length) {
    if (length < expectedPageSize) {
      return false; // No more data available if we received less than expected
    } else {
      pageNumber += 1; // Increment for the next page
      return true; // More data available
    }
  }
  Future<void> getEmailForward(
      context, {
        required dynamic domainId,actionType,
        bool isNewPage = false,
        username
      }) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/rm_cpanel/v1/emails_forward/get",
        query: {
          'page': pageNumber,
          "action_type" : actionType,
     //     "username" : username,
          "domain_id": domainId,
        },
        context: context,
      );

      if (response.data['status'] == true) {
        List newEmails = response.data['res'];

        if (isNewPage) {
          emailForward.addAll(newEmails);
        } else {
          emailForward = newEmails;
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
  Future<void> getDomainForward(
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
        url: "/rm_cpanel/v1/emails_forward/get",
        query: {
          'page': pageNumber,
          "action_type" : actionType,
       //   "username" : username,
          "domain_id": domainId,
        },
        context: context,
      );

      if (response.data['status'] == true) {
        List newDomain = response.data['res'];

        if (isNewPage) {
          domainForward.addAll(newDomain);
        } else {
          domainForward = newDomain;
        }

        hasMore = newDomain.length == expectedPageSize;
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
  addEmailForward(context, {email, domainId,
    actionType, forwardTo}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_cpanel/v1/emails_forward/add",
        data: {
          if(email.isNotEmpty) "username" : email,
          "domain_id" : domainId,
          "action_type" : actionType,
          "forward_to" : forwardTo,
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
  deleteEmailForward(context, {
    domainId,
    dest,
    actionType, forwardTo}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_cpanel/v1/emails_forward/delete",
        data: {
        if(dest != null && dest.toString().isNotEmpty)  "username" : dest,
          "domain_id" : domainId,
          "action_type" : actionType,
          "forward_to" : forwardTo,
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
  updateAutoRes(context, {email, domainId,
    body, from, interval, domain, html, subject}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_cpanel/v1/email_auto_responders/update",
        data: {
          "email" : email,
          "domain_id" : domainId,
          "body" : body,
          "from" : from,
          "interval" : "60",
          "is_html" : html == true? 1 : 0,
          "start" : "2023-01-05",
          "stop" : "2023-12-05",
          "subject" : subject
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
  deleteAuto(context, {account, domainId}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_cpanel/v1/email_auto_responders/delete",
        data: {
          "domain_id" : domainId,
          "email" : account,
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
        AlertsService.error(
            context: context,
            message: response.data['message'],
            title: AppStrings.failed.tr());
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
