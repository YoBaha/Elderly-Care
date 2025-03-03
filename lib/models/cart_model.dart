import 'product_model.dart'; // Import the Product model

class Cart {
  List<CartItem> items;

  Cart({required this.items});

  factory Cart.fromJson(Map<String, dynamic> json) {
    var itemsFromJson = json['items'] as List;
    List<CartItem> itemList = itemsFromJson.map((i) => CartItem.fromJson(i)).toList();

    return Cart(items: itemList);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class CartItem {
  Product product; // Product is now an object
  int quantity;

  CartItem({required this.product, required this.quantity});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}
