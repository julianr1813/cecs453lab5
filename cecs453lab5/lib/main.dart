import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = await SharedPreferences.getInstance();
  final mortgage = Mortgage(data);

  runApp(
    ChangeNotifierProvider.value(value: mortgage, child: const MyApp(),
    ),
  );
}

class Mortgage extends ChangeNotifier {
  final SharedPreferences _data;

  late double _amount;
  late int _years;
  late double _rate;

  Mortgage(this._data) {
    _amount = _data.getDouble('amount') ?? 100000;
    _years = _data.getInt('years') ?? 30;
    _rate = _data.getDouble('rate') ?? 0.035;

  }

  void setAmount(double newamount) {
    if (newamount >= 0){
      _amount = newamount;
      _data.setDouble('amount', _amount);
      notifyListeners();
    }
  }

  void setYears(int newyears) {
    if (newyears >= 0) {
      _years = newyears;
      _data.setInt('years', _years);
      notifyListeners();
    }
  }

  void setRate(double newrate) {
    if (newrate >= 0) {
      _rate = newrate;
      _data.setDouble('rate', _rate);
      notifyListeners();
    }
  }

  double getAmount() {
    return _amount;
  }

  int getYears() {
    return _years;
  }

  double getRate() {
    return _rate;
  }

  double monthlyPayment() {
    double r = _rate / 12;
    int n = _years * 12;
    return (_amount * r * pow(1 + r, n)) /  (pow(1 + r, n) - 1);
  }

  double totalPayment() {
    return monthlyPayment() * _years * 12;
  }

}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MortgageCalculator(),
    );
  }
}

 
class MortgageCalculator extends StatefulWidget {
  const MortgageCalculator({super.key});
 
  @override
  State<MortgageCalculator> createState() => _MortgageCalculatorState();
}
 
class _MortgageCalculatorState extends State<MortgageCalculator> {
  bool _terms = false;

  @override
  Widget build(BuildContext context) {
    final mortgage = context.watch<Mortgage>();
    final percent = (mortgage.getRate() * 100).toStringAsFixed(2);
    return Scaffold(
      appBar: AppBar(title: Text("Mortgage Calculator")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Row(
            children: [
              Container(width: 200, child: Center(child: Text("Amount: ", style: TextStyle(fontSize:20)))),
              Container(width: 200, child: Center(child: Text("\$${mortgage.getAmount().toStringAsFixed(2)}", style: TextStyle(fontSize:20))))
            ]
          ),
          Row(
            children: [
              Container(width: 200, child: Center(child: Text("Years: ", style: TextStyle(fontSize:20)))),
              Container(width: 200, child: Center(child: Text("${mortgage.getYears()}", style: TextStyle(fontSize:20))))
            ]
          ),
          Row(
            children: [
              Container(width: 200, child: Center(child: Text("Interest Rate: ", style: TextStyle(fontSize:20)))),
              Container(width: 200, child: Center(child: Text("$percent%", style: TextStyle(fontSize:20))))
            ]
          ),
          Row(
            children: [
              Container(width: 200, child: Center(child: Text("Monthly Payment: ", style: TextStyle(fontSize:20)))),
              Container(width: 200, child: Center(child: Text("\$${mortgage.monthlyPayment().toStringAsFixed(2)}", style: TextStyle(fontSize:20))))
            ]
          ),
          Row(
            children: [
              Container(width: 200, child: Center(child: Text("Total Payment: ", style: TextStyle(fontSize:20)))),
              Container(width: 200, child: Center(child: Text("\$${mortgage.totalPayment().toStringAsFixed(2)}", style: TextStyle(fontSize:20))))
            ]
          ),
          CheckboxListTile(
            title: Text("Terms and Conditions"),
            value: _terms,
            onChanged: (value) {
              setState(() => _terms = value ?? false);
              if (_terms == true) {
                showMyAlertDialog(context);
              }
            }
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const InputScreen()),
              );
            },
            child: const Text("MODIFY")
          )
          ],
        ),
      ),
    );
  }
}

void showMyAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Terms and Conditions"),
        content: Text("You have accepted everything that will happen from here on out."),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            }
          )
        ]
      );
    },
  );
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});
  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  late TextEditingController _controller;
  late int _years;
  late double _rate;

  @override
  void initState() {
    super.initState();
    final mortgage = context.read<Mortgage>();
    _controller = TextEditingController(text: mortgage.getAmount().toStringAsFixed(2));
    _years = mortgage.getYears();
    _rate = mortgage.getRate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mortgage Calculator")),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Amount: "),
          ),
          Text("Years: "),
          RadioListTile<int>(title: Text("10"), value: 10, groupValue: _years, onChanged: (val) => setState(() => _years = val!)),
          RadioListTile<int>(title: Text("15"), value: 15, groupValue: _years, onChanged: (val) => setState(() => _years = val!)),
          RadioListTile<int>(title: Text("30"), value: 30, groupValue: _years, onChanged: (val) => setState(() => _years = val!)),
          Text("Interest Rate: "),
          Expanded(
            child: ListView.builder(
              itemCount: 53,
              itemBuilder: (context, index) {
                double current = (200 + index * 25) / 10000;
                return ListTile(
                  title: Text("$current"),
                  selected: current == _rate,
                  onTap: () => setState(() => _rate = current),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final mortgage = context.read<Mortgage>();
              mortgage.setAmount(double.tryParse(_controller.text) ?? mortgage.getAmount());
              mortgage.setYears(_years);
              mortgage.setRate(_rate);
              Navigator.pop(context);
            },
            child: Text("DONE"),
          ),
        ],
      ),
    );
  }
}