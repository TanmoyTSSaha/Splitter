import 'package:flutter/material.dart';
import 'package:splitr/Screen/LendingScreen/loan_contract_form_screen.dart';

class CreateLoanScreen extends StatelessWidget {
  const CreateLoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoanContractFormScreen(mode: LoanFormMode.lend);
  }
}
