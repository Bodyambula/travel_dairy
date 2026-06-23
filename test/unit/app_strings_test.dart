import 'package:flutter_test/flutter_test.dart';
import 'package:travel_dairy/utils/AppStrings.dart';

void main() {
  group('Exhaustive AppStrings Localization Tests', () {
    late AppStrings en;
    late AppStrings uk;

    setUp(() {
      en = AppStrings('en');
      uk = AppStrings('uk');
    });

    // --- General ---
    test('appName localization', () {
      expect(en.appName, 'Travel App');
      expect(uk.appName, 'Travel App');
    });

    // --- Login Screen ---
    test('loginTitle localization', () {
      expect(en.loginTitle, 'Welcome back!');
      expect(uk.loginTitle, 'Вітаємо знову!');
    });
    test('loginSubtitle localization', () {
      expect(en.loginSubtitle, 'Sign in to your account');
      expect(uk.loginSubtitle, 'Увійдіть до свого акаунту');
    });
    test('emailLabel localization', () {
      expect(en.emailLabel, 'Email');
      expect(uk.emailLabel, 'Електронна пошта');
    });
    test('passwordLabel localization', () {
      expect(en.passwordLabel, 'Password');
      expect(uk.passwordLabel, 'Пароль');
    });
    test('forgotPassword localization', () {
      expect(en.forgotPassword, 'Forgot password?');
      expect(uk.forgotPassword, 'Забули пароль?');
    });
    test('loginButton localization', () {
      expect(en.loginButton, 'Sign In');
      expect(uk.loginButton, 'Увійти');
    });
    test('registerLink localization', () {
      expect(en.registerLink, 'Sign Up');
      expect(uk.registerLink, 'Зареєструватися');
    });

    // --- Registration Screen ---
    test('registrationTitle localization', () {
      expect(en.registrationTitle, 'Create Account');
      expect(uk.registrationTitle, 'Створити акаунт');
    });
    test('nameLabel localization', () {
      expect(en.nameLabel, 'Name');
      expect(uk.nameLabel, "Ім'я");
    });
    test('confirmPasswordLabel localization', () {
      expect(en.confirmPasswordLabel, 'Confirm Password');
      expect(uk.confirmPasswordLabel, 'Підтвердіть пароль');
    });

    // --- Home Screen & Navigation ---
    test('myTravels localization', () {
      expect(en.myTravels, 'My Trips');
      expect(uk.myTravels, 'Мої подорожі');
    });
    test('navHome localization', () {
      expect(en.navHome, 'Home');
      expect(uk.navHome, 'Головна');
    });
    test('navCalendar localization', () {
      expect(en.navCalendar, 'Calendar');
      expect(uk.navCalendar, 'Календар');
    });
    test('navSettings localization', () {
      expect(en.navSettings, 'Settings');
      expect(uk.navSettings, 'Налаштування');
    });
    test('travelsCount pluralization localization', () {
      expect(en.travelsCount(0), '0 trips saved');
      expect(uk.travelsCount(0), '0 подорожі збережено');
      expect(en.travelsCount(5), '5 trips saved');
      expect(uk.travelsCount(5), '5 подорожі збережено');
    });

    // --- Validation - Login ---
    test('errorEmailRequired localization', () {
      expect(en.errorEmailRequired, 'Please enter email');
      expect(uk.errorEmailRequired, 'Будь ласка, введіть електронну пошту');
    });
    test('errorPasswordTooShort localization', () {
      expect(en.errorPasswordTooShort, 'Password must be at least 6 characters');
      expect(uk.errorPasswordTooShort, 'Пароль має містити не менше 6 символів');
    });

    // --- Validation - Registration ---
    test('errorNameRequired localization', () {
      expect(en.errorNameRequired, 'Please enter your name');
      expect(uk.errorNameRequired, "Будь ласка, введіть ваше ім'я");
    });
    test('errorPasswordMismatch localization', () {
      expect(en.errorPasswordMismatch, 'Passwords do not match');
      expect(uk.errorPasswordMismatch, 'Паролі не збігаються');
    });

    // --- Firebase Errors ---
    test('errorUserNotFound localization', () {
      expect(en.errorUserNotFound, 'No user found with this email');
      expect(uk.errorUserNotFound, 'Користувача з такою поштою не знайдено');
    });
    test('errorNetworkFailed localization', () {
      expect(en.errorNetworkFailed, 'Network error. Check connection');
      expect(uk.errorNetworkFailed, "Помилка мережі. Перевірте інтернет-з'єднання");
    });

    // --- Settings ---
    test('settingsTitle localization', () {
      expect(en.settingsTitle, 'Settings');
      expect(uk.settingsTitle, 'Налаштування');
    });
    test('settingsPushTitle localization', () {
      expect(en.settingsPushTitle, 'Push notifications');
      expect(uk.settingsPushTitle, 'Push-нагадування');
    });
    test('settingsLogoutButton localization', () {
      expect(en.settingsLogoutButton, 'Logout');
      expect(uk.settingsLogoutButton, 'Вийти з акаунту');
    });

    // --- Gallery ---
    test('galleryTitle localization', () {
      expect(en.galleryTitle, 'Gallery');
      expect(uk.galleryTitle, 'Галерея');
    });
    test('photosTitleCount localization', () {
      expect(en.photosTitleCount(3), '3 travel photos');
      expect(uk.photosTitleCount(3), '3 фото з подорожей');
    });

    // --- Add Trip ---
    test('newTripTitle localization', () {
      expect(en.newTripTitle, 'New Trip');
      expect(uk.newTripTitle, 'Нова подорож');
    });
    test('errorEnterName localization', () {
      expect(en.errorEnterName, 'Enter a name');
      expect(uk.errorEnterName, 'Введіть назву');
    });
    test('dateHint localization', () {
      expect(en.dateHint, 'dd. mm. yyyy');
      expect(uk.dateHint, 'дд. мм. рррр');
    });

    // --- Trip Details ---
    test('routeTitle localization', () {
      expect(en.routeTitle, 'Route');
      expect(uk.routeTitle, 'Маршрут');
    });
    test('shareComingSoon localization', () {
      expect(en.shareComingSoon, 'Share feature is in development');
      expect(uk.shareComingSoon, "Функція 'Поділитися' ще в розробці");
    });

    // --- Calendar ---
    test('calendarTitle localization', () {
      expect(en.calendarTitle, 'Trip Calendar');
      expect(uk.calendarTitle, 'Календар подорожей');
    });
    test('monthYearFormat localization', () {
      expect(en.monthYearFormat(1, 2026), 'January 2026');
      expect(uk.monthYearFormat(1, 2026), 'Січень 2026');
      expect(en.monthYearFormat(12, 2026), 'December 2026');
      expect(uk.monthYearFormat(12, 2026), 'Грудень 2026');
    });

    // --- Interaction Feedback ---
    test('routeFeatureComingSoon localization', () {
      expect(en.routeFeatureComingSoon, 'Build Route feature is coming soon!');
      expect(uk.routeFeatureComingSoon, "Функція 'Побудувати маршрут' скоро з'явиться!");
    });

    // --- Confirmation Dialogs ---
    test('deleteTripTitle localization', () {
      expect(en.deleteTripTitle, 'Delete trip?');
      expect(uk.deleteTripTitle, 'Видалити подорож?');
    });
    test('deleteTripContent localization', () {
      expect(en.deleteTripContent, 'Are you sure you want to delete this trip? This action cannot be undone.');
      expect(uk.deleteTripContent, 'Ви впевнені, що хочете видалити цю подорож? Цю дію не можна скасувати.');
    });

    // --- Buttons & Labels ---
    test('cancelBtn localization', () {
      expect(en.cancelBtn, 'Cancel');
      expect(uk.cancelBtn, 'Скасувати');
    });
    test('deleteBtn localization', () {
      expect(en.deleteBtn, 'Delete');
      expect(uk.deleteBtn, 'Видалити');
    });
    test('editBtn localization', () {
      expect(en.editBtn, 'Edit');
      expect(uk.editBtn, 'Редагувати');
    });
    test('shareBtn localization', () {
      expect(en.shareBtn, 'Share');
      expect(uk.shareBtn, 'Поділитися');
    });

    // --- Map Picker Specifics ---
    test('pickOnMapLabel localization', () {
      expect(en.pickOnMapLabel, 'Pick on Map');
      expect(uk.pickOnMapLabel, 'Вибрати на карті');
    });
    test('mapPickerDone localization', () {
      expect(en.mapPickerDone, 'Done');
      expect(uk.mapPickerDone, 'Готово');
    });
    test('mapPickerInstruction localization', () {
      expect(en.mapPickerInstruction, 'Tap on the map to add a stop');
      expect(uk.mapPickerInstruction, 'Торкніться карти, щоб додати зупинку');
    });

    // --- Pluralization Edge Cases ---
    test('photosCount pluralization edge cases', () {
      expect(en.photosCount(0), '0 photos');
      expect(uk.photosCount(0), '0 фото');
      expect(en.photosCount(1), '1 photos');
      expect(uk.photosCount(1), '1 фото');
      expect(en.photosCount(10), '10 photos');
      expect(uk.photosCount(10), '10 фото');
    });

    test('selectedPhotosCount localization', () {
      expect(en.selectedPhotosCount(2), 'Selected photos (2)');
      expect(uk.selectedPhotosCount(2), 'Обрані фото (2)');
    });

    test('errorPasswordMismatch localization', () {
      expect(en.errorPasswordMismatch, 'Passwords do not match');
      expect(uk.errorPasswordMismatch, 'Паролі не збігаються');
    });

    test('errorWeakPassword localization', () {
      expect(en.errorWeakPassword, 'Password is too weak');
      expect(uk.errorWeakPassword, 'Пароль занадто слабкий');
    });

    test('registrationSuccess localization', () {
      expect(en.registrationSuccess, 'Registration successful! Check email to verify');
      expect(uk.registrationSuccess, 'Реєстрація успішна! Перевірте пошту для підтвердження');
    });

    test('passwordResetSent localization', () {
      expect(en.passwordResetSent, 'Password reset email sent');
      expect(uk.passwordResetSent, 'Лист для скидання пароля надіслано на вашу пошту');
    });

    test('addPhotoBtn localization', () {
      expect(en.addPhotoBtn, 'Add Photo');
      expect(uk.addPhotoBtn, 'Додати фото');
    });

    test('cityHint localization', () {
      expect(en.cityHint, 'E.g.: Kyiv');
      expect(uk.cityHint, 'Наприклад: Київ');
    });

    test('mapPickerTitle localization', () {
      expect(en.mapPickerTitle, 'Pick Route Points');
      expect(uk.mapPickerTitle, 'Вибір маршруту');
    });
  });
}
