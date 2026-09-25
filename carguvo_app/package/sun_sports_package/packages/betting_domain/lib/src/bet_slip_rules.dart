library;

const int kMaxSingleBets = 10;

const int kMaxComboMatches = 10;

const int kMinComboMatches = 2;

bool isSingleBetCapped(int count) => count >= kMaxSingleBets;

bool isComboMatchCapped(int matchCount) => matchCount >= kMaxComboMatches;

bool isComboCountValid(int matchCount) =>
    matchCount >= kMinComboMatches && matchCount <= kMaxComboMatches;

String maxSingleBetsMessage([int max = kMaxSingleBets]) =>
    'Phiếu cược chỉ cho phép tối đa $max kèo';

String minComboMatchesMessage([int min = kMinComboMatches]) =>
    'Cần tối thiểu $min trận để cược xiên';

String maxComboMatchesMessage([int max = kMaxComboMatches]) =>
    'Đã đạt số trận tối đa ($max trận) cho cược xiên';
