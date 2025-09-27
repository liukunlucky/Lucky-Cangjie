import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'

class ArticleData {
  id: number = 0
  title: string = ''
  summary: string = ''
  content: string = ''
  author: string = ''
  publishDate: string = ''
  readCount: number = 0
  likeCount: number = 0
  category: string = ''
  tags: string[] = []
  coverImage?: string
  hasCode: boolean = false
  difficulty: string = 'beginner'
  estimatedReadTime: number = 0
}

@Entry
@Component
struct ArticleDetailPage {
  @State article: ArticleData | null = null
  @State isLiked: boolean = false
  @State isFavorited: boolean = false
  @State showCodeCopyTip: boolean = false

  aboutToAppear() {
    const params = router.getParams()
    if (params) {
      try {
        const articleData: Record<string, Object> = JSON.parse(JSON.stringify(params))
        if (articleData.article) {
          this.article = articleData.article as ArticleData
        }
      } catch (error) {
        console.error('Failed to parse article data:', error)
      }
    }
  }

  getDifficultyColor(difficulty: string): string {
    switch (difficulty) {
      case 'beginner': return '#4CAF50'
      case 'intermediate': return '#FF9800'
      case 'advanced': return '#F44336'
      default: return '#666666'
    }
  }

  getDifficultyText(difficulty: string): string {
    switch (difficulty) {
      case 'beginner': return '入门'
      case 'intermediate': return '进阶'
      case 'advanced': return '高级'
      default: return '未知'
    }
  }

  formatContent(content: string): string {
    // 简单的Markdown渲染处理
    return content
      .replace(/^# (.*$)/gm, '<h1>$1</h1>')
      .replace(/^## (.*$)/gm, '<h2>$1</h2>')
      .replace(/^### (.*$)/gm, '<h3>$1</h3>')
      .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
      .replace(/\*(.*?)\*/g, '<em>$1</em>')
      .replace(/`(.*?)`/g, '<code>$1</code>')
      .replace(/```[\s\S]*?```/g, (match) => {
        return `<pre><code>${match.replace(/```\w*\n?/, '').replace(/```$/, '')}</code></pre>`
      })
  }

  copyCodeBlock(code: string) {
    // 这里应该实现复制到剪贴板的功能
    this.showCodeCopyTip = true
    setTimeout(() => {
      this.showCodeCopyTip = false
    }, 2000)
  }

  build() {
    Column() {
      if (this.article) {
        // 顶部导航栏
        this.HeaderSection()
        
        // 文章内容
        Scroll() {
          Column() {
            // 文章头部信息
            this.ArticleHeaderSection()
            
            // 文章正文
            this.ArticleContentSection()

          }
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      } else {
        this.ErrorSection()
      }
      
      // 复制提示
      if (this.showCodeCopyTip) {
        this.CopyTipOverlay()
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
      
      Text('文章详情')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Blank().width(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
  }

  @Builder ArticleHeaderSection() {
    Column() {
      // 封面图片
      if (this.article!.coverImage) {
        Image(this.article!.coverImage)
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)
          .margin({ bottom: 16 })
          .alt('文章封面')
      }
      
      // 标题
      Text(this.article!.title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .lineHeight(32)
        .width('100%')
        .margin({ bottom: 12 })
      
      // 文章信息
      Row() {
        // 难度标识
        Text(this.getDifficultyText(this.article!.difficulty))
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(this.getDifficultyColor(this.article!.difficulty))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(10)
          .margin({ right: 12 })
        
        // 分类
        Text(this.article!.category)
          .fontSize(12)
          .fontColor('#007AFF')
          .backgroundColor('#F0F8FF')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(8)
          .margin({ right: 12 })
        
        Blank()
        
        // 阅读时间
        Row() {
          Image($r('app.media.ic_time'))
            .width(14)
            .height(14)
            .fillColor('#999999')
            .margin({ right: 4 })
          
          Text(`${this.article!.estimatedReadTime}分钟`)
            .fontSize(12)
            .fontColor('#999999')
        }
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 作者和发布信息
      Row() {
        Text(`作者：${this.article!.author}`)
          .fontSize(14)
          .fontColor('#666666')
          .layoutWeight(1)
        
        Text(this.article!.publishDate)
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 标签
      if (this.article!.tags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.article!.tags, (tag: string) => {
            Text(`#${tag}`)
              .fontSize(12)
              .fontColor('#007AFF')
              .backgroundColor('#F0F8FF')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(8)
              .margin({ right: 8, bottom: 8 })
          })
        }
        .width('100%')
        .margin({ bottom: 20 })
      }
      
      // 分割线
      Divider()
        .color('#E5E5E5')
        .margin({ bottom: 20 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(16)
    .margin({ top: 16, bottom: 16 })
  }

  @Builder ArticleContentSection() {
    Column() {
      // 这里应该实现Markdown渲染，暂时用简单的文本显示
      Text(this.article!.content)
        .fontSize(16)
        .fontColor('#333333')
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(16)
    .margin({ bottom: 16 })
  }

  @Builder BottomActionSection() {
    Column() {
      // 统计信息
      Row() {
        Row() {
          Image($r('app.media.ic_statistics'))
            .width(16)
            .height(16)
            .fillColor('#999999')
            .margin({ right: 4 })
          
          Text(`${this.article!.readCount} 阅读`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .margin({ right: 24 })
        
        Row() {
          Image($r('app.media.ic_favorite'))
            .width(16)
            .height(16)
            .fillColor('#999999')
            .margin({ right: 4 })
          
          Text(`${this.article!.likeCount} 点赞`)
            .fontSize(14)
            .fontColor('#666666')
        }
        
        Blank()
      }
      .width('100%')
      .margin({ bottom: 20 })
      
      // 操作按钮
      Row() {
        Button() {
          Row() {
            Image(this.isLiked ? $r('app.media.ic_favorite_filled') : $r('app.media.ic_favorite'))
              .width(20)
              .height(20)
              .fillColor(this.isLiked ? '#FF6B6B' : '#666666')
              .margin({ right: 8 })
            
            Text(this.isLiked ? '已点赞' : '点赞')
              .fontSize(16)
              .fontColor(this.isLiked ? '#FF6B6B' : '#666666')
          }
        }
        .backgroundColor(this.isLiked ? '#FFF0F0' : '#F8F9FA')
        .borderRadius(24)
        .border({ width: 1, color: this.isLiked ? '#FF6B6B' : '#E5E5E5' })
        .layoutWeight(1)
        .height(48)
        .onClick(() => {
          this.isLiked = !this.isLiked
          promptAction.showToast({ 
            message: this.isLiked ? '点赞成功' : '已取消点赞' 
          })
        })
        
        Button() {
          Row() {
            Image($r('app.media.ic_note'))
              .width(20)
              .height(20)
              .fillColor('#666666')
              .margin({ right: 8 })
            
            Text('评论')
              .fontSize(16)
              .fontColor('#666666')
          }
        }
        .backgroundColor('#F8F9FA')
        .borderRadius(24)
        .border({ width: 1, color: '#E5E5E5' })
        .layoutWeight(1)
        .height(48)
        .margin({ left: 12 })
        .onClick(() => {
          promptAction.showToast({ message: '评论功能开发中' })
        })
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(16)
  }

  @Builder ErrorSection() {
    Column() {
      Image($r('app.media.ic_settings'))
        .width(80)
        .height(80)
        .fillColor('#CCCCCC')
        .margin({ bottom: 16 })
      
      Text('文章加载失败')
        .fontSize(18)
        .fontColor('#666666')
        .margin({ bottom: 8 })
      
      Text('请返回重试')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 24 })
      
      Button('返回')
        .backgroundColor('#007AFF')
        .borderRadius(24)
        .width(120)
        .height(40)
        .onClick(() => {
          router.back()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder CopyTipOverlay() {
    Stack() {
      Text('代码已复制到剪贴板')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor('#333333')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .borderRadius(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#80000000')
    .alignContent(Alignment.Center)
  }
}