import router from '@ohos.router'
import { DatabaseManager } from '../common/DatabaseManager'
import { AchievementModel } from '../common/models/AchievementModel'
import { AchievementManager } from '../common/AchievementManager'

@Entry
@Component
struct AchievementPage {
  @State achievements: AchievementModel[] = []
  @State selectedCategory: string = '全部'
  @State categories: string[] = ['全部', '学习成就', '考核成就', '准确率成就']
  @State unlockedCount: number = 0
  @State totalCount: number = 0
  private databaseManager: DatabaseManager = DatabaseManager.getInstance()
  private achievementManager: AchievementManager = AchievementManager.getInstance()

  aboutToAppear() {
    this.loadAchievements()
  }

  async loadAchievements() {
    try {
      console.info('开始加载成就数据')
      
      // 初始化默认成就
      await this.achievementManager.initializeDefaultAchievements()
      
      // 检查并更新成就进度
      await this.achievementManager.checkAndUpdateAchievements()
      
      // 从数据库加载最新的成就数据
      this.achievements = await this.databaseManager.getAllAchievements()
      console.info(`从数据库加载了 ${this.achievements.length} 个成就`)
      
      this.updateStats()
    } catch (error) {
      console.error('加载成就失败:', error)
      // 如果加载失败，设置空数组而不是使用演示数据
      this.achievements = []
      this.updateStats()
    }
  }

  private async addSampleAchievements() {
    const sampleAchievements = AchievementModel.getDefaultAchievements()
    
    for (const achievement of sampleAchievements) {
      try {
        const achievementModel = new AchievementModel()
        achievementModel.id = achievement.id
        achievementModel.title = achievement.title
        achievementModel.description = achievement.description
        achievementModel.icon = achievement.icon
        achievementModel.category = achievement.category
        achievementModel.maxProgress = achievement.maxProgress
        achievementModel.rarity = achievement.rarity
        achievementModel.isUnlocked = achievement.isUnlocked
        achievementModel.progress = achievement.progress
        achievementModel.unlockedDate = achievement.unlockedDate
        
        await this.databaseManager.addAchievement(achievementModel)
      } catch (error) {
        console.error('Failed to add sample achievement:', error)
      }
    }
  }

  private loadDefaultAchievements() {
    this.achievements = AchievementModel.getDefaultAchievements()
  }

  updateStats() {
    this.unlockedCount = this.achievements.filter(a => a.isUnlocked).length
    this.totalCount = this.achievements.length
  }

  getFilteredAchievements(): AchievementModel[] {
    if (this.selectedCategory === '全部') {
      return this.achievements
    }
    return this.achievements.filter(a => a.category === this.selectedCategory)
  }



  build() {
    Column() {
      this.HeaderSection()
      this.StatsSection()
      this.AchievementsList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder HeaderSection() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .fillColor('#333333')
        .onClick(() => {
          router.back()
        })
      
      Text('我的成就')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Column()
        .width(24)
        .height(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
  }

  @Builder StatsSection() {
    Column() {
      Row() {
        Column() {
          Text(this.unlockedCount.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007AFF')
          
          Text('已解锁')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(this.totalCount.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Text('总成就')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(`${Math.round((this.unlockedCount / this.totalCount) * 100)}%`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
          
          Text('完成度')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .margin({ top: 8, bottom: 8 })
  }

  @Builder CategorySection() {
    Scroll() {
      Row({ space: 12 }) {
        ForEach(this.categories, (category: string) => {
          Text(category)
            .fontSize(14)
            .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#666666')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.selectedCategory === category ? '#007AFF' : '#F0F0F0')
            .borderRadius(16)
            .onClick(() => {
              this.selectedCategory = category
            })
        }, (category: string) => category)
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding({ top: 12, bottom: 12 })
    .margin({ bottom: 8 })
  }

  @Builder AchievementsList() {
    Scroll() {
      Grid() {
        ForEach(this.achievements, (achievement: AchievementModel) => {
          GridItem() {
            this.AchievementCard(achievement)
          }
        }, (achievement: AchievementModel) => achievement.id.toString())
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .padding(16)
    }
    .layoutWeight(1)
  }

  @Builder AchievementCard(achievement: AchievementModel) {
    Column() {
      // 成就图标
      Stack() {
        Circle({ width: 50, height: 50 })
          .fill(achievement.isUnlocked ? achievement.getRarityColor() : '#E0E0E0')
        
        Text(achievement.icon)
          .fontSize(20)
          .opacity(achievement.isUnlocked ? 1 : 0.5)
        
        // 已完成成就添加勾选标记
        if (achievement.isUnlocked) {
          Stack() {
            Circle({ width: 16, height: 16 })
              .fill('#4CAF50')
            
            Text('✓')
              .fontSize(10)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
          }
          .position({ x: 34, y: 34 })
        }
      }
      .margin({ bottom: 12 })

      // 成就信息
      Column() {
        Text(achievement.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(achievement.isUnlocked ? '#333333' : '#999999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 4 })

        Text(achievement.getRarityName())
          .fontSize(10)
          .fontColor('#FFFFFF')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor(achievement.getRarityColor())
          .borderRadius(6)
          .margin({ bottom: 8 })

        Text(achievement.description)
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 8 })

        if (achievement.shouldShowProgress()) {
          // 进度条
          Column() {
            Text(achievement.getProgressText())
              .fontSize(10)
              .fontColor('#666666')
              .margin({ bottom: 4 })

            Progress({
              value: achievement.progress,
              total: achievement.maxProgress,
              type: ProgressType.Linear
            })
            .width('100%')
            .height(3)
            .color(achievement.getRarityColor())
          }
        } else if (achievement.isUnlocked && achievement.unlockedDate) {
          Text(`已解锁`)
            .fontSize(10)
            .fontColor('#4CAF50')
            .fontWeight(FontWeight.Medium)
        }
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height(160)
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .opacity(achievement.isUnlocked ? 1 : 0.7)
    .shadow({ 
      radius: achievement.isUnlocked ? 8 : 4, 
      color: achievement.isUnlocked ? '#1A4CAF50' : '#1A000000', 
      offsetX: 0, 
      offsetY: 2 
    })
    .border({
      width: achievement.isUnlocked ? 2 : 0,
      color: achievement.isUnlocked ? achievement.getRarityColor() : Color.Transparent
    })
  }
}