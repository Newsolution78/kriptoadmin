import 'package:crypto_admin/providers/transaction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row;
import '../helper/save_file_mobile.dart'
    if (dart.library.html) 'helper/save_file_web.dart' as helper;

/// The home page of the application which hosts the datagrid.
class TransactionDataSyncScreen extends StatefulWidget {
  /// Creates the home page.
  const TransactionDataSyncScreen({Key? key}) : super(key: key);
  static const routeName = '/transactiondata';

  @override
  TransactionDataSyncScreenState createState() =>
      TransactionDataSyncScreenState();
}

class TransactionDataSyncScreenState extends State<TransactionDataSyncScreen> {
  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();
  List<DataTransaction> transactionData = <DataTransaction>[];
  late TransactionDataSource transactionDataSource;
  final DataGridController _dataGridController = DataGridController();
  int _selectedId = 0;
  late String _selectedCrypto;
  late int _selectedFiatAmount;
  late double _selectedAmount;
  late String _selectedCurrency;
  late double _selectedExchangeRate;
  late String _selectedWallet;
  late int _selectedUserId;
  late int _selectedCustomerID;
  late String _selectedBranchOffice;
  late String _selectedDateTime;
  late String _selectedPaymentMethod;
  late int _selectedProfit;
  late String _selectedStatus;
  late int _selectedAMLLevel;
  late int _selectedAMLRating;
  late String _selectedReceiptId;
  late int _selectedOrderId;
  late int _selectedWithdrawalId;

  var _isLoading = false;
  int _pageNumber = 1;
  late int _countTransaction;

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Tranzakció adatok',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: $_selectedId'),
              Text('Branch Office:$_selectedBranchOffice'),
              Text('Date Time: $_selectedDateTime'),
              Text('Selected Currency:$_selectedCurrency'),
              Text('Fiat Amount: $_selectedFiatAmount'),
              Text('Amount: $_selectedAmount'),
              Text('Customer ID: $_selectedCustomerID'),
              Text('Payment Method: $_selectedPaymentMethod'),
              Text('Profit: $_selectedProfit'),
              Text('Status: $_selectedStatus'),
              Text('Wallet: $_selectedWallet'),
              Text('AML Level: $_selectedAMLLevel'),
              Text('AML Rating: $_selectedAMLRating'),
            ],
          ),
          actions: [TextButton(onPressed: _close, child: const Text('OK'))],
        ),
      );

  void _close() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future.delayed(Duration.zero).then((_) {
      Provider.of<Transaction>(context, listen: false).transactionsCount();
      Provider.of<Transaction>(context, listen: false)
          .allTransaction(pageNumber: 1, pageSize: 20)
          .then((_) {
        _countTransaction =
            Provider.of<Transaction>(context, listen: false).count;

        transactionData = getCustomerData();
        transactionDataSource =
            TransactionDataSource(transactionData: transactionData);
        setState(() {
          _isLoading = false;
        });
      });
      Provider.of<Transaction>(context, listen: false).transactionsCount();
    });
  }

  void pageForward() {
    if (_pageNumber < _countTransaction / 10) {
      _pageNumber = _pageNumber + 1;
      _transactionLoad();
    }
  }

  void pageBack() {
    if (_pageNumber > 1) {
      _pageNumber = _pageNumber - 1;
      _transactionLoad();
    }
  }

  Future<void> _transactionLoad() async {
    _isLoading = true;
    await Provider.of<Transaction>(context, listen: false)
        .allTransaction(pageNumber: _pageNumber, pageSize: 20)
        .then((_) {
      transactionData = getCustomerData();
      transactionDataSource =
          TransactionDataSource(transactionData: transactionData);
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _exportDataGridToExcel() async {
    final Workbook workbook = _key.currentState!.exportToExcelWorkbook();

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    await helper.saveAndLaunchFile(bytes, 'DataGrid.xlsx');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syncfusion Flutter DataGrid'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      child: const Text('Adatok megtekintése'),
                      onPressed: () {
                        _selectedId = _dataGridController.selectedRow!
                            .getCells()[0]
                            .value;

                        _selectedDateTime = _dataGridController.selectedRow!
                            .getCells()[1]
                            .value;
                        _selectedBranchOffice = _dataGridController.selectedRow!
                            .getCells()[2]
                            .value;
                        _selectedCurrency = _dataGridController.selectedRow!
                            .getCells()[3]
                            .value;
                        _selectedFiatAmount = int.parse(_dataGridController
                            .selectedRow!
                            .getCells()[4]
                            .value);
                        _selectedAmount = double.parse(_dataGridController
                            .selectedRow!
                            .getCells()[5]
                            .value);
                        _selectedCustomerID = int.parse(_dataGridController
                            .selectedRow!
                            .getCells()[6]
                            .value);
                        _selectedPaymentMethod = _dataGridController
                            .selectedRow!
                            .getCells()[7]
                            .value;
                        _selectedProfit = int.parse(_dataGridController
                            .selectedRow!
                            .getCells()[8]
                            .value);
                        _selectedStatus = _dataGridController.selectedRow!
                            .getCells()[9]
                            .value;
                        _selectedWallet = _dataGridController.selectedRow!
                            .getCells()[10]
                            .value;
                        _selectedAMLLevel = int.parse(_dataGridController
                            .selectedRow!
                            .getCells()[11]
                            .value);
                        _selectedAMLRating = int.parse(_dataGridController
                            .selectedRow!
                            .getCells()[12]
                            .value);

                        openDialog();
                      },
                    ),
                    MaterialButton(
                      onPressed: _exportDataGridToExcel,
                      child: const Text('Excel'),
                    ),
                  ],
                ),
                Expanded(
                  //height: constraint.maxHeight - 100,
                  child: SfDataGrid(
                    key: _key,
                    source: transactionDataSource,
                    columnWidthMode: ColumnWidthMode.fill,
                    columns: <GridColumn>[
                      GridColumn(
                        columnName: 'id',
                        label: Container(
                          padding: const EdgeInsets.all(16.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'ID',
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'crypto',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'crypto',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'fiatamount',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'fiatamount',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'amount',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'amount',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'currency',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'currency',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'exchangerate',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'exchangerate',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'wallet',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'wallet',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'userid',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'userid',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'customerid',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'customerid',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'branchoffice',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'branchoffice',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'datetime',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'Datetime',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'paymentmethod',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'paymentmethod',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'profit',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'profit',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'status',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'status',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'amllevel',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'amlevel',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'amlrating',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'amlrating',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'receiptId',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'receiptId',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'orderId',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'orderId',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      GridColumn(
                        columnName: 'withdrawalId',
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            'withdrawalId',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    controller: _dataGridController,
                    selectionMode: SelectionMode.single,
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: const Text('<'),
                        onTap: () => pageBack(),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        child: const Text('>'),
                        onTap: () => pageForward(),
                      ),
                      Text(
                          '$_pageNumber oldal / összesen: ${(_countTransaction / 20).round()}'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  List<DataTransaction> getCustomerData() {
    List<DataTransaction> transactionData = [];

    final data =
        Provider.of<Transaction>(context, listen: false).transactionData;

    for (var element in data) {
      //print(element['id'].toString() + ';' + element['amount'].toString());
      transactionData.add(
        DataTransaction(
          element['id'],
          element['crypto'],
          element['fiatAmount'],
          element['amount'],
          element['currency'],
          element['exchangeRate'],
          element['wallet'],
          element['user'],
          element['customerId'],
          element['branchOffice'],
          DateTime.parse(element['dateTime']),
          element['paymentMethod'],
          element['profit'],
          element['status'],
          element['amlLevel'],
          element['amlRating'],
          element['receiptId'],
          element['orderId'],
          element['withdrawalId'],
        ),
      );
    }

    return transactionData;
  }
}

class DataTransaction {
  int id;
  String? crypto;
  int? fiatAmount;
  double? amount;
  String? currency;
  double? exchangerate;
  String? wallet;
  int? userid;
  int? customerId;
  String branchOffice;
  DateTime? dateTime;
  String? paymentMethod;
  int? profit;
  String? status;
  int? amlLevel;
  int? amlRating;
  String? receiptid;
  String? orderid;
  String? withdrawalid;

  DataTransaction(
    this.id,
    this.crypto,
    this.fiatAmount,
    this.amount,
    this.currency,
    this.exchangerate,
    this.wallet,
    this.userid,
    this.customerId,
    this.branchOffice,
    this.dateTime,
    this.paymentMethod,
    this.profit,
    this.status,
    this.amlLevel,
    this.amlRating,
    this.receiptid,
    this.orderid,
    this.withdrawalid,
  );
}

class TransactionDataSource extends DataGridSource {
  TransactionDataSource({required List<DataTransaction> transactionData}) {
    _transactionData = transactionData
        .map<DataGridRow>(
          (e) => DataGridRow(
            cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'crypto', value: e.crypto),
              DataGridCell<int>(columnName: 'fiatamount', value: e.fiatAmount),
              DataGridCell<double>(columnName: 'amount', value: e.amount),
              DataGridCell<String>(columnName: 'currency', value: e.currency),
              DataGridCell<double>(
                  columnName: 'exchangerate', value: e.exchangerate),
              DataGridCell<String>(columnName: 'wallet', value: e.wallet),
              DataGridCell<int>(columnName: 'userid', value: e.userid),
              DataGridCell<String>(
                  columnName: 'customerid', value: e.customerId.toString()),
              DataGridCell<String>(
                  columnName: 'branchoffice', value: e.branchOffice),
              DataGridCell<String>(
                  columnName: 'datetime', value: e.dateTime.toString()),
              DataGridCell<String>(
                  columnName: 'paymentmethod', value: e.paymentMethod),
              DataGridCell<String>(
                  columnName: 'profit', value: e.profit.toString()),
              DataGridCell<String>(columnName: 'status', value: e.status),
              DataGridCell<String>(
                  columnName: 'amllevel', value: e.amlLevel.toString()),
              DataGridCell<String>(
                  columnName: 'amlrating', value: e.amlRating.toString()),
              DataGridCell<String>(columnName: 'receiptid', value: e.receiptid),
              DataGridCell<String>(columnName: 'orderid', value: e.orderid),
              DataGridCell<String>(
                  columnName: 'withdrawalid', value: e.withdrawalid),
            ],
          ),
        )
        .toList();
  }

  List<DataGridRow> _transactionData = [];

  @override
  List<DataGridRow> get rows => _transactionData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
