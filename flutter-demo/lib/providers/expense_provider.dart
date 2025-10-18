import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class ExpenseListProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance; 
  List<Expense> _expenses = []; // Internal list of expenses

  // Getter to expose the private for _expenses list
  List<Expense> get expenses => _expenses;

  // Loads all expenses associated with the currently authenticated user
  Future<void> loadExpenses() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await _db
        .collection('expenses')
        .where('uid', isEqualTo: uid)
        .get();

    // Convert documents to Expense objects
    _expenses = snapshot.docs
        .map((doc) => Expense.fromFirestore(doc))
        .toList();

    notifyListeners(); 
  }

  // Adds a new expense to Firestore and updates the local list
  Future<void> addExpense(Expense expense, String userId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid; 
    if (uid == null) return;

  Map<String, dynamic> expenseData = expense.toJson();
  expenseData['uid'] = uid;

  // Add the expense data to the 'expenses' collection in Firestore
  final docRef = await _db.collection('expenses').add(expenseData);

    // Add the newly created expense
    _expenses.add(expense.copyWith(id: docRef.id));
    notifyListeners();
  }

  Future<void> editExpense(String id, Map<String, dynamic> data) async {
    await _db.collection('expenses').doc(id).update(data); 
    await loadExpenses();
  }

  // Deletes an expense
  Future<void> deleteExpense(String id) async {
    await _db.collection('expenses').doc(id).delete(); // Delete from Firestore
    _expenses.removeWhere((e) => e.id == id); // Remove locally
    notifyListeners(); 
  }
}
