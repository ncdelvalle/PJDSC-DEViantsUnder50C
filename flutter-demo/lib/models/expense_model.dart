
class Expense {
  final String? id;
  final String name;    
  final String description;  
  final String category;     
  final double amount;      
  final bool paid;     

  // Constructor to initialize all fields
  Expense({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.amount,
    required this.paid,
  });


  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'category': category,
        'amount': amount,
        'paid': paid,
      };

  // Factory constructor to create an Expense object from a Firestore document
  factory Expense.fromFirestore(dynamic doc) {
    final data = doc.data(); // Extract data from the document
    return Expense(
      id: doc.id,                      // Use Firestore document ID as expense ID
      name: data['name'],
      description: data['description'],
      category: data['category'],
      amount: data['amount'],
      paid: data['paid'],
    );
  }

  // Creates a copy of the Expense with a new or existing ID (used for immutability)
  Expense copyWith({String? id}) => Expense(
        id: id ?? this.id,
        name: name,
        description: description,
        category: category,
        amount: amount,
        paid: paid,
      );
}
