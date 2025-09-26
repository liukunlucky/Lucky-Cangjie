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

interface ExamConfig {
  id: string
  title: string
  description: string
  difficulty: string
  questionCount: number
  timeLimit: number // 分钟
  passingScore: number // 及格分数
  color: string
  bgColor: string
}

@Entry
@Component
export struct ExamPage {
  @State examConfigs: ExamConfig[] = [
    {
      id: 'basic',
      title: '基础入门考核',
      description: '测试仓颉语言基础语法和概念',
      difficulty: '简单',
      questionCount: 20,
      timeLimit: 30,
      passingScore: 70,
      color: '#4CAF50',
      bgColor: '#E8F5E8'
    },
    {
      id: 'intermediate',
      title: '进阶应用考核',
      description: '测试函数、类和面向对象编程',
      difficulty: '中等',
      questionCount: 30,
      timeLimit: 45,
      passingScore: 75,
      color: '#FF9800',
      bgColor: '#FFF3E0'
    },
    {
      id: 'advanced',
      title: '高级特性考核',
      description: '测试高级语法和复杂应用场景',
      difficulty: '困难',
      questionCount: 40,
      timeLimit: 60,
      passingScore: 80,
      color: '#F44336',
      bgColor: '#FFEBEE'
    },
    {
      id: 'comprehensive',
      title: '综合能力考核',
      description: '全面测试仓颉语言掌握程度',
      difficulty: '综合',
      questionCount: 50,
      timeLimit: 90,
      passingScore: 85,
      color: '#9C27B0',
      bgColor: '#F3E5F5'
    }
  ]

  @State userExamHistory: ExamRecord[] = []
  @StorageLink('examDataRefreshTrigger') @Watch('onRefreshTriggerChange') refreshTrigger: number = 0;

  private databaseManager: DatabaseManager = DatabaseManager.getInstance()

  aboutToAppear() {
    this.loadExamHistory()
  }

  onRefreshTriggerChange() {
    if (this.refreshTrigger > 0) {
      this.loadExamHistory();
      this.refreshTrigger = 0;
    }
  }

  async loadExamHistory() {
    // 从数据库加载用户考核历史
    try {
      this.userExamHistory = await this.databaseManager.getExamRecords()
    } catch (error) {
      console.error('加载考核历史失败:', error)
      this.userExamHistory = []
    }
  }

  build() {
    Scroll() {
      Column() {
        // 页面标题
        this.HeaderSection()
        
        // 考核卡片列表
        this.ExamCardsSection()
        
        // 历史记录
        this.HistorySection()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
    }
    .backgroundColor('#F5F5F5')
    .height('100%')
  }

  @Builder HeaderSection() {
    Column() {
      Text('考核中心')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Start)
      
      Text('选择适合的考核难度，检验你的学习成果')
        .fontSize(16)
        .fontColor('#666666')
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ top: 8 })
    }
    .width('100%')
    .margin({ bottom: 32 })
  }

  @Builder ExamCardsSection() {
    Column() {
      ForEach(this.examConfigs, (exam: ExamConfig) => {
        this.ExamCard(exam)
      })
    }
    .width('100%')
  }

  @Builder ExamCard(exam: ExamConfig) {
    Column() {
      Row() {
        Column() {
          Text(exam.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
          
          Text(exam.description)
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        
        Column() {
          Text(exam.difficulty)
            .fontSize(14)
            .fontColor(exam.color)
            .backgroundColor(exam.bgColor)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(12)
        }
      }
      .width('100%')
      .margin({ bottom: 16 })

      Row() {
        this.ExamInfoItem('题目数量', `${exam.questionCount}题`)
        this.ExamInfoItem('考试时长', `${exam.timeLimit}分钟`)
        this.ExamInfoItem('及格分数', `${exam.passingScore}分`)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 20 })

      Button('开始考核')
        .width('100%')
        .height(44)
        .backgroundColor(exam.color)
        .borderRadius(22)
        .fontColor('#FFFFFF')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.startExam(exam)
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ bottom: 16 })
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder ExamInfoItem(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
      
      Text(label)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder HistorySection() {
    if (this.userExamHistory.length > 0) {
      Column() {
        Text('考核记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 16 })

        ForEach(this.userExamHistory, (record: ExamRecord) => {
          this.HistoryItem(record)
        })
      }
      .width('100%')
      .margin({ top: 32 })
    } else {
      Column() {
        Text('暂无考核记录')
          .fontSize(16)
          .fontColor('#666666')
        
        Text('完成第一次考核后，记录将显示在这里')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 8 })
      }
      .width('100%')
      .height(120)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ top: 32 })
    }
  }

  @Builder HistoryItem(record: ExamRecord) {
    Row() {
      Column() {
        Text(record.examTitle)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Text(record.examDate)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text(`${record.score}分`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(record.passed ? '#4CAF50' : '#F44336')
        
        Text(record.passed ? '通过' : '未通过')
          .fontSize(12)
          .fontColor(record.passed ? '#4CAF50' : '#F44336')
      }
      .alignItems(HorizontalAlign.End)

      // 添加箭头图标提示可点击
      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
        .fillColor('#CCCCCC')
        .margin({ left: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      this.viewExamDetail(record)
    })
  }

  startExam(exam: ExamConfig) {
    // 显示确认对话框
    AlertDialog.show({
      title: '开始考核',
      message: `确定要开始"${exam.title}"吗？\n\n考试时长：${exam.timeLimit}分钟\n题目数量：${exam.questionCount}题\n及格分数：${exam.passingScore}分`,
      primaryButton: {
        value: '开始',
        action: () => {
          router.pushUrl({
            url: 'pages/ExamQuestionPage',
            params: { examConfig: exam }
          })
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    })
  }

  viewExamDetail(record: ExamRecord) {
    // 跳转到考核记录详情页
    router.pushUrl({
      url: 'pages/ExamRecordDetailPage',
      params: { examRecord: record }
    })
  }
}