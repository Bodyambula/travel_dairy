class AppStrings {
  // Загальні
  static const String appName = 'Travel App';

  // Екран входу
  static const String loginTitle = 'Вітаємо знову!';
  static const String loginSubtitle = 'Увійдіть до свого акаунту';
  static const String emailLabel = 'Електронна пошта';
  static const String emailHint = 'example@email.com';
  static const String passwordLabel = 'Пароль';
  static const String passwordHint = '********';
  static const String forgotPassword = 'Забули пароль?';
  static const String loginButton = 'Увійти';
  static const String noAccount = 'Немає акаунту?';
  static const String registerLink = 'Зареєструватися';

  // Екран реєстрації
  static const String registrationTitle = 'Створити акаунт';
  static const String registrationSubtitle = 'Почніть зберігати свої подорожі';
  static const String nameLabel = "Ім'я";
  static const String nameHint = "Введіть ваше ім'я";
  static const String confirmPasswordLabel = 'Підтвердіть пароль';
  static const String registerButton = 'Зареєструватися';
  static const String haveAccount = 'Вже маєте акаунт?';
  static const String loginLink = 'Увійти';

  // Головний екран
  static const String myTravels = 'Мої подорожі';
  static const String travelsCount = '3 подорожі збережено';
  static const String navHome = 'Головна';
  static const String navCalendar = 'Календар';
  static const String navPhotos = 'Фото';
  static const String navSettings = 'Налаштування';
  static const String navLogout = 'Вихід';

  // Валідація - Вхід
  static const String errorEmailRequired =
      'Будь ласка, введіть електронну пошту';
  static const String errorEmailInvalid = 'Введіть коректну електронну адресу';
  static const String errorPasswordRequired = 'Будь ласка, введіть пароль';
  static const String errorPasswordTooShort =
      'Пароль має містити не менше 6 символів';

  // Валідація - Реєстрація
  static const String errorNameRequired = "Будь ласка, введіть ваше ім'я";
  static const String errorNameTooShort =
      'Ім\'я має містити щонайменше 2 символи';
  static const String errorNameWithNumbers = 'Ім\'я не може містити цифри';
  static const String errorPasswordNoDigit =
      'Пароль має містити хоча б одну цифру';
  static const String errorPasswordNoLetter =
      'Пароль має містити хоча б одну літеру';
  static const String errorConfirmPasswordRequired =
      'Будь ласка, підтвердіть пароль';
  static const String errorPasswordMismatch = 'Паролі не збігаються';

  // Firebase помилки - Вхід
  static const String errorUserNotFound =
      'Користувача з такою поштою не знайдено';
  static const String errorWrongPassword = 'Неправильний пароль';
  static const String errorInvalidEmail = 'Некоректна електронна адреса';
  static const String errorUserDisabled =
      'Цей обліковий запис був деактивований';
  static const String errorTooManyRequests =
      'Занадто багато спроб. Спробуйте пізніше';
  static const String errorNetworkFailed =
      'Помилка мережі. Перевірте інтернет-з\'єднання';
  static const String errorLoginGeneric = 'Помилка входу:';
  static const String errorUnexpected = 'Непередбачена помилка:';
  static const String errorLogout = 'Помилка виходу:';

  // Firebase помилки - Реєстрація
  static const String errorEmailInUse =
      'Ця електронна адреса вже використовується';
  static const String errorOperationNotAllowed =
      'Реєстрація через email/пароль відключена';
  static const String errorWeakPassword = 'Пароль занадто слабкий';
  static const String errorRegistrationGeneric = 'Помилка реєстрації:';

  // Повідомлення про успіх
  static const String registrationSuccess =
      'Реєстрація успішна! Перевірте пошту для підтвердження';
  static const String passwordResetSent =
      'Лист для скидання пароля надіслано на вашу пошту';
  static const String passwordResetEmailRequired =
      'Введіть електронну пошту для скидання пароля';

  // Тестування
  static const String throwTestException = 'Throw Test Exception';

  //  Екран налаштувань ---
  static const String settingsTitle = 'Налаштування';
  static const String settingsSubtitle = 'Персоналізація застосунку';
  static const String settingsPushTitle = 'Push-нагадування';
  static const String settingsPushSubtitle = 'Нагадування про нотатки';
  static const String settingsSyncTitle = 'Синхронізація';
  static const String settingsSyncSubtitle = 'Автоматична синхронізація';
  static const String settingsLangTitle = 'Мова інтерфейсу';
  static const String settingsLangValue = 'Українська';
  static const String settingsExportTitle = 'Експорт подорожей';
  static const String settingsExportSubtitle = 'Зберегти всі дані';
  static const String settingsLogoutButton = 'Вийти з акаунту';
}
