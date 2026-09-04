import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_client.dart';

class AgentAssignmentDialog extends StatefulWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onUpdate;

  const AgentAssignmentDialog({
    super.key,
    required this.order,
    this.onUpdate,
  });

  @override
  State<AgentAssignmentDialog> createState() => _AgentAssignmentDialogState();
}

class _AgentAssignmentDialogState extends State<AgentAssignmentDialog> {
  List<Map<String, dynamic>> agents = [];
  String? _selectedAgentId;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedAgentId = (widget.order['assignedAgentId'] ?? null)?.toString();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    setState(() => _loading = true);
    try {
      final client = ApiClient();
      final resp = await client.get('/users?role=agent');
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final parsed = jsonDecode(resp.body);
        List<dynamic> list = [];
        if (parsed is Map && parsed['users'] is List) {
          list = parsed['users'];
        } else if (parsed is List) {
          list = parsed;
        }
        agents = list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading agents: $e')),
        );
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _assignAgent() async {
    if (_selectedAgentId == null) return;

    setState(() => _saving = true);
    try {
      final orderId = widget.order['id'] ?? widget.order['_id'];
      final body = {'assignedAgentId': int.tryParse(_selectedAgentId!)};

      final client = ApiClient();
      final resp = await client.put('/orders/$orderId', body: body);

      if (resp.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agent assigned successfully')),
        );
        widget.onUpdate?.call();
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to assign agent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Agent'),
      content: _loading
          ? const Center(child: CircularProgressIndicator())
          : agents.isEmpty
              ? const Center(child: Text('No agents available'))
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Select an agent to assign to this order:'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 300,
                        child: ListView(
                          children: agents
                              .map(
                                (agent) => RadioListTile<String>(
                                  title: Text(agent['name'] ?? 'Unknown'),
                                  subtitle: Text(agent['email'] ?? ''),
                                  value: agent['id'].toString(),
                                  groupValue: _selectedAgentId,
                                  onChanged: (value) {
                                    setState(() => _selectedAgentId = value);
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.order['assignedAgentId'] != null)
                        Chip(
                          label: Text(
                            'Currently assigned: ${widget.order['assignedAgentName'] ?? 'Unknown'}',
                          ),
                          backgroundColor: Colors.blue.shade100,
                        ),
                    ],
                  ),
                ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedAgentId == null || _saving ? null : _assignAgent,
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Assign'),
        ),
      ],
    );
  }
}
