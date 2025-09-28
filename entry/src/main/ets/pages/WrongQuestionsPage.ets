import router from '@ohos.router'
import { DatabaseManager } from '../common/DatabaseManager'

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

interface WrongQuestion {
  questionId: number
  type: string
  category: string
  difficulty: string
  question: string
  options: Record<string, string>
  correctAnswer: string
  explanation: string
  userAnswer: string
  wrongCount: number
  lastWrongTime: string
  isResolved: boolean
}

interface DifficultyColorStyle {
  bg: string
  text: string
}



@Entry
@Component
struct WrongQuestionsPage {
  @State wrongQuestions: WrongQuestion[] = []
  @State filteredQuestions: WrongQuestion[] = []
  @State selectedCategory: string = '全部'
  @State selectedDifficulty: string = '全部'
  @State selectedStatus: string = '全部'
  @State searchText: string = ''
  @State categories: string[] = ['全部']
  @State difficulties: string[] = ['全部', '简单', '中等', '困难']
  @State statusOptions: string[] = ['全部', '未解决', '已解决']
  @State isLoading: boolean = true
  @State sortBy: string = 'time' // 'time', 'count', 'category'

  aboutToAppear() {
    this.loadWrongQuestions()
  }

  async loadWrongQuestions() {
    try {
      this.isLoading = true
      const dbManager = DatabaseManager.getInstance()
      this.wrongQuestions = await dbManager.getWrongQuestions()

      // 提取分类
      const categorySet = new Set(this.wrongQuestions.map(q => q.category))
      const uniqueCategories = Array.from(categorySet)
      this.categories = ['全部'].concat(uniqueCategories)

      this.applyFilters()
      this.isLoading = false
    } catch (error) {
      console.error('加载错题失败:', error)
      this.isLoading = false
    }
  }

  applyFilters() {
    let filtered = this.wrongQuestions.filter(question => {
      const categoryMatch = this.selectedCategory === '全部' || question.category === this.selectedCategory
      const difficultyMatch = this.selectedDifficulty === '全部' || question.difficulty === this.selectedDifficulty
      const statusMatch = this.selectedStatus === '全部' || 
                         (this.selectedStatus === '已解决' && question.isResolved) ||
                         (this.selectedStatus === '未解决' && !question.isResolved)
      const searchMatch = this.searchText === '' || 
                         question.question.toLowerCase().includes(this.searchText.toLowerCase())
      
      return categoryMatch && difficultyMatch && statusMatch && searchMatch
    })

    // 排序
    switch (this.sortBy) {
      case 'time':
        filtered.sort((a, b) => new Date(b.lastWrongTime).getTime() - new Date(a.lastWrongTime).getTime())
        break
      case 'count':
        filtered.sort((a, b) => b.wrongCount - a.wrongCount)
        break
      case 'category':
        filtered.sort((a, b) => a.category.localeCompare(b.category))
        break
    }

    this.filteredQuestions = filtered
  }

  build() {
    Column() {
      // 顶部导航栏
      this.HeaderSection()
      
      if (this.isLoading) {
        this.LoadingSection()
      } else if (this.wrongQuestions.length === 0) {
        this.EmptySection()
      } else {
        // 统计信息
        this.StatisticsSection()
        
        // 搜索和筛选
        this.FilterSection()
        
        // 题目列表
        this.QuestionList()
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
      
      Text('错题本')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      // 排序按钮
      Image($r('app.media.ic_sort'))
        .width(24)
        .height(24)
        .fillColor('#666666')
        .onClick(() => {
          this.showSortOptions()
        })
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
      
      Text('加载中...')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder EmptySection() {
    Column() {
      Image($r('app.media.ic_wrong_empty'))
        .width(120)
        .height(120)
        .fillColor('#CCCCCC')
      
      Text('暂无错题记录')
        .fontSize(18)
        .fontColor('#666666')
        .margin({ top: 20 })
      
      Text('答错的题目会自动收录到错题本')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
      
      Button('开始练习')
        .width(120)
        .height(40)
        .backgroundColor('#007AFF')
        .borderRadius(20)
        .fontColor('#FFFFFF')
        .fontSize(16)
        .margin({ top: 24 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/QuestionBankPage' })
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder StatisticsSection() {
    Row() {
      Column() {
        Text(this.wrongQuestions.length.toString())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F44336')
        
        Text('总错题')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text(this.getUnresolvedCount().toString())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF9800')
        
        Text('未解决')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text(this.getResolvedCount().toString())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')
        
        Text('已解决')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text(`${this.getResolveRate()}%`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#007AFF')
        
        Text('解决率')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .margin({top: 16})
  }

  @Builder FilterSection() {
    Column() {
      // 搜索框
      Row() {
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
          .fillColor('#666666')
          .margin({ left: 12, right: 8 })
        
        TextInput({ placeholder: '搜索错题内容...', text: this.searchText })
          .layoutWeight(1)
          .placeholderColor('#D5DBDB')
          .backgroundColor('transparent')
          .border({ width: 0 })
          .onChange((value: string) => {
            this.searchText = value
            this.applyFilters()
          })
        
        if (this.searchText.length > 0) {
          Image($r('app.media.ic_clear'))
            .width(20)
            .height(20)
            .fillColor('#666666')
            .margin({ right: 12 })
            .onClick(() => {
              this.searchText = ''
              this.applyFilters()
            })
        }
      }
      .width('100%')
      .height(44)
      .backgroundColor('#FFFFFF')
      .borderRadius(22)
      .margin({ bottom: 12 })

      // 筛选标签
      Scroll() {
        Row() {
          // 状态筛选
          ForEach(this.statusOptions, (status: string) => {
            this.FilterChip(status, this.selectedStatus === status, () => {
              this.selectedStatus = status
              this.applyFilters()
            })
          })

          // 分隔线
          Column()
            .width(1)
            .height(20)
            .backgroundColor('#E0E0E0')
            .margin({ left: 8, right: 8 })

          // 分类筛选
          ForEach(this.categories, (category: string) => {
            this.FilterChip(category, this.selectedCategory === category, () => {
              this.selectedCategory = category
              this.applyFilters()
            })
          })

          // 分隔线
          Column()
            .width(1)
            .height(20)
            .backgroundColor('#E0E0E0')
            .margin({ left: 8, right: 8 })

          // 难度筛选
          ForEach(this.difficulties, (difficulty: string) => {
            this.FilterChip(difficulty, this.selectedDifficulty === difficulty, () => {
              this.selectedDifficulty = difficulty
              this.applyFilters()
            })
          })
        }
        .padding({ left: 4, right: 4 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .visibility(Visibility.None)
    }
    .width('100%')
    .padding(16)
  }

  @Builder FilterChip(text: string, isSelected: boolean, onTap: () => void) {
    Text(text)
      .fontSize(14)
      .fontColor(isSelected ? '#FFFFFF' : '#666666')
      .backgroundColor(isSelected ? '#007AFF' : '#F0F0F0')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(15)
      .margin({ right: 8 })
      .onClick(onTap)
  }

  @Builder QuestionList() {
    Column() {
      // 结果统计
      Row() {
        Text(`共找到 ${this.filteredQuestions.length} 道错题`)
          .fontSize(14)
          .fontColor('#666666')
        
        Blank()
        
        Text(this.getSortText())
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })

      // 题目列表
      Scroll() {
        Column() {
          ForEach(this.filteredQuestions, (question: WrongQuestion) => {
            this.QuestionItem(question)
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
    }
    .layoutWeight(1)
  }

  @Builder QuestionItem(question: WrongQuestion) {
    Column() {
      Row() {
        // 题目信息
        Column() {
          // 题目标签
          Row() {
            this.InfoTag(question.category, '#E3F2FD', '#1976D2')
            this.InfoTag(question.difficulty, this.getDifficultyColor(question.difficulty).bg, this.getDifficultyColor(question.difficulty).text)
            this.InfoTag(question.type === 'single' ? '单选' : '多选', '#F3E5F5', '#7B1FA2')
            this.InfoTag(`错${question.wrongCount}次`, '#FFEBEE', '#F44336')
          }
          .width('100%')
          .margin({ bottom: 8 })

          // 题目内容
          Text(question.question)
            .fontSize(16)
            .fontColor('#333333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .lineHeight(22)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 状态标识
        Column() {
          if (question.isResolved) {
            Image($r('app.media.ic_check_circle'))
              .width(24)
              .height(24)
              .fillColor('#4CAF50')
          } else {
            Image($r('app.media.ic_error_circle'))
              .width(24)
              .height(24)
              .fillColor('#F44336')
          }
          
          Text(question.isResolved ? '已解决' : '未解决')
            .fontSize(10)
            .fontColor(question.isResolved ? '#4CAF50' : '#F44336')
            .margin({ top: 2 })
        }
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      // 答案对比
      Column() {
        Row() {
          Text('正确答案：')
            .fontSize(12)
            .fontColor('#666666')
            .width(70)
          
          Text(question.correctAnswer)
            .fontSize(12)
            .fontColor('#4CAF50')
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 4 })

        Row() {
          Text('你的答案：')
            .fontSize(12)
            .fontColor('#666666')
            .width(70)
          
          Text(question.userAnswer || '未选择')
            .fontSize(12)
            .fontColor('#F44336')
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F8F8F8')
      .borderRadius(8)
      .margin({ top: 8 })

      // 最后错误时间
      Text(`最后错误时间：${this.formatDate(question.lastWrongTime)}`)
        .fontSize(12)
        .fontColor('#999999')
        .width('100%')
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 8 })
    .onClick(() => {
      // 转换WrongQuestion为Question格式
      const questionOptions: QuestionOptions = {
        A: question.options.A || '',
        B: question.options.B || '',
        C: question.options.C || '',
        D: question.options.D || ''
      }
      const questionData: Question = {
        id: question.questionId,
        type: question.type,
        category: question.category,
        difficulty: question.difficulty,
        question: question.question,
        options: questionOptions,
        answer: question.correctAnswer.split(','),
        explanation: question.explanation
      }
      
      router.pushUrl({
        url: 'pages/QuestionDetailPage',
        params: {
          question: questionData,
          questionList: [questionData],
          currentIndex: 0,
          fromWrongQuestions: true
        }
      })
    })
  }

  @Builder InfoTag(text: string, bgColor: string, textColor: string) {
    Text(text)
      .fontSize(12)
      .fontColor(textColor)
      .backgroundColor(bgColor)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .borderRadius(8)
      .margin({ right: 8 })
  }

  getDifficultyColor(difficulty: string): DifficultyColorStyle {
    switch (difficulty) {
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

  formatDate(timestamp: string | number): string {
    const date = new Date(timestamp)
    const now = new Date()
    const diffTime = now.getTime() - date.getTime()
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24))
    
    if (diffDays === 0) {
      return '今天'
    } else if (diffDays === 1) {
      return '昨天'
    } else if (diffDays < 7) {
      return `${diffDays}天前`
    } else {
      return date.toLocaleDateString('zh-CN')
    }
  }

  getUnresolvedCount(): number {
    return this.wrongQuestions.filter(q => !q.isResolved).length
  }

  getResolvedCount(): number {
    return this.wrongQuestions.filter(q => q.isResolved).length
  }

  getResolveRate(): number {
    if (this.wrongQuestions.length === 0) return 0
    return Math.round((this.getResolvedCount() / this.wrongQuestions.length) * 100)
  }

  getSortText(): string {
    switch (this.sortBy) {
      case 'time':
        return '按时间排序'
      case 'count':
        return '按错误次数排序'
      case 'category':
        return '按分类排序'
      default:
        return '按时间排序'
    }
  }

  showSortOptions() {
    // 这里可以显示排序选项的弹窗
    // 暂时简单切换排序方式
    if (this.sortBy === 'time') {
      this.sortBy = 'count'
    } else if (this.sortBy === 'count') {
      this.sortBy = 'category'
    } else {
      this.sortBy = 'time'
    }
    this.applyFilters()
  }
}