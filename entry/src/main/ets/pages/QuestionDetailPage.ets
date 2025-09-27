import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'
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

interface RouterParams {
  question: Question
  questionList?: Question[]
  currentIndex?: number
}

@Entry
@Component
struct QuestionDetailPage {
  @State currentQuestion: Question | null = null
  @State questionList: Question[] = []
  @State currentIndex: number = 0
  @State currentTabIndex: number = 0
  @State selectedAnswers: string[] = []
  @State isAnswered: boolean = false
  @State isCorrect: boolean = false
  @State isFavorite: boolean = false
  @State questionNote: string = ''
  @State showResult: boolean = false
  @State answerStartTime: number = 0
  @State refreshKey: number = 0

  aboutToAppear() {
    const params = router.getParams() as RouterParams
    if (params) {
      this.currentQuestion = params.question
      this.questionList = params.questionList || [params.question]
      this.currentIndex = params.currentIndex || 0
    }
    
    this.answerStartTime = Date.now()
    this.loadQuestionData()
  }

  async loadQuestionData() {
    if (!this.currentQuestion) return

    try {
      const dbManager = DatabaseManager.getInstance()
      this.isFavorite = await dbManager.isFavorite(this.currentQuestion.id)
      this.questionNote = await dbManager.getQuestionNote(this.currentQuestion.id)
    } catch (error) {
      console.error('加载题目数据失败:', error)
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.HeaderSection()
      
      // Tab导航
      this.TabSection()
      
      // 内容区域
      this.ContentSection()
      
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
      
      Text(`题目 ${this.currentQuestion?.id || 0}`)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Image(this.isFavorite ? $r('app.media.ic_favorite_filled') : $r('app.media.ic_favorite'))
        .width(24)
        .height(24)
        .fillColor(this.isFavorite ? '#FF6B6B' : '#666666')
        .onClick(() => {
          this.toggleFavorite()
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
  }

  @Builder TabSection() {
    Row() {
      this.TabItem('题目描述', 0)
      this.TabItem('题目解析', 1)
      this.TabItem('题目笔记', 2)
    }
    .width('100%')
    .height(48)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  @Builder TabItem(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontColor(this.currentTabIndex === index ? '#007AFF' : '#666666')
        .fontWeight(this.currentTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
      
      if (this.currentTabIndex === index) {
        Divider()
          .width(40)
          .height(2)
          .color('#007AFF')
          .margin({ top: 4 })
      }
    }
    .width('33.33%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentTabIndex = index
    })
  }

  @Builder ContentSection() {
    Scroll() {
      Column() {
        if (this.currentTabIndex === 0) {
          this.QuestionContent()
        } else if (this.currentTabIndex === 1) {
          this.ExplanationContent()
        } else {
          this.NoteContent()
        }
      }
      .width('100%')
      .padding(16)
    }
    .layoutWeight(1)
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
          }, (key: string) => `${this.refreshKey}_${key}`)
        }
        .width('100%')
      }

      // 答题结果
      if (this.showResult) {
        this.ResultSection()
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
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
          .width(24)
          .height(24)
          .fillColor(this.isCorrect ? '#4CAF50' : '#F44336')
        
        Text(this.isCorrect ? '回答正确！' : '回答错误')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isCorrect ? '#4CAF50' : '#F44336')
          .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 16 })

      // 正确答案
      Text(`正确答案：${this.currentQuestion?.answer?.join(', ') || ''}`)
        .fontSize(16)
        .fontColor('#666666')
        .width('100%')
        .margin({ bottom: 8 })

      // 你的答案
      Text(`你的答案：${this.selectedAnswers.join(', ') || '未选择'}`)
        .fontSize(16)
        .fontColor('#666666')
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.isCorrect ? '#E8F5E8' : '#FFEBEE')
    .borderRadius(12)
    .margin({ top: 20 })
  }

  @Builder ExplanationContent() {
    Column() {
      if (this.isAnswered || this.showResult) {
        Text('题目解析')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')
          .margin({ bottom: 16 })

        Text(this.currentQuestion?.explanation || '暂无解析')
          .fontSize(16)
          .fontColor('#666666')
          .lineHeight(24)
          .width('100%')
      } else {
        Column() {
          Image($r('app.media.ic_lock'))
            .width(48)
            .height(48)
            .fillColor('#CCCCCC')
          
          Text('请先完成答题')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ top: 16 })
          
          Text('答题后可查看详细解析')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 8 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder NoteContent() {
    Column() {
      Text('我的笔记')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .margin({ bottom: 16 })

      TextArea({ placeholder: '在这里记录你的学习笔记...' })
        .width('100%')
        .height(200)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding(12)
        .fontSize(16)
        .onChange((value: string) => {
          this.questionNote = value
        })
        .onBlur(() => {
          this.saveNote()
        })

      Button('保存笔记')
        .width('100%')
        .height(44)
        .backgroundColor('#007AFF')
        .borderRadius(8)
        .fontColor('#FFFFFF')
        .fontSize(16)
        .margin({ top: 16 })
        .onClick(() => {
          this.saveNote()
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder BottomSection() {
    Row() {
      // 上一题按钮
      Button('上一题')
        .width('30%')
        .height(44)
        .backgroundColor(this.currentIndex > 0 ? '#007AFF' : '#CC007AFF')
        .borderRadius(8)
        .fontColor('#FFFFFF')
        .fontSize(16)
        .enabled(this.currentIndex > 0)
        .onClick(() => {
          this.goToPreviousQuestion()
        })

      // 提交答案/下一题按钮
      if (!this.isAnswered) {
        Button('提交答案')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(this.selectedAnswers.length > 0 ? '#4CAF50' : '#CC4CAF50')
          .borderRadius(8)
          .fontColor('#FFFFFF')
          .fontSize(16)
          .margin({ left: 12, right: 12 })
          .enabled(this.selectedAnswers.length > 0)
          .onClick(() => {
            this.submitAnswer()
          })
      } else {
        Button('继续练习')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#4CAF50')
          .borderRadius(8)
          .fontColor('#FFFFFF')
          .fontSize(16)
          .margin({ left: 12, right: 12 })
          .onClick(() => {
            this.resetQuestion()
          })
      }

      // 下一题按钮
      Button('下一题')
        .width('30%')
        .height(44)
        .backgroundColor(this.currentIndex < this.questionList.length - 1 ? '#007AFF' : '#CC007AFF')
        .borderRadius(8)
        .fontColor('#FFFFFF')
        .fontSize(16)
        .enabled(this.currentIndex < this.questionList.length - 1)
        .onClick(() => {
          this.goToNextQuestion()
        })
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
    if (this.currentQuestion) {
      try {
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
        
        // 触发成就更新
        const achievementManager = AchievementManager.getInstance()
        await achievementManager.onQuestionAnswered(this.isCorrect)
      } catch (error) {
        console.error('记录答题失败:', error)
      }
    }
  }

  resetQuestion() {
    this.selectedAnswers = []
    this.isAnswered = false
    this.showResult = false
    this.answerStartTime = Date.now()
    // 强制刷新UI状态
    this.refreshKey++
  }

  goToPreviousQuestion() {
    if (this.currentIndex > 0) {
      this.currentIndex--
      this.currentQuestion = this.questionList[this.currentIndex]
      this.resetQuestion()
      this.loadQuestionData()
    }
  }

  goToNextQuestion() {
    if (this.currentIndex < this.questionList.length - 1) {
      this.currentIndex++
      this.currentQuestion = this.questionList[this.currentIndex]
      this.resetQuestion()
      this.loadQuestionData()
    }
  }

  async toggleFavorite() {
    if (!this.currentQuestion) return
    
    try {
      const dbManager = DatabaseManager.getInstance()
      if (this.isFavorite) {
        await dbManager.removeFromFavorites(this.currentQuestion.id)
        this.isFavorite = false
      } else {
        await dbManager.addToFavorites(this.currentQuestion.id)
        this.isFavorite = true
      }
    } catch (error) {
      console.error('切换收藏状态失败:', error)
    }
  }

  async saveNote() {
    if (!this.currentQuestion) return
    
    try {
      const dbManager = DatabaseManager.getInstance()
      await dbManager.saveQuestionNote(this.currentQuestion.id, this.questionNote)
      
      promptAction.showToast({
        message: '笔记已保存',
        duration: 2000
      })
    } catch (error) {
      console.error('保存笔记失败:', error)
    }
  }

  getDifficultyColor(): DifficultyColorStyle {
    switch (this.currentQuestion?.difficulty) {
      case '简单':
        return { bg: '#E8F5E8', text: '#4CAF50' }
      case '中等':
        return { bg: '#FFF3E0', text: '#FF9800' }
      case '困难':
        return { bg: '#FFEBEE', text: '#F44336' }
      default:
        return { bg: '#F5F5F5', text: '#666666' }
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
      return this.selectedAnswers.includes(key) ? '#007AFF' : '#FFFFFF'
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
      return this.selectedAnswers.includes(key) ? '#007AFF' : '#E0E0E0'
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
      return this.selectedAnswers.includes(key) ? '#E3F2FD' : '#FFFFFF'
    }
    
    const correctAnswers = this.currentQuestion?.answer || []
    if (correctAnswers.includes(key)) {
      return '#E8F5E8'
    } else if (this.selectedAnswers.includes(key)) {
      return '#FFEBEE'
    }
    return '#FFFFFF'
  }

  getOptionValue(key: string): string {
    if (!this.currentQuestion?.options) return ''
    
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
}