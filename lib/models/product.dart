class Product {
  final int id;
  final String name;
  final double? price;
  final String image;
  int quantity = 0;

  Product(
      {required this.id,
      required this.name,
      required this.price,
      required this.image,
      this.quantity = 1});
}
