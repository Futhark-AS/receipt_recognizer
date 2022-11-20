import 'package:flutter/material.dart';

// Import http package
import 'package:http/http.dart' as http;
// jsonEncode() to convert Dart objects to JSON
import 'dart:convert';
// import File and Directory
import 'dart:io';
// image_picker package
import 'package:image_picker/image_picker.dart';

import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance
      .authStateChanges()
      .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
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
    String initialRoute = '/';
    if(FirebaseAuth.instance.currentUser == null) {
      initialRoute = "/login";
    }

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
      // Home page with name of user as title
      home:  HomePage(header: 'Welcome to Receipt Recognizer'),

    routes: {
      '/login': (context) => const MyLoginPage(),
    },
      initialRoute: initialRoute,
    );
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.header});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String header;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  // Initialize api key and endpoint
  final apiKey = '5a5ee784b11d40218db59dc8c5c8f1b3';
  final endpoint = 'jorgen-receipt-recognizer.cognitiveservices.azure.com';

  final modelId = "prebuilt-receipt";

  // Create _isLoading variable
  bool _isLoading = false;

  // 647471734749-4i4hftheppp1lhi0istjpmih8g68s1jn.apps.googleusercontent.com



  // initialize itemsList to store the items
  // Format: {name: string, price: double, quantity: double, date: string}
  // fill with dummy data
  List<Map<String, dynamic>> _itemsList = [
    {'name': 'Apple', 'price': 1.99, 'quantity': 1, 'date': '2021-01-01'},
    {'name': 'Banana', 'price': 2.99, 'quantity': 2, 'date': '2021-01-01'},
    {'name': 'Orange', 'price': 3.99, 'quantity': 3, 'date': '2021-01-01'},
    {'name': 'Grapes', 'price': 4.99, 'quantity': 4, 'date': '2021-01-01'},
    {'name': 'Pineapple', 'price': 5.99, 'quantity': 5, 'date': '2021-01-01'},
    {'name': 'Watermelon', 'price': 6.99, 'quantity': 6, 'date': '2021-01-01'},
    {'name': 'Mango', 'price': 7.99, 'quantity': 7, 'date': '2021-01-01'},
    {'name': 'Peach', 'price': 8.99, 'quantity': 8, 'date': '2021-01-01'},
    {'name': 'Strawberry', 'price': 9.99, 'quantity': 9, 'date': '2021-01-01'},
    {'name': 'Blueberry', 'price': 10.99, 'quantity': 10, 'date': '2021-01-01'},
    {'name': 'Raspberry', 'price': 11.99, 'quantity': 11, 'date': '2021-01-01'},
    {'name': 'Kiwi', 'price': 12.99, 'quantity': 12, 'date': '2021-01-01'},
    {'name': 'Lemon', 'price': 13.99, 'quantity': 13, 'date': '2021-01-01'},
    {'name': 'Lime', 'price': 14.99, 'quantity': 14, 'date': '2021-01-01'},
    {'name': 'Pomegranate', 'price': 15.99, 'quantity': 15, 'date': '2021-01-01'},
    {'name': 'Papaya', 'price': 16.99, 'quantity': 16, 'date': '2021-01-01'},
    {'name': 'Coconut', 'price': 17.99, 'quantity': 17, 'date': '2021-01-01'},
    {'name': 'Avocado', 'price': 18.99, 'quantity': 18, 'date': '2021-01-01'},
    {'name': 'Cherry', 'price': 19.99, 'quantity': 19, 'date': '2021-01-01'},
    {'name': 'Pineapple', 'price': 20.99, 'quantity': 20, 'date': '2021-01-01'},
    {'name': 'Strawberry', 'price': 9.99, 'quantity': 9, 'date': '2021-01-01'},
    {'name': 'Blueberry', 'price': 10.99, 'quantity': 10, 'date': '2021-01-01'},
    {'name': 'Raspberry', 'price': 11.99, 'quantity': 11, 'date': '2021-01-01'},
    {'name': 'Kiwi', 'price': 12.99, 'quantity': 12, 'date': '2021-01-01'},
    {'name': 'Lemon', 'price': 13.99, 'quantity': 13, 'date': '2021-01-01'},
    {'name': 'Lime', 'price': 14.99, 'quantity': 14, 'date': '2021-01-01'},
    {'name': 'Pomegranate', 'price': 15.99, 'quantity': 15, 'date': '2021-01-01'},
    {'name': 'Papaya', 'price': 16.99, 'quantity': 16, 'date': '2021-01-01'},
    {'name': 'Coconut', 'price': 17.99, 'quantity': 17, 'date': '2021-01-01'},
  ];

  // sort column index
  int? _sortColumnIndex;
  bool _isAscending = false;

  DataColumn dataColumn(String label) {
    String lowerLabel = label.toLowerCase();
    return DataColumn(
      label: Text(label),
      onSort: (int columnIndex, bool ascending) {
        setState(() {
          _sortColumnIndex = columnIndex;
          _isAscending = ascending;
          if (ascending) {
            _itemsList.sort((a, b) => a[lowerLabel]!.compareTo(b[lowerLabel]!));
          } else {
            _itemsList.sort((a, b) => b[lowerLabel]!.compareTo(a[lowerLabel]!));
          }
        });
      },
    );
  }

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
        title: Text(widget.header),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        // if _isLoading is true, show CircularProgressIndicator
        // else show ListView
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
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
                  // if itemsList is empty, show Text
                  // else show ListView
                  _itemsList.isEmpty
                      ? const Text(
                          'No items found',
                          style: TextStyle(fontSize: 20),
                        )
                  //Scrollable data table. The user can edit each cell by clicking
                  // on it. The user can also sort the table by tapping on the
                  // column headers.
                      : Expanded(
                          child: Scrollbar(
                            child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,

                              child: DataTable(
                                // sort the table based on the column clicked
                                sortColumnIndex: _sortColumnIndex,
                                columns: <DataColumn>[
                                  dataColumn('Name'),
                                  dataColumn('Price'),
                                  dataColumn('Quantity'),
                                  dataColumn('Date'),
                                ],
                                rows: _itemsList
                                    .map(
                                      (item) => DataRow(
                                        cells: [
                                          DataCell(Text(item['name']!)),
                                          DataCell(Text(item['price'].toString())),
                                          DataCell(Text(item['quantity'].toString())),
                                          DataCell(Text(item['date']!)),
                                        ],
                                      ),
                                    )
                                    .toList(),

                              ),
                            ),

                          ),
                        ),
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
          takePicture();
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

    // set _isLoading to true
    setState(() {
      _isLoading = true;
    });

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

    // await 3 seconds while showing a load wheel to the user
    await Future.delayed(const Duration(seconds: 5), () {});

    // get results using apim-request-id
    final results = await getResults(operationLocation);

    // transform results to Map object
    Map<String, dynamic> resultsMap = jsonDecode(results);

    // if still running, wait 3 seconds and try again
    if (resultsMap['status'] == 'running') {
      await Future.delayed(const Duration(seconds: 5), () {});
      final results = await getResults(operationLocation);
      resultsMap = jsonDecode(results);
    }

    // stop loading
    setState(() {
      _isLoading = false;
    });

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

    // get items from results
    var items = resultsMap['analyzeResult']['documents'][0]['fields']['Items']
        ['valueArray'];

    // get date from results
    var date = resultsMap['analyzeResult']['documents'][0]['fields']["TransactionDate"]["valueDate"];

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
      var price = valueObject['TotalPrice']['valueNumber'];

      // Add the item to the itemsList
      itemsList.add({
        "date": date,
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
