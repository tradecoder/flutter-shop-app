import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.model.dart';
import '../providers/products_provider.dart';

class EditProductPage extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductPage({super.key});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  var _editedProduct = Product(
    id: "",
    title: "",
    description: "",
    price: 0,
    imageUrl: "",
  );

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
      final productId = ModalRoute.of(context)?.settings.arguments;

      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context).findById(productId.toString());
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveFormData() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != "") {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct)
          .then((_) => Navigator.of(context).pop());
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct)
            .then((_) => Navigator.of(context).pop());
      } catch (error) {
        await showDialog(
            context: context,
            builder: ((ctx) => AlertDialog(
                  title: const Text('Error:'),
                  content: const Text('Somethning went wrong!'),
                  actions: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Ok'),
                    ),
                  ],
                )));
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(onPressed: _saveFormData, icon: const Icon(Icons.save)),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _form,
                child: ListView(children: [
                  TextFormField(
                    initialValue: _initValues['title'],
                    decoration: const InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide a title';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _editedProduct = Product(
                        id: _editedProduct.id,
                        title: newValue!,
                        description: _editedProduct.description,
                        price: _editedProduct.price,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      );
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['price'],
                    decoration: const InputDecoration(labelText: 'Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _priceFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    onSaved: (newValue) {
                      _editedProduct = Product(
                        id: _editedProduct.id,
                        title: _editedProduct.title,
                        description: _editedProduct.description,
                        price: double.parse(
                            newValue!.trim().replaceAll(RegExp('[^0-9.]'), '')),
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      );
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['description'],
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    focusNode: _descriptionFocusNode,
                    onSaved: (newValue) {
                      _editedProduct = Product(
                        id: _editedProduct.id,
                        title: _editedProduct.title,
                        description: newValue!,
                        price: _editedProduct.price,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      );
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide descripton';
                      }
                      if (value.length < 20) {
                        return 'Please add more details';
                      }
                      return null;
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(top: 10, right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                        child: _imageUrlController.text.isEmpty
                            ? const Text('Enter a Url')
                            : FittedBox(
                                fit: BoxFit.cover,
                                child: Image.network(
                                  _imageUrlController.text,
                                  errorBuilder: (BuildContext context,
                                      Object error, StackTrace? stackTrace) {
                                    return Image.asset(
                                      'assets/images/image_not_found.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                      ),
                      Expanded(
                        child: TextFormField(
                          // initialValue: _initValues['imageUrl'],//this line will not work with controller:
                          decoration:
                              const InputDecoration(label: Text('Image url')),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlController,
                          focusNode: _imageUrlFocusNode,
                          onEditingComplete: () {
                            setState(() {});
                          },
                          onFieldSubmitted: (_) {
                            _saveFormData();
                          },
                          onSaved: (newValue) {
                            _editedProduct = Product(
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: _editedProduct.price,
                              imageUrl: newValue!,
                              isFavorite: _editedProduct.isFavorite,
                            );
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a url';
                            }
                            if (!value.startsWith('http')) {
                              return 'Please add a valid url';
                            }
                            if (!value.endsWith('.jpg') &&
                                !value.endsWith('.jpeg') &&
                                !value.endsWith('.png')) {
                              return 'Please add a photo-source url';
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                ]),
              ),
            ),
    );
  }
}
