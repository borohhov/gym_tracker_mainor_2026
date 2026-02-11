class Exercise {
  String name;
  String? description;
  List<BodyGroup> bodyGroups;

  Exercise(this.name, this.description, this.bodyGroups);
}

enum BodyGroup {
  leg, arm, chest, neck, back
}

