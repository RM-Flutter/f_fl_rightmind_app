import 'package:cpanal/constants/app_constants.dart';
import 'package:cpanal/constants/app_strings.dart';
import 'package:cpanal/general_services/alert_service/alerts.service.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class DNSProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;

  bool hasMore = true;
  int pageNumber = 1;
  final int expectedPageSize = 9;
  List types= [
    'AAAA','A', 'MX', 'TXT', 'CNAME'
  ];
  List dns = [];
  bool hasMoreData(int length) {
    if (length < expectedPageSize) {
      return false; // No more data available if we received less than expected
    } else {
      pageNumber += 1; // Increment for the next page
      return true; // More data available
    }
  }
  Future<void> getDns(
      context, {
        bool isNewPage = false,
        dominId
      }) async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await DioHelper.getData(
        url: "/rm_cloud_flare/v1/zones/$dominId/dns_records",
        query: {
          'page': pageNumber,
        },
        context: context,
      );

      if (response.data['status'] == true) {
        List newEmails = response.data['result'];

        if (isNewPage) {
          dns.addAll(newEmails);
          AppConstants.accountsEmailsDNSFilter!.addAll(newEmails);
        } else {
          dns = newEmails;
          AppConstants.accountsEmailsDNSFilter = newEmails;
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
  addDNS(context, {type, domainId, name, content, proxied, ttl, priority}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_cloud_flare/v1/zones/$domainId/dns_records",
        data: {
          if(type != null &&type.toString().isNotEmpty)"type" : type,
          if(name != null &&name.isNotEmpty) "name" : name,
          if(content != null &&content.isNotEmpty) "content" : content,
          if(proxied != null &&proxied.toString().isNotEmpty)"proxied" : proxied,
          if(ttl != null &&ttl.isNotEmpty)"ttl" : int.parse(ttl.toString()),
          if(priority != null &&priority.isNotEmpty) "priority" : priority,
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
  updateDNS(context, {type, domainId, name, content, proxied, ttl, priority, recordId}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.putData(
        url: "/rm_cloud_flare/v1/zones/$domainId/dns_records/$recordId",
        data: {
          if(type != null &&type.toString().isNotEmpty)"type" : type,
          if(name != null &&name.isNotEmpty) "name" : name,
          if(content != null &&content.isNotEmpty) "content" : content,
          if(proxied != null &&proxied.toString().isNotEmpty)"proxied" : proxied,
          if(ttl != null &&ttl.isNotEmpty)"ttl" : int.parse(ttl.toString()),
          if(priority != null &&priority.isNotEmpty) "priority" : priority,
          if(priority != null &&priority.isNotEmpty) "priority" : priority,
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
  deleteDNS(context, {recordId, domainId}) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.deleteData(
        url: "/rm_cloud_flare/v1/zones/$domainId/dns_records/$recordId",
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
