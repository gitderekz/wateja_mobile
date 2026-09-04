import 'package:flutter/material.dart';
import '../services/api_client.dart';

class AppointmentDialog extends StatefulWidget {
  final Map<String, dynamic> order;
  final bool isEditable;
  final VoidCallback? onUpdate;

  const AppointmentDialog({
    super.key,
    required this.order,
    this.isEditable = false,
    this.onUpdate,
  });

  @override
  State<AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<AppointmentDialog> {
  late DateTime? _selectedDate;
  late String _consultationType;
  late String _subscriptionMonths;
  bool _loading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final dateStr = widget.order['appointmentDate'];
    _selectedDate = dateStr != null ? DateTime.tryParse(dateStr.toString()) : null;
    _consultationType = widget.order['consultationType'] ?? 'online';
    _subscriptionMonths = (widget.order['subscriptionMonths'] ?? 1).toString();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveAppointment() async {
    setState(() => _loading = true);
    try {
      final orderId = widget.order['id'] ?? widget.order['_id'];
      final body = {
        'appointmentDate': _selectedDate?.toIso8601String(),
        'consultationType': _consultationType,
        'subscriptionMonths': int.tryParse(_subscriptionMonths) ?? 1,
      };

      final client = ApiClient();
      final resp = await client.put('/orders/$orderId', body: body);

      if (resp.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment details updated')),
        );
        widget.onUpdate?.call();
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update appointment')),
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
          const Text('Appointment Details'),
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
            // Consultation Type
            const Text('Consultation Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (!_isEditing)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(_consultationType.toUpperCase()),
                ),
              )
            else
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'online', label: Text('Online')),
                  ButtonSegment(value: 'field', label: Text('Field Visit')),
                ],
                selected: {_consultationType},
                onSelectionChanged: (s) => setState(() => _consultationType = s.first),
              ),
            const SizedBox(height: 16),

            // Appointment Date
            const Text('Appointment Date', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              color: Colors.blue.shade50,
              child: ListTile(
                title: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                      : 'No date selected',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _isEditing ? _selectDate : null,
              ),
            ),
            const SizedBox(height: 16),

            // Subscription Months (for consultation packages)
            const Text('Duration (Months)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (!_isEditing)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('$_subscriptionMonths month(s)'),
                ),
              )
            else
              DropdownButton<String>(
                isExpanded: true,
                value: _subscriptionMonths,
                items: List.generate(12, (i) => (i + 1).toString())
                    .map((m) => DropdownMenuItem(value: m, child: Text('$m month(s)')))
                    .toList(),
                onChanged: (v) => setState(() => _subscriptionMonths = v ?? '1'),
              ),

            // Order Info Summary
            const SizedBox(height: 16),
            const Text('Order Info', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if ((widget.order['orderType'] ?? '').toString().isNotEmpty)
              Text('Type: ${widget.order['orderType']?.toString().toUpperCase() ?? '—'}'),
            if ((widget.order['items'] as List<dynamic>? ?? []).isNotEmpty)
              Text('Items: ${widget.order['items'].length}'),
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
            onPressed: _loading ? null : _saveAppointment,
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
