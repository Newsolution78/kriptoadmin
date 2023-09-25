class Endpoints {
  var base = '192.168.100.181';
  //'192.168.0.150';
  //'https://flutter-update-8b9cb-default-rtdb.europe-west1.firebasedatabase.app/';
  var login = '/login';

  //USER ENDPOINTS
  var users = '/api/users';
  var finduser = '/finduser'; //param = username GET
  var findemail = '/findemail'; //param = email GET
  var bodytest = '/bodytest'; //param = apitoken, body = json POST
  var userdelete = '/userdelete'; //param = apitoken, body = json POST
  var userscount = '/getuserscount';
  var usersupdate = '/updateuser';

  //TRANSACTION ENDPOINTS
  var transactions = '/api/transactions';
  var transactionUpload =
      '/newtransaction'; //param = apitoken, body = json POST
  var transactionUpdate =
      '/updatetransaction'; //param = apitoken, body = json POST
  var alltransaction = '/getalltransaction';
  var transactionscount = '/gettransactionscount';
  var deletetransaction = '/transactiondelete';

  //CUSTOMER ENDPOINTS
  var customers = '/api/customer';
  var customerUpload = '/newcustomer'; //param = apitoken, body = json POST
  var imageUpload = '/upload-mutiple';
  var customerSearch = '/customersearch'; //param = apitoken, body = json POST
  var allcustomers = '/getallcustomers';
  var deletecustomers = '/customerdelete';
  var customerscount = '/getcustomerscount';
  var findCustomer =
      '/findcustomer'; //param = int pageNumber, int pageSize, string customerEmail, body = json POST
}
