import router from '@ohos.router'
import { DatabaseManager } from '../common/DatabaseManager'

interface ExamRecord {
  id: number
  examTitle: string
  score: number
  totalQuestions: number
  correctAnswers: number
  examDate: string
  duration: number
  passed: boolean
}

interface ExamAnswer {
  id: number
  questionId: number
  userAnswer: string
  correctAnswer: string
  isCorrect: boolean
  answerTime: number
  questionType: string
  category: string
  difficulty: string
  questionText?: string
}

interface CategoryStats {
  total: number
  correct: number
}

interface CategoryStatsItem {
  category: string
  stats: CategoryStats
  accuracy: number
}

interface DifficultyStats {
  total: number
  correct: number
}

interface DifficultyStatsItem {
  difficulty: string
  stats: DifficultyStats
  accuracy: number
  color: string
}

@Entry
@Component
struct ExamRecordDetailPage {
  @State examRecord: ExamRecord | null = null
  @State examAnswers: ExamAnswer[] = []
  @State currentTabIndex: number = 0
  @State isLoading: boolean = true
  @State categoryStatsArray: CategoryStatsItem[] = []
  @State difficultyStatsArray: DifficultyStatsItem[] = []
  private databaseManager: DatabaseManager = DatabaseManager.getInstance()

  aboutToAppear() {
    const params = router.getParams()
    if (params && (params as Record<string, object>).examRecord) {
      this.examRecord = (params as Record<string, object>).examRecord as ExamRecord
      this.loadExamAnswers()
    }
  }

  async loadExamAnswers() {
    if (!this.examRecord) return
    
    try {
      // 这里需要根据考核记录ID加载对应的答题记录
      // 由于当前数据库结构可能不支持，我们先使用模拟数据
      this.examAnswers = await this.loadMockExamAnswers()
      this.calculateCategoryStats()
      this.calculateDifficultyStats()
      this.isLoading = false
    } catch (error) {
      console.error('加载考核答题记录失败:', error)
      this.isLoading = false
    }
  }

  calculateCategoryStats() {
    const categoryStats = this.getCategoryStats()
    this.categoryStatsArray = []
    categoryStats.forEach((stats, category) => {
      const accuracy = stats.total > 0 ? Math.round((stats.correct / stats.total) * 100) : 0
      this.categoryStatsArray.push({
        category: category,
        stats: stats,
        accuracy: accuracy
      } as CategoryStatsItem)
    })
  }

  calculateDifficultyStats() {
    const difficultyStats = this.getDifficultyStats()
    this.difficultyStatsArray = []
    const difficultyColors = new Map([
      ['简单', '#4CAF50'],
      ['中等', '#FF9800'],
      ['困难', '#F44336']
    ])
    
    difficultyStats.forEach((stats, difficulty) => {
      const accuracy = stats.total > 0 ? Math.round((stats.correct / stats.total) * 100) : 0
      this.difficultyStatsArray.push({
        difficulty: difficulty,
        stats: stats,
        accuracy: accuracy,
        color: difficultyColors.get(difficulty) || '#666666'
      } as DifficultyStatsItem)
    })
  }

  async loadMockExamAnswers(): Promise<ExamAnswer[]> {
    // 模拟答题记录数据
    const mockAnswers: ExamAnswer[] = []
    const categories = ['基础语法', '控制结构', '函数', '类', '泛型']
    const difficulties = ['简单', '中等', '困难']
    
    for (let i = 1; i <= (this.examRecord?.totalQuestions || 20); i++) {
      const isCorrect = Math.random() > 0.3 // 70%正确率
      mockAnswers.push({
        id: i,
        questionId: i,
        userAnswer: isCorrect ? 'A' : 'B',
        correctAnswer: 'A',
        isCorrect: isCorrect,
        answerTime: Math.floor(Math.random() * 30000) + 5000, // 5-35秒
        questionType: '单选题',
        category: categories[Math.floor(Math.random() * categories.length)],
        difficulty: difficulties[Math.floor(Math.random() * difficulties.length)],
        questionText: `这是第${i}道题目的内容，测试仓颉语言的相关知识点...`
      })
    }
    
    return mockAnswers
  }

  formatDuration(seconds: number): string {
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = seconds % 60
    return `${minutes}分${remainingSeconds}秒`
  }

  formatAnswerTime(milliseconds: number): string {
    const seconds = Math.floor(milliseconds / 1000)
    return `${seconds}秒`
  }

  getAccuracyRate(): number {
    if (this.examAnswers.length === 0) return 0
    const correctCount = this.examAnswers.filter(answer => answer.isCorrect).length
    return Math.round((correctCount / this.examAnswers.length) * 100)
  }

  getCategoryStats(): Map<string, CategoryStats> {
    const stats = new Map<string, CategoryStats>()
    
    this.examAnswers.forEach(answer => {
      if (!stats.has(answer.category)) {
        stats.set(answer.category, { total: 0, correct: 0 } as CategoryStats)
      }
      const categoryStats = stats.get(answer.category)!
      categoryStats.total++
      if (answer.isCorrect) {
        categoryStats.correct++
      }
    })
    
    return stats
  }

  getDifficultyStats(): Map<string, DifficultyStats> {
    const stats = new Map<string, DifficultyStats>()
    
    this.examAnswers.forEach(answer => {
      if (!stats.has(answer.difficulty)) {
        stats.set(answer.difficulty, { total: 0, correct: 0 } as DifficultyStats)
      }
      const difficultyStats = stats.get(answer.difficulty)!
      difficultyStats.total++
      if (answer.isCorrect) {
        difficultyStats.correct++
      }
    })
    
    return stats
  }

  build() {
    Column() {
      // 顶部导航栏
      this.HeaderSection()
      
      if (this.isLoading) {
        this.LoadingView()
      } else {
        // 标签页
        this.TabSection()
        
        // 内容区域
        if (this.currentTabIndex === 0) {
          this.OverviewContent()
        } else if (this.currentTabIndex === 1) {
          this.AnswerDetailContent()
        } else {
          this.StatisticsContent()
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder HeaderSection() {
    Row() {
      Button() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        router.back()
      })

      Text('考核详情')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 占位，保持标题居中
      Row().width(40).height(40)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder LoadingView() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#007AFF')
      
      Text('正在加载考核详情...')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 20 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder TabSection() {
    Row() {
      this.TabItem('概览', 0)
      this.TabItem('答题详情', 1)
      this.TabItem('统计分析', 2)
    }
    .width('100%')
    .height(48)
    .backgroundColor('#FFFFFF')
    .padding({ left: 16, right: 16 })
  }

  @Builder TabItem(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontColor(this.currentTabIndex === index ? '#007AFF' : '#666666')
        .fontWeight(this.currentTabIndex === index ? FontWeight.Bold : FontWeight.Normal)
      
      if (this.currentTabIndex === index) {
        Divider()
          .width(30)
          .height(2)
          .color('#007AFF')
          .margin({ top: 4 })
      }
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentTabIndex = index
    })
  }

  @Builder OverviewContent() {
    Scroll() {
      Column() {
        // 考核基本信息
        this.ExamInfoCard()
        
        // 成绩概览
        this.ScoreOverviewCard()
        
        // 快速统计
        this.QuickStatsCard()
      }
      .width('100%')
      .padding(16)
    }
    .layoutWeight(1)
  }

  @Builder ExamInfoCard() {
    Column() {
      Text('考核信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 16 })

      this.InfoRow('考核名称', this.examRecord?.examTitle || '')
      this.InfoRow('考核时间', this.examRecord?.examDate || '')
      this.InfoRow('考核时长', this.formatDuration(this.examRecord?.duration || 0))
      this.InfoRow('题目总数', `${this.examRecord?.totalQuestions || 0}题`)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder ScoreOverviewCard() {
    Column() {
      Text('成绩概览')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 16 })

      Row() {
        Column() {
          Text(`${this.examRecord?.score || 0}`)
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.examRecord?.passed ? '#4CAF50' : '#F44336')
          
          Text('总分')
            .fontSize(14)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(`${this.examRecord?.correctAnswers || 0}/${this.examRecord?.totalQuestions || 0}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Text('正确题数')
            .fontSize(14)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(this.examRecord?.passed ? '通过' : '未通过')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.examRecord?.passed ? '#4CAF50' : '#F44336')
          
          Text('考核结果')
            .fontSize(14)
            .fontColor('#666666')
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
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder QuickStatsCard() {
    Column() {
      Text('快速统计')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 16 })

      Row() {
        this.StatItem('正确率', `${this.getAccuracyRate()}%`, '#4CAF50')
        this.StatItem('错误题数', `${(this.examRecord?.totalQuestions || 0) - (this.examRecord?.correctAnswers || 0)}`, '#F44336')
        this.StatItem('平均用时', '25秒', '#FF9800')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor('#666666')
        .layoutWeight(1)
      
      Text(value)
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder StatItem(label: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      
      Text(label)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder AnswerDetailContent() {
    Column() {
      if (this.examAnswers.length === 0) {
        this.EmptyAnswerView()
      } else {
        Scroll() {
          Column() {
            ForEach(this.examAnswers, (answer: ExamAnswer, index: number) => {
              this.AnswerItem(answer, index + 1)
            })
          }
          .width('100%')
          .padding(16)
        }
      }
    }
    .layoutWeight(1)
  }

  @Builder EmptyAnswerView() {
    Column() {
      Image($r('app.media.ic_info'))
        .width(80)
        .height(80)
        .fillColor('#CCCCCC')
      
      Text('暂无答题记录')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder AnswerItem(answer: ExamAnswer, questionNumber: number) {
    Column() {
      Row() {
        Text(`第${questionNumber}题`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Text(answer.isCorrect ? '正确' : '错误')
          .fontSize(14)
          .fontColor(answer.isCorrect ? '#4CAF50' : '#F44336')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(answer.isCorrect ? '#E8F5E8' : '#FFEBEE')
          .borderRadius(12)
      }
      .width('100%')
      .margin({ bottom: 8 })

      Text(answer.questionText || '题目内容')
        .fontSize(14)
        .fontColor('#666666')
        .width('100%')
        .margin({ bottom: 12 })

      Row() {
        Column() {
          Text('你的答案')
            .fontSize(12)
            .fontColor('#666666')
          Text(answer.userAnswer)
            .fontSize(14)
            .fontColor(answer.isCorrect ? '#4CAF50' : '#F44336')
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text('正确答案')
            .fontSize(12)
            .fontColor('#666666')
          Text(answer.correctAnswer)
            .fontSize(14)
            .fontColor('#4CAF50')
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text('用时')
            .fontSize(12)
            .fontColor('#666666')
          Text(this.formatAnswerTime(answer.answerTime))
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(HorizontalAlign.End)
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder StatisticsContent() {
    Scroll() {
      Column() {
        // 分类统计
        this.CategoryStatsCard()
        
        // 难度分布
        this.DifficultyStatsCard()
      }
      .width('100%')
      .padding(16)
    }
    .layoutWeight(1)
  }

  @Builder CategoryStatsCard() {
    Column() {
      Text('分类统计')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 16 })

      ForEach(this.categoryStatsArray, (item: CategoryStatsItem) => {
        Row() {
          Text(item.category)
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)
          
          Text(`${item.stats.correct}/${item.stats.total}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ right: 12 })
          
          Text(`${item.accuracy}%`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.accuracy >= 80 ? '#4CAF50' : item.accuracy >= 60 ? '#FF9800' : '#F44336')
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
        .border({ width: { bottom: 1 }, color: '#F0F0F0' })
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder DifficultyStatsCard() {
    Column() {
      Text('难度分布')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 16 })

      if (this.difficultyStatsArray.length === 0) {
        this.EmptyStatsView()
      } else {
        ForEach(this.difficultyStatsArray, (item: DifficultyStatsItem) => {
          this.DifficultyStatsItem(item)
        })
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder DifficultyStatsItem(item: DifficultyStatsItem) {
    Column() {
      Row() {
        Row() {
          Circle({ width: 8, height: 8 })
            .fill(item.color)
            .margin({ right: 8 })
          
          Text(item.difficulty)
            .fontSize(14)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .alignItems(VerticalAlign.Center)

        Text(`${item.stats.correct}/${item.stats.total}`)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ right: 12 })

        Text(`${item.accuracy}%`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(item.accuracy >= 60 ? '#4CAF50' : '#F44336')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 8 })

      // 进度条
      Row() {
        Stack({ alignContent: Alignment.Start }) {
          // 背景条
          Row()
            .width('100%')
            .height(6)
            .backgroundColor('#F0F0F0')
            .borderRadius(3)
          
          // 进度条
          Row()
            .width(`${item.accuracy}%`)
            .height(6)
            .backgroundColor(item.color)
            .borderRadius(3)
        }
        .width('100%')
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .border({ width: { bottom: 1 }, color: '#F0F0F0' })
  }

  @Builder EmptyStatsView() {
    Column() {
      Image($r('app.media.ic_info'))
        .width(48)
        .height(48)
        .fillColor('#CCCCCC')
        .margin({ bottom: 12 })
      
      Text('暂无统计数据')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .height(100)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
  }
}