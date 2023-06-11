import 'package:status_saver/common.dart';
import 'package:status_saver/models/tab_type.dart';
import 'package:status_saver/screens/not_found_screen.dart';
import 'package:status_saver/services/is_directory_exists.dart';
import 'package:status_saver/widgets/statuses_list.dart';

class DoOrDie extends StatelessWidget {
  final TabType tabType; 
  const DoOrDie({
    super.key, 
    required this.tabType, 
  });

  @override
  Widget build(BuildContext context) {



    return FutureBuilder(
      future: isDirectoryExists(tabType: tabType),
      builder: (_,snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          if(snapshot.data!) {
            return StatusesList(tabType: tabType);
          }
          return NotFoundScreen(
            message: tabType == TabType.recent 
            ? AppLocalizations.of(context)?.noWhatsappFoundMessage ?? "Whatsapp or W4B Not found" 
            : AppLocalizations.of(context)?.noSavedStatusesMessage ?? "No saved statuses" );
        } else {
          // FIXME: return effective progress bar
          return const Center(child: CircularProgressIndicator());
        }
      }
    );
  }
}