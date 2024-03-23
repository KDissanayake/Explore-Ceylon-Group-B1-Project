import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:useraccount/components/appbar.dart';


class Expense {
  final String name;
  final double amount;

  Expense({required this.name, required this.amount});
}

class BudgetTrackerPage extends StatefulWidget {
  @override
  _BudgetTrackerPageState createState() => _BudgetTrackerPageState();
}

class _BudgetTrackerPageState extends State<BudgetTrackerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? currentUser;
  double totalBudget = 0;
  double totalUsed = 0;
  List<Expense> expenses = [];
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController expenseAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setUser(user);
    });
  }

  void setUser(User? user) {
    currentUser = user;
    loadData();
  }

  void loadData() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot snapshot =
            await _firestore.collection('Budget').doc(currentUser!.uid).get();

        if (snapshot.exists) {
          setState(() {
            totalBudget = snapshot['totalBudget'];
            totalUsed = snapshot['totalUsed'];
            expenses = List<Expense>.from(snapshot['expenses'].map(
              (expense) => Expense(
                name: expense['name'],
                amount: expense['amount'],
              ),
            ));
          });
        }
      } catch (error) {
        print("Error loading data: $error");
      }
    }
  }

  void setTotalBudget(double budget) {
    setState(() {
      totalBudget = budget;
      storeData();
    });
  }

  void addExpense(Expense expense) {
    if (totalBudget - expense.amount >= 0) {
      setState(() {
        expenses.add(expense);
        totalBudget -= expense.amount;
        totalUsed += expense.amount;
        storeData();
      });
    } else {
      // Show a pop-up dialog if the expense surpasses the budget
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Budget Exceeded", style: TextStyle(color: Colors.white)),
          content: Text("You have surpassed your budget.",
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  Future<void> storeData() async {
    try {
      await _firestore.collection('Budget').doc(currentUser!.uid).set({
        'totalBudget': totalBudget,
        'totalUsed': totalUsed,
        'expenses':
            expenses.map((e) => {'name': e.name, 'amount': e.amount}).toList(),
      });
    } catch (error) {
      print("Error storing data: $error");
    }
  }

  void deleteExpense(int index) {
    setState(() {
      totalBudget += expenses[index].amount;
      totalUsed -= expenses[index].amount;
      expenses.removeAt(index);
      storeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight * 1.5),
        child: CustomAppBarWithProfile(
          context: context,
          height: kToolbarHeight * 1.5, // Define the height of the app bar
        ),
      ),
      body: Container(
        color: Color(0xFF182727),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(20.0),
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color(0xFF456461),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Budget: $totalBudget',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Total Budget',
                    labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final budget = double.tryParse(budgetController.text) ?? 0;
                    if (budget > 0) {
                      setTotalBudget(budget);
                      budgetController.clear();
                    }
                  },
                  child: Text(
                    'Set Total Budget',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: expenseNameController,
                  decoration: InputDecoration(
                    labelText: 'Expense Name',
                    labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
                TextField(
                  controller: expenseAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Expense Amount',
                    labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = expenseNameController.text;
                    final amount =
                        double.tryParse(expenseAmountController.text) ?? 0;

                    if (name.isNotEmpty && amount > 0) {
                      final expense = Expense(name: name, amount: amount);
                      addExpense(expense);
                      expenseNameController.clear();
                      expenseAmountController.clear();
                    }
                  },
                  child: Text(
                    'Add Expense',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Dismissible(
                        key: Key(expense.name),
                        background: Container(
                          color: Color.fromARGB(255, 148, 15, 5),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20.0),
                        ),
                        onDismissed: (direction) {
                          deleteExpense(index);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 89, 187, 126),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            title: Text(expense.name,
                                style: TextStyle(color: Colors.white)),
                            subtitle: Text(
                                '\$${expense.amount.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Total Used: ${totalUsed.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar: CustomNavBar.CustomBottomNavigationBar(
      //   currentIndex: 2,
      //   onTap: (index) {},
      // ),
    );
  }
}

class MyBudgetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: FirebaseAuth.instance.authStateChanges(),
      initialData: null,
      child: MaterialApp(
        title: 'Budget App',
        theme: ThemeData(
          primaryColor: Colors.green,
          scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Colors.greenAccent,
          ),
        ),
        home: BudgetTrackerPage(),
      ),
    );
  }
}

void main() => runApp(MyBudgetApp());
