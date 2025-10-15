import 'package:cpanal/common_modules_widgets/success_send_complain.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/general_services/alert_service/alerts.service.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SSLProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isLoadingRun = false;
  bool isSuccess = false;
  String? errorMessage;
  bool hasMore = true;
  int pageNumber = 1;
  final int expectedPageSize = 9;
  List SSLS = [];
  bool hasMoreData(int length) {
    if (length < expectedPageSize) {
      return false; // No more data available if we received less than expected
    } else {
      pageNumber += 1; // Increment for the next page
      return true; // More data available
    }
  }
  Future<void> getSSLEmails(
      context, {
        required dynamic domainId,
        bool isNewPage = false,
      }) async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/rm_cpanel/v1/ssl/get",
        query: {
          "domain_id" : domainId,
        },
        data: {
          'page': pageNumber,
        },
        context: context,
      );

      if (response.data['status'] == true) {
        List newEmails = response.data['res'];

        if (isNewPage) {
          SSLS.addAll(newEmails);
        } else {
          SSLS = newEmails;
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
  runSSL(context, {domainId}) async {
    isLoadingRun = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_cpanel/v1/ssl/runAutoSSL",
        data: {
          "domain_id" : domainId,
        },
        context: context,
      );
      if(response.data['status'] == true){
        AlertsService.success(
          title: AppStrings.success.tr(),
          context: context,
          message: response.data['message'] ?? AppStrings.success.tr(),);

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
      isLoadingRun = false;
      notifyListeners();
    } catch (error) {
      isLoadingRun = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    }
  }
}
