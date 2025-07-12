import 'package:get/get.dart';

import '../Model/Product.dart';

class CartController extends GetxController {
  var cartItems = <Product>[].obs;

  void addToCart(Product product) {
    int index = cartItems.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      // If product exists, increase its quantity
      cartItems[index].quantity++;
      cartItems.refresh(); // Notify observers about the update
    } else {
      // If product does not exist, add it with initial quantity
      cartItems.add(Product(id: product.id, name: product.name, price: product.price, quantity: 1));
    }
  }

  void increaseQuantity(int productId) {
    int index = cartItems.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      cartItems[index].quantity++;
      cartItems.refresh(); // Notify observers about the update
    }
  }

  void decreaseQuantity(int productId) {
    int index = cartItems.indexWhere((p) => p.id == productId);
    if (index >= 0 && cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      cartItems.refresh(); // Notify observers about the update
    }
  }

  int getProductQuantity(int productId) {
    int index = cartItems.indexWhere((p) => p.id == productId);
    return index >= 0 ? cartItems[index].quantity : 0;
  }
}
