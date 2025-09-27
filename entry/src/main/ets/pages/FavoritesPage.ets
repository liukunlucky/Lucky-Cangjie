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

interface FavoriteQuestion {
  questionId: number
  type: string
  category: string
  difficulty: string
  question: string
  options: Record<string, string>
  answer: string[]
  explanation: string
  favoriteTime: string
}

interface DifficultyColorStyle {
  bg: string
  text: string
}

interface DatabaseFavoriteQuestion {
  questionId: number
  type: string
  category: string
  difficulty: string
  question: string
  options: Record<string, string>
  answer: string[]
  explanation: string
  favoriteTime: string
}

@Entry
@Component
struct FavoritesPage {
  @State favoriteQuestions: FavoriteQuestion[] = []
  @State filteredQuestions: FavoriteQuestion[] = []
  @State selectedCategory: string = '全部'
  @State selectedDifficulty: string = '全部'
  @State searchText: string = ''
  @State categories: string[] = ['全部']
  @State difficulties: string[] = ['全部', '简单', '中等', '困难']
  @State isLoading: boolean = true

  aboutToAppear() {
    this.loadFavoriteQuestions()
  }

  async loadFavoriteQuestions() {
    try {
      this.isLoading = true
      const dbManager = DatabaseManager.getInstance()
      const favorites: DatabaseFavoriteQuestion[] = await dbManager.getFavoriteQuestions() as DatabaseFavoriteQuestion[]
      
      this.favoriteQuestions = favorites.map((fav: DatabaseFavoriteQuestion) => {
        const favoriteQuestion: FavoriteQuestion = {
          questionId: fav.questionId,
          type: fav.type,
          category: fav.category,
          difficulty: fav.difficulty,
          question: fav.question,
          options: fav.options,
          answer: fav.answer,
          explanation: fav.explanation,
          favoriteTime: fav.favoriteTime
        }
        return favoriteQuestion
      })

      // 提取分类
      const categorySet = new Set(this.favoriteQuestions.map(q => q.category))
      const uniqueCategories = Array.from(categorySet)
      this.categories = ['全部'].concat(uniqueCategories)

      this.applyFilters()
      this.isLoading = false
    } catch (error) {
      console.error('加载收藏题目失败:', error)
      this.isLoading = false
    }
  }

  applyFilters() {
    this.filteredQuestions = this.favoriteQuestions.filter(question => {
      const categoryMatch = this.selectedCategory === '全部' || question.category === this.selectedCategory
      const difficultyMatch = this.selectedDifficulty === '全部' || question.difficulty === this.selectedDifficulty
      const searchMatch = this.searchText === '' || 
                         question.question.toLowerCase().includes(this.searchText.toLowerCase())
      
      return categoryMatch && difficultyMatch && searchMatch
    })
  }

  build() {
    Column() {
      // 顶部导航栏
      this.HeaderSection()
      
      if (this.isLoading) {
        this.LoadingSection()
      } else if (this.favoriteQuestions.length === 0) {
        this.EmptySection()
      } else {
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
      
      Text('我的收藏')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Text(`${this.favoriteQuestions.length}题`)
        .fontSize(14)
        .fontColor('#666666')
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
      Image($r('app.media.ic_favorite_empty'))
        .width(120)
        .height(120)
        .fillColor('#CCCCCC')
      
      Text('还没有收藏的题目')
        .fontSize(18)
        .fontColor('#666666')
        .margin({ top: 20 })
      
      Text('在题目详情页点击收藏按钮来收藏题目')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
      
      Button('去刷题')
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

  @Builder FilterSection() {
    Column() {
      // 搜索框
      Row() {
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
          .fillColor('#666666')
          .margin({ left: 12, right: 8 })
        
        TextInput({ placeholder: '搜索题目内容...', text: this.searchText })
          .layoutWeight(1)
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
        Text(`共找到 ${this.filteredQuestions.length} 道题目`)
          .fontSize(14)
          .fontColor('#666666')
        
        Blank()
        
        Text('按收藏时间排序')
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })

      // 题目列表
      Scroll() {
        Column() {
          ForEach(this.filteredQuestions, (question: FavoriteQuestion) => {
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

  @Builder QuestionItem(question: FavoriteQuestion) {
    Column() {
      Row() {
        // 题目信息
        Column() {
          // 题目标签
          Row() {
            this.InfoTag(question.category, '#E3F2FD', '#1976D2')
            this.InfoTag(question.difficulty, this.getDifficultyColor(question.difficulty).bg, this.getDifficultyColor(question.difficulty).text)
            this.InfoTag(question.type === 'single' ? '单选' : '多选', '#F3E5F5', '#7B1FA2')
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

        // 操作按钮
        Column() {
          Image($r('app.media.ic_favorite_filled'))
            .width(24)
            .height(24)
            .fillColor('#FF6B6B')
            .onClick(() => {
              this.removeFavorite(question.questionId)
            })
        }
        .margin({ left: 12 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      // 收藏时间
      Text(`收藏于 ${this.formatDate(question.favoriteTime)}`)
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
      // 转换FavoriteQuestion为Question格式
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
        answer: question.answer,
        explanation: question.explanation
      }
      
      router.pushUrl({
        url: 'pages/QuestionDetailPage',
        params: {
          question: questionData,
          questionList: [questionData],
          currentIndex: 0,
          fromFavorites: true
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
        return { bg: '#FFF3E0', text: '#FF9800' }
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

  async removeFavorite(questionId: number) {
    try {
      const dbManager = DatabaseManager.getInstance()
      await dbManager.removeFavorite(questionId)
      
      // 更新本地数据
      this.favoriteQuestions = this.favoriteQuestions.filter(q => q.questionId !== questionId)
      this.applyFilters()
      
      // 显示提示
      // 这里可以添加Toast提示
    } catch (error) {
      console.error('取消收藏失败:', error)
    }
  }
}