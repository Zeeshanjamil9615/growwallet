class TreeNode {
  final int id;
  final String name;
  final String username;
  final String position;
  final int downlineCount;

  TreeNode({
    required this.id,
    required this.name,
    required this.username,
    required this.position,
    required this.downlineCount,
  });

  factory TreeNode.fromJson(Map<String, dynamic> json) {
    return TreeNode(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      position: json['position'] ?? '',
      downlineCount: json['downline_count'] ?? 0,
    );
  }

  String getInitials() {
    if (name.isEmpty) return 'U';
    List<String> names = name.trim().split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    } else {
      return '${names[0].substring(0, 1)}${names[1].substring(0, 1)}'.toUpperCase();
    }
  }
}

class TreeResponse {
  final bool success;
  final String message;
  final List<TreeNode> tree;
  final int teamCount;
  final bool downline;
  final int? left;
  final int? middle;
  final int? right;

  TreeResponse({
    required this.success,
    required this.message,
    required this.tree,
    required this.teamCount,
    required this.downline,
    this.left,
    this.middle,
    this.right,
  });

  factory TreeResponse.fromJson(Map<String, dynamic> json) {
    return TreeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      tree: (json['tree'] as List?)
          ?.map((item) => TreeNode.fromJson(item))
          .toList() ?? [],
      teamCount: json['team_count'] ?? 0,
      downline: json['downline'] ?? false,
      left: json['left'] != null ? json['left'] as int : null,
      middle: json['middle'] != null ? json['middle'] as int : null,
      right: json['right'] != null ? json['right'] as int : null,
    );
  }
}

// class TreeNode {
//   final int id;
//   final String name;
//   final String username;
//   final String position;
//   final int downlineCount;
//
//   TreeNode({
//     required this.id,
//     required this.name,
//     required this.username,
//     required this.position,
//     required this.downlineCount,
//   });
//
//   factory TreeNode.fromJson(Map<String, dynamic> json) {
//     return TreeNode(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       username: json['username'] ?? '',
//       position: json['position'] ?? '',
//       downlineCount: json['downline_count'] ?? 0,
//     );
//   }
//
//   String getInitials() {
//     if (name.isEmpty) return 'U';
//     List<String> names = name.trim().split(' ');
//     if (names.length == 1) {
//       return names[0].substring(0, 1).toUpperCase();
//     } else {
//       return '${names[0].substring(0, 1)}${names[1].substring(0, 1)}'.toUpperCase();
//     }
//   }
// }

// class TreeResponse {
//   final bool success;
//   final String message;
//   final List<TreeNode> tree;
//   final TreeNode? left;
//   final TreeNode? middle;
//   final TreeNode? right;
//
//   TreeResponse({
//     required this.success,
//     required this.message,
//     required this.tree,
//     this.left,
//     this.middle,
//     this.right,
//   });
//
//   factory TreeResponse.fromJson(Map<String, dynamic> json) {
//     return TreeResponse(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       tree: (json['tree'] as List?)
//           ?.map((item) => TreeNode.fromJson(item))
//           .toList() ?? [],
//       left: json['left'] != null ? TreeNode.fromJson(json['left']) : null,
//       middle: json['middle'] != null ? TreeNode.fromJson(json['middle']) : null,
//       right: json['right'] != null ? TreeNode.fromJson(json['right']) : null,
//     );
//   }
// }