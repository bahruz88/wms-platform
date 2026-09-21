import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import az from './locales/az.json';
import en from './locales/en.json';
import ru from './locales/ru.json';

/**
 * i18next — az is the default and the interface language (docs/CONVENTIONS.md, ADR-013);
 * en and ru are available for users who need them. The chosen language is remembered per browser.
 *
 * Interpolation never uppercases: `i` would become `I`, which is wrong in Azerbaijani.
 */

export const SUPPORTED_LANGUAGES = ['az', 'en', 'ru'] as const;
export type Language = (typeof SUPPORTED_LANGUAGES)[number];

export const LANGUAGE_NAMES: Record<Language, string> = {
  az: 'Azərbaycan',
  en: 'English',
  ru: 'Русский',
};

const STORAGE_KEY = 'wms.language';

export function storedLanguage(): Language {
  if (typeof window === 'undefined') return 'az';
  const saved = window.localStorage.getItem(STORAGE_KEY);
  return SUPPORTED_LANGUAGES.includes(saved as Language) ? (saved as Language) : 'az';
}

export function setLanguage(language: Language): void {
  window.localStorage.setItem(STORAGE_KEY, language);
  void i18n.changeLanguage(language);
  document.documentElement.lang = language;
}

void i18n.use(initReactI18next).init({
  resources: {
    az: { translation: az },
    en: { translation: en },
    ru: { translation: ru },
  },
  lng: storedLanguage(),
  fallbackLng: 'az',
  interpolation: { escapeValue: false },
  returnNull: false,
});

if (typeof document !== 'undefined') {
  document.documentElement.lang = storedLanguage();
}

export default i18n;
