

import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';


class ExpenseModal extends StatefulWidget {
  final String type; // Determines whether it's Add, Edit, or Delete
  final Expense? expense; 

  const ExpenseModal({
    super.key,
    required this.type,
    this.expense,
  });

  @override
  State<ExpenseModal> createState() => _ExpenseModalState();
}

class _ExpenseModalState extends State<ExpenseModal> {
  // Text controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _category; 
  bool _paid = false; 
  final _formKey = GlobalKey<FormState>(); 

  @override
  void initState() {
    super.initState();
    // If editing, pre-fill the form fields with existing expense data
    if (widget.expense != null) {
      _nameController.text = widget.expense!.name;
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _category = widget.expense!.category;
      _paid = widget.expense!.paid;
    }
  }

  // Return a title widget based on the modal type
  Text _buildTitle() {
    switch (widget.type) {
      case 'Add':
        return const Text("Add New Expense");
      case 'Edit':
        return const Text("Edit Expense");
      case 'Delete':
        return const Text("Delete Expense");
      default:
        return const Text("");
    }
  }

  // Build modal content depending on action type
  Widget _buildContent(BuildContext context) {
    // For deleting, just show a confirmation message
    if (widget.type == 'Delete') {
      return Text("Are you sure you want to delete '${widget.expense!.name}'?");
    }

    // For adding/editing, show a form
    return SizedBox(
      width: 300,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Input field for name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Expense Name'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Enter an Expense Name first.' : null,
            ),
            // Input field for description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Add a Description.' : null,
            ),
            // Input field for amount
            // Amount input field
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter the amount.';
                final parsed = int.tryParse(value);
                if (parsed == null) return 'Enter a VALID amount only.';
                if (parsed < 0) return 'Amount cannot be negative.';
                return null;
              },
            ),
            // Dropdown for category selection
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Select Category'),
              items: <String>[
                'Bills',
                'Transportation',
                'Food',
                'Utilities',
                'Health',
                'Entertainment',
                'Miscellaneous'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _category = newValue;
                });
              },
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please select a category.' : null,
            ),
            // Checkbox for paid status
            CheckboxListTile(
              title: const Text('Paid'),
              value: _paid,
              onChanged: (bool? value) {
                setState(() {
                  _paid = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          ],
        ),
      ),
    );
  }

  TextButton _dialogAction(BuildContext context) {
    return TextButton(
      onPressed: () {
        final expenseProvider = context.read<ExpenseListProvider>();
        final userProvider = context.read<UserAuthProvider>();

        final userId = userProvider.user?.uid;
        if (userId == null) {
          // Show a message if the user is not logged in
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User not authenticated.")),
          );
          return;
        }

        // If the user confirms deletion
        if (widget.type == 'Delete') {
          if (widget.expense != null) {
            expenseProvider.deleteExpense(widget.expense!.id!);
          }
          Navigator.of(context).pop();
        } else {
          // Validate form before proceeding
          if (_formKey.currentState!.validate()) {
            final newExpense = Expense(
              name: _nameController.text,
              description: _descriptionController.text,
              category: _category!,
              amount: double.parse(_amountController.text),
              paid: _paid,
            );

            if (widget.type == 'Add') {
              expenseProvider.addExpense(newExpense, userId);
            } else if (widget.type == 'Edit') {
              expenseProvider.editExpense(widget.expense!.id!, newExpense.toJson());
            }

            Navigator.of(context).pop();
          }
        }
      },
      child: Text(widget.type), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(), 
      content: _buildContent(context),
      actions: [
        _dialogAction(context), 
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
