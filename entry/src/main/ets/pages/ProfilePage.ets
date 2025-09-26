import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'
import bundleManager from '@ohos.bundle.bundleManager'
import { BusinessError } from '@kit.BasicServicesKit'

interface UserStats {
  totalQuestions: number
  correctAnswers: number
  accuracy: number
  streakDays: number
  totalStudyTime: number
  level: number
  experience: number
}

@Entry
@Component
export struct ProfilePage {
  @State userName: string = ''
  @State userAvatar: string = ''
  @State versionName: string = '';
  @State showAboutSheet: boolean = false;
  @State userStats: UserStats = {
    totalQuestions: 0,
    correctAnswers: 0,
    accuracy: 0,
    streakDays: 0,
    totalStudyTime: 0,
    level: 1,
    experience: 0
  }

  aboutToAppear() {
    this.initUserInfo()
    this.loadUserStats()
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionName = bundleInfo.versionName;
    }).catch((error: BusinessError) => {
      console.error("get bundleInfo failed,error is " + error)
    })
  }

  // 显示关于对话框
  private showAboutDialog() {
    // 这里可以实现关于应用的对话框
    this.showAboutSheet = true;
    console.info('关于应用功能');
  }

  initUserInfo() {
    // 生成随机4位数字
    const randomNum = Math.floor(Math.random() * 9000) + 1000
    this.userName = `仓颉编程爱好者${randomNum}`
    this.userAvatar = 'ic_default_avatar'
  }

  async loadUserStats() {
    try {
      // 从数据库加载用户统计数据
      // 暂时使用模拟数据
      this.userStats = {
        totalQuestions: 0,
        correctAnswers: 0,
        accuracy: 0,
        streakDays: 0,
        totalStudyTime: 0,
        level: 1,
        experience: 0
      }
    } catch (error) {
      console.error('加载用户统计失败:', error)
    }
  }

  build() {
    Scroll() {
      Column() {
        // 个人信息区域
        this.ProfileSection()
        
        // 统计数据区域
        this.StatsSection()
        
        // 功能菜单区域
        this.MenuSection()
        
        // 设置区域
        this.SettingsSection()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .bindSheet($$this.showAboutSheet, this.AboutSheet(), {
        height: 400,
        dragBar: true,
        showClose: false,
        preferType:SheetType.CENTER,
        backgroundColor: $r('app.color.surface_color'),
        onDisappear: () => {
          // 移除状态重置，避免与深色模式切换冲突
          this.showAboutSheet = false;
        }
      })
    }
    .backgroundColor('#F5F5F5')
    .height('100%')
  }

  @Builder ProfileSection() {
    Column() {
      // 头像和用户名
      Row() {
        Image($r('app.media.ic_mine'))
          .width(50)
          .height(50)
          .borderRadius(25)
          .borderColor('#333333')
          .borderWidth(1)
          .margin({ right: 16 })
          .backgroundColor('#FFFFFF')
          .padding(10)
          .shadow({
            radius: 4,
            color: 'rgba(0,0,0,0.1)',
            offsetX: 0,
            offsetY: 2
          })
        
        Column() {
          Text(this.userName)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Row() {
            Text(`等级: ${this.userStats.level}`)
              .fontSize(14)
              .fontColor('#007AFF')
              .backgroundColor('#E3F2FD')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(8)
            
            Text(`经验: ${this.userStats.experience}`)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ left: 12 })
          }
          .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ bottom: 20 })
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder StatsSection() {
    Column() {
      Text('学习统计')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 16 })

      // 第一行统计
      Row() {
        this.StatItem('答题总数', this.userStats.totalQuestions.toString(), '#4CAF50')
        this.StatItem('正确答案', this.userStats.correctAnswers.toString(), '#2196F3')
        this.StatItem('正确率', `${this.userStats.accuracy}%`, '#FF9800')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 12 })

      // 第二行统计
      Row() {
        this.StatItem('连续天数', `${this.userStats.streakDays}天`, '#9C27B0')
        this.StatItem('学习时长', `${this.userStats.totalStudyTime}分钟`, '#607D8B')
        this.StatItem('当前等级', `${this.userStats.level}级`, '#795548')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ bottom: 20 })
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder StatItem(title: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      
      Text(title)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .width('30%')
    .height(60)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F8F9FA')
    .borderRadius(12)
  }

  @Builder MenuSection() {
    Column() {
      Text('我的功能')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 16 })

      this.MenuItem('我的收藏', '查看收藏的题目', $r('app.media.ic_favorite'), () => {
        router.pushUrl({ url: 'pages/FavoritesPage' })
      })

      this.MenuItem('错题本', '查看答错的题目', $r('app.media.ic_wrong_questions'), () => {
        router.pushUrl({ url: 'pages/WrongQuestionsPage' })
      })

      this.MenuItem('学习路线', '查看学习进度', $r('app.media.ic_learning_path'), () => {
        router.pushUrl({ url: 'pages/LearningPathPage' })
      })

      this.MenuItem('数据统计', '详细学习数据', $r('app.media.ic_statistics'), () => {
        router.pushUrl({ url: 'pages/StatisticsPage' })
      })

      this.MenuItem('成就系统', '查看获得的成就', $r('app.media.ic_achievement'), () => {
        router.pushUrl({ url: 'pages/AchievementPage' })
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ bottom: 20 })
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder SettingsSection() {
    Column() {
      Text('设置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 16 })

      // this.MenuItem('通知设置', '管理推送通知', $r('app.media.ic_notification'), () => {
      //   router.pushUrl({ url: 'pages/NotificationSettingsPage' })
      // })
      //
      // this.MenuItem('学习提醒', '设置学习提醒时间', $r('app.media.ic_reminder'), () => {
      //   router.pushUrl({ url: 'pages/ReminderSettingsPage' })
      // })
      //
      // this.MenuItem('数据备份', '备份学习数据', $r('app.media.ic_backup'), () => {
      //   router.pushUrl({ url: 'pages/BackupPage' })
      // })

      this.MenuItem('关于应用', '版本信息和帮助', $r('app.media.ic_info'), () => {
        this.showAboutDialog();
      })

      // this.MenuItem('清除数据', '重置所有学习数据', $r('app.media.ic_delete'), () => {
      //   this.showClearDataDialog()
      // }, '#F44336')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder MenuItem(title: string, subtitle: string, icon: Resource, onClick: () => void, textColor?: string) {
    Row() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(textColor || '#666666')
        .margin({ right: 16 })
      
      Column() {
        Text(title)
          .fontSize(16)
          .fontColor(textColor || '#333333')
          .width('100%')
          .textAlign(TextAlign.Start)
        
        Text(subtitle)
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      
      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .height(60)
    .alignItems(VerticalAlign.Center)
    .onClick(onClick)
    .padding({ top: 8, bottom: 8 })
  }

  showClearDataDialog() {
    AlertDialog.show({
      title: '清除数据',
      message: '确定要清除所有学习数据吗？此操作不可恢复。',
      primaryButton: {
        value: '确定',
        fontColor: '#F44336',
        action: () => {
          this.clearAllData()
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    })
  }

  async clearAllData() {
    try {
      // 清除数据库中的所有用户数据
      // 实现数据清除逻辑
      
      // 重新初始化用户信息
      this.initUserInfo()
      this.loadUserStats()
      
      // 显示成功提示
      promptAction.showToast({
        message: '数据已清除',
        duration: 2000
      })
    } catch (error) {
      console.error('清除数据失败:', error)
      promptAction.showToast({
        message: '清除数据失败',
        duration: 2000
      })
    }
  }

  @Builder
  AboutSheet() {
    Column() {
      // Sheet标题
      Text('关于App')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text_color'))
        .margin({ top: 20, bottom: 20 })

      // 应用图标
      Image($r('app.media.startIcon'))
        .width(80)
        .height(80)
        .borderRadius(16)
        .margin({ bottom: 16 })

      // 应用信息
      Column() {
        Text('仓颉学习宝典')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_text_color'))
          .margin({ bottom: 8 })

        Text($r('app.string.version', '版本号', this.versionName))
          .fontSize(14)
          .fontColor($r('app.color.secondary_text_color'))
          .margin({ bottom: 8 })

        Text('仓颉编程从入门到精通')
          .fontSize(14)
          .fontColor($r('app.color.primary_text_color'))
          .textAlign(TextAlign.Center)
          .margin({ bottom: 16 })

      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Blank()

      // 版权信息
      Text('© 2025 仓颉学习宝典团队')
        .fontSize(12)
        .fontColor($r('app.color.tertiary_text_color'))
        .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}