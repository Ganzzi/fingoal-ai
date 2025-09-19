import 'package:flutter/material.dart';
import '../models/rich_message_models.dart';

/// Widget that displays a dashboard item as a removeable chip in the message composer
class DashboardItemChip extends StatelessWidget {
  final DashboardItem item;
  final VoidCallback? onRemove;
  final bool showRemoveButton;

  const DashboardItemChip({
    super.key,
    required this.item,
    this.onRemove,
    this.showRemoveButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Parse color if available
    Color? chipColor;
    if (item.color != null) {
      try {
        chipColor = Color(int.parse(item.color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        chipColor = null;
      }
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      child: Chip(
        avatar: CircleAvatar(
          backgroundColor: chipColor ?? colorScheme.primaryContainer,
          radius: 12,
          child: Icon(
            _getIconData(item.iconName ?? item.type.iconName),
            size: 14,
            color: chipColor != null
                ? _getContrastingTextColor(chipColor)
                : colorScheme.onPrimaryContainer,
          ),
        ),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.title,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        deleteIcon: showRemoveButton
            ? Icon(
                Icons.close,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              )
            : null,
        onDeleted: showRemoveButton ? onRemove : null,
        backgroundColor: colorScheme.surfaceContainer,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  /// Get appropriate icon data from icon name
  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'receipt':
      case 'transaction':
        return Icons.receipt;
      case 'account_balance_wallet':
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'account_balance':
      case 'bank':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      case 'trending_up':
      case 'investment':
        return Icons.trending_up;
      case 'flag':
      case 'goal':
        return Icons.flag;
      case 'analytics':
      case 'analysis':
        return Icons.analytics;
      case 'category':
        return Icons.category;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'home':
        return Icons.home;
      case 'directions_car':
        return Icons.directions_car;
      case 'medical_services':
        return Icons.medical_services;
      case 'school':
        return Icons.school;
      case 'sports_esports':
        return Icons.sports_esports;
      default:
        return Icons.category;
    }
  }

  /// Get contrasting text color for background
  Color _getContrastingTextColor(Color backgroundColor) {
    // Calculate luminance and return black or white for contrast
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Widget that displays multiple dashboard item chips in a wrapping layout
class DashboardItemChipsContainer extends StatelessWidget {
  final List<DashboardItem> items;
  final Function(String)? onRemoveItem;
  final bool showRemoveButtons;
  final EdgeInsets padding;

  const DashboardItemChipsContainer({
    super.key,
    required this.items,
    this.onRemoveItem,
    this.showRemoveButtons = true,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: padding,
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: items.map((item) {
          return DashboardItemChip(
            item: item,
            showRemoveButton: showRemoveButtons,
            onRemove:
                onRemoveItem != null ? () => onRemoveItem!(item.id) : null,
          );
        }).toList(),
      ),
    );
  }
}

/// Dashboard Item Selection Sheet
/// Shows a bottom sheet with dashboard items that can be selected
class DashboardItemSelectionSheet extends StatefulWidget {
  final List<DashboardItem> availableItems;
  final List<String> selectedItemIds;
  final Function(DashboardItem) onItemSelected;

  const DashboardItemSelectionSheet({
    super.key,
    required this.availableItems,
    required this.selectedItemIds,
    required this.onItemSelected,
  });

  @override
  State<DashboardItemSelectionSheet> createState() =>
      _DashboardItemSelectionSheetState();
}

class _DashboardItemSelectionSheetState
    extends State<DashboardItemSelectionSheet> {
  DashboardItemType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Filter items based on selected filter
    final filteredItems = _selectedFilter == null
        ? widget.availableItems
        : widget.availableItems
            .where((item) => item.type == _selectedFilter)
            .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Add Financial Data',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Filter tabs
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All', null, colorScheme),
                const SizedBox(width: 8),
                ...DashboardItemType.values.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child:
                        _buildFilterChip(type.displayName, type, colorScheme),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1),

          // Items list
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items available',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final isSelected =
                          widget.selectedItemIds.contains(item.id);

                      return _buildSelectableItem(
                        item,
                        isSelected,
                        colorScheme,
                        textTheme,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, DashboardItemType? type, ColorScheme colorScheme) {
    final isSelected = _selectedFilter == type;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? type : null;
        });
      },
      backgroundColor: colorScheme.surfaceContainer,
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildSelectableItem(
    DashboardItem item,
    bool isSelected,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isSelected ? colorScheme.primary : colorScheme.primaryContainer,
          child: Icon(
            Icons.receipt,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          item.title,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          item.subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: colorScheme.primary,
              )
            : Icon(
                Icons.add_circle_outline,
                color: colorScheme.onSurfaceVariant,
              ),
        onTap: isSelected
            ? null
            : () {
                widget.onItemSelected(item);
                Navigator.of(context).pop();
              },
      ),
    );
  }
}
