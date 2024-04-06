import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart' as web;

class PayfastPayment extends StatefulWidget {
  PayfastPayment({Key? key}) : super(key: key);
@override
_PayfastPaymentState createState() => _PayfastPaymentState();
}

class _PayfastPaymentState extends State<PayfastPayment> {
  GlobalKey<FormState> formstate = new GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  TextEditingController itemNameController = TextEditingController();
  PaymentViewModel? model;
  var client = http.Client();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Payment Page")),
      body: Form(
        key: formstate,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Amount',
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            TextFormField(
              controller: itemNameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Item Name',
              ),
            ),
            SizedBox(
              width: 220,
              height: 100,
              child: InkWell(
                onTap: () {
                  print(
                      "Amount: ${amountController.text} Item: ${itemNameController.text}");
                  model?.payment(
                      amountController.text, itemNameController.text);
                },
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.blue,
                  child: const Center(
                      child: Text("Pay",
                          style: TextStyle(fontSize: 22, color: Colors.white))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  PaymentViewModel? model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Web View"),
        ),
        body: Column(children: [
          // Expanded(
          //     child: web.WebView(
          //       initialUrl: model?.payFast,
          //       javascriptMode: web.JavascriptMode.unrestricted,
          //       onPageFinished: _onUrlChange,
          //       debuggingEnabled: true,
          //     ))
        ]));
  }

  _onUrlChange(String url) {
    print('Page finished loading: $url');
    if (mounted) {
      setState(() {
        if (url.contains("http://localhost:8080/#/onSuccess")) {
          Navigator.pushNamed(context, "/onSuccess");
        } else if (url.contains("http://localhost:8080/#/onCancel")) {
          Navigator.pushNamed(context, "/onCancel");
        }
      });
    }
  }
}

class PaymentViewModel {
  TextEditingController amountController = TextEditingController();
  TextEditingController itemNameController = TextEditingController();
  API? api;
  String? errorMessage;
  String? payFast;

  void payment(String? amount, String? item_name) {
    //amount = amountController.text;
    item_name = itemNameController.text;
    api
        ?.payFastPayment(amount: amount, item_name: item_name)
        .then((createdPayment) {
      if (createdPayment == null) {
        errorMessage = "Something went wrong. Please try again.";
      } else {
        payFast = createdPayment;
      }
      print("It reaches here");
    }).catchError((error) {
      errorMessage = '${error.toString()}';
    });
  }
}

class API {
  static String baseURL = 'https://sandbox.payfast.co.za';

  var client = new http.Client();

  Future<String> payFastPayment({
    String? amount,
    String? item_name,
  }) async {
    Map<String, String>? requestHeaders;

    final queryParameters = {
      "merchant_key": "46f0cd694581a",
      "merchant_id": "10000100",
      "amount": "$amount",
      "item_name": "$item_name",
      "return_url": "http://localhost:8080/#/onSuccess",
      "cancel_url": "http://localhost:8080/#/onCancel",
    };
    Uri uri = Uri.https(baseURL, "/eng/process", queryParameters);
    print("URI ${uri.data}");
    final response = await client.put(uri, headers: requestHeaders);
    print("Response body ${response.body}");
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 203 ||
        response.statusCode == 204) {
      return response.body;
    } else if (response.body != null) {
      return Future.error(response.body);
    } else {
      return Future.error('${response.toString()}');
    }
  }
}

class OnSuccess extends StatelessWidget {
  const OnSuccess({Key? key}) : super(key: key);
  static const String route = 'onSuccess';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "This is on Success",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 33),
              ),
              SizedBox(width: 15),
              Icon(
                Icons.check,
                color: Colors.green,
                size: 40,
              )
            ],
          )),
    );
  }
}

class OnCancel extends StatelessWidget {
  const OnCancel({Key? key}) : super(key: key);
  static const String route = 'OnCancel';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "This is on Cancel",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 33),
              ),
              SizedBox(width: 15),
              Icon(
                Icons.close,
                color: Colors.red,
                size: 40,
              )
            ],
          )),
    );
  }
}