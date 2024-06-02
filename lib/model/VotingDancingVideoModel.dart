class VotingDancingVideoModel {
  VotingDancingVideoModel({
    this.status = "",
    this.message = "",
    required this.votingVideoList,
  });

  late final String status;
  late final String message;
  late final int version;
  late final List<VotingVideoList> votingVideoList;

  VotingDancingVideoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    version = json['version'] == null ? 0 : json['version'];
    votingVideoList = List.from(json['voting_video_list'])
        .map((e) => VotingVideoList.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['version'] = version;
    _data['voting_video_list'] =
        votingVideoList.map((e) => e.toJson()).toList();
    return _data;
  }
}

class VotingVideoList {
  VotingVideoList({
    required this.id,
    required this.videoName,
    required this.uniqueName,
    required this.path,
    required this.imageUniqueName,
    required this.imagePath,
    required this.beatName,
    required this.artistName,
    this.savedVideoLocation,
    this.savedThumbLocation,
    required this.tos
  });

  late final int id;
  late final String videoName;
  late final String uniqueName;
  late final String path;
  late final String imageUniqueName;
  late final String imagePath;
  late final String beatName;
  late final String artistName;
  late final num tos;
  late String? savedVideoLocation;
  late String? savedThumbLocation;

  VotingVideoList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    videoName = json['video_name'] == null ? "" : json['video_name'];
    uniqueName = json['uniqueName'];
    path = json['path'];
    imageUniqueName = json['image_uniqueName'];
    imagePath = json['image_path'];
    beatName = json['beat_name'];
    tos = json['tos'] == null ? 0 : json['tos'];
    artistName = json['stage_name'] == null ? "" : json['stage_name'];
    savedVideoLocation = "";
    savedThumbLocation = "";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['video_name'] = videoName;
    _data['uniqueName'] = uniqueName;
    _data['path'] = path;
    _data['image_uniqueName'] = imageUniqueName;
    _data['image_path'] = imagePath;
    _data['beat_name'] = beatName;
    _data['stage_name'] = artistName;
    _data['saved_location'] = savedVideoLocation;
    _data['saved_thumb'] = savedThumbLocation;
    _data['tos'] = tos;
    return _data;
  }
}
