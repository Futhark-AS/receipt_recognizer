import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
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
    if (FirebaseAuth.instance.currentUser == null) {
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
      home: HomePage(header: 'Receipt Recognizer'),

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
  // Format: {name: string, price: double, quantity: int, date: string}
  // fill with dummy data
  List<Map<String, dynamic>> _itemsList = [
    {'name': 'Apple', 'price': 2, 'quantity': 1, 'date': '2021-01-01'},
    {'name': 'Banana', 'price': 2.99, 'quantity': 2, 'date': '2021-01-01'},
    {'name': 'Orange', 'price': 3.99, 'quantity': 3, 'date': '2021-01-01'},
    {'name': 'Grapes', 'price': 500, 'quantity': 4, 'date': '2021-01-01'},
    {'name': 'Pineapple', 'price': 2.99, 'quantity': 5, 'date': '2021-01-01'},
    {'name': 'Watermelon', 'price': 2.99, 'quantity': 6, 'date': '2021-01-01'},
    {'name': 'Mango', 'price': 2.99, 'quantity': 7, 'date': '2021-01-01'},
    {'name': 'Peach', 'price': 2.99, 'quantity': 8, 'date': '2021-01-01'},
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

  DataCell dataCell(dynamic text, String type, int index) {
    //Return a DataCell with text and onTap to edit the cell, and if its a date, show a date picker
    var _text = text;
    return DataCell(
      Text(text),
      onTap: () {
        if (type == 'date') {
          showDatePicker(
            context: context,
            initialDate: DateTime.parse(text),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          ).then((value) {
            setState(() {
              _itemsList[index]['date'] = value.toString().substring(0, 10);
            });
          });
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Edit'),
                content: TextField(
                  controller: TextEditingController(text: text),
                  onChanged: (value) {
                    _text = value;
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      try {
                        setState(() {
                          print(type);
                          print(_text);
                          if (type == 'price') {
                            _itemsList[index][type] = double.parse(_text);
                          } else if (type == 'quantity') {
                            _itemsList[index][type] = int.parse(_text);
                          } else {
                            _itemsList[index][type] = _text;
                          }
                        });
                        Navigator.pop(context);
                      } catch (e) {
                        // show error in a dialog
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text(
                                  'Please enter a valid value.\nError message: $e',
                                  style: TextStyle(color: Colors.red)),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Ok'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }

  // Delete button in data cell for each row
  DataCell deleteButton(int index) {
    return DataCell(
      IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          setState(() {
            _itemsList.removeAt(index);
          });
        },
      ),
    );
  }

  // _isEditing variable
  bool _isEditing = false;

  // _priceController and _quantityController and _nameController
  TextEditingController _priceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  // date picker variable
  DateTime? _date_in_editing;

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
                                  sortAscending: _isAscending,
                                  columns: <DataColumn>[
                                    DataColumn(
                                      label: Icon(Icons.delete),
                                      onSort:
                                          (int columnIndex, bool ascending) {
                                        // delete all items if user accepts warning dialog
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Warning'),
                                              content: Text(
                                                  'Are you sure you want to delete all items?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _itemsList.clear();
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    dataColumn('Name'),
                                    dataColumn('Price'),
                                    dataColumn('Quantity'),
                                    dataColumn('Date'),
                                  ],
                                  rows: _itemsList
                                      .asMap()
                                      .map((index, item) => MapEntry(
                                            index,
                                            DataRow(
                                              cells: [
                                                deleteButton(index),
                                                dataCell('${item['name']}',
                                                    'name', index),
                                                dataCell('${item['price']}',
                                                    'price', index),
                                                dataCell('${item['quantity']}',
                                                    'quantity', index),
                                                dataCell('${item['date']}',
                                                    'date', index),
                                              ],
                                            ),
                                          ))
                                      .values
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                  _itemsList.isNotEmpty
                      ? ElevatedButton(
                          child: Text('Add Item'),
                          onPressed: () {
                            if (_itemsList.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                      builder: ((context, setState) {
                                    return AlertDialog(
                                      title: Text('Add Item'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: _nameController,
                                            decoration: InputDecoration(
                                              labelText: 'Name',
                                            ),
                                          ),
                                          TextField(
                                            controller: _priceController,
                                            decoration: InputDecoration(
                                              labelText: 'Price',
                                            ),
                                          ),
                                          TextField(
                                            controller: _quantityController,
                                            decoration: InputDecoration(
                                              labelText: 'Quantity',
                                            ),
                                          ),
                                          // Datecontroller pick date
                                          TextButton(
                                            child: Text(
                                                'Date: ${_date_in_editing == null ? "not selected" : _date_in_editing.toString().substring(0, 10)}'),
                                            onPressed: () async {
                                              final date = await showDatePicker(
                                                context: context,
                                                initialDate:
                                                    _date_in_editing == null
                                                        ? DateTime.now()
                                                        : _date_in_editing!,
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2100),
                                              );
                                              if (date != null) {
                                                setState(() {
                                                  _date_in_editing = date;
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            try {
                                              setState(() {
                                                print(_date_in_editing);
                                                print(_itemsList);
                                                _itemsList.add({
                                                  'name': _nameController.text,
                                                  'price': double.parse(
                                                      _priceController.text),
                                                  'quantity': int.parse(
                                                      _quantityController.text),
                                                  'date': _date_in_editing
                                                      .toString()
                                                      .substring(0, 10),
                                                });
                                                print(_itemsList);
                                              });
                                              Navigator.pop(context, true);
                                            } catch (e) {
                                              // show error in a dialog
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text('Error'),
                                                    content: Text(
                                                        'Please enter a valid value.\nError message: $e',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('Ok'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          child: Text('Add'),
                                        ),
                                        // Button to add items using camera
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              takePicture();
                                            },
                                            child: Icon(Icons.camera_alt)),
                                      ],
                                    );
                                  }));
                                },
                              ).then((exit) => {
                                    if (exit)
                                      {
                                        _nameController.clear(),
                                        _priceController.clear(),
                                        _quantityController.clear(),
                                        _date_in_editing = null,
                                        setState(() => {
                                              _itemsList = _itemsList,
                                            })
                                      }
                                  });
                            }
                          },
                        )
                      : Container(),
                  _itemsList.isNotEmpty
                      ?
                      // Add padding around button
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child:
                              // Save button
                              ElevatedButton(
                            // margin bottom for button
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              // if _isLoading is true, do nothing
                              // else save the data
                              if (!_isLoading) {
                                setState(() {
                                  _isLoading = true;
                                });
                                // save the data
                                postItemsToFireStore();
                              }
                            },
                            child: const Text('Save'),
                          ),
                        )
                      : Container(),
                ],
              ),
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        // 2 floating action buttons, one for take a picture and one for upload image
        FloatingActionButton(
          heroTag: 'camera',
          onPressed: () {
            takePicture();
          },
          tooltip: 'Take a picture',
          child: const Icon(Icons.camera_alt),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'upload',
          onPressed: () {
            pickImage();
          },
          tooltip: 'Upload image',
          child: const Icon(Icons.image),
        ),
      ]), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void postItemsToFireStore() async {
    // get the current user
    User? user = FirebaseAuth.instance.currentUser;
    // get the current user's uid
    String uid = user!.uid;

    // create a new document named uid if it doesn't exist
    // else update the existing document
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);
    // try to set
    try {
      var doc = await userDoc.get();
      if (doc.exists) {
        // update the document
        await userDoc.update({
          'items': FieldValue.arrayUnion(_itemsList),
        });
      } else {
        // set the document
        await userDoc.set({
          'items': _itemsList,
        });
      }
      // Clear the list
      _itemsList.clear();

      // if successful, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Items saved successfully'),
        ),
      );
    } catch (e) {
      // if failed, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving items'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
    var date = resultsMap['analyzeResult']['documents'][0]['fields']
        ["TransactionDate"]["valueDate"];

    // Create an empty list to hold the item objects with name, quantity, and price
    List<Map<String, dynamic>> itemsList = [];

    // Loop through the items
    for (var item in items) {
      // get valueObject from item
      var valueObject = item['valueObject'];
      // Get the name, quantity, and price of the item
      String name = valueObject['Description']['valueString'];

      var quantity = valueObject['Quantity'] != null
          ? valueObject['Quantity']['valueNumber']
          : 1;

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
      _itemsList.addAll(itemsList);
    });

    // show success message in dialog, and tell the user that he can edit each cell and also add new items
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text(
            'Items extracted successfully. Tap on a cell to edit its value.'),
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
