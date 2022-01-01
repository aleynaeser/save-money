import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> _allTransactions;
  final Function _deleteTransaction;

  TransactionList(this._allTransactions, this._deleteTransaction);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return _allTransactions.isEmpty
          // No Transactions
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: constraints.maxHeight * 0.1,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "In any little way, Save everyday!",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  child: Image.asset(
                    "images/save_money.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            )
          // Transactions Present
          : ListView.builder(
              itemCount: _allTransactions.length,
              itemBuilder: (context, index) {
                Transaction txn = _allTransactions[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(
                      vertical: 1.0,
                      horizontal: 15.0,
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: ListTile(
                        leading: Container(
                          width: 70.0,
                          height: 50.0,
                          padding: EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: Colors.green[700],
                          ),
                          child: FittedBox(

                            fit: BoxFit.contain,
                            child: Text(
                              '\$ ${txn.txnAmount}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          txn.txnTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('MMMM d, y -')
                              .add_jm()
                              .format(txn.txnDateTime),
                          // DateFormat.yMMMMd().format(txn.txnDateTime),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline),
                          color: Theme.of(context).errorColor,
                          onPressed: () => _deleteTransaction(txn.txnId),
                          tooltip: "Delete Expense",
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
    });
  }
}
