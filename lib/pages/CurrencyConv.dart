import 'package:flutter/material.dart';
import 'package:firebase_performance/firebase_performance.dart'; // Import Firebase Performance Monitoring
import 'package:useraccount/components/anyToAny.dart';
import 'package:useraccount/functions/fetchrates.dart';
import 'package:useraccount/models/ratesmodel.dart';

class CurrencyConv extends StatefulWidget {
  const CurrencyConv({Key? key}) : super(key: key);

  @override
  _CurrencyFormState createState() => _CurrencyFormState();
}

class _CurrencyFormState extends State<CurrencyConv> {
  late Future<RatesModel> result;
  late Future<Map> allcurrencies;
  final formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      result = fetchrates();
      allcurrencies = fetchcurrencies();
    });
    _startPerformanceMonitoring(); // Start Performance Monitoring
  }

  // Function to start performance monitoring trace
  void _startPerformanceMonitoring() async {
    final Trace currencyConversionTrace =
        FirebasePerformance.instance.newTrace("CurrencyConversion_Performance");
    currencyConversionTrace.start(); // Start the trace

    // Stop the trace when the data is fully loaded
    await Future.wait([result, allcurrencies]);
    currencyConversionTrace.stop(); // Stop the trace
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Wrap with SingleChildScrollView
      child: Container(
        padding: EdgeInsets.all(10),
        color: Color(0xFF182727), // Set the background color to #758d7f
        child: Form(
          key: formkey,
          child: FutureBuilder<RatesModel>(
            future: result,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              return Center(
                child: FutureBuilder<Map>(
                  future: allcurrencies,
                  builder: (context, currSnapshot) {
                    if (currSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnyToAny(
                          currencies: currSnapshot.data!,
                          rates: snapshot.data!.rates,
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
