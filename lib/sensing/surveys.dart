part of pulmonary_monitor_app;

final surveys = _Surveys();

class _Surveys {
  RPOrderedTask get who5 => _WHO5.who5Task;
}

class _WHO5 {
  static List<RPChoice> choices = [
    RPChoice.withParams("All of the time", 5),
    RPChoice.withParams("Most of the time", 4),
    RPChoice.withParams("More than half of the time", 3),
    RPChoice.withParams("Less than half of the time", 2),
    RPChoice.withParams("Some of the time", 1),
    RPChoice.withParams("At no time", 0),
  ];

  static RPChoiceAnswerFormat choiceAnswerFormat =
      RPChoiceAnswerFormat.withParams(ChoiceAnswerStyle.SingleChoice, choices);

  static RPQuestionStep who5Question1 = RPQuestionStep.withAnswerFormat(
    "who5_question1",
    "I have felt cheerful and in good spirits",
    choiceAnswerFormat,
  );

  static RPQuestionStep who5Question2 = RPQuestionStep.withAnswerFormat(
    "who5_question2",
    "I have felt calm and relaxed",
    choiceAnswerFormat,
  );

  static RPQuestionStep who5Question3 = RPQuestionStep.withAnswerFormat(
    "who5_question3",
    "I have felt active and vigorous",
    choiceAnswerFormat,
  );

  static RPQuestionStep who5Question4 = RPQuestionStep.withAnswerFormat(
    "who5_question4",
    "I woke up feeling fresh and rested",
    choiceAnswerFormat,
  );

  static RPQuestionStep who5Question5 = RPQuestionStep.withAnswerFormat(
    "who5_question5",
    "My daily life has been filled with things that interest me",
    choiceAnswerFormat,
  );

  static RPCompletionStep completionStep = RPCompletionStep("completionID")
    ..title = "Finished"
    ..text = "Thank you for filling out the survey!";

  static RPOrderedTask who5Task = RPOrderedTask("who5TaskID", [
    who5Question1,
    who5Question2,
    who5Question3,
    who5Question4,
    who5Question5,
    completionStep,
  ]);
}
