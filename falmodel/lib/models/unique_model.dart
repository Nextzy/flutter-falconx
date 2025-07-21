import 'package:falmodel/lib.dart';

/// A model that has a unique identifier.
/// 
/// Extends [BaseModel] to provide a unique [id] field that is automatically
/// generated using UUID v4 if not provided.
/// 
/// Example:
/// ```dart
/// class Product extends UniqueModel<Product> {
///   const Product({
///     required super.id,
///     required this.name,
///     required this.price,
///   });
///   
///   final String name;
///   final double price;
///   
///   @override
///   Product copyWith({String? id, String? name, double? price}) {
///     return Product(
///       id: id ?? this.id,
///       name: name ?? this.name,
///       price: price ?? this.price,
///     );
///   }
///   
///   @override
///   List<Object?> get props => [id, name, price];
/// }
/// ```
abstract class UniqueModel<T> extends BaseModel<T> {
  /// Creates a model with a unique identifier.
  /// 
  /// If [id] is not provided, a new UUID v4 will be generated.
  UniqueModel({String? id}) : id = id ?? UuidGenerator.getV4();

  /// The unique identifier for this model instance.
  final String id;

  @override
  List<Object?> get props => [id];
}
