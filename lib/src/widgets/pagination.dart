import 'package:flutter/material.dart';

class Pagination extends StatefulWidget {
  final int page;
  final int totalPages;
  final void Function(int) onPage;
  const Pagination({super.key, required this.page, required this.totalPages, required this.onPage});

  @override
  State<Pagination> createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  late TextEditingController _jumpController;

  @override
  void initState() {
    super.initState();
    _jumpController = TextEditingController(text: widget.page.toString());
  }

  @override
  void didUpdateWidget(Pagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      _jumpController.text = widget.page.toString();
    }
  }

  @override
  void dispose() {
    _jumpController.dispose();
    super.dispose();
  }

  void _jumpToPage() {
    final input = int.tryParse(_jumpController.text);
    if (input != null && input > 0 && input <= widget.totalPages) {
      widget.onPage(input);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a page between 1 and ${widget.totalPages}')),
      );
    }
  }

  List<int> _getPageNumbers() {
    final pages = <int>[];
    const maxDisplay = 5;
    
    if (widget.totalPages <= maxDisplay) {
      for (int i = 1; i <= widget.totalPages; i++) {
        pages.add(i);
      }
    } else {
      pages.add(1);
      
      int start = (widget.page - 1).clamp(2, widget.totalPages - 3);
      int end = (widget.page + 1).clamp(3, widget.totalPages - 2);
      
      if (start > 2) pages.add(-1); // ellipsis
      for (int i = start; i <= end; i++) {
        pages.add(i);
      }
      if (end < widget.totalPages - 1) pages.add(-1); // ellipsis
      
      pages.add(widget.totalPages);
    }
    
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final pageNumbers = _getPageNumbers();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: widget.page > 1 ? () => widget.onPage(widget.page - 1) : null,
                ),
                ...pageNumbers.map((p) {
                  if (p == -1) {
                    return const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('...'));
                  }
                  
                  final isActive = p == widget.page;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      color: isActive ? Colors.green.shade600 : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        onTap: () => widget.onPage(p),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Text(
                            p.toString(),
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.black,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: widget.page < widget.totalPages ? () => widget.onPage(widget.page + 1) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Page ${widget.page} of ${widget.totalPages}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Jump to Page'),
                content: TextField(
                  controller: _jumpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter page number (1-${widget.totalPages})',
                    border: const OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  ElevatedButton(onPressed: _jumpToPage, child: const Text('Jump')),
                ],
              ),
            ),
            icon: const Icon(Icons.search),
            label: const Text('Jump to Page'),
          ),
        ],
      ),
    );
  }
}
