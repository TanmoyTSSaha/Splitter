$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

$skip = @(
  'donate_screen.dart',
  'premium_plan_screen.dart',
  'upi_sms_parser.dart',
  'receipt_parser_service.dart',
  'currency_service.dart',
  'currency_controller.dart',
  'currency_utils.dart',
  'migrate-currency-symbols.ps1'
)

$tripFiles = @(
  'trip_timeline_screen.dart',
  'shareable_trip_summary_card.dart'
)

$import = "import 'package:splitr/Utils/currency_utils.dart';"
$currencyImport = "import 'package:splitr/Services/currency_service.dart';"

function Add-ImportIfNeeded([string]$content, [string]$neededImport) {
  if ($content -match [regex]::Escape($neededImport)) { return $content }
  $m = [regex]::Match($content, "import 'package:[^']+';")
  if ($m.Success) {
    return $content.Insert($m.Index + $m.Length, "`n$neededImport")
  }
  return "$neededImport`n$content"
}

Get-ChildItem -Path lib -Recurse -Filter *.dart | ForEach-Object {
  if ($skip -contains $_.Name) { return }
  if ($tripFiles -contains $_.Name) { return }

  $c = Get-Content $_.FullName -Raw
  if ($c -notmatch '₹') { return }

  $orig = $c

  $c = $c -replace "prefixText: '₹ '", 'prefixText: currencyPrefixText()'
  $c = $c -replace 'prefixText: "₹ "', 'prefixText: currencyPrefixText()'
  $c = $c -replace 'hintText: "₹0\.00"', 'hintText: "${userCurrencySymbol()}0.00"'
  $c = $c -replace "Text\(`"₹`"", 'Text(userCurrencySymbol()'
  $c = $c -replace "labelText: 'Estimated Amount \(₹\)'", "labelText: 'Estimated Amount (${userCurrencySymbol()})'"
  $c = $c -replace '₹\$\{', '${userCurrencySymbol()}${'
  $c = $c -replace ' ₹\$\{', ' ${userCurrencySymbol()}${'
  $c = $c -replace '\+''\) : \(''-''\) ₹\$\{', "+') : ('-') `${userCurrencySymbol()}`${"
  $c = $c -replace '\$\{isDeposit \? ''\+'' : ''-''\} ₹\$\{', '${isDeposit ? ''+'' : ''-''} ${userCurrencySymbol()}${'
  $c = $c -replace "owes you ₹\$\{", 'owes you ${userCurrencySymbol()}${'
  $c = $c -replace "you owe ₹\$\{", 'you owe ${userCurrencySymbol()}${'
  $c = $c -replace "Paid ₹\$\{", 'Paid ${userCurrencySymbol()}${'
  $c = $c -replace "Share ₹\$\{", 'Share ${userCurrencySymbol()}${'
  $c = $c -replace "Total: ₹\$\{", 'Total: ${userCurrencySymbol()}${'
  $c = $c -replace "Is owed ₹\$\{", 'Is owed ${userCurrencySymbol()}${'
  $c = $c -replace "Owes ₹\$\{", 'Owes ${userCurrencySymbol()}${'
  $c = $c -replace '\$\{positive \? ''\+'' : ''-''\}₹\$\{', '${positive ? ''+'' : ''-''}${userCurrencySymbol()}${'
  $c = $c -replace "settled ₹\$\{", 'settled ${userCurrencySymbol()}${'
  $c = $c -replace "Confirm settlement of ₹\$\{", 'Confirm settlement of ${userCurrencySymbol()}${'
  $c = $c -replace "settlement of ₹\$\{", 'settlement of ${userCurrencySymbol()}${'
  $c = $c -replace "You only owe ₹\$\{", 'You only owe ${userCurrencySymbol()}${'
  $c = $c -replace "must equal ₹\$\{", 'must equal ${userCurrencySymbol()}${'
  $c = $c -replace "— ₹\$\{", '— ${userCurrencySymbol()}${'
  $c = $c -replace "paid you ₹\$\{", 'paid you ${userCurrencySymbol()}${'
  $c = $c -replace "paid \$\{", 'paid ${'  # noop guard
  $c = $c -replace "You paid \$\{first", 'You paid ${first'  # noop
  $c = $c -replace " owes ₹\$\{", ' owes ${userCurrencySymbol()}${'
  $c = $c -replace "You get ₹\$\{", 'You get ${userCurrencySymbol()}${'
  $c = $c -replace "You owe ₹\$\{", 'You owe ${userCurrencySymbol()}${'
  $c = $c -replace "Reminder: ₹\{amount\}", 'Reminder: {amount}'  # template - handle separately
  $c = $c -replace "💰 \$description — ₹\$amount", '💰 $description — ${userCurrencySymbol()}$amount'
  $c = $c -replace ": '₹';", ": CurrencyService.symbolFor('INR');"
  $c = $c -replace "return '₹';", "return CurrencyService.symbolFor('INR');"
  $c = $c -replace "'\$\{context\['currency'\] \?\? '₹'\}", "'`${context['currency'] ?? userCurrencySymbol()}"
  $c = $c -replace 'Target: ₹\$targetAmount', 'Target: ${userCurrencySymbol()}$targetAmount'
  $c = $c -replace 'Required Monthly Saving: ₹\$\{', 'Required Monthly Saving: ${userCurrencySymbol()}${'

  if ($c -eq $orig) { return }

  if ($c -match 'userCurrencySymbol|currencyPrefixText|CurrencyService\.symbolFor') {
    $c = Add-ImportIfNeeded $c $import
  }
  if ($c -match 'CurrencyService\.symbolFor') {
    $c = Add-ImportIfNeeded $c $currencyImport
  }

  Set-Content -Path $_.FullName -Value $c -NoNewline
  Write-Output $_.FullName
}
