import 'dart:io';

import 'package:flutter/foundation.dart';

import '../Service/CoreService.dart';
import '../Service/GlobalKeys.dart';
import '../util/localStorage.dart';

class MediaService {
  var localStorage = new LocalHiveStorage();

  getMusicTrack() async {
    String accessToken = await localStorage.getValue("access_token");
    final response = await CoreService().apiService(
      method: METHOD.GET,
      endpoint: GlobalKeys.GET_MUSIC_TRACK,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    return response;
  }
  getSliderDetails() async {
    String accessToken = await localStorage.getValue("access_token");
    final response = await CoreService().apiService(
      method: METHOD.GET,
      endpoint: GlobalKeys.GET_SLIDER_DETAILS,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );
    return response;
  }
  submitVideo(String videoUrl, String videoType, String size, int videLength,
      String stageName) async {
    String accessToken = await localStorage.getValue("access_token");
    String musicId = await localStorage.getValue("musicId");

    Map data = {
      "musicId": musicId,
      "videoUrl": videoUrl,
      "videoType": videoType,
      "beatTime": videLength.toString(),
      "videoLength": size + "mb",
      "stageName": stageName
    };
    final response = await CoreService().apiService(
      method: METHOD.POST,
      body: data,
      endpoint: GlobalKeys.SUBMIT_VIDEO,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    return response;
  }

  getVideoTrack() async {
    String accessToken = await localStorage.getValue("access_token");
    final response = await CoreService().apiService(
      method: METHOD.GET,
      endpoint: GlobalKeys.GET_DANCE_TRACK,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    return response;
  }

  getVotingSingingVideo() async {
    String accessToken = await localStorage.getValue("access_token");
    final response = await CoreService().apiService(
      method: METHOD.GET,
      endpoint: GlobalKeys.GET_SINGING_VOTING_VIDEO,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );
    return response;
  }

  getVotingDancingVideo() async {
    String accessToken = await localStorage.getValue("access_token");
    final response = await CoreService().apiService(
      method: METHOD.GET,
      endpoint: GlobalKeys.GET_DANCING_VOTING_VIDEO,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );
    return response;
  }

  submitVotingDanceVideo(int videoId, String artistName, String beatName,
      String videoName, String type, int vote) async {
    String accessToken = await localStorage.getValue("access_token");
    Map data = {
      "dance_video_id": videoId.toString(),
      "artist_name": artistName,
      "beat_name": beatName,
      "video_name": videoName,
      "vote": vote.toString(),
      "type": type
    };
    final response = await CoreService().apiService(
      method: METHOD.POST,
      body: data,
      endpoint: GlobalKeys.POST_VOTING_VIDEO,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    return response;
  }

  submitVotingSingVideo(int videoId, String artistName, String beatName,
      String videoName, String type, int vote) async {
    String accessToken = await localStorage.getValue("access_token");
    Map data = {
      "singing_video_id": videoId.toString(),
      "artist_name": artistName,
      "beat_name": beatName,
      "video_name": videoName,
      "vote": vote.toString(),
      "type": type
    };
    final response = await CoreService().apiService(
      method: METHOD.POST,
      body: data,
      endpoint: GlobalKeys.POST_VOTING_VIDEO,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    return response;
  }

  getWalletDetails() async {
    String accessToken = await localStorage.getValue("access_token");
    final response = await CoreService().apiService(
      method: METHOD.GET,
      endpoint: GlobalKeys.GET_WALLET_DETAILS,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    return response;
  }

  getUseDetailsWithWalletId({String? walletId}) async {
    var result;
    String accessToken = await localStorage.getValue("access_token");
    final response = await CoreService().apiService(
      method: METHOD.POST,
      endpoint: GlobalKeys.GET_USER_DETAILS_BY_ID,
      body: {"wallet_id": walletId},
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );
    if (response["status"] == "success") {
      result = response;
    } else {}
    return result;
  }

  getAvailablePaymentMethods(
    String password,
  ) async {
    String accessToken = await localStorage.getValue("access_token");
    Map data = {
      "password": password,
    };
    final response = await CoreService().apiService(
      method: METHOD.POST,
      body: data,
      endpoint: GlobalKeys.GET_PAYMENT_METHODS,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    return response;
  }

  buyTosToken(
      {String? password,
      String? tosToken,
      String? deviceType,
      String? gateway}) async {
    String accessToken = await localStorage.getValue("access_token");
    Map data = {"password": password, "amount": tosToken, "gateway": gateway};
    final response = await CoreService().apiService(
      method: METHOD.POST,
      body: data,
      endpoint: GlobalKeys.BUY_TOS_TOKEN,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    return response;
  }

  transferTosToken(String password, String tosToken, String userId) async {
    String accessToken = await localStorage.getValue("access_token");
    Map data = {
      "password": password,
      "tos_token": tosToken,
      "send_user_id": userId
    };
    final response = await CoreService().apiService(
      method: METHOD.POST,
      endpoint: GlobalKeys.TRANSFER_TOS_TOKEN,
      body: data,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    return response;
  }

  getWinnersList({int? videoType, int? pagination}) async {
    String accessToken = await localStorage.getValue("access_token");
    Map data = {
      "video_type": videoType.toString(),
      "next": pagination.toString()
    };
    final response = await CoreService().apiService(
      method: METHOD.POST,
      body: data,
      endpoint: GlobalKeys.GET_WINNERS_DANCING,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    return response;
  }

  searchWinner({String? search, int? pagination, int? videoType}) async {
    String accessToken = await localStorage.getValue("access_token");
    Map data = {
      "search_val": search,
      "next": pagination.toString(),
      "video_type": videoType.toString()
    };
    final response = await CoreService().apiService(
      method: METHOD.POST,
      endpoint: GlobalKeys.SEARCH_WINNERS_DANCE,
      body: data,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );

    return response;
  }

  getWalletHistoryDetails() async {
    var result;
    String accessToken = await localStorage.getValue("access_token");
    final response = await CoreService().apiService(
      method: METHOD.GET,
      endpoint: GlobalKeys.GET_WALLET_HISTORY_DETAILS,
      header: {HttpHeaders.authorizationHeader: "Bearer $accessToken"},
    );
    if (response["status"] == "success") {
      result = response;
    } else {}
    return result;
  }
}
