import 'package:crypto_admin/providers/customer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// The home page of the application which hosts the datagrid.
class CustomersDataSyncScreen extends StatefulWidget {
  /// Creates the home page.
  const CustomersDataSyncScreen({Key? key}) : super(key: key);
  static const routeName = '/customerssynctable';

  @override
  CustomersDataSyncScreenState createState() => CustomersDataSyncScreenState();
}

class CustomersDataSyncScreenState extends State<CustomersDataSyncScreen> {
  List<DataCustomer> customersData = <DataCustomer>[];
  late CustomerDataSource customerDataSource;
  final DataGridController _dataGridController = DataGridController();
  int _selectedId = 0;
  String _selectedName = '';
  String _selectedEmail = '';

  var _isLoading = false;
  int _pageNumber = 1;
  late int _countCustomer;
  String _searchString = '';
  bool _search = false;

  //Nincs befejezve a pageelés

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future.delayed(Duration.zero).then((_) {
      Provider.of<Customer>(context, listen: false).customersCount();
      Provider.of<Customer>(context, listen: false)
          .allCustomers(pageNumber: 1, pageSize: 10)
          .then((_) {
        _countCustomer = Provider.of<Customer>(context, listen: false).count;

        customersData = getCustomerData();
        customerDataSource = CustomerDataSource(employeeData: customersData);
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  Future<void> _customerDelete() async {
    _isLoading = true;
    await Provider.of<Customer>(context, listen: false)
        .deleteCustomers(_selectedId, _selectedName, _selectedEmail)
        .then((_) => setState(() {}));
  }

  void pageForward() {
    if (_pageNumber < _countCustomer / 10) {
      _pageNumber = _pageNumber + 1;
      _customerLoad();
    }
  }

  void pageBack() {
    if (_pageNumber > 1) {
      _pageNumber = _pageNumber - 1;
      _customerLoad();
    }
  }

  Future<void> _customerLoad() async {
    _isLoading = true;
    if (!_search) {
      await Provider.of<Customer>(context, listen: false)
          .allCustomers(pageNumber: _pageNumber, pageSize: 10)
          .then((_) {
        customersData = getCustomerData();
        customerDataSource = CustomerDataSource(employeeData: customersData);
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      await Provider.of<Customer>(context, listen: false)
          .customersFind(
              pageNumber: _pageNumber,
              pageSize: 10,
              searchString: _searchString)
          .then((_) {
        customersData = getCustomerData();
        customerDataSource = CustomerDataSource(employeeData: customersData);
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Új ügyfél',
          ),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(hintText: 'Email'),
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Jelszó'),
                ),
              ],
            ),
          ),
          actions: [TextButton(onPressed: _submit, child: const Text('OK'))],
        ),
      );

  void _submit() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer data'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraint) {
                return Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          child: const Text('Ügyfél törlése'),
                          onPressed: () {
                            _selectedId = _dataGridController.selectedRow!
                                .getCells()[0]
                                .value;
                            _selectedName = _dataGridController.selectedRow!
                                .getCells()[1]
                                .value;
                            _selectedEmail = _dataGridController.selectedRow!
                                .getCells()[2]
                                .value;

                            _customerDelete();
                          },
                        ),
                        SizedBox(
                          width: 310,
                          child: TextField(
                            onChanged: (value) {
                              _searchString = value;
                            },
                            maxLength: 300,
                          ),
                        ),
                        ElevatedButton(
                          child: const Text('Keresés'),
                          onPressed: () {
                            if (_searchString == '') {
                              _search = false;
                            } else {
                              _search = true;
                            }

                            _customerLoad();
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: constraint.maxHeight - 150,
                      child: SfDataGrid(
                        source: customerDataSource,
                        columnWidthMode: ColumnWidthMode.fill,
                        columns: <GridColumn>[
                          GridColumn(
                              columnName: 'id',
                              label: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'ID',
                                  ))),
                          GridColumn(
                              columnName: 'name',
                              label: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  child: const Text('Name'))),
                          GridColumn(
                            columnName: 'email',
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'Email',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          GridColumn(
                            columnName: 'country',
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'Country',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          GridColumn(
                            columnName: 'postcode',
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'Postcode',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          GridColumn(
                            columnName: 'address',
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'Address',
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
                              '$_pageNumber oldal / összesen: ${(_countCustomer / 10).round()}'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  List<DataCustomer> getCustomerData() {
    List<DataCustomer> customerData = [];

    final data = Provider.of<Customer>(context, listen: false).customersData;

    for (var element in data) {
      customerData.add(
        DataCustomer(
          element['id'],
          element['name'],
          element['email'],
          element['country'],
          element['postcode'],
          element['address'],
        ),
      );
    }

    return customerData;
  }
}

class DataCustomer {
  int id;
  String? name;
  String email;
  String? country;
  String? postcode;
  String? address;

  DataCustomer(this.id, this.name, this.email, this.country, this.postcode,
      this.address);
}

class CustomerDataSource extends DataGridSource {
  CustomerDataSource({required List<DataCustomer> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>(
          (e) => DataGridRow(
            cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(columnName: 'email', value: e.email),
              DataGridCell<String>(columnName: 'country', value: e.country),
              DataGridCell<String>(columnName: 'postcode', value: e.postcode),
              DataGridCell<String>(columnName: 'address', value: e.address),
            ],
          ),
        )
        .toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

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
