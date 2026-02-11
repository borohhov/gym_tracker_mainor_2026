import 'exercise.dart';

final List<Exercise> defaultExercises = [
  Exercise(
    "Squat",
    "A lower-body exercise that strengthens legs and glutes.",
    [BodyGroup.leg],
  ),
  Exercise(
    "Lunge",
    "Targets quads, hamstrings, and glutes while improving balance.",
    [BodyGroup.leg],
  ),
  Exercise(
    "Push-Up",
    "A bodyweight exercise for chest, shoulders, and arms.",
    [BodyGroup.chest, BodyGroup.arm],
  ),
  Exercise(
    "Bench Press",
    "Classic strength exercise focusing on the chest and arms.",
    [BodyGroup.chest, BodyGroup.arm],
  ),
  Exercise(
    "Pull-Up",
    "Upper-body pulling movement for back and arms.",
    [BodyGroup.back, BodyGroup.arm],
  ),
  Exercise(
    "Deadlift",
    "Full-body movement emphasizing back and legs.",
    [BodyGroup.back, BodyGroup.leg],
  ),
  Exercise(
    "Shoulder Press",
    "Overhead press targeting shoulders and arms.",
    [BodyGroup.arm, BodyGroup.chest],
  ),
  Exercise(
    "Bicep Curl",
    "Isolation exercise for the biceps.",
    [BodyGroup.arm],
  ),
  Exercise(
    "Tricep Dip",
    "Bodyweight exercise focusing on the triceps and chest.",
    [BodyGroup.arm, BodyGroup.chest],
  ),
  Exercise(
    "Lat Pulldown",
    "Machine-based exercise for upper back and arms.",
    [BodyGroup.back, BodyGroup.arm],
  ),
  Exercise(
    "Back Extension",
    "Strengthens lower back muscles.",
    [BodyGroup.back],
  ),
  Exercise(
    "Neck Flexion",
    "Strengthens the front muscles of the neck.",
    [BodyGroup.neck],
  ),
  Exercise(
    "Neck Extension",
    "Targets the back muscles of the neck.",
    [BodyGroup.neck],
  ),
];
