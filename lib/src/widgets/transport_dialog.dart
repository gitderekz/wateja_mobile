import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_client.dart';

class TransportDialog extends StatefulWidget {
  final Map<String, dynamic> order;
  final bool isEditable;
  final VoidCallback? onUpdate;

  const TransportDialog({
    super.key,
    required this.order,
    this.isEditable = false,
    this.onUpdate,
  });

  @override
  State<TransportDialog> createState() => _TransportDialogState();
}

class _TransportDialogState extends State<TransportDialog> {
  late bool _isTransporting;
  late TextEditingController _feeController;
  late TextEditingController _driverNameController;
  late TextEditingController _driverPhoneController;
  late String _transportStatus;
  late TextEditingController _transportTypeController;
  late TextEditingController _plateNumber1Controller;
  late TextEditingController _plateNumber2Controller;

  bool _loading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isTransporting = widget.order['isTransporting'] ?? false;
    _transportStatus = widget.order['transportationStatus'] ?? 'pending';
    var fee = widget.order['transportFee'];
    if (fee is String) fee = double.tryParse(fee) ?? 0;
    _feeController = TextEditingController(text: (fee ?? 0).toString());
    _driverNameController = TextEditingController(text: widget.order['driverName'] ?? '');
    _driverPhoneController = TextEditingController(text: widget.order['driverPhone'] ?? '');

    final details = (widget.order['transportDetails'] is String
        ? jsonDecode(widget.order['transportDetails'])
        : widget.order['transportDetails']) as Map<String, dynamic>?;

    _transportTypeController = TextEditingController(text: details?['transportType'] ?? '');
    _plateNumber1Controller = TextEditingController(text: details?['plateNumber1'] ?? '');
    _plateNumber2Controller = TextEditingController(text: details?['plateNumber2'] ?? '');
  }

  @override
  void dispose() {
    _feeController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _transportTypeController.dispose();
    _plateNumber1Controller.dispose();
    _plateNumber2Controller.dispose();
    super.dispose();
  }

  Future<void> _saveTransport() async {
    setState(() => _loading = true);
    try {
      final fee = double.tryParse(_feeController.text) ?? 0;
      final orderId = widget.order['id'] ?? widget.order['_id'];

      final body = {
        'isTransporting': _isTransporting,
        'transportFee': fee,
        'driverName': _driverNameController.text,
        'driverPhone': _driverPhoneController.text,
        'transportationStatus': _transportStatus,
        'transportDetails': {
          'transportType': _transportTypeController.text,
          'plateNumber1': _plateNumber1Controller.text,
          'plateNumber2': _plateNumber2Controller.text,
        },
      };

      final client = ApiClient();
      final resp = await client.put('/orders/$orderId/transport', body: body);

      if (resp.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transport details updated')),
        );
        widget.onUpdate?.call();
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update transport details')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.isEditable && !_loading;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Transport Details'),
          if (canEdit)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current status
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transporting: ${_isTransporting ? 'Yes' : 'No'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status: ${_transportStatus.toUpperCase()}'),
                        if (_isEditing)
                          DropdownButton<String>(
                            value: _transportStatus,
                            items: const [
                              DropdownMenuItem(value: 'pending', child: Text('Pending')),
                              DropdownMenuItem(value: 'onTransit', child: Text('On Transit')),
                              DropdownMenuItem(value: 'arrived', child: Text('Arrived')),
                            ],
                            onChanged: (v) => setState(() => _transportStatus = v ?? 'pending'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Transport Fee
            TextField(
              controller: _feeController,
              enabled: _isEditing,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Transport Fee',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Driver Info
            TextField(
              controller: _driverNameController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Driver Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _driverPhoneController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Driver Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Transport Details
            const Text('Vehicle Details', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            TextField(
              controller: _transportTypeController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Transport Type',
                hintText: 'e.g., Truck, Van, Motorcycle',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _plateNumber1Controller,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Plate Number 1',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _plateNumber2Controller,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Plate Number 2 (Optional)',
                border: OutlineInputBorder(),
              ),
            ),

            // Location info for reference
            if ((widget.order['region'] ?? '').toString().isNotEmpty ||
                (widget.order['district'] ?? '').toString().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text('Delivery Location', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.order['region'] ?? ''}, ${widget.order['district'] ?? ''}, ${widget.order['townVillage'] ?? ''}',
                  ),
                  if ((widget.order['street'] ?? '').toString().isNotEmpty)
                    Text('${widget.order['street'] ?? ''} ${widget.order['houseNumber'] ?? ''}'),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (_isEditing && canEdit)
          ElevatedButton(
            onPressed: _loading ? null : _saveTransport,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
      ],
    );
  }
}
