import 'package:flutter/widgets.dart';
import 'package:research_package/model.dart';

///
/// CHOICES
///

List<RPChoice> timeChoices = [
  RPChoice(text: "All of the time", value: 5),
  RPChoice(text: "Most of the time", value: 4),
  RPChoice(text: "More than half of the time", value: 3),
  RPChoice(text: "Less than half of the time", value: 2),
  RPChoice(text: "Some of the time", value: 1),
  RPChoice(text: "At no time", value: 0),
];

List<RPChoice> joyfulActivities = [
  RPChoice(text: "Playing games", value: 6),
  RPChoice(text: "Jogging", value: 5),
  RPChoice(text: "Playing an instrument", value: 4),
  RPChoice(text: "Family and friends", value: 3),
  RPChoice(text: "Doing sports", value: 2),
  RPChoice(text: "Reading", value: 1),
  RPChoice(text: "Being productive", value: 0),
];

List<RPChoice> instruments = [
  RPChoice(text: "Guitar", value: 3),
  RPChoice(text: "Piano", value: 2),
  RPChoice(text: "Saxophone", value: 1),
];

List<RPChoice> who5Choices = [
  RPChoice(text: "All of the time", value: 5),
  RPChoice(text: "Most of the time", value: 4),
  RPChoice(text: "More than half of the time", value: 3),
  RPChoice(text: "Less than half of the time", value: 2),
  RPChoice(text: "Some of the time", value: 1),
  RPChoice(text: "At no time", value: 0),
];

List<RPImageChoice> images = [
  RPImageChoice(
      image: Image.asset('assets/images/very-sad.png'),
      value: 0,
      description: 'Feeling very sad'),
  RPImageChoice(
      image: Image.asset('assets/images/sad.png'),
      value: 1,
      description: 'Feeling sad'),
  RPImageChoice(
      image: Image.asset('assets/images/ok.png'),
      value: 2,
      description: 'Feeling ok'),
  RPImageChoice(
      image: Image.asset('assets/images/happy.png'),
      value: 3,
      description: 'Feeling happy'),
  RPImageChoice(
      image: Image.asset('assets/images/very-happy.png'),
      value: 4,
      description: 'Feeling very happy'),
];

List<RPChoice> guitarReasons = [
  RPChoice(text: "Fun", value: 3),
  RPChoice(text: "Easy to play", value: 2),
  RPChoice(text: "Charming", value: 1),
  RPChoice(text: "Popular", value: 0),
];

///
/// ANSWER FORMATS
///

RPBooleanAnswerFormat yesNoAnswerFormat =
    RPBooleanAnswerFormat(trueText: "Yes", falseText: "No");
RPImageChoiceAnswerFormat imageChoiceAnswerFormat =
    RPImageChoiceAnswerFormat(choices: images);
RPIntegerAnswerFormat nrOfCigarettesAnswerFormat =
    RPIntegerAnswerFormat(minValue: 0, maxValue: 200, suffix: "cigarettes");
RPChoiceAnswerFormat who5AnswerFormat = RPChoiceAnswerFormat(
    answerStyle: RPChoiceAnswerStyle.SingleChoice, choices: who5Choices);
RPChoiceAnswerFormat joyfulActivitiesAnswerFormat = RPChoiceAnswerFormat(
    answerStyle: RPChoiceAnswerStyle.MultipleChoice, choices: joyfulActivities);
RPChoiceAnswerFormat instrumentsAnswerFormat = RPChoiceAnswerFormat(
    answerStyle: RPChoiceAnswerStyle.SingleChoice, choices: instruments);
RPIntegerAnswerFormat minutesIntegerAnswerFormat =
    RPIntegerAnswerFormat(minValue: 0, maxValue: 10000, suffix: "minutes");
RPChoiceAnswerFormat guitarAnswerFormat = RPChoiceAnswerFormat(
    answerStyle: RPChoiceAnswerStyle.MultipleChoice, choices: guitarReasons);

///
/// STEPS
///

RPQuestionStep smokingQuestionStep = RPQuestionStep("smokingQuestionId",
    title: "Do you smoke?", answerFormat: yesNoAnswerFormat);

RPQuestionStep imageChoiceQuestionStep = RPQuestionStep(
  "imageStepID",
  title: "Indicate you mood by selecting a picture!",
  answerFormat: imageChoiceAnswerFormat,
);

RPQuestionStep nrOfCigarettesQuestionStep = RPQuestionStep(
    "nrOfCigarettesQuestionStepID",
    title: "How many cigarettes do you smoke a day?",
    answerFormat: nrOfCigarettesAnswerFormat);

RPInstructionStep instructionStep = RPInstructionStep(
  "instructionID",
  title: "Welcome!",
  detailText: "For the sake of science of course...",
)..text =
    "Please fill out this questionnaire!\n\nIn this questionnaire answers to some questions will determine what other questions you will get. You can not skip these question, although you are free to skip the other questions.";

RPQuestionStep singleChoiceQuestionStep = RPQuestionStep(
  "singleChoiceQuestionStepID",
  title: "I have felt cheerful and in good spirits",
  answerFormat: who5AnswerFormat,
);

RPQuestionStep multiChoiceQuestionStep = RPQuestionStep(
  "multiChoiceQuestionStepID",
  title: "What makes you happy?",
  answerFormat: joyfulActivitiesAnswerFormat,
);

RPQuestionStep instrumentChoiceQuestionStep = RPQuestionStep(
    "instrumentChoiceQuestionStepID",
    title: "Which instrument are you playing?",
    answerFormat: instrumentsAnswerFormat);
RPQuestionStep minutesQuestionStep = RPQuestionStep("minutesQuestionStepID",
    title: "How many minutes do you spend practicing a week?",
    answerFormat: minutesIntegerAnswerFormat);
RPFormStep formStep = RPFormStep(
  "formstepID",
  steps: [instrumentChoiceQuestionStep, minutesQuestionStep],
  title: "Questions about music",
  optional: true,
);

RPQuestionStep guitarChoiceQuestionStep = RPQuestionStep(
    "guitarChoiceQuestionStepID",
    title: "Why did you start playing the guitar?",
    answerFormat: guitarAnswerFormat);

RPCompletionStep completionStep = RPCompletionStep("completionID")
  ..title = "Finished"
  ..text = "Thank you for filling out the survey!";

///
/// PREDICATES
///

RPResultPredicate singleChoicePredicate =
    RPResultPredicate.forChoiceQuestionResult(
  resultSelector: RPResultSelector.forStepId("singleChoiceQuestionStepID"),
  expectedValue: [5],
  choiceQuestionResultPredicateMode:
      ChoiceQuestionResultPredicateMode.ExactMatch,
);

RPResultPredicate multiChoicePredicate =
    RPResultPredicate.forChoiceQuestionResult(
  resultSelector: RPResultSelector.forStepId("multiChoiceQuestionStepID"),
  expectedValue: [0, 6],
  choiceQuestionResultPredicateMode:
      ChoiceQuestionResultPredicateMode.ExactMatch,
);

RPResultPredicate yesSmokingPredicate =
    RPResultPredicate.forBooleanQuestionResult(
        resultSelector: RPResultSelector.forStepId("smokingQuestionId"),
        expectedValue: true);

RPResultPredicate noSmokingPredicate =
    RPResultPredicate.forBooleanQuestionResult(
        resultSelector: RPResultSelector.forStepId("smokingQuestionId"),
        expectedValue: false);

RPResultPredicate instrumentChoicePredicate =
    RPResultPredicate.forChoiceQuestionResult(
  resultSelector:
      RPResultSelector.forStepIdInFormStep("instrumentChoiceQuestionStepID"),
  expectedValue: [1],
  choiceQuestionResultPredicateMode:
      ChoiceQuestionResultPredicateMode.ExactMatch,
);

///
/// NAVIGATION RULES
///

RPPredicateStepNavigationRule smokingNavigationRule =
    RPPredicateStepNavigationRule(
  {
    noSmokingPredicate: imageChoiceQuestionStep.identifier,
  },
);

RPPredicateStepNavigationRule singleChoiceNavigationRule =
    RPPredicateStepNavigationRule(
  {
    singleChoicePredicate: imageChoiceQuestionStep.identifier,
  },
);

RPPredicateStepNavigationRule multiChoiceNavigationRule =
    RPPredicateStepNavigationRule(
  {
    multiChoicePredicate: imageChoiceQuestionStep.identifier,
  },
);

RPPredicateStepNavigationRule guitarNavigationRule =
    RPPredicateStepNavigationRule(
  {
    instrumentChoicePredicate: smokingQuestionStep.identifier,
  },
);

///
/// TASK
///

RPNavigableOrderedTask navigableSurveyTask = RPNavigableOrderedTask(
  "NavigableTaskID",
  [
    instructionStep,
    formStep,
    guitarChoiceQuestionStep,
    smokingQuestionStep,
    nrOfCigarettesQuestionStep,
//    multiChoiceQuestionStep,
//    singleChoiceQuestionStep,
    imageChoiceQuestionStep,
    completionStep,
  ],
)
  ..setNavigationRuleForTriggerStepIdentifier(
      smokingNavigationRule, smokingQuestionStep.identifier)
  ..setNavigationRuleForTriggerStepIdentifier(
      singleChoiceNavigationRule, singleChoiceQuestionStep.identifier)
  ..setNavigationRuleForTriggerStepIdentifier(
      multiChoiceNavigationRule, multiChoiceQuestionStep.identifier)
  ..setNavigationRuleForTriggerStepIdentifier(
      guitarNavigationRule, formStep.identifier);

//RPDirectStepNavigationRule navigationRuleAfterSmokingResult =
//    RPDirectStepNavigationRule(imageChoiceQuestionStep.identifier);
