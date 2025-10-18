import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseExpenseApi {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Fetch all expenses
  Stream<QuerySnapshot> getAllExpenses() {
    return db.collection('expenses').snapshots();
  }

  // Add an expense
  Future<String> addExpense(Map<String, dynamic> expense) async {
    try {
      if (expense['amount'] == null || expense['amount'] < 0) {
        return "Amount must be zero or positive.";
      }

      expense['id'] = db.collection('expenses').doc().id;
      await db.collection('expenses').doc(expense['id']).set(expense);
      return "Successfully added expense!";
    } catch (e) {
      return "Error on ${e.toString()}";
    }
  }

  // Delete an expense
  Future<String> deleteExpense(String id) async {
    try {
      await db.collection('expenses').doc(id).delete();
      return "Successfully deleted expense!";
    } catch (e) {
      return "Error on ${e.toString()}";
    }
  }

  // Edit an expense
  Future<String> editExpense(String id, Map<String, dynamic> updatedExpense) async {
    try {
      if (updatedExpense['amount'] == null || updatedExpense['amount'] < 0) {
        return "Amount must be zero or positive.";
      }

      await db.collection('expenses').doc(id).update(updatedExpense);
      return "Successfully updated expense!";
    } catch (e) {
      return "Error on ${e.toString()}";
    }
  }
}
