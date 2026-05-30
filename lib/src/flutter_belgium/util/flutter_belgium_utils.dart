String toLocalPersonAvatarPath(String recordId, String filename) =>
    'assets/flutter_belgium/people/avatars/$recordId.${_ext(filename)}';

String toLocalCompanyLogoPath(String recordId, String filename) =>
    'assets/flutter_belgium/companies/logos/$recordId.${_ext(filename)}';

String toLocalMeetupPosterPath(String recordId, String filename) =>
    'assets/flutter_belgium/meetups/posters/$recordId.${_ext(filename)}';

String _ext(String filename) {
  final parts = filename.split('.');
  return parts.length > 1 ? parts.last.toLowerCase() : 'jpg';
}
