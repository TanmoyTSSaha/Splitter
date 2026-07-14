import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controller/all_transactions_controller.dart';
import 'package:splitr/Screen/HomeScreen/widgets/personal_transaction_sheet.dart';
import 'package:splitr/Screen/HomeScreen/widgets/transaction_filter_sheet.dart';
import 'package:splitr/Screen/HomeScreen/widgets/transaction_section_header.dart';
import 'package:splitr/Screen/HomeScreen/widgets/transaction_sort_sheet.dart';
import 'package:splitr/Utils/transaction_section_grouper.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Widgets/transaction_tile.dart';

class AllTransactionsScreen extends StatefulWidget {
  final bool? isGroupFilter;
  final bool? isTripFilter;
  final List<dynamic>? groups;
  final Set<String>? tripGroupIds;

  const AllTransactionsScreen({
    super.key,
    this.isGroupFilter,
    this.isTripFilter,
    this.groups,
    this.tripGroupIds,
  });

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  late final AllTransactionsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      AllTransactionsController(
        isGroupFilter: widget.isGroupFilter,
        isTripFilter: widget.isTripFilter,
        groups: widget.groups,
        tripGroupIds: widget.tripGroupIds,
      ),
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<AllTransactionsController>()) {
      Get.delete<AllTransactionsController>();
    }
    super.dispose();
  }

  String _title() {
    if (widget.isGroupFilter == true) return AppStrings.home.groupTransactions;
    if (widget.isTripFilter == true) return AppStrings.home.tripTransactions;
    return AppStrings.home.allTransactions;
  }

  void _openPersonalTransactionSheet(Map<String, dynamic> txn) {
    PersonalTransactionSheet.show(
      context,
      txn: txn,
      onChanged: _controller.fetchTransactions,
    );
  }

  List<Widget> _buildListItems(List<TransactionSection> sections) {
    final items = <Widget>[];
    for (final section in sections) {
      items.add(TransactionSectionHeader(title: section.header));
      for (final txn in section.transactions) {
        items.add(TransactionTile(
          txn: txn,
          onLongPress: txn['type'] != TransactionTypes.group
              ? () => _openPersonalTransactionSheet(txn)
              : null,
        ));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: _title(),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: groupOnSurface),
            tooltip: AppStrings.a11y.sort,
            onPressed: () => TransactionSortSheet.show(context, _controller),
          ),
          Obx(() {
            final count = _controller.activeFilterCount;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list, color: groupOnSurface),
                  tooltip: AppStrings.a11y.filter,
                  onPressed: () =>
                      TransactionFilterSheet.show(context, _controller),
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(groupGapXxs),
                      decoration: const BoxDecoration(
                        color: neopopAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: caption_text.copyWith(
                          color: neopopOnBackground,
                          fontSize: splitrFontNanoSm,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: neopopBackground,
              size: AppDimensions.loadingIndicatorLg,
            ),
          );
        }

        final sections = _controller.sections;
        final error = _controller.fetchError.value;
        if (sections.isEmpty && error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  error,
                  style: body1_text.copyWith(color: groupOnSurfaceMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: groupGapMd),
                TextButton(
                  onPressed: () => _controller.fetchTransactions(reset: true),
                  child: Text(
                    AppStrings.actions.tryAgain,
                    style: body2_text.copyWith(color: neopopAccent),
                  ),
                ),
              ],
            ),
          );
        }
        if (sections.isEmpty) {
          return Center(
            child: Text(
              AppStrings.home.noTransactions,
              style: body1_text.copyWith(color: groupOnSurfaceMuted),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: groupGutter),
              sliver: SliverList(
                delegate: SliverChildListDelegate(_buildListItems(sections)),
              ),
            ),
            if (_controller.canLoadOlder.value)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(groupGutter),
                  child: Obx(() {
                    final loading = _controller.isLoadingOlder.value;
                    return TextButton(
                      onPressed: loading ? null : _controller.loadOlder,
                      child: loading
                          ? const SizedBox(
                              height: AppDimensions.loadingIndicatorSm,
                              width: AppDimensions.loadingIndicatorSm,
                              child: CircularProgressIndicator(
                                strokeWidth: groupProgressStrokeWidth,
                                color: neopopAccent,
                              ),
                            )
                          : Text(
                              AppStrings.home.loadOlder,
                              style: body1_text.copyWith(
                                color: neopopAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  }),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: groupGapMd)),
          ],
        );
      }),
    );
  }
}
