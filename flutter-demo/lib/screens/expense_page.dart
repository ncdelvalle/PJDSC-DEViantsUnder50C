import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';
import 'modal_expense.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  bool _isLoaded = false; // Tracks if expenses have already been loaded

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load expenses once the user is signed in
    if (!_isLoaded) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<ExpenseListProvider>().loadExpenses();
        _isLoaded = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Expense> expenses = context.watch<ExpenseListProvider>().expenses;

    return Scaffold(
          // Custom AppBar with purple background and white, bold title
          appBar: AppBar(
            title: const Text(
              "My Expenses",
              style: TextStyle(
                color: Colors.white,  
                fontWeight: FontWeight.bold,  
              ),
            ),
            backgroundColor: Colors.purple, 
            actions: [
              // Logout button in app bar
              ElevatedButton.icon(
                onPressed: () => context.read<UserAuthProvider>().signOut(),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ],
          ),

      // Show message if no expenses, otherwise show list
      body: expenses.isEmpty
          ? const Center(
              child: Text("No Expenses Found. Click the button to add!"),
            )
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                Expense expense = expenses[index];

                return Dismissible(
                  key: Key(expense.id.toString()),
                  onDismissed: (direction) {
                    // Delete expense on swipe
                    context.read<ExpenseListProvider>().deleteExpense(expense.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${expense.name} dismissed')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete),
                  ),
                  child: ListTile(
                    // Expense name as the title
                    title: Text(
                      expense.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show amount and category
                        Text('₱${expense.amount.toStringAsFixed(2)} - ${expense.category}'),
                        Row(
                          children: [
                            // Show check or cancel icon based on paid status
                            Icon(
                              expense.paid ? Icons.check_circle : Icons.cancel,
                              color: expense.paid ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            // Show "Paid" or "Not Paid" 
                            Text(
                              expense.paid ? 'Paid' : 'Not Paid',
                              style: TextStyle(
                                color: expense.paid ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Show expense details on tap
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Expense Details'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${expense.name}'),
                              Text('Description: ${expense.description}'),
                              Text('Category: ${expense.category}'),
                              Text('Amount: ₱${expense.amount.toStringAsFixed(2)}'),
                              Text('Status: ${expense.paid ? 'Paid' : 'Not Paid'}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    // Edit and delete buttons
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  ExpenseModal(type: 'Edit', expense: expense),
                            );
                          },
                          icon: const Icon(Icons.create_outlined),
                        ),
                        // Delete button opens modal in 'Delete' mode
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  ExpenseModal(type: 'Delete', expense: expense),
                            );
                          },
                          icon: const Icon(Icons.delete_outlined),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      // Floating button to add a new expense
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => const ExpenseModal(type: 'Add'),
          );
        },
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
