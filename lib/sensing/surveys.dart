part of pulmonary_monitor_app;

final surveys = _Surveys();

class _Surveys {
  final Survey _who5 = _WHO5Survey();
  Survey get who5 => _who5;

  final Survey _demographics = _DemographicSurvey();
  Survey get demographics => _demographics;

  final Survey _symptoms = _SymptomsSurvey();
  Survey get symptoms => _symptoms;

  final Survey _cognition = _CognitionSurvey();
  Survey get cognition => _cognition;
}

/// An interface for an survey from the RP package.
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
  @override
  String get title => "WHO5 Well-Being";
  @override
  String get description => "A short 5-item survey on your well-being.";
  @override
  int get minutesToComplete => 1;

  final RPChoiceAnswerFormat _choiceAnswerFormat = RPChoiceAnswerFormat(
    answerStyle: RPChoiceAnswerStyle.SingleChoice,
    choices: [
      RPChoice(text: "All of the time", value: 5),
      RPChoice(text: "Most of the time", value: 4),
      RPChoice(text: "More than half of the time", value: 3),
      RPChoice(text: "Less than half of the time", value: 2),
      RPChoice(text: "Some of the time", value: 1),
      RPChoice(text: "At no time", value: 0),
    ],
  );

  @override
  RPTask get survey => RPOrderedTask(
        identifier: "who5_survey",
        steps: [
          RPInstructionStep(
              identifier: 'who5',
              title: "WHO Well-Being Index",
              text:
                  "Please indicate for each of the following five statements which is closest to how you have been feeling over the last two weeks. "
                  "Notice that higher numbers mean better well-being.\n\n"
                  "Example: If you have felt cheerful and in good spirits more than half of the time during the last two weeks, "
                  "select the box with the label 'More than half of the time'."),
          RPQuestionStep(
            identifier: "who5_1",
            title: "I have felt cheerful and in good spirits",
            answerFormat: _choiceAnswerFormat,
          ),
          RPQuestionStep(
            identifier: "who5_2",
            title: "I have felt calm and relaxed",
            answerFormat: _choiceAnswerFormat,
          ),
          RPQuestionStep(
            identifier: "who5_3",
            title: "I have felt active and vigorous",
            answerFormat: _choiceAnswerFormat,
          ),
          RPQuestionStep(
            identifier: "who5_4",
            title: "I woke up feeling fresh and rested",
            answerFormat: _choiceAnswerFormat,
          ),
          RPQuestionStep(
            identifier: "who5_5",
            title: "My daily life has been filled with things that interest me",
            answerFormat: _choiceAnswerFormat,
          ),
          RPCompletionStep(
              identifier: "who5_ompletion",
              title: "Finished",
              text: "Thank you for filling out the survey!"),
        ],
      );
}

class _DemographicSurvey implements Survey {
  @override
  String get title => "Demographics";
  @override
  String get description => "A short 4-item survey on your background.";
  @override
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

  @override
  RPTask get survey => RPOrderedTask(
        identifier: "demo_survey",
        steps: [
          RPQuestionStep(
            identifier: "demo_1",
            title: "Which is your biological sex?",
            answerFormat: _sexChoices,
          ),
          RPQuestionStep(
            identifier: "demo_2",
            title: "How old are you?",
            answerFormat: _ageChoices,
          ),
          RPQuestionStep(
            identifier: "demo_3",
            title: "Do you have any of these medical conditions?",
            answerFormat: _medicalChoices,
          ),
          RPQuestionStep(
            identifier: "demo_4",
            title: "Do you, or have you, ever smoked (including e-cigarettes)?",
            answerFormat: _smokeChoices,
          ),
        ],
      );
}

class _SymptomsSurvey implements Survey {
  @override
  String get title => "Symptoms";
  @override
  String get description => "A short 1-item survey on your daily symptoms.";
  @override
  int get minutesToComplete => 1;

  final RPChoiceAnswerFormat _symptomsChoices = RPChoiceAnswerFormat(
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

  @override
  RPTask get survey => RPOrderedTask(
        identifier: "symptoms_survey",
        steps: [
          RPQuestionStep(
            identifier: "sym_1",
            title: "Do you have any of the following symptoms today?",
            answerFormat: _symptomsChoices,
          ),
        ],
      );
}

class _CognitionSurvey implements Survey {
  @override
  String get title => "Cognitive Assessment";
  @override
  String get description => "A short 2-item cognitive assessment.";
  @override
  int get minutesToComplete => 2;

  @override
  RPTask get survey => RPOrderedTask(
        identifier: "cognition_survey",
        steps: [
          RPInstructionStep(
              identifier: 'cognitive_instruction',
              title: "Cognitive Assessment",
              text:
                  "In the following pages, you will be asked to solve two simple test which will help assess your cognitive perfomance. "
                  "Each test has an instruction page, which you should read carefully before starting the test.\n\n"
                  "Please sit down confortably and just relax. Remember that there are no right or wrong answers."),
          RPFlankerActivity(
            'flanker_1',
            lengthOfTest: 300,
            numberOfCards: 10,
            includeResults: true,
          ),
          RPPictureSequenceMemoryActivity('picture_sequence_memory_1',
              lengthOfTest: 180,
              numberOfTests: 1,
              numberOfPics: 6,
              includeResults: true),
          // RPVisualArrayChangeActivity('visual_array_change_1',
          //     lengthOfTest: 180,
          //     numberOfTests: 3,
          //     waitTime: 3,
          //     includeResults: true),
          RPCompletionStep(
              identifier: 'cognition_completion',
              title: 'Finished',
              text: 'Thank you for taking the tests'),
        ],
      );
}
