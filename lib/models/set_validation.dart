class SetValidation {
  static bool validWeight(double weight) => weight.isFinite && weight >= 0;
  static bool validRepetitions(int repetitions) => repetitions > 0;
}
