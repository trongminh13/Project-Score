// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a vi locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'vi';

  static String m0(homeScore, awayScore) =>
      "Tổng tỉ số (${homeScore} - ${awayScore})";

  static String m1(number) => "Vòng ${number}";

  static String m2(number) => "Mùa giải ${number}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aggregateScore": m0,
    "all": MessageLookupByLibrary.simpleMessage("Tất cả"),
    "allLeaguesTooltip": MessageLookupByLibrary.simpleMessage(
      "Tất cả các giải đấu",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("QUANTSCORE"),
    "appVersion": MessageLookupByLibrary.simpleMessage("Phiên bản"),
    "appearance": MessageLookupByLibrary.simpleMessage("Giao diện"),
    "appearanceDescription": MessageLookupByLibrary.simpleMessage(
      "Tùy chỉnh giao diện hiển thị của ứng dụng.",
    ),
    "arabic": MessageLookupByLibrary.simpleMessage("Tiếng Ả Rập"),
    "assist": MessageLookupByLibrary.simpleMessage("Kiến tạo"),
    "dark": MessageLookupByLibrary.simpleMessage("Tối"),
    "discoverTopLeagues": MessageLookupByLibrary.simpleMessage(
      "Khám phá giải đấu hàng đầu",
    ),
    "drawnShort": MessageLookupByLibrary.simpleMessage("H"),
    "english": MessageLookupByLibrary.simpleMessage("Tiếng Anh"),
    "errorClientClosedRequest": MessageLookupByLibrary.simpleMessage(
      "Đã xảy ra lỗi khi tải dữ liệu. Vui lòng thử lại.",
    ),
    "errorInternalServerError": MessageLookupByLibrary.simpleMessage(
      "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.",
    ),
    "errorLoadFixtures": MessageLookupByLibrary.simpleMessage(
      "Không thể tải lịch thi đấu lúc này.",
    ),
    "errorLoadStandings": MessageLookupByLibrary.simpleMessage(
      "Không thể tải bảng xếp hạng lúc này.",
    ),
    "errorNetworkConnectError": MessageLookupByLibrary.simpleMessage(
      "Kết nối thất bại. Vui lòng kiểm tra mạng và thử lại.",
    ),
    "errorUnexpected": MessageLookupByLibrary.simpleMessage(
      "Đã xảy ra lỗi không xác định.",
    ),
    "errorWebProxyRequired": MessageLookupByLibrary.simpleMessage(
      "Flutter Web yêu cầu máy chủ proxy cho API này.",
    ),
    "events": MessageLookupByLibrary.simpleMessage("Sự kiện"),
    "exploreLeagues": MessageLookupByLibrary.simpleMessage("Khám phá giải đấu"),
    "fixtures": MessageLookupByLibrary.simpleMessage("Lịch thi đấu"),
    "form": MessageLookupByLibrary.simpleMessage("Phong độ"),
    "fullLineups": MessageLookupByLibrary.simpleMessage("Đội hình chi tiết"),
    "goalDifferenceShort": MessageLookupByLibrary.simpleMessage("HS"),
    "goalsAgainstShort": MessageLookupByLibrary.simpleMessage("SBT"),
    "goalsForShort": MessageLookupByLibrary.simpleMessage("BT"),
    "home": MessageLookupByLibrary.simpleMessage("Trang chủ"),
    "language": MessageLookupByLibrary.simpleMessage("Ngôn ngữ"),
    "languageDescription": MessageLookupByLibrary.simpleMessage(
      "Chọn ngôn ngữ hiển thị của ứng dụng.",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Sáng"),
    "lineups": MessageLookupByLibrary.simpleMessage("Đội hình"),
    "liveFallback": MessageLookupByLibrary.simpleMessage("TRỰC TIẾP"),
    "liveFixtures": MessageLookupByLibrary.simpleMessage("Đang diễn ra"),
    "liveScore": MessageLookupByLibrary.simpleMessage("QUANTSCORE"),
    "lostShort": MessageLookupByLibrary.simpleMessage("B"),
    "noEvents": MessageLookupByLibrary.simpleMessage("Sự kiện chưa có sẵn"),
    "noFixtures": MessageLookupByLibrary.simpleMessage(
      "Không có trận đấu nào hôm nay",
    ),
    "noLineups": MessageLookupByLibrary.simpleMessage("Đội hình chưa có sẵn"),
    "noRouteFound": MessageLookupByLibrary.simpleMessage(
      "Không tìm thấy trang",
    ),
    "noStandingsYet": MessageLookupByLibrary.simpleMessage(
      "Bảng xếp hạng chưa có sẵn.",
    ),
    "noStats": MessageLookupByLibrary.simpleMessage("Thống kê chưa có sẵn"),
    "playedShort": MessageLookupByLibrary.simpleMessage("ST"),
    "pointsShort": MessageLookupByLibrary.simpleMessage("Đ"),
    "reload": MessageLookupByLibrary.simpleMessage("Tải lại"),
    "roundNumber": m1,
    "seasonNumber": m2,
    "settings": MessageLookupByLibrary.simpleMessage("Cài đặt"),
    "standings": MessageLookupByLibrary.simpleMessage("Bảng xếp hạng"),
    "statistics": MessageLookupByLibrary.simpleMessage("Thống kê"),
    "systemDefault": MessageLookupByLibrary.simpleMessage("Mặc định hệ thống"),
    "tbd": MessageLookupByLibrary.simpleMessage("TBD"),
    "teamName": MessageLookupByLibrary.simpleMessage("Đội"),
    "topStats": MessageLookupByLibrary.simpleMessage("Chỉ số nổi bật"),
    "versus": MessageLookupByLibrary.simpleMessage("vs"),
    "vietnamese": MessageLookupByLibrary.simpleMessage("Tiếng Việt"),
    "viewAll": MessageLookupByLibrary.simpleMessage("Xem tất cả"),
    "viewFixtures": MessageLookupByLibrary.simpleMessage("Xem lịch thi đấu"),
    "viewStandings": MessageLookupByLibrary.simpleMessage("Xem bảng xếp hạng"),
    "viewUpcoming": MessageLookupByLibrary.simpleMessage("Xem vòng đấu tới"),
    "wonShort": MessageLookupByLibrary.simpleMessage("T"),
  };
}
