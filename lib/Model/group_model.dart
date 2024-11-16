class GroupModel {
  String? groupID;
  String? groupName;
  List<GroupBalanceModel>? groupBalance;
  DateTime? createdAt;
  DateTime? updatedOn;
  String? createdBy;

  GroupModel({
    this.groupID,
    this.groupName,
    this.groupBalance,
    this.createdAt,
    this.updatedOn,
    this.createdBy,
  });

  GroupModel.fromJSON(Map<String, dynamic> data) {
    List<GroupBalanceModel> groupBalanceList = [];

    for (var element in (data["group_balance"] as List<Map<String, dynamic>>)) {
      groupBalanceList.add(GroupBalanceModel.fromJSON(element));
    }

    groupID = data["group_id"];
    groupName = data["group_name"];
    groupBalance = groupBalanceList;
    createdAt = DateTime.parse(data["created_at"]);
    updatedOn = DateTime.parse(data["updated_on"]);
    createdBy = data["created_by"];
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};
    List<Map<String, dynamic>> groupBalanceData = [];
    for (var element in groupBalance!) {
      groupBalanceData.add(element.toJSON());
    }

    data["group_id"] = groupID;
    data["group_name"] = groupName;
    data["group_balance"] = groupBalanceData;
    data["created_at"] = createdAt;
    data["updated_on"] = updatedOn;
    data["created_by"] = createdBy;

    return data;
  }
}

class GroupBalanceModel {
  String? donor;
  String? donorID;
  String? receiver;
  String? receiverID;
  double? amount;

  GroupBalanceModel({
    this.donor,
    this.donorID,
    this.receiver,
    this.receiverID,
    this.amount,
  });

  GroupBalanceModel.fromJSON(Map<String, dynamic> data) {
    donor = data["donor"];
    donorID = data["donor_id"];
    receiver = data["receiver"];
    receiverID = data["receiver_id"];
    amount = double.parse(data["amount"].toString());
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};

    data["donor"] = donor;
    data["donor_id"] = donorID;
    data["receiver"] = receiver;
    data["receiver_id"] = receiverID;
    data["amount"] = amount;

    return data;
  }
}

class GroupMembers {
  String? groupID;
  String? userID;

  GroupMembers({this.groupID, this.userID});

  GroupMembers.fromJSON(Map<String, dynamic> data) {
    groupID = data["group_id"];
    userID = data["user_id"];
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};

    data["group_id"] = groupID;
    data["user_id"] = userID;

    return data;
  }
}

class GroupTransactionModel {
  String? transactionID;
  String? transactionGroupID;
  String? groupID;
  String? paidByUUID;
  String? paidByName;
  String? sharedWithUUID;
  String? sharedWithName;
  double? totalTransactionAmount;
  double? sharedTransactionAmount;
  double? sharedPercentage;
  double? selfShareAmount;
  double? selfSharePercentage;
  String? sharingType;
  String? category;
  String? categoryLogo;
  String? description;
  String? transactionPhoto;
  String? transactionNote;
  bool? isSettledUp;
  DateTime? transactionDate;

  GroupTransactionModel({
    this.transactionID,
    this.transactionGroupID,
    this.groupID,
    this.paidByUUID,
    this.paidByName,
    this.sharedWithUUID,
    this.sharedWithName,
    this.totalTransactionAmount,
    this.sharedTransactionAmount,
    this.sharedPercentage,
    this.selfShareAmount,
    this.selfSharePercentage,
    this.sharingType,
    this.category,
    this.categoryLogo,
    this.description,
    this.transactionPhoto,
    this.transactionNote,
    this.isSettledUp,
    this.transactionDate,
  });

  GroupTransactionModel.fromJSON(Map<String, dynamic> data,
      String paidByNameStr, String sharedWithNameStr, String categoryLogoStr) {
    transactionID = data["transaction_id"];
    transactionGroupID = data["transaction_group_id"];
    groupID = data["group_id"];
    paidByUUID = data["paid_by"];
    paidByName = paidByNameStr;
    sharedWithUUID = data["shared_with"];
    sharedWithName = sharedWithNameStr;
    totalTransactionAmount =
        double.parse(data["total_transaction_amount"].toString());
    sharedTransactionAmount =
        double.parse(data["shared_transaction_amount"].toString());
    sharedPercentage = double.parse(data["shared_percentage"].toString());
    selfShareAmount = double.parse(data["self_share_amount"].toString());
    selfSharePercentage =
        double.parse(data["self_share_percentage"].toString());
    sharingType = data["sharing_type"];
    category = data["category"];
    categoryLogo = categoryLogoStr;
    description = data["description"];
    transactionPhoto = data["transaction_photo"];
    transactionNote = data["transaction_note"];
    isSettledUp = data["is_settled_up"];
    transactionDate = DateTime.parse(data["transaction_date"]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};

    data["transaction_id"] = transactionID;
    data["transaction_group_id"] = transactionGroupID;
    data["group_id"] = groupID;
    data["paid_by"] = paidByUUID;
    data["shared_with"] = sharedWithUUID;
    data["total_transaction_amount"] = totalTransactionAmount;
    data["shared_transaction_amount"] = sharedTransactionAmount;
    data["shared_percentage"] = sharedPercentage;
    data["sharing_type"] = sharingType;
    data["category"] = category;
    data["description"] = description;
    data["transaction_photo"] = transactionPhoto;
    data["transaction_note"] = transactionNote;
    data["transaction_date"] = transactionDate;

    return data;
  }
}

class ConsolidatedGroupTransactionModel {
  String? transactionGroupID;
  String? groupID;
  String? paidByUUID;
  String? paidByName;
  double? totalTransactionAmount;
  double? selfSharingAmount;
  double? selfSharingPercentage;
  List<ConsolidatedGroupTransactionSharedTransactionModel>? sharedWith;
  String? sharingType;
  String? category;
  String? categoryLogo;
  String? description;
  String? transactionPhotoURL;
  String? transactionNote;
  bool? isSettledUp;
  DateTime? transactionDate;

  ConsolidatedGroupTransactionModel({
    this.transactionGroupID,
    this.groupID,
    this.paidByUUID,
    this.paidByName,
    this.totalTransactionAmount,
    this.selfSharingAmount,
    this.selfSharingPercentage,
    this.sharedWith,
    this.sharingType,
    this.category,
    this.categoryLogo,
    this.description,
    this.transactionPhotoURL,
    this.transactionNote,
    this.isSettledUp,
    this.transactionDate,
  });

  ConsolidatedGroupTransactionModel.fromTransactionModel(
      List<GroupTransactionModel> groupTransactionModel) {
    List<ConsolidatedGroupTransactionSharedTransactionModel> sharedWithList =
        [];

    for (var element in groupTransactionModel) {
      Map<String, dynamic> data = <String, dynamic>{
        "shared_with_uuid": element.sharedWithUUID,
        "shared_with_name": element.sharedWithName,
        "shared_transaction_amount": element.sharedTransactionAmount,
        "shared_percentage": element.sharedPercentage,
      };

      sharedWithList.add(
          ConsolidatedGroupTransactionSharedTransactionModel.fromJSON(data));
    }

    transactionGroupID = groupTransactionModel[0].transactionGroupID;
    groupID = groupTransactionModel[0].groupID;
    paidByUUID = groupTransactionModel[0].paidByUUID;
    paidByName = groupTransactionModel[0].paidByName;
    totalTransactionAmount = groupTransactionModel[0].totalTransactionAmount;
    selfSharingAmount = groupTransactionModel[0].selfShareAmount;
    selfSharingPercentage = groupTransactionModel[0].selfSharePercentage;
    sharedWith = sharedWithList;
    sharingType = groupTransactionModel[0].sharingType;
    category = groupTransactionModel[0].category;
    categoryLogo = groupTransactionModel[0].categoryLogo;
    description = groupTransactionModel[0].description;
    transactionPhotoURL = groupTransactionModel[0].transactionPhoto;
    transactionNote = groupTransactionModel[0].transactionNote;
    isSettledUp = groupTransactionModel[0].isSettledUp;
    transactionDate = groupTransactionModel[0].transactionDate;
  }
}

class ConsolidatedGroupTransactionSharedTransactionModel {
  String? sharedWithUUID;
  String? sharedWithName;
  double? sharedTransactionAmount;
  double? sharedPercentage;

  ConsolidatedGroupTransactionSharedTransactionModel({
    this.sharedWithUUID,
    this.sharedWithName,
    this.sharedTransactionAmount,
    this.sharedPercentage,
  });

  ConsolidatedGroupTransactionSharedTransactionModel.fromJSON(
      Map<String, dynamic> data) {
    sharedWithUUID = data["shared_with_uuid"];
    sharedWithName = data["shared_with_name"];
    sharedTransactionAmount =
        double.parse(data["shared_transaction_amount"].toString());
    sharedPercentage = double.parse(data["shared_percentage"].toString());
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};

    data["shared_with_uuid"] = sharedWithUUID;
    data["shared_with_name"] = sharedWithName;
    data["shared_transaction_amount"] = sharedTransactionAmount;
    data["shared_percentage"] = sharedPercentage;

    return data;
  }
}

class GroupMembersWithNameModel {
  String? groupID;
  String? userID;
  String? userName;
  String? userPic;

  GroupMembersWithNameModel({
    this.groupID,
    this.userID,
    this.userName,
    this.userPic,
  });

  GroupMembersWithNameModel.fromVariables(GroupMembers groupMember,
      String memberName, String memberProfilePictureURL) {
    groupID = groupMember.groupID;
    userID = groupMember.userID;
    userName = memberName;
    userPic = memberProfilePictureURL;
  }
}
