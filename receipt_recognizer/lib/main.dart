import 'package:flutter/material.dart';
// Import http package
import 'package:http/http.dart' as http;
// jsonEncode() to convert Dart objects to JSON
import 'dart:convert';
// import File and Directory
import 'dart:io';
// image_picker package
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Create the request body

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Initialize api key and endpoint
  final apiKey = '5a5ee784b11d40218db59dc8c5c8f1b3';
  final endpoint = 'jorgen-receipt-recognizer.cognitiveservices.azure.com';

  final modelId = "prebuilt-receipt";

  // initialize itemsList to store the items
  // Format: {name: string, price: double, quantity: double}
  List<Map<String, dynamic>> _itemsList = [];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display the items in a table
            DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Quantity')),
              ],
              rows: _itemsList
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(Text(item['name'])),
                        DataCell(Text(item['price'].toString())),
                        DataCell(Text(item['quantity'].toString())),
                      ],
                    ),
                  )
                  .toList(),
            ),

            // Add a button to list all operations in a dialog
            ElevatedButton(
              onPressed: pickImage,
              // use icon of image gallery
              child: const Icon(Icons.image),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Add an onPressed listener to the button that displays a loading wheel while the request is being processed
        onPressed: () async {
          // Display a loading wheel while the request is being processed
          showDialog(
            context: context,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
          takePicture();
          // Close the loading wheel
          Navigator.pop(context);
        },

        child: const Icon(Icons.camera_alt),
        //child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // Create a function to pick an image from the gallery
  Future<void> pickImage() async {
    // Use the image_picker package to pick an image
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    await postImage(File(image!.path));
  }

  // Create a function to take a picture with the camera
  Future<void> takePicture() async {
    // Use the image_picker package to take a picture
    final image = await ImagePicker().pickImage(source: ImageSource.camera);

    await postImage(File(image!.path));
  }

  // Create a function to send the request with the image in the resources folder
  Future<void> postImage(File imageFile) async {
    // Create a List<int> from the image file
    List<int> imageBytes = imageFile.readAsBytesSync();

    // Convert the List<int> to a base64 String
    String base64Image = base64Encode(imageBytes);

    // Create a Map<String, dynamic> to hold the request body
    Map<String, dynamic> requestBody = {
      "base64Source": base64Image,
    };

    // Convert the Map to a JSON String
    String jsonBody = jsonEncode(requestBody);

    // Create a Map<String, String> to hold the headers
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Ocp-Apim-Subscription-Key": apiKey,
    };

    // Create a POST request
    http.Response response = await http.post(
      Uri.parse(
          "https://$endpoint/formrecognizer/documentModels/$modelId:analyze?api-version=2022-08-31"),
      headers: headers,
      body: jsonBody,
    );
    // Print the response status code
    print(response.statusCode);

    // Print the response body
    print(response.headers);

    // Get operation-location from response headers
    String operationLocation = response.headers['operation-location']!;
    // Get apim-request-id from response headers
    String apimRequestId = response.headers['apim-request-id']!;

    // await 5 seconds while showing a load wheel to the user
    await Future.delayed(const Duration(seconds: 7), () {});

    // get results using apim-request-id
    final results = await getResults(operationLocation);

    // transform results to Map object
    Map<String, dynamic> resultsMap = jsonDecode(results);

    // if still running, wait 5 seconds and try again
    if (resultsMap['status'] == 'running') {
      await Future.delayed(const Duration(seconds: 5), () {});
      final results = await getResults(operationLocation);
      resultsMap = jsonDecode(results);
    }
    // if status is not succeeded, show error message
    if (resultsMap['status'] != 'succeeded') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error while processing the image, please try again' +
              "\n" +
              resultsMap.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    var items = resultsMap['analyzeResult']['documents'][0]['fields']['Items']
        ['valueArray'];

    // Create an empty list to hold the item objects with name, quantity, and price
    List<Map<String, dynamic>> itemsList = [];

    // Loop through the items
    for (var item in items) {
      // get valueObject from item
      var valueObject = item['valueObject'];
      // Get the name, quantity, and price of the item
      String name = valueObject['Description']['valueString'];
      var quantity = valueObject['Quantity']['valueNumber'];
      // print type of quantity
      print(quantity.runtimeType);
      var price = valueObject['TotalPrice']['valueNumber'];

      // Add the item to the itemsList
      itemsList.add({
        "name": name,
        "quantity": quantity,
        "price": price,
      });
    }

    setState(() {
      _itemsList = itemsList;
    });
  }

  // Create a function to get the results from the API that takes in resultId and returns the results
  Future<String> getResults(String path) async {
    // Create a Map<String, String> to hold the headers
    Map<String, String> headers = {
      "Ocp-Apim-Subscription-Key": apiKey,
    };

    // Create a GET request
    http.Response response = await http.get(
      Uri.parse(path),
      //"https://$endpoint/formrecognizer/documentModels/$modelId:analyzeResults/$resultId?api-version=2022-08-31"),
      headers: headers,
    );

    // Print the response status code
    print(response.statusCode);

    // Return the response body
    return response.body;
  }

  // Function that gets all the operations, returns the body of the response
  Future<String> listOperations() async {
    // Create a Map<String, String> to hold the headers
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Ocp-Apim-Subscription-Key": apiKey,
    };

    // Create a GET request
    http.Response response = await http.get(
      Uri.parse(
          "https://$endpoint/formrecognizer/operations?api-version=2022-08-31"),
      headers: headers,
    );

    // Print the response body
    print(response.body);

    // Print the response status code
    print(response.statusCode);

    // Return the response body
    return response.body;
  }
}
