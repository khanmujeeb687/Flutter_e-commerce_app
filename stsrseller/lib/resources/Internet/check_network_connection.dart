import 'package:connectivity/connectivity.dart';

Future<bool> IsConnectedtoInternet()
async{
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return false;
  } else if (connectivityResult == ConnectivityResult.wifi) {
// I am connected to a wifi network.
  return false;
  }
  return true;
}