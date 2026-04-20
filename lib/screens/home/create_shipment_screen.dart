import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/constants.dart';

class CreateShipmentScreen extends StatefulWidget {
  final String userId;
  const CreateShipmentScreen({super.key, required this.userId});

  @override
  State<CreateShipmentScreen> createState() => _CreateShipmentScreenState();
}

class _CreateShipmentScreenState extends State<CreateShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senderCtrl = TextEditingController();
  final _receiverCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _service = FirestoreService();
  bool _loading = false;
  String _packageType = 'Documents';
  String _deliveryType = 'Standard';
  double _estimatedCost = 0;

  final _packageTypes = ['Documents', 'Parcel', 'Fragile', 'Electronics'];
  final _deliveryTypes = ['Standard', 'Express'];

  void _updateCost() {
    final w = double.tryParse(_weightCtrl.text) ?? 0;
    setState(() => _estimatedCost = _service.calculateCost(w, _deliveryType));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final shipment = await _service.createShipment(
        userId: widget.userId,
        senderAddress: _senderCtrl.text.trim(),
        receiverAddress: _receiverCtrl.text.trim(),
        weight: double.parse(_weightCtrl.text),
        packageType: _packageType,
        deliveryType: _deliveryType,
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Shipment Created! 🎉'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Your tracking ID:'),
            const SizedBox(height: 8),
            Text(shipment.trackingId,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            const SizedBox(height: 8),
            Text('Cost: ৳${shipment.estimatedCost.toStringAsFixed(0)}'),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
        ),
      );
      _senderCtrl.clear(); _receiverCtrl.clear(); _weightCtrl.clear();
      setState(() { _estimatedCost = 0; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Shipment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Package Type', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _packageTypes.map((type) {
              final selected = _packageType == type;
              return ChoiceChip(
                label: Text(type),
                selected: selected,
                onSelected: (_) => setState(() => _packageType = type),
                selectedColor: AppColors.lightBlue,
                labelStyle: TextStyle(
                    color: selected ? AppColors.primaryBlue : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal),
              );
            }).toList()),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Sender Address',
              hint: 'e.g. 12 Mirpur Road, Dhaka',
              controller: _senderCtrl,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            CustomTextField(
              label: 'Receiver Address',
              hint: 'e.g. 45 Agrabad, Chattogram',
              controller: _receiverCtrl,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            CustomTextField(
              label: 'Weight (kg)',
              hint: 'e.g. 2.5',
              controller: _weightCtrl,
              keyboardType: TextInputType.number,
              validator: (v) => (double.tryParse(v ?? '') == null) ? 'Enter valid weight' : null,
            ),
            const Text('Delivery Type', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            const SizedBox(height: 8),
            Row(children: _deliveryTypes.map((type) {
              final selected = _deliveryType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(type),
                  selected: selected,
                  onSelected: (_) { setState(() => _deliveryType = type); _updateCost(); },
                  selectedColor: AppColors.lightBlue,
                  labelStyle: TextStyle(color: selected ? AppColors.primaryBlue : AppColors.textSecondary),
                ),
              );
            }).toList()),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _updateCost,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Estimated Cost', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.green)),
                  Text('৳ ${_estimatedCost.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.green)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _updateCost, child: const Text('Calculate cost first')),
            const SizedBox(height: 12),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(onPressed: _submit, child: const Text('Confirm Shipment')),
          ]),
        ),
      ),
    );
  }
}