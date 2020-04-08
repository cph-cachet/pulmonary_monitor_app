part of pulmonary_monitor_app;

final surveys = _Surveys();

class _Surveys {
  //RPOrderedTask get who5 => _WHO5.who5Task;

  Survey _who5 = _WHO5();
  Survey get who5 => _who5;
}

abstract class Survey {
  String get title;
  String get description;
  RPTask get survey;
}

class _WHO5 implements Survey {
  String get title => "WHO Well-Being Index";

  String get description =>
      "Please indicate for each of the five statements which is closest to how you have been feeling over the last two weeks.";

  RPTask get survey => who5Task;
}

// ----------------------------------------------------------
//  WHO5
// ----------------------------------------------------------

List<RPChoice> choices = [
  RPChoice.withParams("All of the time", 5),
  RPChoice.withParams("Most of the time", 4),
  RPChoice.withParams("More than half of the time", 3),
  RPChoice.withParams("Less than half of the time", 2),
  RPChoice.withParams("Some of the time", 1),
  RPChoice.withParams("At no time", 0),
];

RPChoiceAnswerFormat choiceAnswerFormat = RPChoiceAnswerFormat.withParams(ChoiceAnswerStyle.SingleChoice, choices);

RPInstructionStep instructionStep = RPInstructionStep(
    identifier: "instructionID", title: "WHO Well-Being Index", detailText: "For the sake of science of course...")
  ..text =
      "Please indicate for each of the five statements which is closest to how you have been feeling over the last two weeks. "
          "Notice that higher numbers mean better well-being.\n\n"
          "Example: If you have felt cheerful and in good spirits more than half of the time during the last two weeks, "
          "put a tick in the box with the number 3 in the upper right corner.";

RPQuestionStep who5Question1 = RPQuestionStep.withAnswerFormat(
  "who5_question1",
  "I have felt cheerful and in good spirits",
  choiceAnswerFormat,
);

RPQuestionStep who5Question2 = RPQuestionStep.withAnswerFormat(
  "who5_question2",
  "I have felt calm and relaxed",
  choiceAnswerFormat,
);

RPQuestionStep who5Question3 = RPQuestionStep.withAnswerFormat(
  "who5_question3",
  "I have felt active and vigorous",
  choiceAnswerFormat,
);

RPQuestionStep who5Question4 = RPQuestionStep.withAnswerFormat(
  "who5_question4",
  "I woke up feeling fresh and rested",
  choiceAnswerFormat,
);

RPQuestionStep who5Question5 = RPQuestionStep.withAnswerFormat(
  "who5_question5",
  "My daily life has been filled with things that interest me",
  choiceAnswerFormat,
);

RPCompletionStep completionStep = RPCompletionStep("completionID")
  ..title = "Finished"
  ..text = "Thank you for filling out the survey!";

RPOrderedTask who5Task = RPOrderedTask("who5TaskID", [
  instructionStep,
  who5Question1,
  who5Question2,
  who5Question3,
  who5Question4,
  who5Question5,
  completionStep,
]);
