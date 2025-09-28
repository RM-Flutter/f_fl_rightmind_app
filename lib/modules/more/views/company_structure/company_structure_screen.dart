import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cpanal/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'dart:html' as html;

class WebViewStack extends StatefulWidget {
  const WebViewStack({super.key});

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  var loadingPercentage = 0;
  WebViewController? controller;
  late String url;

  @override
  void initState() {
    super.initState();

    final jsonString = CacheHelper.getString("USG");
    Map<String, dynamic>? gCache;
    if (jsonString != null && jsonString.isNotEmpty) {
      gCache = json.decode(jsonString) as Map<String, dynamic>;
    }
    url = gCache?['company_structure_url'] ?? "https://www.google.com/";

    if (!kIsWeb) {
      // ✅ موبايل
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => setState(() => loadingPercentage = 0),
            onProgress: (progress) =>
                setState(() => loadingPercentage = progress),
            onPageFinished: (_) =>
                setState(() => loadingPercentage = 100),
          ),
        )
        ..addJavaScriptChannel(
          'SnackBar',
          onMessageReceived: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message.message)),
            );
          },
        )
        ..loadRequest(Uri.parse(url));
    } else {
      // ✅ ويب → افتح في تبويب جديد
      html.window.open(url, "_blank");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb ? AppBar(title: const Text("فتح الرابط"))
          : AppBar(toolbarHeight: 0.0),
      body: kIsWeb
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.open_in_new, size: 60, color: Colors.blue),
            const SizedBox(height: 16),
            const Text("تم فتح الرابط في تبويب جديد"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                html.window.open(url, "_blank");
              },
              child: const Text("إعادة فتح الرابط"),
            )
          ],
        ),
      )
          : Stack(
        children: [
          WebViewWidget(controller: controller!), // للموبايل
          if (loadingPercentage < 100)
            LinearProgressIndicator(value: loadingPercentage / 100.0),
        ],
      ),
    );
  }
}
