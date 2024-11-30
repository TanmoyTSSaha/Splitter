import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Model/product_category_model.dart';
import 'package:splitter/Model/personal_transaction_model.dart';
import 'package:splitter/Model/user_details_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuth {
  final supabase = Supabase.instance.client;

  String supabaseGetUserID() {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      Fluttertoast.showToast(
        msg: "Something went wrong.",
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );

      return "";
    }

    return currentUser.id;
  }

  Future<bool> supabaseEmailPassSignIn(
      {required String userEmail, required String userPassword}) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: userEmail,
        password: userPassword,
      );

      final Session? session = response.session;
      final User? user = response.user;

      debugPrint("Session: $session |\t User: $user");

      if (user == null) {
        Fluttertoast.showToast(
          msg: "Invalid user details!",
          textColor: neopopBackground,
          backgroundColor: neopopYellow,
        );

        return false;
      }

      return true;
    } on AuthException catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(
        msg: e.message.toString(),
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );
      return false;
    } catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(
        msg: e.toString(),
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );
      return false;
    }
  }

  void supabaseSignOut() async {
    try {
      await supabase.auth.signOut().then(
        (value) {
          Fluttertoast.showToast(
            msg: "Logged out successfully.",
            textColor: neopopBackground,
            backgroundColor: neopopYellow,
          );
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );
    }
  }

  bool supabaseRetrieveSession() {
    try {
      final Session? session = supabase.auth.currentSession;

      if (session == null) {
        debugPrint("SESSION STATUS: $session");
        return false;
      }

      if (session.isExpired) {
        Fluttertoast.showToast(
          msg: "Session expired! Please login again.",
          textColor: neopopBackground,
          backgroundColor: neopopYellow,
        );

        return false;
      }

      return true;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "$e. Please login again.",
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );

      return false;
    }
  }
}

class SupabaseDatabase {
  final supabase = Supabase.instance.client;

  Future<List<PersonalTransactionModel>> getPersonalTransaction(
      {required String userID, int? limit}) async {
    final data = limit != null
        ? await supabase
            .from("personal_transactions")
            .select()
            .eq("user_id", userID)
            .order("transaction_date", ascending: false)
            .limit(limit)
        : await supabase
            .from("personal_transactions")
            .select()
            .eq("user_id", userID)
            .order("transaction_date", ascending: false);

    List<PersonalTransactionModel> personalTransactionsModel = [];

    for (final singleData in data) {
      PersonalTransactionModel personalTransaction;

      personalTransaction = PersonalTransactionModel.fromJSON(singleData);

      personalTransactionsModel.add(personalTransaction);
    }

    return personalTransactionsModel;
  }

  Future<List<PersonalTransactionWithProductCategoryModel>>
      getHomePhaseExpenseHistory({required String userID}) async {
    final personal_transaction_data = await supabase
        .from("personal_transactions")
        .select()
        .eq("user_id", userID)
        .order("transaction_date", ascending: false)
        .limit(10);

    List<PersonalTransactionModel> personalTransactionsModel = [];
    List<String> productCategories = [];

    for (final singleData in personal_transaction_data) {
      PersonalTransactionModel personalTransaction;

      personalTransaction = PersonalTransactionModel.fromJSON(singleData);

      productCategories.add(singleData["category"]);

      personalTransactionsModel.add(personalTransaction);
    }

    final productCategoryData = await supabase
        .from("master_product_categorisation")
        .select("category, category_logo")
        .inFilter("category", productCategories);

    List<CategoryOnlyModel> categories = [];
    List<String> categoriesString = [];

    for (var element in productCategoryData) {
      if (!categoriesString.contains(element["category"])) {
        categories.add(CategoryOnlyModel.fromJSON(element));
        categoriesString.add(element["category"]);
      }
    }

    categoriesString = [];

    List<PersonalTransactionWithProductCategoryModel>
        personalTransactionWithCategoryList = [];

    for (var i = 0; i < personalTransactionsModel.length; i++) {
      for (var j = 0; j < categories.length; j++) {
        if (personalTransactionsModel[i].category == categories[j].category) {
          personalTransactionWithCategoryList.add(
              PersonalTransactionWithProductCategoryModel.fromModel(
                  personalTransactionsModel[i], categories[j]));
        }
      }
    }

    return personalTransactionWithCategoryList;
  }

  Future<List<GroupMembers>> getGroupMembersData(
      {required String userID}) async {
    try {
      final groupMemberData =
          await supabase.from("group_members").select().eq("user_id", userID);

      List<GroupMembers> groupMembersDetails = [];

      for (var element in groupMemberData) {
        groupMembersDetails.add(GroupMembers.fromJSON(element));
      }

      return groupMembersDetails;
    } catch (e) {
      debugPrint("GROUP MEMBER EXCEPTION: $e");
      List<GroupMembers> groupMembersDetails = [];
      return groupMembersDetails;
    }
  }

  List<ConsolidatedGroupTransactionModel> getConsolidatedGroupTransactionData(
      {required List<GroupTransactionModel> groupTransactionList}) {
    List<ConsolidatedGroupTransactionModel> cnsGrpTrnsData = [];
    List<String> transactionGroupIDs = [];
    List<String> categories = [];
    // List<String> userIDs = [];

    for (var element in groupTransactionList) {
      if (!transactionGroupIDs.contains(element.transactionGroupID!)) {
        transactionGroupIDs.add(element.transactionGroupID!);
      }
    }

    for (var element in groupTransactionList) {
      if (!categories.contains(element.category!)) {
        categories.add(element.category!);
      }
    }

    for (var element in transactionGroupIDs) {
      List<GroupTransactionModel> grpTrnsList = [];

      for (var grpTrnselem in groupTransactionList) {
        if (element == grpTrnselem.transactionGroupID) {
          grpTrnsList.add(grpTrnselem);
        }
      }

      cnsGrpTrnsData.add(ConsolidatedGroupTransactionModel.fromTransactionModel(
        grpTrnsList,
      ));
    }

    return cnsGrpTrnsData;
  }

  Future<List<GroupTransactionModel>> getGroupTransactionsData(
      {required String userID, required String groupID}) async {
    final grpTrnsData = await supabase
        .from("group_transaction")
        .select()
        .eq("group_id", groupID);

    List<GroupTransactionModel> groupTransactions = [];
    List<String> categories = [];

    for (var element in grpTrnsData) {
      if (!categories.contains(element["category"])) {
        categories.add(element["category"]);
      }
    }

    final masterProdCategory = await supabase
        .from("master_product_categorisation")
        .select("category, category_logo")
        .inFilter('category', categories);

    List<Map<String, dynamic>> distinctMasterProdCategory = [];
    List<String> distinctCategory = [];

    for (var element in masterProdCategory) {
      if (!distinctCategory.contains(element["category"])) {
        distinctCategory.add(element["category"]);
        distinctMasterProdCategory.add(element);
      }
    }

    for (var element in grpTrnsData) {
      // OPTIMIZATION NEEDED HERE -> INSTEAD OF CALLING BELOW 2 QUERIES AGAIN AND AGAIN FOR EACH TRANSACTIONS, FIRST SAVE THE USER ID'S BY RUNNING A FOR LOOP OVER THE RAW MAP DATA AND SAVE THE USER ID'S AND QUERY FOR ALL THOSE ID'S AT ONCE. THEN RUN ANOTHER FOR LOOP TO MATCH THE DATA WITH IT'S RESPECTIVE GROUP TRANSACTION.
      final paidByUserMap = await supabase
          .from("users")
          .select("firstname, lastname")
          .eq('user_id', element["paid_by"])
          .single();

      final sharedWithUserMap = await supabase
          .from("users")
          .select("firstname, lastname")
          .eq('user_id', element["paid_by"])
          .single();

      for (var masterCatElem in distinctMasterProdCategory) {
        if (masterCatElem["category"] == element["category"]) {
          groupTransactions.add(
            GroupTransactionModel.fromJSON(
              element,
              "${paidByUserMap["firstname"]} ${paidByUserMap["lastname"]}",
              "${sharedWithUserMap["firstname"]} ${sharedWithUserMap["lastname"]}",
              masterCatElem["category_logo"],
            ),
          );
        }
      }
    }

    return groupTransactions;
  }

  Future<List<GroupModel>> getGroupData({required String userID}) async {
    try {
      List<GroupMembers> groupMembers =
          await getGroupMembersData(userID: userID);

      List<String> groupIDs = [];

      for (var element in groupMembers) {
        groupIDs.add(element.groupID!.toString());
      }

      final groupData = await supabase
          .from("groups")
          .select()
          .inFilter('group_id', groupIDs)
          .order('updated_on', ascending: false)
          .order('group_name', ascending: true);

      List<GroupModel> groupModelData = [];

      for (var element in groupData) {
        List<Map<String, dynamic>> groupBalanceList = [];
        for (var elm in (element["group_balance"] as List<dynamic>)) {
          Map<String, dynamic> groupBalance = {};
          groupBalance["donor"] = elm["donor"];
          groupBalance["donor_id"] = elm["donor_id"];
          groupBalance["receiver"] = elm["receiver"];
          groupBalance["receiver_id"] = elm["receiver_id"];
          groupBalance["amount"] = double.parse(elm["amount"].toString());

          groupBalanceList.add(groupBalance);
        }

        element["group_balance"] = groupBalanceList;

        GroupModel groupModel = GroupModel.fromJSON(element);
        groupModelData.add(groupModel);
      }

      return groupModelData;
    } catch (e) {
      debugPrint("GROUPS EXCEPTION: $e");
      List<GroupModel> groupModelData = [];
      return groupModelData;
    }
  }

  Future<UserDetails> getCurrentUserProfile({required String userID}) async {
    final data =
        await supabase.from("users").select().eq("user_id", userID).single();

    UserDetails userDetails = UserDetails.fromJSON(data);

    return userDetails;
  }

  Future<List<GroupMembersWithNameModel>> getGroupMembers(
      {required String groupID, required String currentUserID}) async {
    final groupMembersRawData =
        await supabase.from("group_members").select().eq("group_id", groupID);

    List<String> userIDs = [];

    for (var element in groupMembersRawData) {
      userIDs.add(element["user_id"]);
    }

    final groupMembersNameData = await supabase
        .from("users")
        .select("user_id, firstname, lastname, profile_picture_url")
        .inFilter("user_id", userIDs);

    List<GroupMembersWithNameModel> grpMbrNmList = [];

    for (var grpElem in groupMembersRawData) {
      for (var userElem in groupMembersNameData) {
        if (grpElem["user_id"] == userElem["user_id"]) {
          GroupMembers groupMembersModel = GroupMembers.fromJSON(
            {
              "group_id": grpElem["group_id"],
              "user_id": grpElem["user_id"],
            },
          );

          grpMbrNmList.add(
            GroupMembersWithNameModel.fromVariables(
              groupMembersModel,
              currentUserID == userElem["user_id"]
                  ? userElem["firstname"] + " " + userElem["lastname"] + "(you)"
                  : userElem["firstname"] + " " + userElem["lastname"] + "",
              userElem["profile_picture_url"] ?? "",
            ),
          );
        }
      }
    }

    return grpMbrNmList;
  }

  Future<List<Map<String, dynamic>>> getDistinctGroups(
      {required String userID}) async {
    List<Map<String, dynamic>> distinctGroupRawData = await supabase
        .from("group_members")
        .select("group_id")
        .eq("user_id", userID);

    List<String> distinctGroupIDs = [];

    for (var element in distinctGroupRawData) {
      if (!distinctGroupIDs.contains(element["group_id"])) {
        distinctGroupIDs.add(element["group_id"]);
      }
    }

    distinctGroupRawData = await supabase
        .from("groups")
        .select("group_id, group_name")
        .inFilter("group_id", distinctGroupIDs);

    List<Map<String, dynamic>> distinctMapGroupDetails = [];

    for (var element in distinctGroupRawData) {
      distinctMapGroupDetails.add(element);
    }

    return distinctMapGroupDetails;
  }
}
