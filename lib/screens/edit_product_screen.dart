import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var editedProduct =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');
  var _isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };

  var _isLoading = false;
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;

      if (productId != null) {
        editedProduct =
            Provider.of<ProductsProvider>(context, listen: false).findById(
          productId,
        );

        _initValues = {
          'title': editedProduct.title,
          'description': editedProduct.description,
          'price': editedProduct.price.toString(),
          'imageUrl': ''
        };
        _imageUrlController.text = editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    super.dispose();
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) return;

    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    if (editedProduct.id != null) {
      Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(editedProduct.id, editedProduct);
      Navigator.of(context).pop();
    } else {
      Provider.of<ProductsProvider>(
        context,
        listen: false,
      )
          .addProduct(
        editedProduct,
      )
          .catchError((error) {
        return showDialog<Null>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('An error Ocurred'),
                content: Text(
                  'Something went wrong',
                ),
                actions: <Widget>[
                  FlatButton(child: Text('Okay'), onPressed: () {
                    Navigator.of(ctx).pop();
                  },)
                ],
              );
            });
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                            title: value,
                            id: editedProduct.id,
                            price: editedProduct.price,
                            description: editedProduct.description,
                            imageUrl: editedProduct.imageUrl,
                            isFavorite: editedProduct.isFavorite);
                      },
                      validator: (value) {
                        return value.isEmpty ? 'Please provide a value' : null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                            title: editedProduct.title,
                            id: editedProduct.id,
                            price: double.parse(value),
                            description: editedProduct.description,
                            imageUrl: editedProduct.imageUrl,
                            isFavorite: editedProduct.isFavorite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value';
                        }

                        if (double.tryParse(value) == null) {
                          return 'Please provide a valid number';
                        }

                        if (double.parse(value) <= 0) {
                          return 'Please provide a valid number';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        editedProduct = Product(
                            title: editedProduct.title,
                            id: editedProduct.id,
                            price: editedProduct.price,
                            description: value,
                            imageUrl: editedProduct.imageUrl,
                            isFavorite: editedProduct.isFavorite);
                      },
                      validator: (value) {
                        return value.isEmpty ? 'Please provide a value' : null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter an URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) => _saveForm(),
                            onSaved: (value) {
                              editedProduct = Product(
                                  title: editedProduct.title,
                                  id: editedProduct.id,
                                  price: editedProduct.price,
                                  description: editedProduct.description,
                                  imageUrl: value,
                                  isFavorite: editedProduct.isFavorite);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter valid value';
                              }

                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid url';
                              }

                              if (!value.endsWith('.png') &&
                                  !value.endsWith('jpg') &&
                                  !value.endsWith('jepg')) {
                                return 'Please enter a valid image';
                              }

                              return null;
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
