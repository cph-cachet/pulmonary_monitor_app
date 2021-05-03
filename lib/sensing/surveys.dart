part of pulmonary_monitor_app;

final surveys = _Surveys();

class _Surveys {
  Survey _who5 = _WHO5Survey();
  Survey get who5 => _who5;

  Survey _demographics = _DemographicSurvey();
  Survey get demographics => _demographics;

  Survey _symptoms = _SymptomsSurvey();
  Survey get symptoms => _symptoms;
}

abstract class Survey {
  /// The title of this survey.
  String get title;

  /// A short description (one line) of this survey
  String get description;

  /// How many minutes will it take to do this survey?
  int get minutesToComplete;

  /// The survey to fill out.
  RPTask get survey;
}

class _WHO5Survey implements Survey {
  String get title => "WHO5 Well-Being";
  String get description => "A short 5-item survey on your well-being.";
  int get minutesToComplete => 1;

  RPChoiceAnswerFormat _choiceAnswerFormat = RPChoiceAnswerFormat(
      answerStyle: RPChoiceAnswerStyle.SingleChoice,
      choices: [
        RPChoice(text: "All of the time", value: 5),
        RPChoice(text: "Most of the time", value: 4),
        RPChoice(text: "More than half of the time", value: 3),
        RPChoice(text: "Less than half of the time", value: 2),
        RPChoice(text: "Some of the time", value: 1),
        RPChoice(text: "At no time", value: 0),
      ]);

  RPTask get survey => RPOrderedTask("who5_survey", [
        RPInstructionStep('who5', title: "WHO Well-Being Index")
          ..text =
              "Please indicate for each of the following five statements which is closest to how you have been feeling over the last two weeks. "
                  "Notice that higher numbers mean better well-being.\n\n"
                  "Example: If you have felt cheerful and in good spirits more than half of the time during the last two weeks, "
                  "select the box with the label 'More than half of the time'.",
        RPQuestionStep(
          "who5_1",
          title: "I have felt cheerful and in good spirits",
          answerFormat: _choiceAnswerFormat,
        ),
        RPQuestionStep(
          "who5_2",
          title: "I have felt calm and relaxed",
          answerFormat: _choiceAnswerFormat,
        ),
        RPQuestionStep(
          "who5_3",
          title: "I have felt active and vigorous",
          answerFormat: _choiceAnswerFormat,
        ),
        RPQuestionStep(
          "who5_4",
          title: "I woke up feeling fresh and rested",
          answerFormat: _choiceAnswerFormat,
        ),
        RPQuestionStep(
          "who5_5",
          title: "My daily life has been filled with things that interest me",
          answerFormat: _choiceAnswerFormat,
        ),
        RPCompletionStep("who5_ompletion")
          ..title = "Finished"
          ..text = "Thank you for filling out the survey!",
      ]);
}

class _DemographicSurvey implements Survey {
  String get title => "Demographics";
  String get description => "A short 4-item survey on your background.";
  int get minutesToComplete => 2;

  final RPChoiceAnswerFormat _sexChoices = RPChoiceAnswerFormat(
      answerStyle: RPChoiceAnswerStyle.SingleChoice,
      choices: [
        RPChoice(text: "Femal", value: 1),
        RPChoice(text: "Male", value: 2),
        RPChoice(text: "Other", value: 3),
        RPChoice(text: "Prefer not to say", value: 4),
      ]);

  final RPChoiceAnswerFormat _ageChoices = RPChoiceAnswerFormat(
      answerStyle: RPChoiceAnswerStyle.SingleChoice,
      choices: [
        RPChoice(text: "Under 20", value: 1),
        RPChoice(text: "20-29", value: 2),
        RPChoice(text: "30-39", value: 3),
        RPChoice(text: "40-49", value: 4),
        RPChoice(text: "50-59", value: 5),
        RPChoice(text: "60-69", value: 6),
        RPChoice(text: "70-79", value: 7),
        RPChoice(text: "80-89", value: 8),
        RPChoice(text: "90 and above", value: 9),
        RPChoice(text: "Prefer not to say", value: 10),
      ]);

  final RPChoiceAnswerFormat _medicalChoices = RPChoiceAnswerFormat(
      answerStyle: RPChoiceAnswerStyle.MultipleChoice,
      choices: [
        RPChoice(text: "None", value: 1),
        RPChoice(text: "Asthma", value: 2),
        RPChoice(text: "Cystic fibrosis", value: 3),
        RPChoice(text: "COPD/Emphysema", value: 4),
        RPChoice(text: "Pulmonary fibrosis", value: 5),
        RPChoice(text: "Other lung disease  ", value: 6),
        RPChoice(text: "High Blood Pressure", value: 7),
        RPChoice(text: "Angina", value: 8),
        RPChoice(
            text: "Previous stroke or Transient ischaemic attack  ", value: 9),
        RPChoice(text: "Valvular heart disease", value: 10),
        RPChoice(text: "Previous heart attack", value: 11),
        RPChoice(text: "Other heart disease", value: 12),
        RPChoice(text: "Diabetes", value: 13),
        RPChoice(text: "Cancer", value: 14),
        RPChoice(text: "Previous organ transplant", value: 15),
        RPChoice(text: "HIV or impaired immune system", value: 16),
        RPChoice(text: "Other long-term condition", value: 17),
        RPChoice(text: "Prefer not to say", value: 18),
      ]);

  final RPChoiceAnswerFormat _smokeChoices = RPChoiceAnswerFormat(
      answerStyle: RPChoiceAnswerStyle.SingleChoice,
      choices: [
        RPChoice(text: "Never smoked", value: 1),
        RPChoice(text: "Ex-smoker", value: 2),
        RPChoice(text: "Current smoker (less than once a day", value: 3),
        RPChoice(text: "Current smoker (1-10 cigarettes pr day", value: 4),
        RPChoice(text: "Current smoker (11-20 cigarettes pr day", value: 5),
        RPChoice(text: "Current smoker (21+ cigarettes pr day", value: 6),
        RPChoice(text: "Prefer not to say", value: 7),
      ]);

  RPTask get survey => RPOrderedTask("demo_survey", [
        RPQuestionStep(
          "demo_1",
          title: "Which is your biological sex?",
          answerFormat: _sexChoices,
        ),
        RPQuestionStep(
          "demo_2",
          title: "How old are you?",
          answerFormat: _ageChoices,
        ),
        RPQuestionStep(
          "demo_3",
          title: "Do you have any of these medical conditions?",
          answerFormat: _medicalChoices,
        ),
        RPQuestionStep(
          "demo_4",
          title: "Do you, or have you, ever smoked (including e-cigarettes)?",
          answerFormat: _smokeChoices,
        ),
      ]);
}

class _SymptomsSurvey implements Survey {
  String get title => "Symptoms";
  String get description => "A short 1-item survey on your daily symptoms.";
  int get minutesToComplete => 1;

  RPChoiceAnswerFormat _symptomsChoices = RPChoiceAnswerFormat(
      answerStyle: RPChoiceAnswerStyle.MultipleChoice,
      choices: [
        RPChoice(text: "None", value: 1),
        RPChoice(text: "Fever (warmer than usual)", value: 2),
        RPChoice(text: "Dry cough", value: 3),
        RPChoice(text: "Wet cough", value: 4),
        RPChoice(text: "Sore throat, runny or blocked nose", value: 5),
        RPChoice(text: "Loss of taste and smell", value: 6),
        RPChoice(
            text: "Difficulty breathing or feeling short of breath", value: 7),
        RPChoice(text: "Tightness in your chest", value: 8),
        RPChoice(text: "Dizziness, confusion or vertigo", value: 9),
        RPChoice(text: "Headache", value: 10),
        RPChoice(text: "Muscle aches", value: 11),
        RPChoice(text: "Chills", value: 12),
        RPChoice(text: "Prefer not to say", value: 13),
      ]);

  RPTask get survey => RPOrderedTask("symptoms_survey", [
        RPQuestionStep(
          "sym_1",
          title: "Do you have any of the following symptoms today?",
          answerFormat: _symptomsChoices,
        ),
      ]);
}
