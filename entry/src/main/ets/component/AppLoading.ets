@Component
export struct AppLoading {
  @Prop loadingText: string = '加载中...';

  build() {
    Column({ space: 16 }) {
      LoadingProgress()
        .width(32)
        .height(32)
        .color('#007DFF')

      Text(this.loadingText)
        .fontSize(14)
        .fontColor('#666666')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}