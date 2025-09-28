export enum AppButtonType {
  PRIMARY = 'primary',
  SECONDARY = 'secondary',
  SUCCESS = 'success',
  WARNING = 'warning',
  DANGER = 'danger',
  TEXT = 'text'
}

export enum AppButtonSize {
  SMALL = 'small',
  MEDIUM = 'medium',
  LARGE = 'large'
}

@Component
export struct AppButton {
  @Prop buttonText: string = '';
  @Prop type: AppButtonType = AppButtonType.PRIMARY;
  @Prop buttonSize: AppButtonSize = AppButtonSize.MEDIUM;
  @Prop isEnabled: boolean = true;
  @Prop loading: boolean = false;
  @Prop buttonWidth: string | number = 'auto';
  @Prop buttonHeight: string | number = 'auto';
  onButtonClick?: () => void;

  build() {
    Button(this.loading ? '加载中...' : this.buttonText)
      .width(this.buttonWidth)
      .height(this.getButtonHeight())
      .backgroundColor(this.getBackgroundColor())
      .fontColor(this.getFontColor())
      .fontSize(this.getFontSize())
      .borderRadius(this.getBorderRadius())
      .border(this.getBorder())
      .enabled(this.isEnabled && !this.loading)
      .opacity(this.isEnabled && !this.loading ? 1 : 0.6)
      .onClick(() => {
        if (this.onButtonClick && !this.loading) {
          this.onButtonClick();
        }
      })
  }

  private getButtonHeight(): string | number {
    if (this.buttonHeight !== 'auto') {
      return this.buttonHeight;
    }
    switch (this.buttonSize) {
      case AppButtonSize.SMALL:
        return 32;
      case AppButtonSize.LARGE:
        return 48;
      default:
        return 40;
    }
  }

  private getFontSize(): number {
    switch (this.buttonSize) {
      case AppButtonSize.SMALL:
        return 12;
      case AppButtonSize.LARGE:
        return 16;
      default:
        return 14;
    }
  }

  private getBorderRadius(): number {
    switch (this.buttonSize) {
      case AppButtonSize.SMALL:
        return 4;
      case AppButtonSize.LARGE:
        return 8;
      default:
        return 6;
    }
  }

  private getBackgroundColor(): string {
    switch (this.type) {
      case AppButtonType.PRIMARY:
        return '#F34F40';
      case AppButtonType.SUCCESS:
        return '#52c41a';
      case AppButtonType.WARNING:
        return '#fa8c16';
      case AppButtonType.DANGER:
        return '#f5222d';
      case AppButtonType.TEXT:
        return 'transparent';
      default:
        return '#ffffff';
    }
  }

  private getFontColor(): string {
    switch (this.type) {
      case AppButtonType.PRIMARY:
      case AppButtonType.SUCCESS:
      case AppButtonType.WARNING:
      case AppButtonType.DANGER:
        return '#ffffff';
      case AppButtonType.TEXT:
        return '#1890ff';
      default:
        return '#333333';
    }
  }

  private getBorder(): BorderOptions {
    if (this.type === AppButtonType.SECONDARY) {
      return { width: 1, color: '#d9d9d9' };
    }
    return { width: 0, color: 'transparent' };
  }
}