/// Local asset paths and external URL builders.
abstract final class AppAssets {
  static const emptyStateSplittingBills =
      'assets/dev_images/premium_empty_state_splitting_bills.png';

  static const iconArrowRight =
      'assets/icons/svg/solar--arrow-right-outline.svg';
  static const iconGoogle = 'assets/icons/svg/devicon--google.svg';
  static const iconNote = 'assets/icons/svg/hugeicons--note.svg';
  static const iconTag = 'assets/icons/svg/hugeicons--tag.svg';
  static const iconBill = 'assets/icons/svg/mingcute--bill-line.svg';
  static const iconEdit = 'assets/icons/svg/ic--baseline-edit.svg';
  static const iconEqual = 'assets/icons/svg/material-symbols--equal.svg';
  static const iconThreeDots = 'assets/icons/svg/bi--three-dots.svg';

  static const splashWordmarkStrokes =
      'assets/splash/splitr_wordmark_strokes.svg';
  static const splashWordmarkDark =
      'assets/brand/master/splitr-wordmark-dark-2048w.png';

  static const lottieRupeeCoin = 'assets/lottie/Rupee Coin.lottie';
  static const lottieRupeeCoinFallback = 'assets/lottie/rupee_coin.json';
  static const lottieAnimationsDir = 'animations/';
  static const lottieJsonSuffix = '.json';

  static const badgeExplorer = 'assets/badges/explorer.png';
  static const badgeMoneyBag = 'assets/badges/money_bag.png';
  static const badgeHandshake = 'assets/badges/handshake.png';
  static const badgeSun = 'assets/badges/sun.png';
}

abstract final class AppUrls {
  static const dicebearInitialsBase =
      'https://api.dicebear.com/9.x/initials/svg?seed=';
  static const dicebearIdenticonBase =
      'https://api.dicebear.com/9.x/identicon/svg?seed=';
  static const iconifyMoreHoriz =
      'https://api.iconify.design/material-symbols-light/more-horiz.svg';

  static String dicebearInitials(String seed) => '$dicebearInitialsBase$seed';
  static String dicebearIdenticon(String userId) =>
      '$dicebearIdenticonBase$userId&backgroundColor=transparent';
}

abstract final class AvatarSentinels {
  static const nullImageUrl = 'null';
}
