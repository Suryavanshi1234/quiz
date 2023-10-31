
import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  final String url;

  WebViewExample({required this.url});

  @override
  _WebViewExampleState createState() =>
      _WebViewExampleState();
}

class _WebViewExampleState
    extends State<WebViewExample> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      floatingActionButton: FloatingActionButton.extended(
            backgroundColor:Colors.black,
            onPressed: () {
             Navigator.pop(context);
             Navigator.pop(context);
              // winner();
              // Navigator.pop(context);
            },
            label: Text("Go back"),
            icon: const Icon(Icons.arrow_back_ios),
          ),

        body: Column(
          children: <Widget>[

            Expanded(
              child: WebView(
                backgroundColor: Colors.blue,
                initialUrl: widget.url,
                javascriptMode: JavascriptMode.unrestricted,
                // Enable JavaScript
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                  webViewController.clearCache();
                  final cookieManager = CookieManager();
                  cookieManager.clearCookies();
                },
                navigationDelegate: (NavigationRequest request) {
                  // Intercept and handle UPI app URLs here
                  if (request.url.startsWith('upi://')) {
                    launch(request.url);
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },

                onPageStarted: (String url) {
                  setState(() {
                    _isLoading = false; // Hide the loading indicator when the page is loaded.
                  });
                },
                onPageFinished: (String url) {
                  setState(() {
                    Text('erty',style: TextStyle(color: Colors.red),);
                  });
                },
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 150),
            //   child: CustomRoundedButton(
            //
            //     widthPercentage: 0.4,
            //     backgroundColor: Theme.of(context).primaryColor,
            //     buttonTitle:
            //     "Go Back",
            //     radius: 15.0,
            //     showBorder: false,
            //     titleColor: Theme.of(context).backgroundColor,
            //     fontWeight: FontWeight.bold,
            //     textSize: 17.0,
            //
            //     onTap: () async{
            //       Navigator.pop(context);
            //       Navigator.pop(context);
            //     },
            //     height: 40.0,
            //   ),
            // ),
            // ButtonBar(
            //   alignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     ElevatedButton(
            //       onPressed: () {
            //         Navigator.pop(context);
            //         Navigator.pop(context);
            //       },
            //       child: Text('Go Back'),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

