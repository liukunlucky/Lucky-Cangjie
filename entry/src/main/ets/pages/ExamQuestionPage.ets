import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'
import { DatabaseManager } from '../common/DatabaseManager'
import { AchievementManager } from '../common/AchievementManager'

interface ExamConfig {
  id: string
  title: string
  description: string
  difficulty: string
  questionCount: number
  timeLimit: number
  passingScore: number
  color: string
  bgColor: string
}

interface QuestionOptions {
  A: string
  B: string
  C: string
  D: string
}

interface ExamQuestion {
  id: number
  question: string
  options: QuestionOptions
  answer: string
  explanation: string
  category: string
  difficulty: string
}

@Entry
@Component
struct ExamQuestionPage {
  @State examConfig: ExamConfig | null = null
  @State questions: ExamQuestion[] = []
  @State currentQuestionIndex: number = 0
  @State selectedAnswer: string = ''
  @State userAnswers: string[] = []
  @State timeRemaining: number = 0
  @State isExamStarted: boolean = false
  @State isExamFinished: boolean = false
  @State score: number = 0
  @State correctCount: number = 0
  @State showAnalysis: boolean = false
  private databaseManager: DatabaseManager = DatabaseManager.getInstance()
  private achievementManager: AchievementManager = AchievementManager.getInstance()

  aboutToAppear() {
    const params = router.getParams()
    if (params && (params as Record<string, object>).examConfig) {
      this.examConfig = (params as Record<string, object>).examConfig as ExamConfig
      this.timeRemaining = this.examConfig.timeLimit * 60 // 转换为秒
      this.loadExamQuestions()
    }
  }

  async loadExamQuestions() {
    // 根据考试类型加载对应的题目
    const allQuestions = await this.databaseManager.getAllQuestions()
    const examType = this.examConfig?.id || 'basic'
    
    // 将Question类型转换为ExamQuestion类型
    const convertedQuestions: ExamQuestion[] = allQuestions.map((q): ExamQuestion => {
      const options: QuestionOptions = {
        A: q.options['A'] || '',
        B: q.options['B'] || '',
        C: q.options['C'] || '',
        D: q.options['D'] || ''
      }
      
      const examQuestion: ExamQuestion = {
        id: q.id,
        question: q.question,
        options: options,
        answer: Array.isArray(q.answer) ? q.answer[0] : q.answer,
        explanation: q.explanation,
        category: q.category,
        difficulty: q.difficulty
      }
      
      return examQuestion
    })
    
    // 根据考试类型筛选题目
    let filteredQuestions: ExamQuestion[] = []
    
    switch (examType) {
      case 'basic':
        filteredQuestions = convertedQuestions.filter(q => 
          q.category === '语法基础' || q.category === '数据类型'
        )
        break
      case 'intermediate':
        filteredQuestions = convertedQuestions.filter(q => 
          q.category === '函数' || q.category === '面向对象' || q.category === '函数编程'
        )
        break
      case 'advanced':
        filteredQuestions = convertedQuestions.filter(q => 
          q.category === '高级特性' || q.category === '并发编程' || q.category === '内存管理'
        )
        break
      case 'comprehensive':
        filteredQuestions = convertedQuestions
        break
      default:
        filteredQuestions = convertedQuestions.filter(q => q.category === '语法基础')
    }
    
    // 随机选择指定数量的题目
    const questionCount = this.examConfig?.questionCount || 20
    this.questions = this.shuffleArray(filteredQuestions).slice(0, questionCount)
    
    // 初始化用户答案数组
    this.userAnswers = new Array(this.questions.length).fill('')
    this.isExamStarted = true
    this.startTimer()
  }



  private shuffleArray<T>(array: T[]): T[] {
    const shuffled: T[] = []
    for (let i = 0; i < array.length; i++) {
      shuffled.push(array[i])
    }
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      const temp = shuffled[i]
      shuffled[i] = shuffled[j]
      shuffled[j] = temp
    }
    return shuffled
  }

  startTimer() {
    const timer = setInterval(async () => {
      if (this.timeRemaining > 0) {
        this.timeRemaining--
      } else {
        clearInterval(timer)
        await this.finishExam()
      }
    }, 1000)
  }

  selectAnswer(answer: string) {
    this.selectedAnswer = answer
    this.userAnswers[this.currentQuestionIndex] = answer
  }

  getOptionText(option: string): string {
    const question = this.questions[this.currentQuestionIndex]
    if (!question || !question.options) return ''
    
    if (option === 'A') return question.options.A || ''
    if (option === 'B') return question.options.B || ''
    if (option === 'C') return question.options.C || ''
    if (option === 'D') return question.options.D || ''
    
    return ''
  }

  getAnalysisOptionText(question: ExamQuestion, option: string): string {
    if (!question || !question.options) return ''
    
    if (option === 'A') return question.options.A || ''
    if (option === 'B') return question.options.B || ''
    if (option === 'C') return question.options.C || ''
    if (option === 'D') return question.options.D || ''
    
    return ''
  }

  nextQuestion() {
    if (this.currentQuestionIndex < this.questions.length - 1) {
      this.currentQuestionIndex++
      this.selectedAnswer = this.userAnswers[this.currentQuestionIndex]
    }
  }

  previousQuestion() {
    if (this.currentQuestionIndex > 0) {
      this.currentQuestionIndex--
      this.selectedAnswer = this.userAnswers[this.currentQuestionIndex]
    }
  }

  async finishExam() {
    // 计算分数
    this.correctCount = 0
    for (let i = 0; i < this.questions.length; i++) {
      if (this.userAnswers[i] === this.questions[i].answer) {
        this.correctCount++
      }
    }
    this.score = Math.round((this.correctCount / this.questions.length) * 100)
    
    // 保存考核记录到数据库
    try {
      const examDuration = (this.examConfig?.timeLimit || 1800) - this.timeRemaining; // 计算用时
      const passed = this.score >= (this.examConfig?.passingScore || 60);
      await this.databaseManager.recordExamResult(
        this.examConfig?.id || 'exam_' + Date.now(),
        this.examConfig?.title || '考核',
        this.questions.length,
        this.correctCount,
        this.score,
        examDuration,
        passed
      );
      console.info('考核记录保存成功');
      
      // 触发成就更新
        await this.achievementManager.onExamCompleted(this.score, passed);
      
      // 触发考试数据刷新
      AppStorage.setOrCreate('examDataRefreshTrigger', Date.now());
    } catch (error) {
      console.error('保存考核记录失败:', error);
    }
    
    this.isExamFinished = true
  }

  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = seconds % 60
    return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`
  }

  build() {
    Column() {
      if (!this.isExamStarted) {
        this.LoadingView()
      } else if (this.isExamFinished && this.showAnalysis) {
        this.AnalysisView()
      } else if (this.isExamFinished) {
        this.ResultView()
      } else {
        this.ExamView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder LoadingView() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#007AFF')
      
      Text('正在加载考核题目...')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder ExamView() {
    Column() {
      // 顶部信息栏
      Row() {
        Button('退出考核')
          .fontSize(14)
          .fontColor('#FF4444')
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#FF4444' })
          .borderRadius(20)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => {
            AlertDialog.show({
              title: '确认退出',
              message: '确定要退出考核吗？当前进度将不会保存。',
              primaryButton: {
                value: '确定',
                action: () => {
                  router.back()
                }
              },
              secondaryButton: {
                value: '取消',
                action: () => {}
              }
            })
          })

        Blank()

        Text(`${this.formatTime(this.timeRemaining)}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.timeRemaining < 300 ? '#FF4444' : '#333333')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 进度条
      Row() {
        Text(`${this.currentQuestionIndex + 1}/${this.questions.length}`)
          .fontSize(14)
          .fontColor('#666666')
        
        Progress({
          value: this.currentQuestionIndex + 1,
          total: this.questions.length,
          type: ProgressType.Linear
        })
        .width('100%')
        .height(4)
        .color('#007AFF')
        .margin({ left: 12 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 题目内容
      if (this.questions.length > 0) {
        Scroll() {
          Column() {
            // 题目
            Text(this.questions[this.currentQuestionIndex].question)
              .fontSize(18)
              .fontColor('#333333')
              .lineHeight(28)
              .width('100%')
              .margin({ bottom: 24 })

            // 选项
            Column({ space: 12 }) {
              ForEach(['A', 'B', 'C', 'D'], (option: string) => {
                Row() {
                  Radio({ value: option, group: 'answers' })
                    .checked(this.selectedAnswer === option)
                    .onChange((isChecked: boolean) => {
                      if (isChecked) {
                        this.selectAnswer(option)
                      }
                    })

                  Text(`${option}. ${this.getOptionText(option)}`)
                    .fontSize(16)
                    .fontColor('#333333')
                    .margin({ left: 12 })
                    .layoutWeight(1)
                }
                .width('100%')
                .padding(16)
                .backgroundColor(this.selectedAnswer === option ? '#E3F2FD' : '#FFFFFF')
                .borderRadius(8)
                .border({
                  width: 1,
                  color: this.selectedAnswer === option ? '#007AFF' : '#E0E0E0'
                })
                .onClick(() => {
                  this.selectAnswer(option)
                })
              }, (option: string) => option)
            }
          }
          .padding(20)
        }
        .layoutWeight(1)
        .backgroundColor('#FFFFFF')
        .margin({ top: 8 })
      }

      // 底部按钮
      Row() {
        Button('上一题')
          .enabled(this.currentQuestionIndex > 0)
          .backgroundColor(this.currentQuestionIndex > 0 ? '#007AFF' : '#CC007AFF')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .onClick(() => {
            this.previousQuestion()
          })

        Blank()

        if (this.currentQuestionIndex < this.questions.length - 1) {
          Button('下一题')
            .backgroundColor('#007AFF')
            .fontColor('#FFFFFF')
            .borderRadius(8)
            .padding({ left: 20, right: 20, top: 12, bottom: 12 })
            .onClick(() => {
              this.nextQuestion()
            })
        } else {
          Button('提交考核')
            .backgroundColor('#4CAF50')
            .fontColor('#FFFFFF')
            .borderRadius(8)
            .padding({ left: 20, right: 20, top: 12, bottom: 12 })
            .onClick(() => {
              AlertDialog.show({
                title: '提交考核',
                message: '确定要提交考核吗？提交后将无法修改答案。',
                primaryButton: {
                  value: '提交',
                  action: async () => {
                    await this.finishExam()
                  }
                },
                secondaryButton: {
                  value: '取消',
                  action: () => {}
                }
              })
            })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
    }
  }

  @Builder ResultView() {
    Column() {
      // 结果展示
      Column() {
        Text('考核完成')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 20 })

        Text(`${this.score}分`)
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.score >= (this.examConfig?.passingScore || 60) ? '#4CAF50' : '#FF4444')
          .margin({ bottom: 12 })

        Text(this.score >= (this.examConfig?.passingScore || 60) ? '恭喜通过！' : '未达到及格线')
          .fontSize(18)
          .fontColor(this.score >= (this.examConfig?.passingScore || 60) ? '#4CAF50' : '#FF4444')
          .margin({ bottom: 32 })

        // 详细统计
        Column({ space: 16 }) {
          Row() {
            Text('正确题数：')
              .fontSize(16)
              .fontColor('#666666')
            Text(`${this.correctCount}/${this.questions.length}`)
              .fontSize(16)
              .fontColor('#333333')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text('正确率：')
              .fontSize(16)
              .fontColor('#666666')
            Text(`${Math.round((this.correctCount / this.questions.length) * 100)}%`)
              .fontSize(16)
              .fontColor('#333333')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            Text('考核难度：')
              .fontSize(16)
              .fontColor('#666666')
            Text(this.examConfig?.difficulty || '')
              .fontSize(16)
              .fontColor('#333333')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#F8F9FA')
        .borderRadius(12)
        .margin({ bottom: 32 })

        // 操作按钮
        Column({ space: 12 }) {
          Button('查看答案解析')
            .width('100%')
            .height(44)
            .backgroundColor('#007AFF')
            .fontColor('#FFFFFF')
            .borderRadius(8)
            .onClick(() => {
              this.showAnalysis = true
            })

          Button('返回考核中心')
            .width('100%')
            .height(44)
            .backgroundColor('#FFFFFF')
            .fontColor('#007AFF')
            .border({ width: 1, color: '#007AFF' })
            .borderRadius(8)
            .onClick(() => {
              // 触发考试数据刷新
              AppStorage.setOrCreate('examDataRefreshTrigger', Date.now());
              router.back()
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(32)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
  }

  @Builder AnalysisView() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('返回结果')
          .fontSize(16)
          .fontColor('#007AFF')
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showAnalysis = false
          })
        
        Blank()
        
        Text('答案解析')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Text(`${this.correctCount}/${this.questions.length}`)
          .fontSize(16)
          .fontColor('#666666')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E5E5E5' })

      // 题目解析列表
      List() {
        ForEach(this.questions, (question: ExamQuestion, index: number) => {
          ListItem() {
            this.buildAnalysisItem(question, index)
          }
        }, (question: ExamQuestion) => question.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .padding({ top: 8, bottom: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder buildAnalysisItem(question: ExamQuestion, index: number) {
    Column() {
      // 题目标题
      Row() {
        Text(`第${index + 1}题`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        // 答题结果标识
         if (this.userAnswers[index] === question.answer) {
           Text('✓')
             .fontSize(18)
             .fontColor('#4CAF50')
             .fontWeight(FontWeight.Bold)
         } else {
           Text('✗')
             .fontSize(18)
             .fontColor('#F44336')
             .fontWeight(FontWeight.Bold)
         }
      }
       .width('100%')
       .margin({ bottom: 12 })

       // 题目内容
       Text(question.question)
         .fontSize(16)
         .fontColor('#333333')
         .lineHeight(24)
         .width('100%')
         .margin({ bottom: 16 })

       // 选项列表
         Column({ space: 8 }) {
            ForEach(Object.keys(question.options), (optionKey: string) => {
              Row() {
                Text(optionKey + '. ')
                  .fontSize(14)
                  .fontColor(optionKey === question.answer ? '#4CAF50' : (optionKey === this.userAnswers[index] ? '#F44336' : '#666666'))
                  .fontWeight(optionKey === question.answer || optionKey === this.userAnswers[index] ? FontWeight.Bold : FontWeight.Normal)
                
                Text(this.getAnalysisOptionText(question, optionKey))
                  .fontSize(14)
                  .fontColor(optionKey === question.answer ? '#4CAF50' : (optionKey === this.userAnswers[index] ? '#F44336' : '#666666'))
                  .fontWeight(optionKey === question.answer || optionKey === this.userAnswers[index] ? FontWeight.Bold : FontWeight.Normal)
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(8)
              .backgroundColor(optionKey === question.answer ? '#E8F5E8' : (optionKey === this.userAnswers[index] ? '#FFEBEE' : Color.Transparent))
              .borderRadius(4)
            }, (optionKey: string) => `${question.id}_${optionKey}`)
      }
       .width('100%')
       .margin({ bottom: 16 })

       // 正确答案提示
        Text(`正确答案：${question.answer}`)
          .fontSize(14)
          .fontColor('#4CAF50')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ bottom: 8 })

      // 答案解析
      if (question.explanation && question.explanation.length > 0) {
        Column() {
          Text('解析：')
             .fontSize(14)
             .fontColor('#666666')
             .fontWeight(FontWeight.Bold)
             .width('100%')
             .margin({ bottom: 4 })
          
          Text(question.explanation)
            .fontSize(14)
            .fontColor('#666666')
            .lineHeight(20)
            .width('100%')
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F9F9F9')
        .borderRadius(8)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ left: 16, right: 16, bottom: 8 })
  }
}