import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CodeLearn'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get home;

  /// No description provided for @courses.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get courses;

  /// No description provided for @journey.
  ///
  /// In en, this message translates to:
  /// **'Your journey'**
  String get journey;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get continueLearning;

  /// No description provided for @startLearning.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get startLearning;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Small steps. Real skills.'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Learn by doing. Build your coding habit, one lesson at a time.'**
  String get welcomeBody;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Today’s goal'**
  String get dailyGoal;

  /// No description provided for @lessonGoal.
  ///
  /// In en, this message translates to:
  /// **'Complete one lesson'**
  String get lessonGoal;

  /// No description provided for @goalComplete.
  ///
  /// In en, this message translates to:
  /// **'Daily goal complete'**
  String get goalComplete;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get streak;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Foundations'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Next level'**
  String get intermediate;

  /// No description provided for @searchCourses.
  ///
  /// In en, this message translates to:
  /// **'Find your next skill'**
  String get searchCourses;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matching courses'**
  String get noResults;

  /// No description provided for @trySearch.
  ///
  /// In en, this message translates to:
  /// **'Try another search or filter.'**
  String get trySearch;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get next;

  /// No description provided for @theory.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get theory;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get quiz;

  /// No description provided for @practice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// No description provided for @checkAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get checkAnswer;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'That’s right!'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Let’s learn from it.'**
  String get incorrect;

  /// No description provided for @retryQuiz.
  ///
  /// In en, this message translates to:
  /// **'Try the quiz again'**
  String get retryQuiz;

  /// No description provided for @quizPassed.
  ///
  /// In en, this message translates to:
  /// **'Ready to put it into practice'**
  String get quizPassed;

  /// No description provided for @quizFailed.
  ///
  /// In en, this message translates to:
  /// **'A little more practice'**
  String get quizFailed;

  /// No description provided for @runCode.
  ///
  /// In en, this message translates to:
  /// **'Run & check'**
  String get runCode;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get running;

  /// No description provided for @output.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get output;

  /// No description provided for @testPassed.
  ///
  /// In en, this message translates to:
  /// **'All checks passed'**
  String get testPassed;

  /// No description provided for @testFailed.
  ///
  /// In en, this message translates to:
  /// **'Keep going — check the feedback'**
  String get testFailed;

  /// No description provided for @completeLesson.
  ///
  /// In en, this message translates to:
  /// **'Complete lesson'**
  String get completeLesson;

  /// No description provided for @lessonComplete.
  ///
  /// In en, this message translates to:
  /// **'Another step forward!'**
  String get lessonComplete;

  /// No description provided for @alreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Practice complete. Your progress is saved.'**
  String get alreadyCompleted;

  /// No description provided for @nextLesson.
  ///
  /// In en, this message translates to:
  /// **'Next lesson'**
  String get nextLesson;

  /// No description provided for @returnCourse.
  ///
  /// In en, this message translates to:
  /// **'Back to course'**
  String get returnCourse;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Complete the previous lesson first'**
  String get locked;

  /// No description provided for @quizRequired.
  ///
  /// In en, this message translates to:
  /// **'Pass the quiz to unlock practice.'**
  String get quizRequired;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Use a hint'**
  String get hint;

  /// No description provided for @hintEmpty.
  ///
  /// In en, this message translates to:
  /// **'Get hint tokens in Rewards.'**
  String get hintEmpty;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Your draft is saved on this device'**
  String get draftSaved;

  /// No description provided for @resetCode.
  ///
  /// In en, this message translates to:
  /// **'Reset code'**
  String get resetCode;

  /// No description provided for @savePortfolio.
  ///
  /// In en, this message translates to:
  /// **'Save to portfolio'**
  String get savePortfolio;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Code portfolio'**
  String get portfolio;

  /// No description provided for @portfolioEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your solutions belong here'**
  String get portfolioEmpty;

  /// No description provided for @portfolioEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Save code from a lesson or add a snippet of your own.'**
  String get portfolioEmptyBody;

  /// No description provided for @addSnippet.
  ///
  /// In en, this message translates to:
  /// **'Add a snippet'**
  String get addSnippet;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this saved snippet?'**
  String get deleteConfirm;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get achievements;

  /// No description provided for @firstLesson.
  ///
  /// In en, this message translates to:
  /// **'First step'**
  String get firstLesson;

  /// No description provided for @fiveLessons.
  ///
  /// In en, this message translates to:
  /// **'Building momentum'**
  String get fiveLessons;

  /// No description provided for @tenLessons.
  ///
  /// In en, this message translates to:
  /// **'Learning habit'**
  String get tenLessons;

  /// No description provided for @firstCourse.
  ///
  /// In en, this message translates to:
  /// **'Pathfinder'**
  String get firstCourse;

  /// No description provided for @weekStreak.
  ///
  /// In en, this message translates to:
  /// **'Seven days stronger'**
  String get weekStreak;

  /// No description provided for @xpMilestone.
  ///
  /// In en, this message translates to:
  /// **'Experience collector'**
  String get xpMilestone;

  /// No description provided for @skillMap.
  ///
  /// In en, this message translates to:
  /// **'Skill map'**
  String get skillMap;

  /// No description provided for @missions.
  ///
  /// In en, this message translates to:
  /// **'Daily missions'**
  String get missions;

  /// No description provided for @missionLesson.
  ///
  /// In en, this message translates to:
  /// **'Complete a lesson today'**
  String get missionLesson;

  /// No description provided for @missionPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Save a solution today'**
  String get missionPortfolio;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Learning insights'**
  String get insights;

  /// No description provided for @noInsights.
  ///
  /// In en, this message translates to:
  /// **'Complete a lesson to see your progress.'**
  String get noInsights;

  /// No description provided for @practiceAgain.
  ///
  /// In en, this message translates to:
  /// **'Revisit this skill'**
  String get practiceAgain;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Your credits'**
  String get wallet;

  /// No description provided for @dailyReward.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get dailyReward;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'Claim reward'**
  String get claim;

  /// No description provided for @claimed.
  ///
  /// In en, this message translates to:
  /// **'See you tomorrow'**
  String get claimed;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Make progress your own'**
  String get shop;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Get it'**
  String get buy;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get owned;

  /// No description provided for @insufficientCredits.
  ///
  /// In en, this message translates to:
  /// **'Not enough credits yet'**
  String get insufficientCredits;

  /// No description provided for @booster.
  ///
  /// In en, this message translates to:
  /// **'XP boost'**
  String get booster;

  /// No description provided for @boosterBody.
  ///
  /// In en, this message translates to:
  /// **'25% extra XP for your next 3 lessons'**
  String get boosterBody;

  /// No description provided for @shield.
  ///
  /// In en, this message translates to:
  /// **'Streak shield'**
  String get shield;

  /// No description provided for @shieldBody.
  ///
  /// In en, this message translates to:
  /// **'Protect one missed day'**
  String get shieldBody;

  /// No description provided for @hints.
  ///
  /// In en, this message translates to:
  /// **'Hint pack'**
  String get hints;

  /// No description provided for @hintsBody.
  ///
  /// In en, this message translates to:
  /// **'5 hints for tricky challenges'**
  String get hintsBody;

  /// No description provided for @frame.
  ///
  /// In en, this message translates to:
  /// **'Aurora frame'**
  String get frame;

  /// No description provided for @frameBody.
  ///
  /// In en, this message translates to:
  /// **'A little personality for your profile'**
  String get frameBody;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get transactions;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'Your rewards will appear here.'**
  String get noTransactions;

  /// No description provided for @purchaseComplete.
  ///
  /// In en, this message translates to:
  /// **'Added to your inventory'**
  String get purchaseComplete;

  /// No description provided for @uiLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get uiLanguage;

  /// No description provided for @learningLanguage.
  ///
  /// In en, this message translates to:
  /// **'Lesson language'**
  String get learningLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get sound;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get haptics;

  /// No description provided for @previewSound.
  ///
  /// In en, this message translates to:
  /// **'Preview sound'**
  String get previewSound;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Learning reminders'**
  String get reminders;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'A gentle reminder at 19:00'**
  String get reminderBody;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Curious coder'**
  String get guest;

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Guest profile'**
  String get guestMode;

  /// No description provided for @localBody.
  ///
  /// In en, this message translates to:
  /// **'Your learning is saved on this device.'**
  String get localBody;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get displayName;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get bio;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get google;

  /// No description provided for @magicLink.
  ///
  /// In en, this message translates to:
  /// **'Email a sign-in link'**
  String get magicLink;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @authUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cloud accounts are not configured in this build. You can keep learning as a guest.'**
  String get authUnavailable;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Check your details and connection.'**
  String get authError;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get emailSent;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Help & feedback'**
  String get support;

  /// No description provided for @supportBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us what happened or what you would improve.'**
  String get supportBody;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @queued.
  ///
  /// In en, this message translates to:
  /// **'Saved. Waiting to sync.'**
  String get queued;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get sync;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get synced;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting to sync'**
  String get syncPending;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Could not sync. Your changes are safe on this device.'**
  String get syncError;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something needs attention'**
  String get errorTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'This page could not be found.'**
  String get notFound;

  /// No description provided for @sourceFallback.
  ///
  /// In en, this message translates to:
  /// **'This lesson is shown in English while its translation is being updated.'**
  String get sourceFallback;

  /// No description provided for @simulatorNotice.
  ///
  /// In en, this message translates to:
  /// **'Learning sandbox: supports the syntax used in this course.'**
  String get simulatorNotice;

  /// No description provided for @testLabel.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get testLabel;

  /// No description provided for @unsupportedCode.
  ///
  /// In en, this message translates to:
  /// **'This syntax is not supported by the learning sandbox yet.'**
  String get unsupportedCode;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Please complete this field'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export my learning data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import learning data'**
  String get importData;

  /// No description provided for @importHelp.
  ///
  /// In en, this message translates to:
  /// **'Paste a CodeLearn export. Existing completions will be preserved.'**
  String get importHelp;

  /// No description provided for @exportHelp.
  ///
  /// In en, this message translates to:
  /// **'Copy this backup and keep it somewhere safe.'**
  String get exportHelp;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'This backup is invalid or incompatible.'**
  String get importFailed;

  /// No description provided for @welcomeAction.
  ///
  /// In en, this message translates to:
  /// **'Let’s build something'**
  String get welcomeAction;

  /// No description provided for @onboardingStep1.
  ///
  /// In en, this message translates to:
  /// **'Understand it'**
  String get onboardingStep1;

  /// No description provided for @onboardingStep2.
  ///
  /// In en, this message translates to:
  /// **'Try it'**
  String get onboardingStep2;

  /// No description provided for @onboardingStep3.
  ///
  /// In en, this message translates to:
  /// **'Make it a habit'**
  String get onboardingStep3;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Short lessons that make complex ideas feel clear.'**
  String get onboardingBody1;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Write code, explore branches, and learn from feedback.'**
  String get onboardingBody2;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Keep your progress and grow a little every day.'**
  String get onboardingBody3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @newAchievement.
  ///
  /// In en, this message translates to:
  /// **'Milestone unlocked'**
  String get newAchievement;

  /// No description provided for @correctCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} correct'**
  String correctCount(int count, int total);

  /// No description provided for @courseProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} lessons'**
  String courseProgress(int completed, int total);

  /// No description provided for @dayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No streak yet} one{1 day} other{{count} days}}'**
  String dayCount(int count);

  /// No description provided for @lessonCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 lesson} other{{count} lessons}}'**
  String lessonCount(int count);

  /// No description provided for @completionReward.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP · +{credits} credits'**
  String completionReward(int xp, int credits);

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to your next level'**
  String nextLevel(int xp);

  /// No description provided for @accountMerge.
  ///
  /// In en, this message translates to:
  /// **'Your guest progress will be merged into your account.'**
  String get accountMerge;

  /// No description provided for @practiceChecks.
  ///
  /// In en, this message translates to:
  /// **'{passed} of {total} checks passed'**
  String practiceChecks(int passed, int total);

  /// No description provided for @cancelRun.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get cancelRun;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission was not granted. You can enable it in system settings.'**
  String get permissionDenied;

  /// No description provided for @learningFocus.
  ///
  /// In en, this message translates to:
  /// **'Your focus'**
  String get learningFocus;

  /// No description provided for @dailyMinutes.
  ///
  /// In en, this message translates to:
  /// **'Daily learning goal (minutes)'**
  String get dailyMinutes;

  /// No description provided for @codeChallenge.
  ///
  /// In en, this message translates to:
  /// **'Coding warm-up'**
  String get codeChallenge;

  /// No description provided for @challengePrompt.
  ///
  /// In en, this message translates to:
  /// **'What does print(3 * 2 + 1) output?'**
  String get challengePrompt;

  /// No description provided for @challengeAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get challengeAnswer;

  /// No description provided for @challengeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Nice! Now sign in to your account.'**
  String get challengeSuccess;

  /// No description provided for @sessionRestore.
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off'**
  String get sessionRestore;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutesLabel;

  /// No description provided for @pendingRewards.
  ///
  /// In en, this message translates to:
  /// **'Cloud rewards are confirmed after sync.'**
  String get pendingRewards;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @achievementLessons.
  ///
  /// In en, this message translates to:
  /// **'Complete {count} lessons'**
  String achievementLessons(int count);

  /// No description provided for @achievementStreak.
  ///
  /// In en, this message translates to:
  /// **'Build a {count}-day streak'**
  String achievementStreak(int count);

  /// No description provided for @achievementCourses.
  ///
  /// In en, this message translates to:
  /// **'Complete {count} courses'**
  String achievementCourses(int count);

  /// No description provided for @outputMismatch.
  ///
  /// In en, this message translates to:
  /// **'The output does not match the expected result.'**
  String get outputMismatch;

  /// No description provided for @executionTimeout.
  ///
  /// In en, this message translates to:
  /// **'This run took too long. Try a smaller example.'**
  String get executionTimeout;

  /// No description provided for @executionStopped.
  ///
  /// In en, this message translates to:
  /// **'The run was stopped.'**
  String get executionStopped;

  /// No description provided for @practiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not start practice. Reload and try again.'**
  String get practiceUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
