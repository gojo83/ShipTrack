import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/geocoding_service.dart';
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
  final _receiverAddrCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _receiverEmailCtrl = TextEditingController();
  final _receiverPhoneCtrl = TextEditingController();
  final _service = FirestoreService();
  final _geo = GeocodingService();

  bool _loading = false;
  bool _validatingReceiver = false;
  String _packageType = 'Documents';
  String _deliveryType = 'Standard';
  double _estimatedCost = 0;
  String _estimatedDelivery = '';

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
      // 1. Validate receiver exists
      setState(() => _validatingReceiver = true);
      final receiver = await _service.findReceiver(
        _receiverEmailCtrl.text,
        _receiverPhoneCtrl.text,
      );
      setState(() => _validatingReceiver = false);

      if (receiver == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receiver not found. Check email and phone number.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _loading = false);
        return;
      }

      // 2. Get coordinates (random demo points)
      final senderCoords = (await _geo.getCoordinates(_senderCtrl.text))!;
      final receiverCoords = (await _geo.getCoordinates(_receiverAddrCtrl.text))!;


      // 3. Calculate distance and ETA
      final distanceKm = _geo.calculateDistanceKm(senderCoords, receiverCoords);
      final eta = _geo.estimateDeliveryTime(distanceKm, _deliveryType);

      // 4. Create shipment
      final shipment = await _service.createShipment(
        userId: widget.userId,
        receiverUserId: receiver.uid,
        receiverEmail: receiver.email,
        receiverPhone: receiver.phone,
        senderAddress: _senderCtrl.text.trim(),
        receiverAddress: _receiverAddrCtrl.text.trim(),
        weight: double.parse(_weightCtrl.text),
        packageType: _packageType,
        deliveryType: _deliveryType,
        estimatedDelivery: eta,
        senderLat: senderCoords.latitude,
        senderLng: senderCoords.longitude,
        receiverLat: receiverCoords.latitude,
        receiverLng: receiverCoords.longitude,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Shipment Created! 🎉'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Tracking ID:'),
            const SizedBox(height: 8),
            Text(shipment.trackingId,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue)),
            const SizedBox(height: 8),
            Text('Cost: ৳${shipment.estimatedCost.toStringAsFixed(0)}'),
            const SizedBox(height: 4),
            Text('ETA: $eta', style: const TextStyle(color: AppColors.green)),
            const SizedBox(height: 4),
            Text('Sending to: ${receiver.name}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
        ),
      );

      _senderCtrl.clear();
      _receiverAddrCtrl.clear();
      _weightCtrl.clear();
      _receiverEmailCtrl.clear();
      _receiverPhoneCtrl.clear();
      setState(() { _estimatedCost = 0; _estimatedDelivery = ''; });

    } catch (e) {
      if (!mounted) return;
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

            // Package type
            const Text('Package Type',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
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
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList()),
            const SizedBox(height: 16),

            // Sender address
            CustomTextField(
              label: 'Sender Address',
              hint: 'e.g. Le Meridien, Dhaka',
              controller: _senderCtrl,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),

            // Receiver address
            CustomTextField(
              label: 'Receiver Address',
              hint: 'e.g. Westin Hotel, Dhaka',
              controller: _receiverAddrCtrl,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),

            // Receiver email
            CustomTextField(
              label: "Receiver's Email (must match their account)",
              hint: 'receiver@email.com',
              controller: _receiverEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),

            // Receiver phone
            CustomTextField(
              label: "Receiver's Phone (must match their account)",
              hint: '+880 1XXXXXXXXX',
              controller: _receiverPhoneCtrl,
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),

            // Weight + delivery type
            Row(children: [
              Expanded(child: CustomTextField(
                label: 'Weight (kg)',
                hint: '2.5',
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
              )),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Delivery Type',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, children: _deliveryTypes.map((type) {
                    final selected = _deliveryType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _deliveryType = type);
                        _updateCost();
                      },
                      selectedColor: AppColors.lightBlue,
                      labelStyle: TextStyle(
                          color: selected ? AppColors.primaryBlue : AppColors.textSecondary),
                    );
                  }).toList()),
                ]),
              ),
            ]),

            const SizedBox(height: 8),

            // Cost display
            GestureDetector(
              onTap: _updateCost,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Estimated Cost',
                      style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.green)),
                  Text('৳ ${_estimatedCost.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                          color: AppColors.green)),
                ]),
              ),
            ),
            TextButton(onPressed: _updateCost, child: const Text('Tap to calculate cost')),

            const SizedBox(height: 12),

            if (_validatingReceiver)
              const Center(child: Text('Verifying receiver…',
                  style: TextStyle(color: AppColors.textSecondary))),

            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                onPressed: _submit,
                child: const Text('Confirm Shipment')),
          ]),
        ),
      ),
    );
  }
}