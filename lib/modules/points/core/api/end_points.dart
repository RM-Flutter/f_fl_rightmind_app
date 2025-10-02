import 'package:cpanal/general_services/app_config.service.dart';
import 'package:provider/provider.dart';

class EndPoints {
  String postId = '';
  ///replace with token after login
  ///replace with deviceId after login
  static const String getHistory = '/rm_pointsys/v1/history';
  static const String getPrize = '/prizes/entities-operations';
  static const String coupoun = '/rm_pointsys/v1/redeem_gift_card';
  static const String conditions = '/rm_page/v1/show?slug=points-terms-and-conditions';
  static const String postGroups = '/social-groups/entities-operations';
  static const String postPrize = '/redeem-requests/entities-operations/store';
  static  String addComment = '/social-posts/entities-operations/:id/comments';
  static const String postsInGroup= '/social-posts/entities-operations?with=social_group_id,user_id';
}
