import router from '@ohos.router'
import { util } from '@kit.ArkTS'
import { DatabaseManager } from '../common/DatabaseManager'

interface QuestionOptions {
  A: string
  B: string
  C: string
  D: string
}

interface DailyQuestion {
  id: number
  question: string
  options: QuestionOptions
  answer: string
  explanation: string
  category: string
  difficulty: string
}

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
export struct HomePage {
  @State currentDate: string = ''
  @State currentWeekday: string = ''
  @State dailyQuestion: DailyQuestion | null = null
  @State userStats: UserStats = {
    totalQuestions: 0,
    correctAnswers: 0,
    accuracy: 0,
    streakDays: 0,
    totalStudyTime: 0,
    level: 1,
    experience: 0
  }

  async aboutToAppear() {
    this.updateDateTime()
    await this.initDatabase()
    this.loadDailyQuestion()
    this.loadUserStats()
  }

  onPageShow() {
    // 页面显示时重新加载用户统计数据，确保数据实时更新
    this.loadUserStats()
  }

  async initDatabase() {
    try {
      const context = getContext(this)
      const dbManager = DatabaseManager.getInstance()
      await dbManager.initDatabase(context)
      console.info('数据库初始化成功')
    } catch (error) {
      console.error('数据库初始化失败:', error)
    }
  }

  updateDateTime() {
    const now = new Date()
    const year = now.getFullYear()
    const month = String(now.getMonth() + 1).padStart(2, '0')
    const day = String(now.getDate()).padStart(2, '0')
    this.currentDate = `${year}年${month}月${day}日`
    
    const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
    this.currentWeekday = weekdays[now.getDay()]
  }

  async loadDailyQuestion() {
    // 这里会从题库中随机选择一道题作为每日一题
    // 实际实现时会根据日期确保每天的题目固定
    try {
      const context = getContext(this)
      const fileData = await context.resourceManager.getRawFileContent('cangjie.json')
      const decoder = new util.TextDecoder('utf-8')
      const jsonStr = decoder.decodeWithStream(new Uint8Array(fileData.buffer))
      const questions: DailyQuestion[] = JSON.parse(jsonStr)
      
      // 根据日期生成固定的随机数，确保每天题目一致
      const today = new Date().toDateString()
      const seed = this.hashCode(today)
      const randomIndex = Math.abs(seed) % questions.length
      this.dailyQuestion = questions[randomIndex]
    } catch (error) {
      console.error('加载每日一题失败:', error)
    }
  }

  hashCode(str: string): number {
    let hash = 0
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i)
      hash = ((hash << 5) - hash) + char
      hash = hash & hash // 转换为32位整数
    }
    return hash
  }

  async loadUserStats() {
    try {
      const dbManager = DatabaseManager.getInstance()
      const stats = await dbManager.getUserStats()
      this.userStats = {
        totalQuestions: stats.totalQuestions,
        correctAnswers: stats.correctAnswers,
        accuracy: stats.accuracy,
        streakDays: stats.streakDays,
        totalStudyTime: stats.totalStudyTime,
        level: stats.level,
        experience: stats.experience
      }
    } catch (error) {
      console.error('加载用户统计失败:', error)
    }
  }

  build() {
    Scroll() {
      Column() {
        // 顶部问候语
        this.GreetingSection()
        
        // 功能图标区域
        this.FunctionIconsSection()
        
        // 每日一题卡片
        this.DailyQuestionCard()
        
        // 数据统计区域
        this.StatsSection()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
    }
    .backgroundColor('#F5F5F5')
    .height('100%')
  }

  @Builder GreetingSection() {
    Column() {
      Text(`${this.currentDate} ${this.currentWeekday}`)
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 8 })
      
      Text('Hello, 仓颉编程学习者')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 32 })
  }

  @Builder FunctionIconsSection() {
    Column() {
      // 第一行图标
      Row() {
        this.FunctionIcon('题库', $r('app.media.ic_question_bank'), () => {
          router.pushUrl({ url: 'pages/QuestionBankPage' })
        })
        this.FunctionIcon('考核', $r('app.media.ic_exam'), () => {
          router.pushUrl({ url: 'pages/ExamPage' })
        })
        this.FunctionIcon('我的收藏', $r('app.media.ic_favorite'), () => {
          router.pushUrl({ url: 'pages/FavoritesPage' })
        })
        this.FunctionIcon('错题本', $r('app.media.ic_wrong_questions'), () => {
          router.pushUrl({ url: 'pages/WrongQuestionsPage' })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 24 })

      // 第二行图标
      Row() {
        this.FunctionIcon('我的统计', $r('app.media.ic_statistics'), () => {
          router.pushUrl({ url: 'pages/StatisticsPage' })
        })
        this.FunctionIcon('学习路线', $r('app.media.icon_learning_path'), () => {
          router.pushUrl({ url: 'pages/LearningPathPage' })
        })
        this.FunctionIcon('我的成就', $r('app.media.ic_achievement'), () => {
          router.pushUrl({ url: 'pages/AchievementPage' })
        })
        this.FunctionIcon('我的目标', $r('app.media.icon_traget'), () => {
          router.pushUrl({ url: 'pages/GoalsPage' })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 24 })

      // 第三行图标
      Row() {
        this.FunctionIcon('我的日记', $r('app.media.ic_diary'), () => {
          router.pushUrl({ url: 'pages/DiaryPage' })
        })
        // 空白占位
        Column().width('20%')
        Column().width('20%')
        Column().width('20%')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .margin({ bottom: 32 })
  }

  @Builder FunctionIcon(title: string, icon: Resource, onClick: () => void) {
    Column() {
      Stack() {
        Circle({ width: 60, height: 60 })
          .fill('#FFFFFF')
          .shadow({
            radius: 8,
            color: '#00000010',
            offsetX: 0,
            offsetY: 2
          })

        Image(icon)
          .width(32)
          .height(32)
          .fillColor('#007AFF')
      }
      .width(60)
      .height(60).margin({bottom: 6})

      Text(title)
        .fontSize(12)
        .fontColor('#333333')
        .textAlign(TextAlign.Center)
    }
    .width('20%')
    .alignItems(HorizontalAlign.Center)
    .onClick(onClick)
  }

  @Builder DailyQuestionCard() {
    Column() {
      Row() {
        Text('每日一题')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Text('点击答题')
          .fontSize(14)
          .fontColor('#007AFF')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/DailyQuestionPage',
              params: { question: this.dailyQuestion }
            })
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      if (this.dailyQuestion) {
        Column() {
          Text(this.dailyQuestion.question)
            .fontSize(16)
            .fontColor('#333333')
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Row() {
            Text(`难度: ${this.dailyQuestion.difficulty}`)
              .fontSize(12)
              .fontColor('#666666')
            
            Blank()
            
            Text(`分类: ${this.dailyQuestion.category}`)
              .fontSize(12)
              .fontColor('#666666')
          }
          .width('100%')
          .margin({ top: 12 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/DailyQuestionPage',
            params: { question: this.dailyQuestion }
          })
        })
      }
    }
    .width('100%')
    .margin({ bottom: 32 })
  }

  @Builder StatsSection() {
    Column() {
      Row() {
        Text('我的数据')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)

      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 16 })

      Row() {
        this.StatCardTotalQuestion('已答题目', '#4CAF50')
        this.StatCardAccuracy('正确率', '#2196F3')
        this.StatCardStreakDay('连续天数', '#FF9800')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  @Builder StatCardTotalQuestion(title: string, color: string) {
    Column() {
      Text((this.userStats.totalQuestions || 0).toString())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(title)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .width('30%')
    .height(80)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/StatisticsPage' })
    })
  }

  @Builder StatCardAccuracy(title: string, color: string) {
    Column() {
      Text((`${(this.userStats.accuracy || 0).toFixed(1)}%`))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(title)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .width('30%')
    .height(80)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/StatisticsPage' })
    })
  }

  @Builder StatCardStreakDay(title: string, color: string) {
    Column() {
      Text(( this.userStats.streakDays || 0).toString())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(title)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .width('30%')
    .height(80)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/StatisticsPage' })
    })
  }

  @Builder StatCard(title: string, value: string | number, color: string) {
    Column() {
      Text(value.toString())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      
      Text(title)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .width('30%')
    .height(80)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/StatisticsPage' })
    })
  }
}