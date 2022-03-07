import './map_types.dart';

class Item {
  static final Item noItem = Item.none();

  final ItemCategory category;
  final ItemType type;

  Item(this.type, this.category);

  Item.none()
      : category = ItemCategory.none,
        type = ItemType.none;
}
