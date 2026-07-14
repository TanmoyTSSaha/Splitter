import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';

class GroupModel {
  String? groupID;
  String? groupName;
  List<GroupBalanceModel>? groupBalance;
  DateTime? createdAt;
  DateTime? updatedOn;
  String? createdBy;
  bool isTrip;
  bool isArchived;

  GroupModel({
    this.groupID,
    this.groupName,
    this.groupBalance,
    this.createdAt,
    this.updatedOn,
    this.createdBy,
    this.isTrip = false,
    this.isArchived = false,
  });

  GroupModel.fromJSON(Map<String, dynamic> data)
      : isTrip = data[SupabaseColumns.isTrip] ?? false,
        isArchived = data[SupabaseColumns.isArchived] == true {
    List<GroupBalanceModel> groupBalanceList = [];

    if (data[SupabaseColumns.groupBalance] != null) {
      for (var element
          in (data[SupabaseColumns.groupBalance] as List<dynamic>)) {
        groupBalanceList.add(GroupBalanceModel.fromJSON(element));
      }
    }

    groupID = data[SupabaseColumns.groupId];
    groupName = data[SupabaseColumns.groupName];
    groupBalance = groupBalanceList;
    createdAt = DateTime.tryParse(data[SupabaseColumns.createdAt].toString());
    updatedOn = DateTime.tryParse(data[SupabaseColumns.updatedOn].toString());
    createdBy = data[SupabaseColumns.createdBy];
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};
    List<Map<String, dynamic>> groupBalanceData = [];
    if (groupBalance != null) {
      for (var element in groupBalance!) {
        groupBalanceData.add(element.toJSON());
      }
    }

    data[SupabaseColumns.groupId] = groupID;
    data[SupabaseColumns.groupName] = groupName;
    data[SupabaseColumns.groupBalance] = groupBalanceData;
    data[SupabaseColumns.createdAt] = createdAt?.toIso8601String();
    data[SupabaseColumns.updatedOn] = updatedOn?.toIso8601String();
    data[SupabaseColumns.createdBy] = createdBy;
    data[SupabaseColumns.isTrip] = isTrip;

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
    donor = data[GroupBalanceKeys.donor];
    donorID = data[GroupBalanceKeys.donorId];
    receiver = data[GroupBalanceKeys.receiver];
    receiverID = data[GroupBalanceKeys.receiverId];
    amount = double.parse(data[GroupBalanceKeys.amount].toString());
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};

    data[GroupBalanceKeys.donor] = donor;
    data[GroupBalanceKeys.donorId] = donorID;
    data[GroupBalanceKeys.receiver] = receiver;
    data[GroupBalanceKeys.receiverId] = receiverID;
    data[GroupBalanceKeys.amount] = amount;

    return data;
  }
}

class GroupMembers {
  String? groupID;
  String? userID;

  GroupMembers({this.groupID, this.userID});

  GroupMembers.fromJSON(Map<String, dynamic> data) {
    groupID = data[SupabaseColumns.groupId];
    userID = data[SupabaseColumns.userId];
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};

    data[SupabaseColumns.groupId] = groupID;
    data[SupabaseColumns.userId] = userID;

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
    transactionID = data[SupabaseColumns.transactionId];
    transactionGroupID = data[SupabaseColumns.transactionGroupId];
    groupID = data[SupabaseColumns.groupId];
    paidByUUID = data[SupabaseColumns.paidBy];
    paidByName = paidByNameStr;
    sharedWithUUID = data[SupabaseColumns.sharedWith];
    sharedWithName = sharedWithNameStr;
    totalTransactionAmount =
        double.parse(data[SupabaseColumns.totalTransactionAmount].toString());
    sharedTransactionAmount =
        double.parse(data[SupabaseColumns.sharedTransactionAmount].toString());
    sharedPercentage =
        double.parse(data[SupabaseColumns.sharedPercentage].toString());
    selfShareAmount =
        double.parse(data[SupabaseColumns.selfShareAmount].toString());
    selfSharePercentage =
        double.parse(data[SupabaseColumns.selfSharePercentage].toString());
    sharingType = data[SupabaseColumns.sharingType];
    category = data[SupabaseColumns.category];
    categoryLogo = categoryLogoStr;
    description = data[SupabaseColumns.description];
    transactionPhoto = data[SupabaseColumns.transactionPhoto];
    transactionNote = data[SupabaseColumns.transactionNote];
    isSettledUp = data[SupabaseColumns.isSettledUp];
    transactionDate = TransactionDateFormatter.parseStorage(
      data[SupabaseColumns.transactionDate],
    );
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};

    data[SupabaseColumns.transactionId] = transactionID;
    data[SupabaseColumns.transactionGroupId] = transactionGroupID;
    data[SupabaseColumns.groupId] = groupID;
    data[SupabaseColumns.paidBy] = paidByUUID;
    data[SupabaseColumns.sharedWith] = sharedWithUUID;
    data[SupabaseColumns.totalTransactionAmount] = totalTransactionAmount;
    data[SupabaseColumns.sharedTransactionAmount] = sharedTransactionAmount;
    data[SupabaseColumns.sharedPercentage] = sharedPercentage;
    data[SupabaseColumns.sharingType] = sharingType;
    data[SupabaseColumns.category] = category;
    data[SupabaseColumns.description] = description;
    data[SupabaseColumns.transactionPhoto] = transactionPhoto;
    data[SupabaseColumns.transactionNote] = transactionNote;
    data[SupabaseColumns.transactionDate] = transactionDate;

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
        ConsolidatedTxnKeys.sharedWithUuid: element.sharedWithUUID,
        ConsolidatedTxnKeys.sharedWithName: element.sharedWithName,
        ConsolidatedTxnKeys.sharedTransactionAmount:
            element.sharedTransactionAmount,
        ConsolidatedTxnKeys.sharedPercentage: element.sharedPercentage,
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
    sharedWithUUID = data[ConsolidatedTxnKeys.sharedWithUuid];
    sharedWithName = data[ConsolidatedTxnKeys.sharedWithName];
    sharedTransactionAmount = double.parse(
        data[ConsolidatedTxnKeys.sharedTransactionAmount].toString());
    sharedPercentage =
        double.parse(data[ConsolidatedTxnKeys.sharedPercentage].toString());
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};

    data[ConsolidatedTxnKeys.sharedWithUuid] = sharedWithUUID;
    data[ConsolidatedTxnKeys.sharedWithName] = sharedWithName;
    data[ConsolidatedTxnKeys.sharedTransactionAmount] = sharedTransactionAmount;
    data[ConsolidatedTxnKeys.sharedPercentage] = sharedPercentage;

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
