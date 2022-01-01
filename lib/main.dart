import 'dart:io';
import 'package:expense_tracker/util/constants.dart';
import 'package:expense_tracker/widgets/chart.dart';
import 'package:expense_tracker/widgets/new_transaction_form.dart';
import 'package:expense_tracker/widgets/transaction_list.dart';
import 'package:flutter/material.dart';

import 'db_helper/db_helper.dart';
import 'models/transaction.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save Money',
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: kPrimaryColor,
        ),
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white, elevation: 0),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Transaction> _userTransactions = [];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    DateTime lastDayOfPrevWeek = DateTime.now().subtract(Duration(days: 6));
    lastDayOfPrevWeek = DateTime(
        lastDayOfPrevWeek.year, lastDayOfPrevWeek.month, lastDayOfPrevWeek.day);
    return _userTransactions.where((element) {
      return element.txnDateTime.isAfter(
        lastDayOfPrevWeek,
      );
    }).toList();
  }

  _MyHomePageState() {
    _updateUserTransactionsList();
  }

  void _updateUserTransactionsList() {
    Future<List<Transaction>> res =
        DatabaseHelper.instance.getAllTransactions();

    res.then((txnList) {
      setState(() {
        _userTransactions = txnList;
      });
    });
  }

  void _showChartHandler(bool show) {
    setState(() {
      _showChart = show;
    });
  }

  Future<void> _addNewTransaction(
      String title, double amount, DateTime chosenDate) async {
    final newTxn = Transaction(
      DateTime.now().millisecondsSinceEpoch.toString(),
      title,
      amount,
      chosenDate,
    );
    int res = await DatabaseHelper.instance.insert(newTxn);

    if (res != 0) {
      _updateUserTransactionsList();
    }
  }

  void _startAddNewTransaction(BuildContext context) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.80,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: NewTransactionForm(_addNewTransaction),
        );
      },
    );
  }

  Future<void> _deleteTransaction(String id) async {
    int res =
        await DatabaseHelper.instance.deleteTransactionById(int.tryParse(id));
    if (res != 0) {
      _updateUserTransactionsList();
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    final bool isLandscape =
        mediaQueryData.orientation == Orientation.landscape;

    final double availableHeight = mediaQueryData.size.height -
        mediaQueryData.padding.top -
        mediaQueryData.padding.bottom;

    final double availableWidth = mediaQueryData.size.width -
        mediaQueryData.padding.left -
        mediaQueryData.padding.right;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Show Chart",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[500],
                    ),
                  ),
                  Switch.adaptive(
                    activeColor: Colors.amber[700],
                    value: _showChart,
                    onChanged: (value) => _showChartHandler(value),
                  ),
                ],
              ),
            if (isLandscape)
              _showChart
                  ? myChartContainer(
                      height: availableHeight * 0.8,
                      width: 0.6 * availableWidth)
                  : myTransactionListContainer(
                      height: availableHeight * 0.8,
                      width: 0.6 * availableWidth),
            if (!isLandscape)
              myChartContainer(
                  height: availableHeight * 0.5, width: availableWidth),
            if (!isLandscape)
              myTransactionListContainer(
                  height: availableHeight * 0.8, width: availableWidth),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Platform.isIOS
          ? Container()
          : FloatingActionButton(
              splashColor: kPrimaryColor,
              child: Icon(
                Icons.add,
                color: kPrimaryColor,
              ),
              tooltip: "Add New Expense",
              onPressed: () => _startAddNewTransaction(context),
            ),
    );
  }

  Widget myChartContainer({double height, double width}) {
    return Container(
      height: height,
      width: width,
      child: Chart(_recentTransactions),
    );
  }

  Widget myTransactionListContainer({double height, double width}) {
    return Container(
      height: height,
      width: width,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );
  }
}
