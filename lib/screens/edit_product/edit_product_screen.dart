import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product.dart';
import '../../providers/products.dart';

class EditProductScreen extends StatefulWidget {

  static const routeName = "/edit-product";

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: "",
    price: 0,
    description: "",
    imageUrl: ""
  );
  var _initValues = {
    "title": "",
    "description" : "",
    "price" : "",
    "imageUrl" : ""
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if(_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if(productId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          "title": _editedProduct.title,
          "description" : _editedProduct.description,
          "price" : _editedProduct.price.toString(),
          "imageUrl" : ""
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if(!isValid) {
      return;
    }
    _form.currentState.save();
    setState((){
      _isLoading = true;
    });
    if(_editedProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      setState((){
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch(error) {
        await showDialog<Null>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("An error occured!"),
            content: Text("Something went wrong"),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Okay")
              )
            ],
          )
        );
      } finally {
        setState((){
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: <Widget>[
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save)
          )
        ],
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(),)
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    initialValue: _initValues["title"],
                    decoration: InputDecoration(labelText: "Title"),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if(value.isEmpty) {
                        return "Please provide a value";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                        id: _editedProduct.id,
                        title: value,
                        description: _editedProduct.description,
                        price: _editedProduct.price,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite
                      );
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues["price"],
                    decoration: InputDecoration(labelText: "Price"),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if(value.isEmpty) {
                        return "Please enter a price.";
                      }
                      if(double.tryParse(value) == null) {
                        return "Please enter a valid number";
                      }
                      if(double.parse(value) <= 0) {
                        return "Please enter a number greater than zero.";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(value),
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite
                      );
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues["description"],
                    decoration: InputDecoration(labelText: "Description"),
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if(value.isEmpty) {
                        return "Please enter a description.";
                      }
                      if(value.length < 10) {
                        return "Should be at least 10 characters long";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: value,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite
                      );
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.only(top: 8, right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey
                          )
                        ),
                        child: _imageUrlController.text.isEmpty
                          ? Text("Enter a URL")
                          : FittedBox(
                              child: Image.network(
                                _imageUrlController.text,
                                fit: BoxFit.cover,
                              ),
                            ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _imageUrlController,
                          decoration: InputDecoration(labelText: "Image URL"),
                          validator: (value) {
                            if(value.isEmpty) {
                              return "Please enter an image URL.";
                            }
                            if(!value.startsWith("http") && !value.startsWith("https")) {
                              return "Please enter a valid URL.";
                            }
                            if(!value.endsWith("png") && !value.endsWith(".jpg") && !value.endsWith(".jpeg")) {
                              return "Please enter a valid image URL.";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          onTap: () {
                            _imageUrlController.text = "https://fileinfo.com/img/ss/xl/jpg_44.png";
                          },
                          onFieldSubmitted: (_) {
                            setState(() {});
                            _saveForm();
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: _editedProduct.price,
                              imageUrl: value,
                              isFavorite: _editedProduct.isFavorite
                            );
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
        ),
    );
  }
}
