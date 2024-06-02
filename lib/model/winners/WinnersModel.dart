class WinnersModel {
  WinnersModel({
    this.status = "",
    this.message = "",
    required this.votingVideoList,
    this.totalVideo,
  });

  late final String status;
  late final String message;
  late final List<WinnersModelList> votingVideoList;
  int? totalVideo;

  WinnersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    votingVideoList = List.from(json['voting_video_list'])
        .map((e) => WinnersModelList.fromJson(e))
        .toList();
    totalVideo = json['total_video'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['voting_video_list'] =
        votingVideoList.map((e) => e.toJson()).toList();
    _data['total_video'] = totalVideo;
    return _data;
  }
}

class WinnersModelList {
  WinnersModelList({
    required this.id,
    required this.beatName,
    required this.artistName,
    required this.uniqueName,
    required this.path,
    required this.createdAt,
    required this.imageUniqueName,
    required this.imagePath,
    this.savedVideoLocation,
    this.videoType,
    required this.tos
  });

  late final int id;
  late final String beatName;
  late final String artistName;
  late final String uniqueName;
  late final String path;
  late final String createdAt;
  late final String imageUniqueName;
  late final String imagePath;
  late final num tos;
  late String? savedVideoLocation;
  late num? videoType;

  WinnersModelList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    beatName = json['beat_name'];
    artistName = json['stage_name'];
    uniqueName = json['uniqueName'];
    path = json['path'];
    createdAt = json['created_at'];
    imageUniqueName = json['image_uniqueName'];
    tos = json['tos'] == null? 0:json['tos'];
    imagePath = json['image_path'];
    savedVideoLocation = "";
    videoType = json["video_type"] == null ? 1 : json["video_type"];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['beat_name'] = beatName;
    _data['stage_name'] = artistName;
    _data['uniqueName'] = uniqueName;
    _data['path'] = path;
    _data['created_at'] = createdAt;
    _data['image_uniqueName'] = imageUniqueName;
    _data['image_path'] = imagePath;
    _data['saved_location'] = savedVideoLocation;
    _data['video_type'] = videoType;
    _data['tos'] = tos;
    return _data;
  }
}
