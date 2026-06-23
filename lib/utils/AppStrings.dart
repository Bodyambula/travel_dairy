import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class AppStrings {
  final String locale;

  AppStrings(this.locale);

  static AppStrings of(BuildContext context, {bool listen = true}) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: listen);
    return AppStrings(localeProvider.locale.languageCode);
  }

  // Загальні
  String get appName => locale == 'en' ? 'Travel App' : 'Travel App';

  // Екран входу
  String get loginTitle => locale == 'en' ? 'Welcome back!' : 'Вітаємо знову!';
  String get loginSubtitle => locale == 'en' ? 'Sign in to your account' : 'Увійдіть до свого акаунту';
  String get emailLabel => locale == 'en' ? 'Email' : 'Електронна пошта';
  String get emailHint => locale == 'en' ? 'example@email.com' : 'example@email.com';
  String get passwordLabel => locale == 'en' ? 'Password' : 'Пароль';
  String get passwordHint => locale == 'en' ? '********' : '********';
  String get forgotPassword => locale == 'en' ? 'Forgot password?' : 'Забули пароль?';
  String get loginButton => locale == 'en' ? 'Sign In' : 'Увійти';
  String get noAccount => locale == 'en' ? "Don't have an account?" : 'Немає акаунту?';
  String get registerLink => locale == 'en' ? 'Sign Up' : 'Зареєструватися';

  // Екран реєстрації
  String get registrationTitle => locale == 'en' ? 'Create Account' : 'Створити акаунт';
  String get registrationSubtitle => locale == 'en' ? 'Start saving your trips' : 'Почніть зберігати свої подорожі';
  String get nameLabel => locale == 'en' ? 'Name' : "Ім'я";
  String get nameHint => locale == 'en' ? 'Enter your name' : "Введіть ваше ім'я";
  String get confirmPasswordLabel => locale == 'en' ? 'Confirm Password' : 'Підтвердіть пароль';
  String get registerButton => locale == 'en' ? 'Sign Up' : 'Зареєструватися';
  String get haveAccount => locale == 'en' ? 'Already have an account?' : 'Вже маєте акаунт?';
  String get loginLink => locale == 'en' ? 'Sign In' : 'Увійти';

  // Головний екран
  String get myTravels => locale == 'en' ? 'My Trips' : 'Мої подорожі';
  String travelsCount(int count) => locale == 'en' ? '$count trips saved' : '$count подорожі збережено';
  String get navHome => locale == 'en' ? 'Home' : 'Головна';
  String get navCalendar => locale == 'en' ? 'Calendar' : 'Календар';
  String get navPhotos => locale == 'en' ? 'Photos' : 'Фото';
  String get navSettings => locale == 'en' ? 'Settings' : 'Налаштування';
  String get navLogout => locale == 'en' ? 'Logout' : 'Вихід';

  // Валідація - Вхід
  String get errorEmailRequired => locale == 'en' ? 'Please enter email' : 'Будь ласка, введіть електронну пошту';
  String get errorEmailInvalid => locale == 'en' ? 'Enter a valid email' : 'Введіть коректну електронну адресу';
  String get errorPasswordRequired => locale == 'en' ? 'Please enter password' : 'Будь ласка, введіть пароль';
  String get errorPasswordTooShort => locale == 'en' ? 'Password must be at least 6 characters' : 'Пароль має містити не менше 6 символів';

  // Валідація - Реєстрація
  String get errorNameRequired => locale == 'en' ? 'Please enter your name' : "Будь ласка, введіть ваше ім'я";
  String get errorNameTooShort => locale == 'en' ? 'Name must be at least 2 characters' : "Ім'я має містити щонайменше 2 символи";
  String get errorNameWithNumbers => locale == 'en' ? 'Name cannot contain numbers' : "Ім'я не може містити цифри";
  String get errorPasswordNoDigit => locale == 'en' ? 'Password must contain at least one digit' : 'Пароль має містити хоча б одну цифру';
  String get errorPasswordNoLetter => locale == 'en' ? 'Password must contain at least one letter' : 'Пароль має містити хоча б одну літеру';
  String get errorConfirmPasswordRequired => locale == 'en' ? 'Please confirm password' : 'Будь ласка, підтвердіть пароль';
  String get errorPasswordMismatch => locale == 'en' ? 'Passwords do not match' : 'Паролі не збігаються';

  // Firebase помилки - Вхід
  String get errorUserNotFound => locale == 'en' ? 'No user found with this email' : 'Користувача з такою поштою не знайдено';
  String get errorWrongPassword => locale == 'en' ? 'Wrong password' : 'Неправильний пароль';
  String get errorInvalidEmail => locale == 'en' ? 'Invalid email address' : 'Некоректна електронна адреса';
  String get errorUserDisabled => locale == 'en' ? 'This account has been disabled' : 'Цей обліковий запис був деактивований';
  String get errorTooManyRequests => locale == 'en' ? 'Too many requests. Try again later' : 'Занадто багато спроб. Спробуйте пізніше';
  String get errorNetworkFailed => locale == 'en' ? 'Network error. Check connection' : "Помилка мережі. Перевірте інтернет-з'єднання";
  String get errorLoginGeneric => locale == 'en' ? 'Login error:' : 'Помилка входу:';
  String get thisMonthTrips => locale == 'en' ? 'Trips this month:' : 'Подорожі цього місяця:';
  String get noTripsThisMonth => locale == 'en' ? 'No planned trips this month.' : 'У цьому місяці немає запланованих подорожей.';
  List<String> get daysOfWeek => locale == 'en' ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] : ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];
  String get errorUnexpected => locale == 'en' ? 'Unexpected error:' : 'Непередбачена помилка:';
  String get errorLogout => locale == 'en' ? 'Logout error:' : 'Помилка виходу:';

  // Firebase помилки - Реєстрація
  String get errorEmailInUse => locale == 'en' ? 'Email is already in use' : 'Ця електронна адреса вже використовується';
  String get errorOperationNotAllowed => locale == 'en' ? 'Email/password registration is disabled' : 'Реєстрація через email/пароль відключена';
  String get errorWeakPassword => locale == 'en' ? 'Password is too weak' : 'Пароль занадто слабкий';
  String get errorRegistrationGeneric => locale == 'en' ? 'Registration error:' : 'Помилка реєстрації:';

  // Повідомлення про успіх
  String get registrationSuccess => locale == 'en' ? 'Registration successful! Check email to verify' : 'Реєстрація успішна! Перевірте пошту для підтвердження';
  String get passwordResetSent => locale == 'en' ? 'Password reset email sent' : 'Лист для скидання пароля надіслано на вашу пошту';
  String get passwordResetEmailRequired => locale == 'en' ? 'Enter email to reset password' : 'Введіть електронну пошту для скидання пароля';

  // Тестування
  String get throwTestException => locale == 'en' ? 'Throw Test Exception' : 'Throw Test Exception';

  // Екран налаштувань
  String get settingsTitle => locale == 'en' ? 'Settings' : 'Налаштування';
  String get settingsSubtitle => locale == 'en' ? 'App personalization' : 'Персоналізація застосунку';
  String get settingsPushTitle => locale == 'en' ? 'Push notifications' : 'Push-нагадування';
  String get settingsPushSubtitle => locale == 'en' ? 'Reminders about trips' : 'Нагадування про нотатки';
  String get settingsSyncTitle => locale == 'en' ? 'Synchronization' : 'Синхронізація';
  String get settingsSyncSubtitle => locale == 'en' ? 'Auto sync' : 'Автоматична синхронізація';
  String get settingsLangTitle => locale == 'en' ? 'Interface language' : 'Мова інтерфейсу';
  String get settingsLangValue => locale == 'en' ? 'English' : 'Українська';
  String get settingsExportTitle => locale == 'en' ? 'Export trips' : 'Експорт подорожей';
  String get settingsExportSubtitle => locale == 'en' ? 'Save all data' : 'Зберегти всі дані';
  String get settingsLogoutButton => locale == 'en' ? 'Logout' : 'Вийти з акаунту';

  // Home Screen
  String get loading => locale == 'en' ? 'Updating...' : 'Оновлення...';
  String get tryAgain => locale == 'en' ? 'Try again' : 'Спробувати знову';
  String get noTripsYet => locale == 'en' ? 'No trips yet' : 'Поки що немає подорожей';
  String photosCount(int count) => locale == 'en' ? '$count photos' : '$count фото';
  String get deleteTripTitle => locale == 'en' ? 'Delete trip?' : 'Видалити подорож?';
  String get deleteTripContent => locale == 'en' ? 'Are you sure you want to delete this trip? This action cannot be undone.' : 'Ви впевнені, що хочете видалити цю подорож? Цю дію не можна скасувати.';
  String get cancelBtn => locale == 'en' ? 'Cancel' : 'Скасувати';
  String get deleteBtn => locale == 'en' ? 'Delete' : 'Видалити';

  // Gallery
  String get categoryAll => locale == 'en' ? 'All' : 'Всі';
  String get galleryTitle => locale == 'en' ? 'Gallery' : 'Галерея';
  String photosTitleCount(int count) => locale == 'en' ? '$count travel photos' : '$count фото з подорожей';
  String get noPhotos => locale == 'en' ? 'No photos' : 'Немає фотографій';

  // Add Trip
  String get errorSelectDates => locale == 'en' ? 'Please select trip dates' : 'Будь ласка, оберіть дати подорожі';
  String errorGeneric(String e) => locale == 'en' ? 'Error: $e' : 'Помилка: $e';
  String get newTripTitle => locale == 'en' ? 'New Trip' : 'Нова подорож';
  String get editTripTitle => locale == 'en' ? 'Edit Trip' : 'Редагувати подорож';
  String get fillDetails => locale == 'en' ? 'Fill details' : 'Заповніть деталі';
  String get tripNameLabel => locale == 'en' ? 'Trip name' : 'Назва подорожі';
  String get tripNameHint => locale == 'en' ? 'E.g.: Summer in Greece' : 'Наприклад: Літо в Греції';
  String get errorEnterName => locale == 'en' ? 'Enter a name' : 'Введіть назву';
  String get startDate => locale == 'en' ? 'Start Date' : 'Дата початку';
  String get endDate => locale == 'en' ? 'End Date' : 'Дата завершення';
  String get descriptionLabel => locale == 'en' ? 'Description' : 'Опис';
  String get descriptionHint => locale == 'en' ? 'Tell us about your trip...' : 'Розкажіть про вашу подорож...';
  String selectedPhotosCount(int count) => locale == 'en' ? 'Selected photos ($count)' : 'Обрані фото ($count)';
  String get addPhotoBtn => locale == 'en' ? 'Add Photo' : 'Додати фото';
  String get buildRouteBtn => locale == 'en' ? 'Build Route' : 'Побудувати маршрут';
  String get routeFeatureComingSoon => locale == 'en' ? 'Build Route feature is coming soon!' : "Функція 'Побудувати маршрут' скоро з'явиться!";
  String get addCityLabel => locale == 'en' ? 'Add City' : 'Додати місто';
  String get cityHint => locale == 'en' ? 'E.g.: Kyiv' : 'Наприклад: Київ';
  String get errorEnterCity => locale == 'en' ? 'Please enter a city name' : 'Введіть назву міста';
  String get errorNoCitiesForRoute => locale == 'en' ? 'Add at least 2 cities to build a route' : 'Додайте щонайменше 2 міста для маршруту';
  String get mapLoading => locale == 'en' ? 'Building route...' : 'Будуємо маршрут...';
  String get mapError => locale == 'en' ? 'Failed to build route' : 'Не вдалося побудувати маршрут';
  String get pickOnMapLabel => locale == 'en' ? 'Pick on Map' : 'Вибрати на карті';
  String get mapPickerTitle => locale == 'en' ? 'Pick Route Points' : 'Вибір маршруту';
  String get mapPickerInstruction => locale == 'en' ? 'Tap on the map to add a stop' : 'Торкніться карти, щоб додати зупинку';
  String get errorCityNotFound => locale == 'en' ? 'Could not recognize a city here' : 'Не вдалося розпізнати місто в цій точці';
  String get mapPickerDone => locale == 'en' ? 'Done' : 'Готово';
  String get mapPickerFetching => locale == 'en' ? 'Fetching city...' : 'Визначення міста...';
  String get dateHint => locale == 'en' ? 'dd. mm. yyyy' : 'дд. мм. рррр';
  String monthYearFormat(int month, int year) {
    List<String> mEn = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    List<String> mUk = ['Січень', 'Лютий', 'Березень', 'Квітень', 'Травень', 'Червень', 'Липень', 'Серпень', 'Вересень', 'Жовтень', 'Листопад', 'Грудень'];
    String m = locale == 'en' ? mEn[month - 1] : mUk[month - 1];
    return '$m $year';
  }
  String get calendarTitle => locale == 'en' ? 'Trip Calendar' : 'Календар подорожей';

  // Trip Details
  String get routeTitle => locale == 'en' ? 'Route' : 'Маршрут';
  String get photosSubtitle => locale == 'en' ? 'Photos' : 'Фото';
  String get editBtn => locale == 'en' ? 'Edit' : 'Редагувати';
  String get shareBtn => locale == 'en' ? 'Share' : 'Поділитися';
  String get shareComingSoon => locale == 'en' ? 'Share feature is in development' : "Функція 'Поділитися' ще в розробці";
}
