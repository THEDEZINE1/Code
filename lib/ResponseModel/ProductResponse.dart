class Product {
  final int id;
  final String partnerName;
  final String name;
  final String modelNo;
  final String image;
  final String mrp;
  final String price;
  final int inCart;
  final bool inWishlist;
  final String unit;
  final String? viewMore;
  final String baseWeight;

  Product({
    required this.id,
    required this.partnerName,
    required this.name,
    required this.modelNo,
    required this.image,
    required this.mrp,
    required this.price,
    required this.inCart,
    required this.inWishlist,
    required this.unit,
    this.viewMore,
    required this.baseWeight,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      partnerName: json['partner_name'],
      name: json['name'],
      modelNo: json['model_no'],
      image: json['image'],
      mrp: json['mrp'],
      price: json['price'],
      inCart: json['in_cart'],
      inWishlist: json['in_wishlist'],
      unit: json['unit'],
      viewMore: json['view_more'],
      baseWeight: json['base_weight'],
    );
  }
}

class Pagination {
  final int count;
  final String nextPage;

  Pagination({
    required this.count,
    required this.nextPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      count: json['count'],
      nextPage: json['next_page'] ?? '',
    );
  }
}

class ProductResponse {
  final String status;
  final int result;
  final String message;
  final List<Product> products;
  final Pagination pagination;

  ProductResponse({
    required this.status,
    required this.result,
    required this.message,
    required this.products,
    required this.pagination,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      status: json['status'],
      result: json['result'],
      message: json['message'],
      products: (json['data']['products'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      pagination: Pagination.fromJson(json['data']['pagination']),
    );
  }
}
