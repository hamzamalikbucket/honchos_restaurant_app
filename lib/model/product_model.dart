class ProductModel {

  final String id;
  final String cartId;
  final String image;
  final String price;
  final String quantity;
  final String name;

  ProductModel({
    required this.id,
    required this.cartId,
    required this.image,
    required this.name,
    required this.quantity,
    required this.price,
  });
}