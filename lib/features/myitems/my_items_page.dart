import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/notifiers/items_notifier.dart';
import '../../data/models/my_item.dart';

class MyItemsPage extends StatefulWidget {
  const MyItemsPage({super.key});

  @override
  State<MyItemsPage> createState() => _MyItemsPageState();
}

class _MyItemsPageState extends State<MyItemsPage> {
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final notifier = scope.itemsNotifier;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('my_items'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final item = await showModalBottomSheet<MyItem>(
            context: context,
            isScrollControlled: true,
            builder: (context) => _ItemEditor(),
          );
          if (item != null) {
            setState(() => notifier.add(item));
          }
        },
        child: const Icon(Icons.add),
      ),
      body: AnimatedBuilder(
        animation: notifier,
        builder: (context, child) {
          if (notifier.myItems.isEmpty) {
            return Center(child: Text(l10n.t('no_results')));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: notifier.myItems.length,
            itemBuilder: (context, index) {
              final item = notifier.myItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(backgroundImage: NetworkImage(item.photos.first), radius: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                                Text('${item.specs.brand} · ${item.specs.year}'),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              final updated = await showModalBottomSheet<MyItem>(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => _ItemEditor(item: item),
                              );
                              if (updated != null) {
                                setState(() => notifier.update(updated));
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => setState(() => notifier.remove(item.id)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('${l10n.t('tips')}: ${item.tips.join(', ')}'),
                      const SizedBox(height: 8),
                      Text('Status: ${item.status}'),
                      if (item.wantedPrice != null) Text('${l10n.t('wanted_price')}: USD ${item.wantedPrice!.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ItemEditor extends StatefulWidget {
  const _ItemEditor({this.item});

  final MyItem? item;

  @override
  State<_ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends State<_ItemEditor> {
  late TextEditingController _title;
  late TextEditingController _brand;
  late TextEditingController _year;
  late TextEditingController _notes;
  late TextEditingController _photo;
  late TextEditingController _tips;
  late TextEditingController _price;
  bool _forSale = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _title = TextEditingController(text: item?.title ?? '');
    _brand = TextEditingController(text: item?.specs.brand ?? '');
    _year = TextEditingController(text: item?.specs.year.toString() ?? '2020');
    _notes = TextEditingController(text: item?.specs.notes ?? '');
    _photo = TextEditingController(text: item?.photos.first ?? 'https://picsum.photos/seed/myitem/800/600');
    _tips = TextEditingController(text: item?.tips.join(', ') ?? '');
    _price = TextEditingController(text: item?.wantedPrice?.toString() ?? '');
    _forSale = item?.forSale ?? false;
  }

  @override
  void dispose() {
    for (final controller in [_title, _brand, _year, _notes, _photo, _tips, _price]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('add_item'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _brand, decoration: InputDecoration(labelText: 'Brand')),
            TextField(controller: _year, decoration: InputDecoration(labelText: 'Year'), keyboardType: TextInputType.number),
            TextField(controller: _notes, decoration: InputDecoration(labelText: l10n.t('tips'))),
            TextField(controller: _photo, decoration: const InputDecoration(labelText: 'Image URL')),
            TextField(controller: _tips, decoration: const InputDecoration(labelText: 'Tips comma separated')),
            SwitchListTile(
              title: Text(l10n.t('for_sale_now')),
              value: _forSale,
              onChanged: (value) => setState(() => _forSale = value),
            ),
            if (_forSale)
              TextField(
                controller: _price,
                decoration: InputDecoration(labelText: l10n.t('wanted_price')),
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final item = MyItem(
                    id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _title.text,
                    photos: [_photo.text],
                    specs: MyItemSpecs(
                      condition: 'Good',
                      brand: _brand.text,
                      year: int.tryParse(_year.text) ?? 2020,
                      notes: _notes.text,
                    ),
                    forSale: _forSale,
                    wantedPrice: _forSale ? double.tryParse(_price.text) : null,
                    tips: _tips.text.split(',').map((e) => e.trim()).where((element) => element.isNotEmpty).toList(),
                    status: _forSale ? 'listed' : 'waiting_offers',
                  );
                  Navigator.of(context).pop(item);
                },
                child: Text(l10n.t('save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
