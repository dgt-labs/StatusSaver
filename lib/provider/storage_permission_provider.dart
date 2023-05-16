import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:status_saver/common.dart';
import 'package:status_saver/services/show_without_ui_block_message.dart';

class StoragePermissionProvider extends ChangeNotifier {

  PermissionStatus? _storagePermissionStatus;
  Permission? _storagePermission;
  bool _tempFirstTime = true;

  void initialize() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    _storagePermission = androidInfo.version.sdkInt >= 31 
    ? Permission.manageExternalStorage
    : Permission.storage;
    
    _storagePermissionStatus = await _storagePermission?.request();
    notifyListeners();
  }

  PermissionStatus? get status => _storagePermissionStatus;

  void requestAndHandle(BuildContext context) {
    if(_storagePermission == null) return;

    _storagePermission!.request()
    .then((status) async {
      switch(status) {
        case PermissionStatus.granted:
          _storagePermissionStatus = PermissionStatus.granted;
          notifyListeners();
          return;
        case PermissionStatus.denied:
          return;
        case PermissionStatus.permanentlyDenied: 
        case PermissionStatus.restricted:
        case PermissionStatus.limited: // do not have idea about limited
          if(_tempFirstTime) {
            _tempFirstTime = false;
            return;
          }
          openAppSettings()
          .then((value) {
            if(value) {
              showMessageWithoutUiBlock(message: AppLocalizations.of(context)?.allowStoragePermission ?? "Allow storage permission for Status Saver",toastLength: Toast.LENGTH_LONG); // FIXME: dynamic app name
            } else {
              showMessageWithoutUiBlock(message: AppLocalizations.of(context)?.couldNotOpenAppSettings ?? "Could not open app settings for storage permission.");
            }
          });
          return;
      }
    });
  }
}