import 'smart_management.dart';
import 'typedefs.dart';

/// GetInterface allows any auxiliary package to be merged into the "Get"
/// class through extensions.
abstract class GetInterface {
  SmartManagement smartManagement = SmartManagement.full;
  bool isLogEnable = false;
  LogWriterCallback log = defaultLogWriter;
}
