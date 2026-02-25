import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @setupPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setupPageTitle;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @loginPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginPageTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone number'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••••••'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account ? '**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as a guest'**
  String get continueAsGuest;

  /// No description provided for @validationEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email or phone number'**
  String get validationEmailEmpty;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email or phone number'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get validationPasswordEmpty;

  /// No description provided for @validationPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordShort;

  /// No description provided for @loginErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get loginErrorInvalid;

  /// No description provided for @registerPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerPageTitle;

  /// No description provided for @ownerInfo.
  ///
  /// In en, this message translates to:
  /// **'Owner Info'**
  String get ownerInfo;

  /// No description provided for @brandInfo.
  ///
  /// In en, this message translates to:
  /// **'Brand Info'**
  String get brandInfo;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get firstNameHint;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get lastNameHint;

  /// No description provided for @userNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get userNameLabel;

  /// No description provided for @userNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get userNameHint;

  /// No description provided for @birthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDateLabel;

  /// No description provided for @brandNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand Name'**
  String get brandNameLabel;

  /// No description provided for @brandNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter brand name'**
  String get brandNameHint;

  /// No description provided for @vatRegistrationNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT Registration Number (Optional)'**
  String get vatRegistrationNumberLabel;

  /// No description provided for @vatRegistrationNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter VAT number'**
  String get vatRegistrationNumberHint;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @categoryHint.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get categoryHint;

  /// No description provided for @categoryClothes.
  ///
  /// In en, this message translates to:
  /// **'Clothes'**
  String get categoryClothes;

  /// No description provided for @categoryPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get categoryPharmacy;

  /// No description provided for @categoryGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get categoryGym;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a description for your brand'**
  String get descriptionHint;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your brand\'s location'**
  String get locationHint;

  /// No description provided for @repeatPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat Password'**
  String get repeatPasswordLabel;

  /// No description provided for @repeatPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••••••'**
  String get repeatPasswordHint;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordMismatch;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccess;

  /// No description provided for @brandPictureLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand Picture'**
  String get brandPictureLabel;

  /// No description provided for @tapToUploadPicture.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload a picture'**
  String get tapToUploadPicture;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get homeWelcomeBack;

  /// No description provided for @homeRecentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get homeRecentOrders;

  /// No description provided for @homeStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get homeStats;

  /// No description provided for @homeOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get homeOrders;

  /// No description provided for @homeProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get homeProducts;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get orderDetails;

  /// No description provided for @drawerLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get drawerLanguage;

  /// No description provided for @drawerTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get drawerTheme;

  /// No description provided for @drawerHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get drawerHelpSupport;

  /// No description provided for @drawerFollowUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get drawerFollowUs;

  /// No description provided for @drawerLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get drawerLogOut;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @monthlyOverview.
  ///
  /// In en, this message translates to:
  /// **'Monthly Overview'**
  String get monthlyOverview;

  /// No description provided for @totalViews.
  ///
  /// In en, this message translates to:
  /// **'Total Views'**
  String get totalViews;

  /// No description provided for @newCustomers.
  ///
  /// In en, this message translates to:
  /// **'New Customers'**
  String get newCustomers;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// No description provided for @productsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get productsAll;

  /// No description provided for @productsTops.
  ///
  /// In en, this message translates to:
  /// **'Tops'**
  String get productsTops;

  /// No description provided for @productsBottoms.
  ///
  /// In en, this message translates to:
  /// **'Pants'**
  String get productsBottoms;

  /// No description provided for @productsAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get productsAccessories;

  /// No description provided for @addProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProductTitle;

  /// No description provided for @productImage.
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get productImage;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @additionalImages.
  ///
  /// In en, this message translates to:
  /// **'Additional Images'**
  String get additionalImages;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Orders'**
  String get ordersTitle;

  /// No description provided for @ordersTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ordersTotal;

  /// No description provided for @ordersPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ordersPending;

  /// No description provided for @ordersDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get ordersDelivered;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderStatusShipped;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @shopInformation.
  ///
  /// In en, this message translates to:
  /// **'Shop Information'**
  String get shopInformation;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @productSold.
  ///
  /// In en, this message translates to:
  /// **'sold'**
  String get productSold;

  /// No description provided for @noProductsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No products found in this category'**
  String get noProductsInCategory;

  /// No description provided for @tryOn.
  ///
  /// In en, this message translates to:
  /// **'Try On'**
  String get tryOn;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @profileSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSavedSuccess;

  /// No description provided for @faqQuestion1.
  ///
  /// In en, this message translates to:
  /// **'How do I add a new product?'**
  String get faqQuestion1;

  /// No description provided for @faqAnswer1.
  ///
  /// In en, this message translates to:
  /// **'Navigate to the \'Products\' screen and tap the \'+\' button in the bottom right corner.'**
  String get faqAnswer1;

  /// No description provided for @faqQuestion2.
  ///
  /// In en, this message translates to:
  /// **'How can I see my sales statistics?'**
  String get faqQuestion2;

  /// No description provided for @faqAnswer2.
  ///
  /// In en, this message translates to:
  /// **'From the home screen, tap on the \'Stats\' card to view your dashboard.'**
  String get faqAnswer2;

  /// No description provided for @faqQuestion3.
  ///
  /// In en, this message translates to:
  /// **'Can I change my shop\'s information?'**
  String get faqQuestion3;

  /// No description provided for @faqAnswer3.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can edit your shop\'s details from the \'Shop Information\' section in your profile.'**
  String get faqAnswer3;

  /// No description provided for @faqQuestion4.
  ///
  /// In en, this message translates to:
  /// **'What do the different order statuses mean?'**
  String get faqQuestion4;

  /// No description provided for @faqAnswer4.
  ///
  /// In en, this message translates to:
  /// **'\'Pending\' means a new order has been placed. \'Shipped\' means it\'s on its way. \'Delivered\' means the customer has received it.'**
  String get faqAnswer4;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @newOrders.
  ///
  /// In en, this message translates to:
  /// **'New Orders'**
  String get newOrders;

  /// No description provided for @promotionsAndUpdates.
  ///
  /// In en, this message translates to:
  /// **'Promotions & Updates'**
  String get promotionsAndUpdates;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading'**
  String get errorLoading;

  /// No description provided for @pullDownToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullDownToRefresh;

  /// No description provided for @storeNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeNamePlaceholder;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @shopInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Shop info saved!'**
  String get shopInfoSaved;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving'**
  String get errorSaving;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @productAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully!'**
  String get productAddedSuccess;

  /// No description provided for @errorAddingProduct.
  ///
  /// In en, this message translates to:
  /// **'Error adding product'**
  String get errorAddingProduct;

  /// No description provided for @errorUpdatingProduct.
  ///
  /// In en, this message translates to:
  /// **'Error updating product'**
  String get errorUpdatingProduct;

  /// No description provided for @errorDeletingProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product. Please try again.'**
  String get errorDeletingProduct;

  /// No description provided for @errorLoadingProduct.
  ///
  /// In en, this message translates to:
  /// **'Failed to load product. Please try again.'**
  String get errorLoadingProduct;

  /// No description provided for @errorLoadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories. Please try again.'**
  String get errorLoadingCategories;

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image. Please try again.'**
  String get errorUploadingImage;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @pleaseAddMainImage.
  ///
  /// In en, this message translates to:
  /// **'Please add a main product image'**
  String get pleaseAddMainImage;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @pleaseFixErrors.
  ///
  /// In en, this message translates to:
  /// **'Please fix the errors in the form'**
  String get pleaseFixErrors;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Invalid Price'**
  String get invalidPrice;

  /// No description provided for @invalidStock.
  ///
  /// In en, this message translates to:
  /// **'Invalid Stock'**
  String get invalidStock;

  /// No description provided for @contactUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsTitle;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Start the conversation!'**
  String get noMessagesYet;

  /// No description provided for @messageSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully!'**
  String get messageSentSuccess;

  /// No description provided for @errorSendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message.'**
  String get errorSendingMessage;

  /// No description provided for @firstPage.
  ///
  /// In en, this message translates to:
  /// **'First page'**
  String get firstPage;

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// No description provided for @lastPage.
  ///
  /// In en, this message translates to:
  /// **'Last page'**
  String get lastPage;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String pageOf(int page, int total);

  /// No description provided for @itemsRange.
  ///
  /// In en, this message translates to:
  /// **'{start}-{end} of {total} items'**
  String itemsRange(int start, int end, int total);

  /// No description provided for @loadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get loadingMore;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @noMoreItems.
  ///
  /// In en, this message translates to:
  /// **'No more items'**
  String get noMoreItems;

  /// No description provided for @allBrandsTitle.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get allBrandsTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @noBrandsFound.
  ///
  /// In en, this message translates to:
  /// **'No brands found'**
  String get noBrandsFound;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorPrefix;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found for this brand'**
  String get noProductsFound;

  /// No description provided for @replySentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reply sent successfully!'**
  String get replySentSuccess;

  /// No description provided for @errorSendingReply.
  ///
  /// In en, this message translates to:
  /// **'Error sending reply:'**
  String get errorSendingReply;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// No description provided for @invalidProductId.
  ///
  /// In en, this message translates to:
  /// **'Invalid Product ID'**
  String get invalidProductId;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @brandsSellers.
  ///
  /// In en, this message translates to:
  /// **'Brands/Sellers'**
  String get brandsSellers;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @userConversations.
  ///
  /// In en, this message translates to:
  /// **'User Conversations'**
  String get userConversations;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// No description provided for @noConversationsFound.
  ///
  /// In en, this message translates to:
  /// **'No conversations found'**
  String get noConversationsFound;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations'**
  String get searchConversations;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @errorRegistering.
  ///
  /// In en, this message translates to:
  /// **'Error registering account'**
  String get errorRegistering;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @errorWhileLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Error while trying to Login'**
  String get errorWhileLoggingIn;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login Successful!'**
  String get loginSuccess;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @pageNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'The page you requested was not found.'**
  String get pageNotFoundDescription;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @shopInfoSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Shop information has been updated successfully!'**
  String get shopInfoSavedSuccess;

  /// No description provided for @editProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProductTitle;

  /// No description provided for @productUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully!'**
  String get productUpdatedSuccess;

  /// No description provided for @tapToSetPrimary.
  ///
  /// In en, this message translates to:
  /// **'Tap an image to set it as primary'**
  String get tapToSetPrimary;

  /// No description provided for @errorCouldNotLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not open this link'**
  String get errorCouldNotLaunchUrl;

  /// No description provided for @cartOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get cartOrders;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartStartShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get cartStartShopping;

  /// Message shown when an item is removed from cart
  ///
  /// In en, this message translates to:
  /// **'Removed \"{title}\"'**
  String cartItemRemoved(String title);

  /// Subtotal for a specific item row
  ///
  /// In en, this message translates to:
  /// **'Subtotal: \${price}'**
  String cartItemSubtotal(String price);

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotal;

  /// No description provided for @cartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get cartCheckout;

  /// No description provided for @cartClearDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cart'**
  String get cartClearDialogTitle;

  /// No description provided for @cartClearDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all items from the cart?'**
  String get cartClearDialogContent;

  /// No description provided for @cartClearDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cartClearDialogCancel;

  /// No description provided for @cartClearDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get cartClearDialogConfirm;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetailsTitle;

  /// No description provided for @orderItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String orderItemsCount(int count);

  /// No description provided for @orderItemFormat.
  ///
  /// In en, this message translates to:
  /// **'{quantity} x {title}'**
  String orderItemFormat(int quantity, String title);

  /// No description provided for @orderTotalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price: {price}'**
  String orderTotalPrice(String price);

  /// No description provided for @orderTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total : {price}'**
  String orderTotalLabel(String price);

  /// No description provided for @orderStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Status: {status}'**
  String orderStatusLabel(String status);

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status : {status}'**
  String statusLabel(String status);

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @orderIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Order ID: {id}'**
  String orderIdLabel(String id);

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Method : {method}'**
  String paymentMethodLabel(String method);

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @shippingAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address : {address}'**
  String shippingAddressLabel(String address);

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @tryOnTitle.
  ///
  /// In en, this message translates to:
  /// **'Try On'**
  String get tryOnTitle;

  /// No description provided for @underConstructionTitle.
  ///
  /// In en, this message translates to:
  /// **'Under Construction'**
  String get underConstructionTitle;

  /// No description provided for @comingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon.'**
  String get comingSoonMessage;

  /// No description provided for @brandOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get brandOwner;

  /// No description provided for @brandProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get brandProducts;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no orders, yet!'**
  String get ordersEmpty;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @building.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get building;

  /// No description provided for @floor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floor;

  /// No description provided for @flat.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get flat;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the required address fields (City, Street)'**
  String get fillRequiredFields;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed!'**
  String get orderPlaced;

  /// No description provided for @orderIdDisplay.
  ///
  /// In en, this message translates to:
  /// **'Order ID: #{id}'**
  String orderIdDisplay(String id);

  /// No description provided for @backToShopping.
  ///
  /// In en, this message translates to:
  /// **'Back to Shopping'**
  String get backToShopping;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'Items ({count})'**
  String itemsCount(int count);

  /// No description provided for @placedOn.
  ///
  /// In en, this message translates to:
  /// **'Placed on {date}'**
  String placedOn(String date);

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get statusShipped;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a 6-digit code to reset your password.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendOtpButton.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendOtpButton;

  /// No description provided for @otpSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to your email.'**
  String get otpSentSuccess;

  /// No description provided for @otpResentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification code resent successfully.'**
  String get otpResentSuccess;

  /// No description provided for @confirmEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Email'**
  String get confirmEmailTitle;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below.'**
  String get resetPasswordDescription;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPasswordLabel;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code'**
  String get otpHint;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendOtp;

  /// No description provided for @resendOtpCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendOtpCountdown(int seconds);

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code has been sent to {email}'**
  String otpSentTo(String email);

  /// No description provided for @emailConfirmedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed successfully! You can now sign in.'**
  String get emailConfirmedSuccess;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully! Please sign in with your new password.'**
  String get passwordResetSuccess;

  /// No description provided for @emailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Email Not Confirmed'**
  String get emailNotConfirmed;

  /// No description provided for @emailNotConfirmedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your email has not been confirmed yet. Would you like to confirm it now?'**
  String get emailNotConfirmedDescription;

  /// No description provided for @nationalIdLabel.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalIdLabel;

  /// No description provided for @nationalIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your 14-digit national ID'**
  String get nationalIdHint;

  /// No description provided for @nationalIdLength.
  ///
  /// In en, this message translates to:
  /// **'National ID must be exactly 14 digits'**
  String get nationalIdLength;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneNumberHint;

  /// No description provided for @birthDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select your birth date'**
  String get birthDateHint;

  /// No description provided for @adminUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsersTitle;

  /// No description provided for @adminUsersSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email or role…'**
  String get adminUsersSearch;

  /// No description provided for @adminUsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get adminUsersEmpty;

  /// No description provided for @adminUsersEmptySearch.
  ///
  /// In en, this message translates to:
  /// **'No users match your search'**
  String get adminUsersEmptySearch;

  /// No description provided for @adminUsersFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load users'**
  String get adminUsersFailedToLoad;

  /// No description provided for @adminUsersEmailVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get adminUsersEmailVerified;

  /// No description provided for @adminUsersEmailUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get adminUsersEmailUnverified;

  /// No description provided for @adminUsersRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminUsersRoleAdmin;

  /// No description provided for @adminUsersRoleStoreOwner.
  ///
  /// In en, this message translates to:
  /// **'Store Owner'**
  String get adminUsersRoleStoreOwner;

  /// No description provided for @adminUsersRoleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get adminUsersRoleUser;

  /// No description provided for @avgOrderValue.
  ///
  /// In en, this message translates to:
  /// **'Avg. Order Value'**
  String get avgOrderValue;

  /// No description provided for @salesPerCustomer.
  ///
  /// In en, this message translates to:
  /// **'Sales per Customer'**
  String get salesPerCustomer;

  /// No description provided for @salesTrend.
  ///
  /// In en, this message translates to:
  /// **'Sales Trend'**
  String get salesTrend;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @ordersChart.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersChart;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @conversionRate.
  ///
  /// In en, this message translates to:
  /// **'Conversion Rate'**
  String get conversionRate;

  /// No description provided for @egpCurrency.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get egpCurrency;

  /// No description provided for @storeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Store not found'**
  String get storeNotFound;

  /// No description provided for @storeNotFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Please ensure you are logged in as a seller with an active store.'**
  String get storeNotFoundDesc;

  /// No description provided for @salesLabel.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesLabel;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get material;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @orderHash.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderHash(String id);

  /// No description provided for @couldNotLoadOrder.
  ///
  /// In en, this message translates to:
  /// **'Could not load order details'**
  String get couldNotLoadOrder;

  /// No description provided for @updateOrderStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Order Status'**
  String get updateOrderStatus;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// No description provided for @itemsOrdered.
  ///
  /// In en, this message translates to:
  /// **'Items Ordered'**
  String get itemsOrdered;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @checkoutPreferences.
  ///
  /// In en, this message translates to:
  /// **'Checkout Preferences'**
  String get checkoutPreferences;

  /// No description provided for @savePreferences.
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get savePreferences;

  /// No description provided for @preferencesSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved successfully!'**
  String get preferencesSavedSuccess;

  /// No description provided for @saveAsDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Save as default address'**
  String get saveAsDefaultAddress;

  /// No description provided for @useAsDefaultAddressDesc.
  ///
  /// In en, this message translates to:
  /// **'Use this address automatically for future orders'**
  String get useAsDefaultAddressDesc;

  /// No description provided for @defaultShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Default Shipping Address'**
  String get defaultShippingAddress;

  /// No description provided for @saveShippingDetailsDesc.
  ///
  /// In en, this message translates to:
  /// **'Save your details here so you don\'t have to enter them every time you checkout.'**
  String get saveShippingDetailsDesc;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPasswordLabel;

  /// No description provided for @currentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get currentPasswordHint;

  /// No description provided for @changePasswordSaved.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get changePasswordSaved;

  /// No description provided for @changePasswordEmailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email not found. Please log in again.'**
  String get changePasswordEmailNotFound;

  /// No description provided for @securePasswordChange.
  ///
  /// In en, this message translates to:
  /// **'Secure Password Change'**
  String get securePasswordChange;

  /// No description provided for @otpSentToEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'To change your password, we\'ll send a One-Time Password (OTP) to your registered email address.'**
  String get otpSentToEmailDesc;

  /// No description provided for @noEmailFound.
  ///
  /// In en, this message translates to:
  /// **'No email found'**
  String get noEmailFound;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @unexpectedErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedErrorOccurred;

  /// No description provided for @differentBrandTitle.
  ///
  /// In en, this message translates to:
  /// **'Different Brand'**
  String get differentBrandTitle;

  /// No description provided for @differentBrandContent.
  ///
  /// In en, this message translates to:
  /// **'Your cart already contains items from another brand. Would you like to clear your cart and add this new item instead?'**
  String get differentBrandContent;

  /// No description provided for @clearCartAndAdd.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart & Add'**
  String get clearCartAndAdd;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @addressesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No addresses saved yet'**
  String get addressesEmpty;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
