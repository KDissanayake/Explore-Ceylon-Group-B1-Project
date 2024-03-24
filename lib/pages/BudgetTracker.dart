import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_performance/firebase_performance.dart';
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

  final FirebasePerformance performance = FirebasePerformance.instance;

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
    final Trace trace = performance.newTrace('Budget_store_data');
    trace.start();

    try {
      await _firestore.collection('Budget').doc(currentUser!.uid).set({
        'totalBudget': totalBudget,
        'totalUsed': totalUsed,
        'expenses':
            expenses.map((e) => {'name': e.name, 'amount': e.amount}).toList(),
      });
    } catch (error) {
      print("Error storing data: $error");
    } finally {
      trace.stop();
    }
  }

  void deleteExpense(int index) {
    setState(() {
      totalBudget += expenses[index]
          .amount; // Add the expense amount back to the total budget
      totalUsed -= expenses[index]
          .amount; // Subtract the expense amount from the total used
      expenses.removeAt(index);
      storeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF456461),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight * 1.5),
        child: CustomAppBarWithProfile(
          context: context,
          height: kToolbarHeight * 1.5, // Define the height of the app bar
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          // Wrap your body with SingleChildScrollView
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF182727),
              borderRadius:
                  BorderRadius.circular(20.0), // Adjust the value as needed
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF182727),
                    borderRadius: BorderRadius.circular(40.0), // Curved edge
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: totalBudget > 0
                        ? LinearProgressIndicator(
                            value: totalUsed / totalBudget,
                            backgroundColor: Colors.grey[400],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              getProgressColor(totalUsed /
                                  totalBudget), // Determine color dynamically
                            ),
                            minHeight: 20,
                          )
                        : SizedBox(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total Budget: $totalBudget',
                        style: TextStyle(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: budgetController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontFamily: 'Poppins',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Enter Total Budget',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontFamily: 'Poppins',
                          ),
                          hintStyle: TextStyle(),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final budget =
                              double.tryParse(budgetController.text) ?? 0;
                          if (budget > 0) {
                            setTotalBudget(budget);
                            budgetController.clear();
                          }
                        },
                        child: Text(
                          'Set Total Budget',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: expenseNameController,
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontFamily: 'Poppins',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Expense Name',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      TextField(
                        controller: expenseAmountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontFamily: 'Poppins',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Expense Amount',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final name = expenseNameController.text;
                          final amount =
                              double.tryParse(expenseAmountController.text) ??
                                  0;

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
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 200, // Limit the height of the ListView
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
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ListTile(
                                  title: Text(
                                    expense.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  subtitle: Text(
                                    '\$${expense.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
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
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom,
                        // Adjust the height to the height of the keyboard
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color getProgressColor(double value) {
    if (value < 0.5) {
      return Colors.green; // Green if below 50%
    } else if (value >= 0.5 && value < 0.8) {
      return Colors.orange; // Orange if between 50% and 80%
    } else {
      return Colors.red; // Red if above 80%
    }
  }
}
