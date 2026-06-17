import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/transaction_provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  Stream<List<Map<String, dynamic>>>? _transactionsStream;

  @override
  void initState() {
    super.initState();
    _transactionsStream =
        Provider.of<TransactionProvider>(context, listen: false)
            .getTransactionsStream();
  }

  List<String> get _filterOptions {
    return ['All', 'Stock In', 'Stock Out', 'Adjustment'];
  }

  List<Map<String, dynamic>> _filterTransactions(
      List<Map<String, dynamic>> transactions) {
    var filtered = transactions;

    if (_selectedFilter != 'All') {
      filtered = filtered
          .where((t) => t['transactionType'] == _selectedFilter)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((t) =>
              (t['productName'] as String?)
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              (t['productId'] as String?)
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false)
          .toList();
    }

    return filtered;
  }

  String _formatDate(DateTime date) {
    return '${_monthName(date.month)} ${date.day}, ${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section Two Supermarket - Transactions'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2,
        centerTitle: true,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, _) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _transactionsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final transactions = snapshot.data ?? [];
              final filteredTransactions = _filterTransactions(transactions);

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    color: Colors.grey[200],
                    child: Text(
                      'Total: ${transactions.length} | Shown: ${filteredTransactions.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search transactions...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ..._filterOptions.map((filter) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(filter),
                                selected: _selectedFilter == filter,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                              ),
                            )),
                      ],
                    ),
                  ),
                  Expanded(
                    child: transactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.history,
                                    size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions recorded yet',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                const Text('Try adjusting stock for a product.'),
                              ],
                            ),
                          )
                        : filteredTransactions.isEmpty
                            ? Center(
                                child: Text(
                                  'No transactions match your filters',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                            : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: filteredTransactions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final transaction =
                                  filteredTransactions[index];
                              DateTime? timestamp;
                              if (transaction['timestamp'] is Timestamp) {
                                timestamp = (transaction['timestamp'] as Timestamp).toDate();
                              } else if (transaction['timestamp'] is DateTime) {
                                timestamp = transaction['timestamp'] as DateTime;
                              }

                              final dateStr = timestamp != null
                                  ? _formatDate(timestamp)
                                  : 'N/A';
                              final txnType =
                                  transaction['transactionType'] ?? 'Unknown';
                              final quantity =
                                  transaction['quantityChanged'] ?? 0;
                              final previousQty =
                                  transaction['previousQuantity'] ?? 0;
                              final newQty = transaction['newQuantity'] ?? 0;

                              Color txnColor = Colors.blue;
                              if (txnType == 'Stock In') {
                                txnColor = Colors.green;
                              } else if (txnType == 'Stock Out') {
                                txnColor = Colors.red;
                              }

                              return Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: txnColor,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    transaction['productName'] ?? 'Unknown Product',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    txnType,
                                                    style: TextStyle(
                                                      color: txnColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    dateStr,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '$quantity units',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: txnColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Previous: $previousQty',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          Text(
                                            'New: $newQty',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
