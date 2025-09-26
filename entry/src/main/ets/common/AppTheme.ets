// 应用主题管理
export interface AppColors {
  primary: string;
  onPrimary: string;
  secondary: string;
  onSecondary: string;
  surface: string;
  onSurface: string;
  background: string;
  onBackground: string;
  error: string;
  onError: string;
  outline: string;
  surfaceVariant: string;
  onSurfaceVariant: string;
}

export interface AppTheme {
  colors: AppColors;
  isDark: boolean;
}

// 浅色主题
const lightColors: AppColors = {
  primary: '#6750A4',
  onPrimary: '#FFFFFF',
  secondary: '#625B71',
  onSecondary: '#FFFFFF',
  surface: '#FFFBFE',
  onSurface: '#1C1B1F',
  background: '#FFFBFE',
  onBackground: '#1C1B1F',
  error: '#BA1A1A',
  onError: '#FFFFFF',
  outline: '#79747E',
  surfaceVariant: '#E7E0EC',
  onSurfaceVariant: '#49454F'
};

// 深色主题
const darkColors: AppColors = {
  primary: '#D0BCFF',
  onPrimary: '#381E72',
  secondary: '#CCC2DC',
  onSecondary: '#332D41',
  surface: '#1C1B1F',
  onSurface: '#E6E1E5',
  background: '#1C1B1F',
  onBackground: '#E6E1E5',
  error: '#F2B8B5',
  onError: '#601410',
  outline: '#938F99',
  surfaceVariant: '#49454F',
  onSurfaceVariant: '#CAC4D0'
};

export const lightTheme: AppTheme = {
  colors: lightColors,
  isDark: false
};

export const darkTheme: AppTheme = {
  colors: darkColors,
  isDark: true
};

// 主题管理器
export class ThemeManager {
  private static instance: ThemeManager;
  private currentTheme: AppTheme = lightTheme;
  private listeners: ((theme: AppTheme) => void)[] = [];

  private constructor() {}

  static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  getCurrentTheme(): AppTheme {
    return this.currentTheme;
  }

  setTheme(theme: AppTheme): void {
    this.currentTheme = theme;
    this.notifyListeners();
  }

  toggleTheme(): void {
    this.currentTheme = this.currentTheme.isDark ? lightTheme : darkTheme;
    this.notifyListeners();
  }

  addThemeListener(listener: (theme: AppTheme) => void): void {
    this.listeners.push(listener);
  }

  removeThemeListener(listener: (theme: AppTheme) => void): void {
    const index = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this.currentTheme));
  }
}