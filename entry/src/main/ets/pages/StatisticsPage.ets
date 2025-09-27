import router from '@ohos.router'
import { DatabaseManager } from '../common/DatabaseManager'

interface AnswerRecord {
  questionId: number
  userAnswer: string
  correctAnswer: string
  isCorrect: boolean
  answerTime: number
  questionType: string
  category: string
  difficulty: string
  createdAt: string
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

interface DailyMapStat {
  questions: number
  correct: number
}

interface CategoryMapStat {
  total: number
  correct: number
}

interface DifficultyMapStat {
  total: number
  correct: number
}

interface StatisticsData {
  totalQuestions: number
  correctAnswers: number
  accuracy: number
  streakDays: number
  studyTime: number
  categoryStats: CategoryStat[]
  difficultyStats: DifficultyStats
  dailyStats: DailyStat[]
  weeklyStats: WeeklyStat[]
  monthlyStats: MonthlyStat[]
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

interface DailyStat {
  date: string
  questions: number
  correct: number
  accuracy: number
}

interface WeeklyStat {
  week: string
  questions: number
  correct: number
  accuracy: number
}

interface MonthlyStat {
  month: string
  questions: number
  correct: number
  accuracy: number
}

@Entry
@Component
struct StatisticsPage {
  @State statisticsData: StatisticsData = {
    totalQuestions: 0,
    correctAnswers: 0,
    accuracy: 0,
    streakDays: 0,
    studyTime: 0,
    categoryStats: [],
    difficultyStats: {
      easy: { total: 0, correct: 0, accuracy: 0 },
      medium: { total: 0, correct: 0, accuracy: 0 },
      hard: { total: 0, correct: 0, accuracy: 0 }
    },
    dailyStats: [],
    weeklyStats: [],
    monthlyStats: []
  }
  @State selectedTimeRange: string = '7天'
  @State timeRangeOptions: string[] = ['7天', '30天', '90天', '全部']
  @State isLoading: boolean = true

  aboutToAppear() {
    this.loadStatistics()
  }

  async loadStatistics() {
    try {
      this.isLoading = true
      const dbManager = DatabaseManager.getInstance()
      
      // 加载基础统计数据
      const statsData = await dbManager.getUserStats()
      console.info('[StatisticsPage] 加载的用户统计数据:', JSON.stringify(statsData))
      
      const userStats: UserStats = {
        totalQuestions: statsData.totalQuestions,
        correctAnswers: statsData.correctAnswers,
        accuracy: statsData.accuracy,
        streakDays: statsData.streakDays,
        totalStudyTime: statsData.totalStudyTime,
        level: statsData.level,
        experience: statsData.experience
      }
      console.info('[StatisticsPage] 处理后的用户统计:', JSON.stringify(userStats))
      
      const answerRecords: AnswerRecord[] = await dbManager.getAnswerRecords()
      console.info('[StatisticsPage] 加载的答题记录数量:', answerRecords.length)
      if (answerRecords.length > 0) {
        console.info('[StatisticsPage] 前3条答题记录:', JSON.stringify(answerRecords.slice(0, 3)))
      }
      
      this.calculateStatistics(userStats, answerRecords)
      this.isLoading = false
    } catch (error) {
      console.error('加载统计数据失败:', error)
      this.isLoading = false
    }
  }

  calculateStatistics(userStats: UserStats, answerRecords: AnswerRecord[]) {
    // 计算基础统计
    this.statisticsData.totalQuestions = userStats?.totalQuestions || 0
    this.statisticsData.correctAnswers = userStats?.correctAnswers || 0
    this.statisticsData.accuracy = this.statisticsData.totalQuestions > 0 ? 
      Math.round((this.statisticsData.correctAnswers / this.statisticsData.totalQuestions) * 100) : 0
    this.statisticsData.streakDays = userStats?.streakDays || 0
    this.statisticsData.studyTime = userStats?.totalStudyTime || 0

    // 计算分类统计
    this.calculateCategoryStats(answerRecords)
    
    // 计算难度统计
    this.calculateDifficultyStats(answerRecords)
    
    // 计算时间统计
    this.calculateTimeStats(answerRecords)
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
      categoryMap.set(category, { total: 0, correct: 0 })
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

    this.statisticsData.categoryStats = Array.from(categoryMap.entries()).map((entry) => {
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
    })
  }

  calculateDifficultyStats(answerRecords: AnswerRecord[]) {
    let easyStats: DifficultyMapStat = { total: 0, correct: 0 }
    let mediumStats: DifficultyMapStat = { total: 0, correct: 0 }
    let hardStats: DifficultyMapStat = { total: 0, correct: 0 }

    answerRecords.forEach(record => {
      const difficulty = record.difficulty || '中等'
      if (difficulty === '简单') {
        easyStats.total++
        if (record.isCorrect) {
          easyStats.correct++
        }
      } else if (difficulty === '中等') {
        mediumStats.total++
        if (record.isCorrect) {
          mediumStats.correct++
        }
      } else if (difficulty === '困难') {
        hardStats.total++
        if (record.isCorrect) {
          hardStats.correct++
        }
      }
    })

    const easyItem: DifficultyStatItem = {
      total: easyStats.total,
      correct: easyStats.correct,
      accuracy: easyStats.total > 0 ? 
        Math.round((easyStats.correct / easyStats.total) * 100) : 0
    }
    
    const mediumItem: DifficultyStatItem = {
      total: mediumStats.total,
      correct: mediumStats.correct,
      accuracy: mediumStats.total > 0 ? 
        Math.round((mediumStats.correct / mediumStats.total) * 100) : 0
    }
    
    const hardItem: DifficultyStatItem = {
      total: hardStats.total,
      correct: hardStats.correct,
      accuracy: hardStats.total > 0 ? 
        Math.round((hardStats.correct / hardStats.total) * 100) : 0
    }
    
    this.statisticsData.difficultyStats.easy = easyItem
    this.statisticsData.difficultyStats.medium = mediumItem
    this.statisticsData.difficultyStats.hard = hardItem
  }

  calculateTimeStats(answerRecords: AnswerRecord[]) {
    console.info('[StatisticsPage] 开始计算时间统计, 记录数量:', answerRecords.length)
    console.info('[StatisticsPage] 选择的时间范围:', this.selectedTimeRange)
    
    // 计算每日统计
    const dailyMap = new Map<string, DailyMapStat>()
    const now = new Date()
    
    // 获取指定时间范围内的记录
    const daysToShow = this.getDaysFromRange(this.selectedTimeRange)
    const startDate = new Date(now.getTime() - (daysToShow - 1) * 24 * 60 * 60 * 1000)
    console.info('[StatisticsPage] 开始日期:', startDate.toLocaleDateString('zh-CN'))
    console.info('[StatisticsPage] 结束日期:', now.toLocaleDateString('zh-CN'))
    
    answerRecords.forEach((record, index) => {
      // 使用createdAt字段而不是answerTime（answerTime是答题用时，不是时间戳）
      const recordDate = new Date(record.createdAt)
      console.info(`[StatisticsPage] 记录${index}: createdAt=${record.createdAt}, 转换后日期=${recordDate.toLocaleDateString('zh-CN')}`)
      
      if (recordDate >= startDate) {
        const dateStr = recordDate.toLocaleDateString('zh-CN')
        if (!dailyMap.has(dateStr)) {
          const newStat: DailyMapStat = { questions: 0, correct: 0 }
          dailyMap.set(dateStr, newStat)
        }
        const stat = dailyMap.get(dateStr)!
        stat.questions++
        if (record.isCorrect) {
          stat.correct++
        }
        console.info(`[StatisticsPage] 添加到日期 ${dateStr}: 题数=${stat.questions}, 正确=${stat.correct}`)
      }
    })

    console.info('[StatisticsPage] 每日统计Map:', Array.from(dailyMap.entries()))

    this.statisticsData.dailyStats = Array.from(dailyMap.entries()).map((entry) => {
      const date = entry[0]
      const stat = entry[1]
      const dailyStat: DailyStat = {
        date: date,
        questions: stat.questions,
        correct: stat.correct,
        accuracy: stat.questions > 0 ? Math.round((stat.correct / stat.questions) * 100) : 0
      }
      return dailyStat
    }).sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime())
    
    console.info('[StatisticsPage] 最终每日统计:', JSON.stringify(this.statisticsData.dailyStats))
  }

  getDaysFromRange(range: string): number {
    switch (range) {
      case '7天': return 7
      case '30天': return 30
      case '90天': return 90
      case '全部': return 365 // 最多显示一年
      default: return 7
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.HeaderSection()
      
      if (this.isLoading) {
        this.LoadingSection()
      } else {
        Scroll() {
          Column() {
            // 总体统计
            this.OverallStats()
            
            // 时间范围选择
            this.TimeRangeSelector()
            
            // 答题趋势图
            this.TrendChart()
            
            // 分类统计
            this.CategoryStats()
            
            // 难度统计
            this.DifficultyStats()
            
            // 学习成就
            this.AchievementStats()
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
      }
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
      
      Text('我的统计')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      // 占位，保持居中
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

  @Builder LoadingSection() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#007AFF')
      
      Text('加载统计数据中...')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder OverallStats() {
    Column() {
      Text('总体统计')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 16 })

      Row() {
        Column() {
          Text(this.statisticsData.totalQuestions.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007AFF')
          
          Text('总题数')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(this.statisticsData.correctAnswers.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
          
          Text('正确数')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(`${this.statisticsData.accuracy}%`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9800')
          
          Text('正确率')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(this.statisticsData.streakDays.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#9C27B0')
          
          Text('连续天数')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder TimeRangeSelector() {
    Column() {
      Text('答题趋势')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 12 })

      Row() {
        ForEach(this.timeRangeOptions, (option: string) => {
          Text(option)
            .fontSize(14)
            .fontColor(this.selectedTimeRange === option ? '#FFFFFF' : '#666666')
            .backgroundColor(this.selectedTimeRange === option ? '#007AFF' : '#F0F0F0')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .borderRadius(16)
            .onClick(() => {
              this.selectedTimeRange = option
              this.loadStatistics()
            })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder TrendChart() {
    Column() {
      Text('答题趋势图')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 16 })

      // 简化的趋势图显示
      if (this.statisticsData.dailyStats.length > 0) {
        Column() {
          ForEach(this.statisticsData.dailyStats.slice(-7), (stat: DailyStat) => {
            Row() {
              Text(stat.date)
                .fontSize(12)
                .fontColor('#666666')
                .width(80)
              
              // 简单的条形图
              Row() {
                Row()
                  .width(`${stat.accuracy}%`)
                  .height(20)
                  .backgroundColor('#007AFF')
                  .borderRadius(10)
              }
              .width(120)
              .height(20)
              .backgroundColor('#E0E0E0')
              .borderRadius(10)
              .margin({ left: 8, right: 8 })
              
              Text(`${stat.questions}题 ${stat.accuracy}%`)
                .fontSize(12)
                .fontColor('#333333')
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 8 })
          })
        }
        .width('100%')
      } else {
        Text('暂无数据')
          .fontSize(14)
          .fontColor('#999999')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(20)
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder CategoryStats() {
    Column() {
      Text('分类统计')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 16 })

      if (this.statisticsData.categoryStats.length > 0) {
        ForEach(this.statisticsData.categoryStats, (stat: CategoryStat) => {
          Row() {
            Text(stat.category)
              .fontSize(14)
              .fontColor('#333333')
              .width(80)
            
            Column() {
              Row() {
                Row()
                  .width(`${stat.accuracy}%`)
                  .height(8)
                  .backgroundColor('#4CAF50')
                  .borderRadius(4)
              }
              .width('100%')
              .height(8)
              .backgroundColor('#E0E0E0')
              .borderRadius(4)
              
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
          .margin({ bottom: 12 })
        })
      } else {
        Text('暂无数据')
          .fontSize(14)
          .fontColor('#999999')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(20)
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder DifficultyStats() {
    Column() {
      Text('难度统计')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 16 })

      Row() {
        this.DifficultyItem('简单', this.statisticsData.difficultyStats.easy, '#4CAF50')
        this.DifficultyItem('中等', this.statisticsData.difficultyStats.medium, '#FF9800')
        this.DifficultyItem('困难', this.statisticsData.difficultyStats.hard, '#F44336')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder DifficultyItem(label: string, stat: DifficultyStatItem, color: string) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 8 })
      
      Text(`${stat.accuracy}%`)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .margin({ bottom: 4 })
      
      Text(`${stat.correct}/${stat.total}`)
        .fontSize(12)
        .fontColor('#999999')
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder AchievementStats() {
    Column() {
      Text('学习成就')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 16 })

      Row() {
        Column() {
          Image($r('app.media.ic_time'))
            .width(32)
            .height(32)
            .fillColor('#FF9800')
          
          Text(`${this.statisticsData.studyTime}分钟`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 8 })
          
          Text('学习时长')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Image($r('app.media.ic_streak'))
            .width(32)
            .height(32)
            .fillColor('#9C27B0')
          
          Text(`${this.statisticsData.streakDays}天`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 8 })
          
          Text('连续学习')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Image($r('app.media.ic_trophy'))
            .width(32)
            .height(32)
            .fillColor('#FFD700')
          
          Text(this.getAchievementLevel())
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 8 })
          
          Text('当前等级')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  getAchievementLevel(): string {
    const total = this.statisticsData.totalQuestions
    if (total >= 1000) return '大师'
    if (total >= 500) return '专家'
    if (total >= 200) return '熟练'
    if (total >= 50) return '入门'
    return '新手'
  }
}