import 'package:flutter/material.dart';
import 'package:cpanal/general_services/url_launcher.service.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

class ContactUsController extends ChangeNotifier{
 bool isLoading = false;
 bool isSuccess = false;
 String? errorMessage;


 Future<void> sendMailToCompany({
   required BuildContext context,
   required String email,
   required String? subject,
   required String? body,
 }) async {
   if (email.isEmpty) return;

   final Uri params = Uri(
     scheme: 'mailto',
     path: email,
     query:
     'subject=${Uri.encodeComponent(subject ?? 'Contact From Application')}&body=${Uri.encodeComponent(body ?? 'Hello')}',
   );

   final url = params.toString();

   if (kIsWeb) {
     html.window.open(url, '_blank'); // يفتح نافذة البريد في المتصفح
   } else {
     if (await canLaunchUrl(Uri.parse(url))) {
       await launchUrl(Uri.parse(url));
     } else {
       throw 'Could not launch $url';
     }
   }
 }
}

