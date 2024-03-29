import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/product_details.page.dart';
import '../providers/product.model.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    //don't listen for whole widgets - listen false
    // but it will listen where required through Consumer
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        header: Text(
          'Product ID: ${product.id.toUpperCase()}',
        ),
        footer: GridTileBar(
            backgroundColor: Colors.black87,

            // consume updates only where you want
            //and only this widget will be rebuilt

            leading: Consumer<Product>(
              builder: (ctx, prod, child) => IconButton(
                onPressed: () {
                  product.toggleFavoriteStatus(
                    authData.token,
                    authData.userId,
                  );
                },
                color: Theme.of(context).primaryColor,
                icon: Icon(product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
              ),
            ),
            trailing: IconButton(
                onPressed: () {
                  cart.addItem(product.id, product.title, product.price);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Added the item to Cart'),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () => cart.removeSingleItem(product.id)),
                    ),
                  );
                },
                color: Theme.of(context).primaryColor,
                icon: const Icon(Icons.shopping_cart_outlined)),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            )),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailsPage.routeName,
              arguments: product.id,
            );
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              // load a local image if product image delayed to load
              placeholder:
                  const AssetImage('assets/images/image_not_found.jpg'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
