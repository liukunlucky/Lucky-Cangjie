import { HomePage } from './HomePage'
import { QuestionBankPage } from './QuestionBankPage'
import { ExamPage } from './ExamPage'
import { ProfilePage } from './ProfilePage'

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        HomePage()
      }
      .tabBar(this.TabBuilder(0, '首页', $r('app.media.ic_home')))

      TabContent() {
        QuestionBankPage()
      }
      .tabBar(this.TabBuilder(1, '题库', $r('app.media.ic_question_bank')))

      TabContent() {
        ExamPage()
      }
      .tabBar(this.TabBuilder(2, '考试', $r('app.media.ic_exam')))

      TabContent() {
        ProfilePage()
      }
      .tabBar(this.TabBuilder(3, '我的', $r('app.media.ic_profile')))
    }
    .animationDuration(300)
    .scrollable(false)
    .barMode(BarMode.Fixed)
    .barHeight(56)
    .onChange((index: number) => {
      this.currentTabIndex = index
      if (index == 0) {
        // 当首页tab显示时，刷新收藏状态
        AppStorage.setOrCreate('refreshHome', Date.now());
      }
    })
    .backgroundColor('#F5F5F5')
  }

  @Builder TabBuilder(index: number, title: string, icon: Resource) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentTabIndex === index ? '#007AFF' : '#999999')
      
      Text(title)
        .fontSize(12)
        .fontColor(this.currentTabIndex === index ? '#007AFF' : '#999999')
        .margin({ top: 4 })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}