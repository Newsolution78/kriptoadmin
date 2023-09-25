import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../providers/user.dart';

/// The home page of the application which hosts the datagrid.
class UsersDataSyncScreen extends StatefulWidget {
  /// Creates the home page.
  const UsersDataSyncScreen({Key? key}) : super(key: key);
  static const routeName = '/userssynctable';

  @override
  UsersDataSyncScreenState createState() => UsersDataSyncScreenState();
}

class UsersDataSyncScreenState extends State<UsersDataSyncScreen> {
  List<DataUser> usersData = <DataUser>[];
  final GlobalKey<FormState> _formKey = GlobalKey();
  late UserDataSource userDataSource;
  final DataGridController _dataGridController = DataGridController();

  var _isLoading = false;
  int _pageNumber = 1;
  late int _countUser;

  late String name;
  late String email;
  late String type;
  String password = '';
  String password2 = '';
  late String branchOffice;

  late int _selectedId;
  late String _selectedName;
  late String _selectedEmail;
  late String _selectedType;
  late String _selectedBranch;

  //Nincs befejezve a pageelés

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future.delayed(Duration.zero).then((_) {
      Provider.of<User>(context, listen: false).usersCount();
      Provider.of<User>(context, listen: false)
          .allUsers(pageNumber: 1, pageSize: 10)
          .then((_) {
        _countUser = Provider.of<User>(context, listen: false).count;
        //_countUser = 1;

        usersData = getUserData();
        userDataSource = UserDataSource(employeeData: usersData);
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  void pageForward() {
    if (_pageNumber < _countUser / 10) {
      _pageNumber = _pageNumber + 1;
      _userLoad();
    }
  }

  void pageBack() {
    if (_pageNumber > 1) {
      _pageNumber = _pageNumber - 1;
      _userLoad();
    }
  }

  Future<void> _userLoad() async {
    _isLoading = true;
    await Provider.of<User>(context, listen: false)
        .allUsers(pageNumber: _pageNumber, pageSize: 10)
        .then((_) {
      usersData = getUserData();

      userDataSource = UserDataSource(employeeData: usersData);
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future openDialog(bool modification) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Új ügyfél',
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                modification
                    ? Center(child: Text('ID : $_selectedId'))
                    : const Center(child: Text('ID : 0')),
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  initialValue: modification ? _selectedEmail : '',
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Hibás email cím!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    email = value!;
                  },
                ),
                modification
                    ? Container()
                    : TextFormField(
                        autofocus: true,
                        decoration: const InputDecoration(hintText: 'Jelszó'),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Hibás jelszó!';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          password = value!;
                        },
                      ),
                modification
                    ? Container()
                    : TextFormField(
                        autofocus: true,
                        decoration:
                            const InputDecoration(hintText: 'Jelszó ismétlése'),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Hibás jelszó!';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          password2 = value!;
                        },
                      ),
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Név'),
                  keyboardType: TextInputType.text,
                  initialValue: modification ? _selectedName : '',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Hibás név!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    name = value!;
                  },
                ),
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Tipus'),
                  keyboardType: TextInputType.text,
                  initialValue: modification ? _selectedType : '',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Hibás tipus!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    type = value!;
                  },
                ),
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Branch Office'),
                  keyboardType: TextInputType.text,
                  initialValue: modification ? _selectedBranch : '',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Hibás branch office!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    branchOffice = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: _close, child: const Text('Vissza')),
            TextButton(
                onPressed: () {
                  _submit(modification);
                },
                child: const Text('OK'))
          ],
        ),
      );

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Felvitel hiba!',
        ),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Rendben'))
        ],
      ),
    );
  }

  Future<void> _submit(bool modification) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (password != password2 && !modification) {
      _showErrorDialog('A jelszavak nem egyeznek meg!');
    }
    setState(() {
      _isLoading = true;
    });
    print(modification.toString());
    try {
      if (modification) {
        await Provider.of<User>(context, listen: false)
            .updateUser(_selectedId, name, email, type, branchOffice);
      } else {
        await Provider.of<User>(context, listen: false).newUser(
          name,
          type,
          email,
          password,
          branchOffice,
        );
      }
    } catch (error) {
      _showErrorDialog('A felhasználó rögzítése nem sikerült!');
    }
    setState(() {
      _isLoading = false;
    });

    _userLoad();
    _close();
    if (!modification) {
      _close();
    }
  }

  void _close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Felhasználó adatok'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraint) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          child: const Text('Új felhasználó'),
                          onPressed: () {
                            openDialog(false);
                          },
                        ),
                        ElevatedButton(
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
                              _selectedType = _dataGridController.selectedRow!
                                  .getCells()[3]
                                  .value;
                              _selectedBranch = _dataGridController.selectedRow!
                                  .getCells()[4]
                                  .value;
                              openDialog(true);
                            },
                            child: const Text('Felhasználó módosítása')),
                      ],
                    ),
                    SizedBox(
                      height: constraint.maxHeight - 150,
                      child: SfDataGrid(
                        source: userDataSource,
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
                            columnName: 'type',
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'Type',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          GridColumn(
                            columnName: 'branch',
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'Branch',
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
                              '$_pageNumber oldal / összesen: ${(_countUser / 10).round()}'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  List<DataUser> getUserData() {
    List<DataUser> userData = [];

    final data = Provider.of<User>(context, listen: false).usersData;

    for (var element in data) {
      userData.add(
        DataUser(element['id'], element['name'], element['email'],
            element['type'], element['branch']),
      );
    }

    return userData;
  }
}

class DataUser {
  int id;
  String name;
  String email;
  String? type;
  String? branch;

  DataUser(this.id, this.name, this.email, this.type, this.branch);
}

class UserDataSource extends DataGridSource {
  UserDataSource({required List<DataUser> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>(
          (e) => DataGridRow(
            cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(columnName: 'email', value: e.email),
              DataGridCell<String>(columnName: 'type', value: e.type),
              DataGridCell<String>(columnName: 'branch', value: e.branch),
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
