enum MuscleGroup { chest, back, arms, legs }

int getAllMuscleGroups() {
  return MuscleGroup.values.length;
}

List<String> getNameOfMuscleGroups() {
  return MuscleGroup.values.map((group) => group.name.toUpperCase()).toList();
}
