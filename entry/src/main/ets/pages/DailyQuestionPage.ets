import router from '@ohos.router'
import { DatabaseManager } from '../common/DatabaseManager'
import { AchievementManager } from '../common/AchievementManager'

interface QuestionOptions {
  A: string
  B: string
  C: string
  D: string
}

interface Question {
  id: number
  type: string
  category: string
  difficulty: string
  question: string
  options: QuestionOptions
  answer: string[]
  explanation: string
}

interface DifficultyColorStyle {
  bg: string
  text: string
}

@Entry
@Component
struct DailyQuestionPage {
  @State currentQuestion: Question | null = null
  @State selectedAnswers: string[] = []
  @State isAnswered: boolean = false
  @State isCorrect: boolean = false
  @State showResult: boolean = false
  @State answerStartTime: number = 0
  @State todayDate: string = ''

  aboutToAppear() {
    const params: Record<string, Object> = router.getParams() as Record<string, Object>
    if (params && params.question) {
      this.currentQuestion = params.question as Question
    }
    
    this.answerStartTime = Date.now()
    this.todayDate = new Date().toLocaleDateString('zh-CN')
    this.checkTodayCompletion()
  }

  aboutToDisappear(): void {
    AppStorage.setOrCreate('refreshHome', Date.now());
  }

  async checkTodayCompletion() {
    // 检查今天是否已经完成每日一题
    try {
      const dbManager = DatabaseManager.getInstance()
      // 这里可以添加检查逻辑
    } catch (error) {
      console.error('检查每日一题完成状态失败:', error)
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.HeaderSection()
      
      // 每日一题标识
      this.DailyBadgeSection()
      
      // 题目内容
      Scroll() {
        Column() {
          this.QuestionContent()
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      
      // 底部操作栏
      this.BottomSection()
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
      
      Text('每日一题')
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

  @Builder DailyBadgeSection() {
    Column() {
      Row() {
        Image($r('app.media.ic_calendar'))
          .width(20)
          .height(20)
          .fillColor('#FF9800')
          .margin({ right: 8 })
        
        Text(this.todayDate)
          .fontSize(16)
          .fontColor('#FF9800')
          .fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 8 })

      Text('今日挑战')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
      
      Text('坚持每日一题，提升编程技能')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: 16 })
  }

  @Builder QuestionContent() {
    Column() {
      // 题目信息
      Row() {
        this.InfoChip('分类', this.currentQuestion?.category || '', '#E3F2FD', '#1976D2')
        this.InfoChip('难度', this.currentQuestion?.difficulty || '', this.getDifficultyColor().bg, this.getDifficultyColor().text)
        this.InfoChip('类型', this.currentQuestion?.type === 'single' ? '单选' : '多选', '#F3E5F5', '#7B1FA2')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 20 })

      // 题目内容
      Text(this.currentQuestion?.question || '')
        .fontSize(18)
        .fontColor('#333333')
        .lineHeight(28)
        .width('100%')
        .margin({ bottom: 24 })

      // 选项
      if (this.currentQuestion?.options) {
        Column() {
          ForEach(Object.keys(this.currentQuestion.options), (key: string) => {
            this.OptionItem(key, this.getOptionValue(key))
          })
        }
        .width('100%')
      }

      // 答题结果
      if (this.showResult) {
        this.ResultSection()
      }

      // 解析（答题后显示）
      if (this.isAnswered) {
        this.ExplanationSection()
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  getOptionValue(key: string): string {
    if (!this.currentQuestion?.options) {
      return ''
    }
    switch (key) {
      case 'A':
        return this.currentQuestion.options.A
      case 'B':
        return this.currentQuestion.options.B
      case 'C':
        return this.currentQuestion.options.C
      case 'D':
        return this.currentQuestion.options.D
      default:
        return ''
    }
  }

  @Builder OptionItem(key: string, value: string) {
    Row() {
      // 选项标识
      Text(key)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getOptionTextColor(key))
        .width(32)
        .height(32)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.getOptionBackgroundColor(key))
        .borderRadius(16)
        .border({
          width: 2,
          color: this.getOptionBorderColor(key)
        })
      
      // 选项内容
      Text(value)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)
        .margin({ left: 12 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.getOptionRowBackgroundColor(key))
    .borderRadius(8)
    .margin({ bottom: 12 })
    .onClick(() => {
      if (!this.isAnswered) {
        this.selectOption(key)
      }
    })
  }

  @Builder ResultSection() {
    Column() {
      // 答题结果
      Row() {
        Image(this.isCorrect ? $r('app.media.ic_correct') : $r('app.media.ic_wrong'))
          .width(32)
          .height(32)
          .fillColor(this.isCorrect ? '#4CAF50' : '#F44336')
        
        Column() {
          Text(this.isCorrect ? '恭喜答对了！' : '答错了，继续加油！')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isCorrect ? '#4CAF50' : '#F44336')
          
          Text(this.isCorrect ? '今日挑战完成' : '学习永无止境')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 16 })

      // 答案对比
      Column() {
        Row() {
          Text('正确答案：')
            .fontSize(14)
            .fontColor('#666666')
            .width(80)
          
          Text(this.currentQuestion?.answer?.join(', ') || '')
            .fontSize(14)
            .fontColor('#4CAF50')
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Row() {
          Text('你的答案：')
            .fontSize(14)
            .fontColor('#666666')
            .width(80)
          
          Text(this.selectedAnswers.join(', ') || '未选择')
            .fontSize(14)
            .fontColor(this.isCorrect ? '#4CAF50' : '#F44336')
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.isCorrect ? '#E8F5E8' : '#FFEBEE')
    .borderRadius(12)
    .margin({ top: 20 })
  }

  @Builder ExplanationSection() {
    Column() {
      Text('题目解析')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 12 })

      Text(this.currentQuestion?.explanation || '暂无解析')
        .fontSize(16)
        .fontColor('#666666')
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 20 })
  }

  @Builder BottomSection() {
    Column() {
      if (!this.isAnswered) {
        Button('提交答案')
          .width('100%')
          .height(48)
          .backgroundColor(this.selectedAnswers.length > 0 ? '#FF9800' : '#CCCCCC')
          .borderRadius(24)
          .fontColor('#FFFFFF')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .enabled(this.selectedAnswers.length > 0)
          .onClick(() => {
            this.submitAnswer()
          })
      } else {
        Row() {
          Button('返回首页')
            .width('48%')
            .height(48)
            .backgroundColor('#666666')
            .borderRadius(24)
            .fontColor('#FFFFFF')
            .fontSize(16)
            .onClick(() => {
              router.clear()
              router.pushUrl({ url: 'pages/Index' })
            })
          
          Button('继续练习')
            .width('48%')
            .height(48)
            .backgroundColor('#007AFF')
            .borderRadius(24)
            .fontColor('#FFFFFF')
            .fontSize(16)
            .onClick(() => {
              router.pushUrl({ url: 'pages/QuestionBankPage' })
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: -1 })
  }

  @Builder InfoChip(label: string, value: string, bgColor: string, textColor: string) {
    Text(`${label}: ${value}`)
      .fontSize(12)
      .fontColor(textColor)
      .backgroundColor(bgColor)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .borderRadius(8)
      .margin({ right: 8 })
  }

  selectOption(key: string) {
    if (this.currentQuestion?.type === 'single') {
      this.selectedAnswers = [key]
    } else {
      const index = this.selectedAnswers.indexOf(key)
      if (index > -1) {
        this.selectedAnswers.splice(index, 1)
      } else {
        this.selectedAnswers.push(key)
      }
    }
  }

  async submitAnswer() {
    if (this.selectedAnswers.length === 0) return

    this.isAnswered = true
    this.showResult = true
    
    const correctAnswers = this.currentQuestion?.answer || []
    this.isCorrect = this.selectedAnswers.length === correctAnswers.length &&
                    this.selectedAnswers.every(answer => correctAnswers.includes(answer))

    // 记录答题结果
    try {
      if (!this.currentQuestion) {
        return
      }
      
      const dbManager = DatabaseManager.getInstance()
      const answerTime = Date.now() - this.answerStartTime
      
      await dbManager.recordAnswer(
        this.currentQuestion.id,
        this.selectedAnswers.join(','),
        correctAnswers.join(','),
        this.isCorrect,
        answerTime,
        this.currentQuestion.type,
        this.currentQuestion.category,
        this.currentQuestion.difficulty
      )

      // 记录每日一题完成状态
      // 这里可以添加每日一题特殊的记录逻辑
      
      // 触发成就更新
      const achievementManager = AchievementManager.getInstance()
      await achievementManager.onQuestionAnswered(this.isCorrect)
      
    } catch (error) {
      console.error('记录答题失败:', error)
    }
  }

  getDifficultyColor(): DifficultyColorStyle {
    switch (this.currentQuestion?.difficulty) {
      case '简单':
        const easyStyle: DifficultyColorStyle = { bg: '#E8F5E8', text: '#4CAF50' }
        return easyStyle
      case '中等':
        const mediumStyle: DifficultyColorStyle = { bg: '#FFF3E0', text: '#FF9800' }
        return mediumStyle
      case '困难':
        const hardStyle: DifficultyColorStyle = { bg: '#FFEBEE', text: '#F44336' }
        return hardStyle
      default:
        const defaultStyle: DifficultyColorStyle = { bg: '#F5F5F5', text: '#666666' }
        return defaultStyle
    }
  }

  getOptionTextColor(key: string): string {
    if (!this.showResult) {
      return this.selectedAnswers.includes(key) ? '#FFFFFF' : '#333333'
    }
    
    const correctAnswers = this.currentQuestion?.answer || []
    if (correctAnswers.includes(key)) {
      return '#FFFFFF'
    } else if (this.selectedAnswers.includes(key)) {
      return '#FFFFFF'
    }
    return '#333333'
  }

  getOptionBackgroundColor(key: string): string {
    if (!this.showResult) {
      return this.selectedAnswers.includes(key) ? '#FF9800' : '#FFFFFF'
    }
    
    const correctAnswers = this.currentQuestion?.answer || []
    if (correctAnswers.includes(key)) {
      return '#4CAF50'
    } else if (this.selectedAnswers.includes(key)) {
      return '#F44336'
    }
    return '#FFFFFF'
  }

  getOptionBorderColor(key: string): string {
    if (!this.showResult) {
      return this.selectedAnswers.includes(key) ? '#FF9800' : '#E0E0E0'
    }
    
    const correctAnswers = this.currentQuestion?.answer || []
    if (correctAnswers.includes(key)) {
      return '#4CAF50'
    } else if (this.selectedAnswers.includes(key)) {
      return '#F44336'
    }
    return '#E0E0E0'
  }

  getOptionRowBackgroundColor(key: string): string {
    if (!this.showResult) {
      return this.selectedAnswers.includes(key) ? '#FFF3E0' : '#FFFFFF'
    }
    
    const correctAnswers = this.currentQuestion?.answer || []
    if (correctAnswers.includes(key)) {
      return '#E8F5E8'
    } else if (this.selectedAnswers.includes(key)) {
      return '#FFEBEE'
    }
    return '#FFFFFF'
  }
}