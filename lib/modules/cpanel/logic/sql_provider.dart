import 'package:cpanal/common_modules_widgets/success_send_complain.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/general_services/alert_service/alerts.service.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SqlProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;
  bool hasMore = true;
  int pageNumber = 1;
  final int expectedPageSize = 9;
  List sqls = [];
  bool hasMoreData(int length) {
    if (length < expectedPageSize) {
      return false; // No more data available if we received less than expected
    } else {
      pageNumber += 1; // Increment for the next page
      return true; // More data available
    }
  }
  Future<void> getSQLEmails(
      context, {
        required dynamic domainId,
        bool isNewPage = false,
      }) async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await DioHelper.postData(
        url: "/rm_cpanel/v1/actions",
        data: {
          'page': pageNumber,
          "domain_id": domainId,
          "action_type": "mysql",
          "action": "get",
        },
        context: context,
      );

      if (response.data['status'] == true) {
        List newEmails = response.data['res'];

        if (isNewPage) {
          sqls.addAll(newEmails);
        } else {
          sqls = newEmails;
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
  addSql(context, {username, domainId,
     password, db_name}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_cpanel/v1/actions",
        data: {
          "action" : "add",
          "domain_id" : domainId,
          "action_type" : "mysql",
          "username" : username,
          "password" : password,
          "db_name" : db_name,
          "send_welcome_email" : 1
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
  updateSql(context, {username, domainId, password, db_name}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_cpanel/v1/actions",
        data: {
          "action" : "update",
          "domain_id" : domainId,
          "action_type" : "mysql",
          "username" : username,
          "db_name" : db_name,
          "password" : password,
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
  deleteSql(context, {username, domainId, db_name}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_cpanel/v1/actions",
        data: {
          "action" : "delete",
          "domain_id" : domainId,
          "action_type" : "mysql",
          "username" : username,
          "db_name" : db_name,
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
