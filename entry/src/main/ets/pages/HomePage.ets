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

interface AnswerRecord {
  answerTime: number
  isCorrect: boolean
  category: string
  difficulty: string
}

interface CategoryStat {
  category: string
  total: number
  correct: number
  accuracy: number
}

interface DifficultyStatItem {
  total: number
  correct: number
  accuracy: number
}

interface DifficultyStats {
  easy: DifficultyStatItem
  medium: DifficultyStatItem
  hard: DifficultyStatItem
}

interface CategoryMapStat {
  total: number
  correct: number
}

interface DifficultyMapStat {
  total: number
  correct: number
}

@Entry
@Component
export struct HomePage {
  @State currentDate: string = ''
  @State currentWeekday: string = ''
  @State dailyQuestion: DailyQuestion | null = null
  @StorageProp('refreshHome') @Watch('onRefreshHome') refreshHomeNumber: number = 0;

  @State userStats: UserStats = {
    totalQuestions: 0,
    correctAnswers: 0,
    accuracy: 0,
    streakDays: 0,
    totalStudyTime: 0,
    level: 1,
    experience: 0
  }

  @State categoryStats: CategoryStat[] = []
  @State difficultyStats: DifficultyStats = {
    easy: { total: 0, correct: 0, accuracy: 0 },
    medium: { total: 0, correct: 0, accuracy: 0 },
    hard: { total: 0, correct: 0, accuracy: 0 }
  }

  async aboutToAppear() {
    this.updateDateTime()
    await this.initDatabase()
    await this.initAchievements()
    // 检查数据库状态
    await DatabaseManager.getInstance().checkDatabaseStatus()
    await this.loadDailyQuestion()
    await this.loadUserStats()
    await this.loadStatistics()
  }



  // 监听收藏状态刷新
  async onRefreshHome() {
    if (this.refreshHomeNumber > 0) {
      await this.loadUserStats()
      await this.loadStatistics()
      this.refreshHomeNumber = 0;
    }
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

  async initAchievements() {
    try {
      const AchievementManagerModule = await import('../common/AchievementManager')
      const achievementManager = AchievementManagerModule.AchievementManager.getInstance()
      await achievementManager.initializeDefaultAchievements()
      await achievementManager.checkAndUpdateAchievements()
      console.info('成就系统初始化成功')
    } catch (error) {
      console.error('成就系统初始化失败:', error)
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

  async loadStatistics() {
    try {
      console.info('[HomePage] 开始加载统计数据...')
      
      const dbManager = DatabaseManager.getInstance()
      const answerRecords: AnswerRecord[] = await dbManager.getAnswerRecords()
      
      console.info(`[HomePage] 加载答题记录数量: ${answerRecords.length}`)
      
      if (answerRecords.length > 0) {
        console.info(`[HomePage] 示例记录:`, JSON.stringify(answerRecords[0]))
        console.info(`[HomePage] 前3条记录:`, JSON.stringify(answerRecords.slice(0, 3)))
      } else {
        console.info('[HomePage] 没有找到任何答题记录')
      }
      
      this.calculateCategoryStats(answerRecords)
      
      console.info('[HomePage] 开始计算难度统计...')
      this.calculateDifficultyStats(answerRecords)
      console.info(`[HomePage] 计算后的难度统计:`, JSON.stringify(this.difficultyStats))
      
      // 检查每个难度的具体数据
      console.info(`[HomePage] 简单难度: ${this.difficultyStats.easy.correct}/${this.difficultyStats.easy.total}`)
      console.info(`[HomePage] 中等难度: ${this.difficultyStats.medium.correct}/${this.difficultyStats.medium.total}`)
      console.info(`[HomePage] 困难难度: ${this.difficultyStats.hard.correct}/${this.difficultyStats.hard.total}`)
      
    } catch (error) {
      console.error('[HomePage] 加载统计数据失败:', error)
    }
  }

  calculateCategoryStats(answerRecords: AnswerRecord[]) {
    // 定义所有可能的分类
    const allCategories = [
      '基础知识',
      '语法基础', 
      '函数编程',
      '面向对象',
      '数据结构',
      '高级特性',
      '并发编程',
      '性能优化'
    ]
    
    const categoryMap = new Map<string, CategoryMapStat>()
    
    // 初始化所有分类，确保都显示
    allCategories.forEach(category => {
      const newStat: CategoryMapStat = { total: 0, correct: 0 }
      categoryMap.set(category, newStat)
    })
    
    // 统计答题记录
    answerRecords.forEach(record => {
      const category = record.category || '未分类'
      if (!categoryMap.has(category)) {
        const newStat: CategoryMapStat = { total: 0, correct: 0 }
        categoryMap.set(category, newStat)
      }
      const stat = categoryMap.get(category)!
      stat.total++
      if (record.isCorrect) {
        stat.correct++
      }
    })

    this.categoryStats = Array.from(categoryMap.entries()).map((entry) => {
      const category = entry[0]
      const stat = entry[1]
      const categoryStat: CategoryStat = {
        category: category,
        total: stat.total,
        correct: stat.correct,
        accuracy: stat.total > 0 ? Math.round((stat.correct / stat.total) * 100) : 0
      }
      return categoryStat
    }).sort((a, b) => {
      // 先按答题数量排序，再按分类名称排序
      if (b.total !== a.total) {
        return b.total - a.total
      }
      return a.category.localeCompare(b.category)
    }).slice(0, 5) // 只显示前5个分类
  }

  calculateDifficultyStats(answerRecords: AnswerRecord[]) {
    console.info(`[calculateDifficultyStats] 开始处理 ${answerRecords.length} 条记录`)
    
    let easyStats: DifficultyMapStat = { total: 0, correct: 0 }
    let mediumStats: DifficultyMapStat = { total: 0, correct: 0 }
    let hardStats: DifficultyMapStat = { total: 0, correct: 0 }

    answerRecords.forEach((record, index) => {
      const difficulty = record.difficulty || '中等'
      console.info(`[calculateDifficultyStats] 记录${index}: 难度=${difficulty}, 正确=${record.isCorrect}`)
      
      if (difficulty === '简单') {
        easyStats.total++
        if (record.isCorrect) {
          easyStats.correct++
        }
        console.info(`[calculateDifficultyStats] 简单难度更新: ${easyStats.correct}/${easyStats.total}`)
      } else if (difficulty === '中等') {
        mediumStats.total++
        if (record.isCorrect) {
          mediumStats.correct++
        }
        console.info(`[calculateDifficultyStats] 中等难度更新: ${mediumStats.correct}/${mediumStats.total}`)
      } else if (difficulty === '困难') {
        hardStats.total++
        if (record.isCorrect) {
          hardStats.correct++
        }
        console.info(`[calculateDifficultyStats] 困难难度更新: ${hardStats.correct}/${hardStats.total}`)
      } else {
        console.warn(`[calculateDifficultyStats] 未知难度: ${difficulty}`)
      }
    })
    
    console.info(`[calculateDifficultyStats] 最终统计 - 简单: ${easyStats.correct}/${easyStats.total}, 中等: ${mediumStats.correct}/${mediumStats.total}, 困难: ${hardStats.correct}/${hardStats.total}`)

    this.difficultyStats = {
      easy: {
        total: easyStats.total,
        correct: easyStats.correct,
        accuracy: easyStats.total > 0 ? Math.round((easyStats.correct / easyStats.total) * 100) : 0
      },
      medium: {
        total: mediumStats.total,
        correct: mediumStats.correct,
        accuracy: mediumStats.total > 0 ? Math.round((mediumStats.correct / mediumStats.total) * 100) : 0
      },
      hard: {
        total: hardStats.total,
        correct: hardStats.correct,
        accuracy: hardStats.total > 0 ? Math.round((hardStats.correct / hardStats.total) * 100) : 0
      }
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
        this.FunctionIcon('知识库', $r('app.media.icon_article'), () => {
          router.pushUrl({ url: 'pages/ArticlePage' })
        })
        this.FunctionIcon('视频课程', $r('app.media.icon_video'), () => {
          router.pushUrl({ url: 'pages/VideoCoursePage' })
        })
        this.FunctionIcon('示例代码', $r('app.media.icon_code'), () => {
          router.pushUrl({ url: 'pages/SampleCodePage' })
        })
        this.FunctionIcon('学习路线', $r('app.media.icon_learning_path'), () => {
          router.pushUrl({ url: 'pages/LearningPathPage' })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 24 })

      // 第二行图标
      Row() {
        this.FunctionIcon('我的收藏', $r('app.media.ic_favorite'), () => {
          router.pushUrl({ url: 'pages/FavoritesPage' })
        })
        this.FunctionIcon('我的错题', $r('app.media.ic_wrong_questions'), () => {
          router.pushUrl({ url: 'pages/WrongQuestionsPage' })
        })
        this.FunctionIcon('我的统计', $r('app.media.ic_statistics'), () => {
          router.pushUrl({ url: 'pages/StatisticsPage' })
        })

        this.FunctionIcon('我的成就', $r('app.media.ic_achievement'), () => {
          router.pushUrl({ url: 'pages/AchievementPage' })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 24 })

      // 第三行图标
      Row() {
        this.FunctionIcon('我的目标', $r('app.media.icon_traget'), () => {
          router.pushUrl({ url: 'pages/GoalsPage' })
        })
        this.FunctionIcon('我的日记', $r('app.media.ic_diary'), () => {
          router.pushUrl({ url: 'pages/DiaryPage' })
        })
        // 空白占位
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
      .margin({ bottom: 24 })

      // 分类统计
      this.CategoryStatsSection()
      
      // 难度统计
      this.DifficultyStatsSection()
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

  @Builder CategoryStatsSection() {
    Column() {
      Text('分类统计')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 12 })

      if (this.categoryStats.length > 0) {
        ForEach(this.categoryStats, (stat: CategoryStat) => {
          Row() {
            Text(stat.category)
              .fontSize(14)
              .fontColor('#333333')
              .width(70)
            
            Column() {
              Row() {
                Row()
                  .width(`${stat.accuracy}%`)
                  .height(6)
                  .backgroundColor('#4CAF50')
                  .borderRadius(3)
              }
              .width('100%')
              .height(6)
              .backgroundColor('#E0E0E0')
              .borderRadius(3)
              
              Row() {
                Text(`${stat.correct}/${stat.total}`)
                  .fontSize(12)
                  .fontColor('#666666')
                
                Blank()
                
                Text(`${stat.accuracy}%`)
                  .fontSize(12)
                  .fontColor('#4CAF50')
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .margin({ top: 4 })
            }
            .layoutWeight(1)
            .margin({ left: 12 })
          }
          .width('100%')
          .margin({ bottom: 8 })
        })
      } else {
        Text('暂无数据')
          .fontSize(14)
          .fontColor('#999999')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(16)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/StatisticsPage' })
    })
  }

  @Builder DifficultyStatsSection() {
    Column() {
      Text('难度统计')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 12 })

      Row() {
        this.DifficultyItemEasy()
        this.DifficultyItemMedium()
        this.DifficultyItemHard()
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/StatisticsPage' })
    })
  }

  @Builder DifficultyItemEasy() {
    Column() {
      Text('简单')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ bottom: 6 })
      
      Text((this.difficultyStats.easy.accuracy || 0).toString() + '%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4CAF50')
        .margin({ bottom: 4 })
      
      Text((this.difficultyStats.easy.correct || 0).toString() + '/' + (this.difficultyStats.easy.total || 0).toString())
        .fontSize(10)
        .fontColor('#999999')
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder DifficultyItemMedium() {
    Column() {
      Text('中等')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ bottom: 6 })
      
      Text((this.difficultyStats.medium.accuracy || 0).toString() + '%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF9800')
        .margin({ bottom: 4 })
      
      Text((this.difficultyStats.medium.correct || 0).toString() + '/' + (this.difficultyStats.medium.total || 0).toString())
        .fontSize(10)
        .fontColor('#999999')
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder DifficultyItemHard() {
    Column() {
      Text('困难')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ bottom: 6 })
      
      Text((this.difficultyStats.hard.accuracy || 0).toString() + '%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F44336')
        .margin({ bottom: 4 })
      
      Text((this.difficultyStats.hard.correct || 0).toString() + '/' + (this.difficultyStats.hard.total || 0).toString())
        .fontSize(10)
        .fontColor('#999999')
    }
    .alignItems(HorizontalAlign.Center)
  }
}