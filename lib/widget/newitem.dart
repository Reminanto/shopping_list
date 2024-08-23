import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/groceryitem.dart';

class Newitem extends StatefulWidget {
  const Newitem({super.key});

  @override
  State<Newitem> createState() => _NewitemState();
}

class _NewitemState extends State<Newitem> {
  final _formkey = GlobalKey<FormState>();
  var _entername = '';
  var _selectedcategories = categories[Categories.vegetables]!;
  var _enternumer = 1;
  var _issending = false;
  void _saveitem() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      setState(() {
        _issending = true;
      });
      final url = Uri.https(
          'course-a405f-default-rtdb.firebaseio.com', 'shopping_list.json');
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'name': _entername,
            'quantity': _enternumer,
            'category': _selectedcategories.title
          }));
      final Map<String, dynamic> resdata = json.decode(response.body);
      if (response.statusCode == 200) {
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pop(GroceryItem(
            id: resdata['name'],
            name: _entername,
            quantity: _enternumer,
            category: _selectedcategories));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ADD NEW ITEM'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
                key: _formkey,
                child: Column(children: [
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(label: Text('Name')),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1 ||
                          value.trim().length > 50) {
                        return 'Enter valid data';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _entername = value!;
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration:
                              const InputDecoration(label: Text('Quantity')),
                          keyboardType: TextInputType.number,
                          initialValue: '1',
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null ||
                                int.tryParse(value)! <= 0) {
                              return 'Enter valid data';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enternumer = int.parse(value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField(
                            value: _selectedcategories,
                            items: [
                              for (final category in categories.entries)
                                DropdownMenuItem(
                                    value: category.value,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          color: category.value.color,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(category.value.title)
                                      ],
                                    ))
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedcategories = value!;
                              });
                            }),
                      )
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed:_issending?null: () {
                            _formkey.currentState!.reset();
                          },
                          child: const Text('Reset')),
                      ElevatedButton(
                          onPressed:_issending?null: _saveitem, child: _issending? const SizedBox(width: 16,height: 16,child:  CircularProgressIndicator(),) :const Text('Add Item'))
                    ],
                  )
                ]))));
  }
}
