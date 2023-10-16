import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Dashboard extends StatefulWidget {
  final token;
  const Dashboard({@required this.token, Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String userId;

  //controllers
  TextEditingController _companyController = TextEditingController();
  TextEditingController _warehouseController = TextEditingController();
  TextEditingController _referenceController = TextEditingController();
  TextEditingController _requiredDateController = TextEditingController();

  //company list
  final List<String> companies = [
    'Nippon Paints',
    'Rocell Ceramics',
    'JAT Solutions',
    'Dulux Paints',
    'IKEA'
  ];

  String? _selectedCompany;
  List? items;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    userId = jwtDecodedToken['_id'];
    getOrdersList(userId);
  }

//add method
  // void addTodo() async {
  //   if (_todoTitle.text.isNotEmpty && _todoDesc.text.isNotEmpty) {
  //     var regBody = {
  //       "userId": userId,
  //       "title": _todoTitle.text,
  //       "desc": _todoDesc.text
  //     };

  //     var response = await http.post(Uri.parse(addtodo),
  //         headers: {"Content-Type": "application/json"},
  //         body: jsonEncode(regBody));

  //     var jsonResponse = jsonDecode(response.body);

  //     print(jsonResponse['status']);

  //     if (jsonResponse['status']) {

  //       _todoDesc.clear();
  //       _todoTitle.clear();
  //       Navigator.pop(context);
  //       getTodoList(userId);
  //     } else {
  //       print("SomeThing Went Wrong");
  //     }
  //   }
  // }

  //add new order method
  void addNewOrder() async {
    if (_selectedCompany != null && _warehouseController.text.isNotEmpty) {
      var regBody = {
        "userId": userId,
        "Company": _selectedCompany,
        "Warehouse": _warehouseController.text,
        "Reference": _referenceController.text,
        "Required_Date": _requiredDateController.text.trim()
      };

      var response = await http.post(
        Uri.parse(addOrder),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status']) {
        _selectedCompany = null;
        _warehouseController.clear();
        _companyController.clear();
        _referenceController.clear();
        _requiredDateController.clear();
        Navigator.pop(context);
        getOrdersList(userId);
      } else {
        print("Something Went Wrong");
      }
    }
  }

  //edit order method
  void editItem(index) {
    TextEditingController _editCompany =
        TextEditingController(text: items![index]['Company']);
    TextEditingController _editWarehouse =
        TextEditingController(text: items![index]['Warehouse']);
    TextEditingController _editReference =
        TextEditingController(text: items![index]['Reference']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Purchase Order '),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //company field
              TextField(
                controller: _editCompany,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Company",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ).p4().px8(),

              //warehouse location field
              TextField(
                controller: _editWarehouse,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Warehouse Location",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ).p4().px8(),

              //reference field
              TextField(
                controller: _editReference,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Reference Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ).p4().px8(),

              //elevated button
              ElevatedButton(
                onPressed: () async {
                  var regBody = {
                    "id": items![index]['_id'],
                    "Company": _editCompany.text,
                    "Warehouse": _editWarehouse.text,
                    "Reference": _editReference.text
                  };

                  var response = await http.put(
                    Uri.parse(updateOrder),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(regBody),
                  );

                  var jsonResponse = jsonDecode(response.body);

                  if (jsonResponse['status']) {
                    Navigator.pop(context);
                    getOrdersList(userId);
                  } else {
                    print("Something Went Wrong");
                  }
                },
                child: Text("Update Order Details"),
              ),
            ],
          ),
        );
      },
    );
  }

  //retrieve orders method
  void getOrdersList(userId) async {
    var regBody = {"userId": userId};

    var response = await http.post(Uri.parse(getOrderList),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody));

    var jsonResponse = jsonDecode(response.body);
    items = jsonResponse['success'];

    setState(() {});
  }

  //delete orders method
  void deleteItem(id) async {
    var regBody = {"id": id};

    var response = await http.post(Uri.parse(deleteOrder),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody));

    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      getOrdersList(userId);
    }
  }

  //datepicker for requiredDate  method
  Future<void> _selectRequiredDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      _requiredDateController.text =
          "${pickedDate.toLocal()}".split(' ')[0]; // Format the selected date
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
                top: 60.0, left: 30.0, right: 30.0, bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CircleAvatar(
                //   child: Icon(
                //     Icons.list,
                //     size: 30.0,
                //   ),
                //   backgroundColor: Colors.white,
                //   radius: 30.0,
                // ),
                SizedBox(height: 10.0),

                //title
                Text(
                  'Smart Home Construrctions Pvt. Ltd.',
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8.0),

                //sub title
                Text(
                  'Site Manager Dashboard',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: items == null
                    ? null
                    : ListView.builder(
                        itemCount: items!.length,
                        itemBuilder: (context, int index) {
                          return Slidable(
                            key: const ValueKey(0),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              dismissible: DismissiblePane(onDismissed: () {}),
                              children: [
                                SlidableAction(
                                  backgroundColor: Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                  onPressed: (BuildContext context) {
                                    print('item id : ${items![index]['_id']}');
                                    deleteItem('${items![index]['_id']}');
                                  },
                                ),
                                SlidableAction(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Edit',
                                  onPressed: (BuildContext context) {
                                    editItem(index);
                                  },
                                ),
                              ],
                            ),

                            //card view
                            child: Card(
                              borderOnForeground: false,
                              child: ListTile(
                                leading: Icon(Icons.task),
                                title: Text('${items![index]['Company']}'),
                                subtitle: Text('${items![index]['Warehouse']}'),
                                trailing: Icon(Icons.arrow_back),
                              ),
                            ),
                          );
                        }),
              ),
            ),
          )
        ],
      ),

      //floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayTextInputDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Add-New Order',
      ),
    );
  }

  // Future<void> _displayTextInputDialog(BuildContext context) async {
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //             title: Text('Add To-Do'),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextField(
  //                   controller: _todoTitle,
  //                   keyboardType: TextInputType.text,
  //                   decoration: InputDecoration(
  //                       filled: true,
  //                       fillColor: Colors.white,
  //                       hintText: "Title",
  //                       border: OutlineInputBorder(
  //                           borderRadius:
  //                               BorderRadius.all(Radius.circular(10.0)))),
  //                 ).p4().px8(),
  //                 TextField(
  //                   controller: _todoDesc,
  //                   keyboardType: TextInputType.text,
  //                   decoration: InputDecoration(
  //                       filled: true,
  //                       fillColor: Colors.white,
  //                       hintText: "Description",
  //                       border: OutlineInputBorder(
  //                           borderRadius:
  //                               BorderRadius.all(Radius.circular(10.0)))),
  //                 ).p4().px8(),
  //                 ElevatedButton(
  //                     onPressed: () {
  //                       addTodo();
  //                     },
  //                     child: Text("Add"))
  //               ],
  //             ));
  //       });
  // }

  //dialog pop for edit method
  Future<void> _displayTextInputDialog(BuildContext context) async {
    //to hold new value
    String? newCompany;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Purchase Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //supplier selector
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButton<String>(
                    hint: Text('Select The Supplier'),
                    value: newCompany,
                    onChanged: (String? newValue) {
                      setState(() {
                        newCompany = newValue;
                      });
                    },
                    items: companies.map((String title) {
                      return DropdownMenuItem<String>(
                        value: title,
                        child: Text(title),
                      );
                    }).toList(),
                  );
                },
              ).p4().px8(),

              //warehouse field
              TextField(
                controller: _warehouseController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Warehouse Location",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ).p4().px8(),

              //ref no field
              TextField(
                controller: _referenceController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Reference No :",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ).p4().px8(),

              //date field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: () => _selectRequiredDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _requiredDateController,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.calendar_month_rounded),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Required Date',
                      ),
                    ),
                  ),
                ),
              ),

              //elevated button
              ElevatedButton(
                onPressed: () {
                  _selectedCompany = newCompany; // Update the selected title
                  addNewOrder();
                },
                child: Text("Place Order ✔"),
              ),
            ],
          ),
        );
      },
    );
  }
}
