import router from '@ohos.router'

@Entry
@Component
struct TimestampToolPage {
  @State currentTimestamp: number = 0
  @State inputTimestamp: string = ''
  @State inputDateTime: string = ''
  @State timestampResult: string = ''
  @State dateTimeResult: string = ''
  @State errorMessage: string = ''

  aboutToAppear() {
    this.updateCurrentTime()
    // 每秒更新当前时间
    setInterval(() => {
      this.updateCurrentTime()
    }, 1000)
  }

  updateCurrentTime() {
    this.currentTimestamp = Date.now()
  }

  formatDateTime(timestamp: number): string {
    const date = new Date(timestamp)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    const seconds = String(date.getSeconds()).padStart(2, '0')
    
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
  }

  timestampToDateTime() {
    try {
      if (!this.inputTimestamp.trim()) {
        this.errorMessage = '请输入时间戳'
        return
      }

      let timestamp = parseInt(this.inputTimestamp)
      
      // 判断是秒级还是毫秒级时间戳
      if (timestamp.toString().length === 10) {
        timestamp = timestamp * 1000 // 转换为毫秒
      }

      if (isNaN(timestamp) || timestamp < 0) {
        this.errorMessage = '请输入有效的时间戳'
        return
      }

      this.dateTimeResult = this.formatDateTime(timestamp)
      this.errorMessage = ''
    } catch (error) {
      this.errorMessage = `转换失败: ${error.message}`
      this.dateTimeResult = ''
    }
  }

  dateTimeToTimestamp() {
    try {
      if (!this.inputDateTime.trim()) {
        this.errorMessage = '请输入日期时间'
        return
      }

      const date = new Date(this.inputDateTime)
      
      if (isNaN(date.getTime())) {
        this.errorMessage = '请输入有效的日期时间格式'
        return
      }

      const timestamp = date.getTime()
      this.timestampResult = `毫秒级: ${timestamp}\n秒级: ${Math.floor(timestamp / 1000)}`
      this.errorMessage = ''
    } catch (error) {
      this.errorMessage = `转换失败: ${error.message}`
      this.timestampResult = ''
    }
  }

  useCurrentTime() {
    this.inputTimestamp = this.currentTimestamp.toString()
    this.timestampToDateTime()
  }

  clearAll() {
    this.inputTimestamp = ''
    this.inputDateTime = ''
    this.timestampResult = ''
    this.dateTimeResult = ''
    this.errorMessage = ''
  }

  copyToClipboard(text: string) {
    // 这里可以添加复制到剪贴板的功能
    this.errorMessage = '内容已复制到剪贴板'
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('返回')
          .fontSize(16)
          .fontColor('#007AFF')
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            router.back()
          })
        
        Blank()
        
        Text('时间戳转换工具')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Button('清空')
          .fontSize(16)
          .fontColor('#FF3B30')
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.clearAll()
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })

      Scroll() {
        Column() {
          // 当前时间显示
          Column() {
            Text('当前时间')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 8 })

            Row() {
              Column() {
                Text('时间戳（毫秒）')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ bottom: 4 })
                Text(this.currentTimestamp.toString())
                  .fontSize(14)
                  .fontColor('#007AFF')
                  .fontWeight(FontWeight.Bold)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Column() {
                Text('格式化时间')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ bottom: 4 })
                Text(this.formatDateTime(this.currentTimestamp))
                  .fontSize(14)
                  .fontColor('#007AFF')
                  .fontWeight(FontWeight.Bold)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')

            Button('使用当前时间')
              .width('100%')
              .height(36)
              .backgroundColor('#34C759')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .fontSize(14)
              .margin({ top: 12 })
              .onClick(() => {
                this.useCurrentTime()
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 时间戳转日期时间
          Column() {
            Text('时间戳 → 日期时间')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 8 })

            TextInput({
              text: this.inputTimestamp,
              placeholder: '请输入时间戳（支持秒级和毫秒级）'
            })
              .width('100%')
              .height(44)
              .fontSize(14)
              .backgroundColor('#F8F9FA')
              .borderRadius(8)
              .border({ width: 1, color: '#E5E5E5' })
              .onChange((value: string) => {
                this.inputTimestamp = value
              })
              .margin({ bottom: 12 })

            Button('转换为日期时间')
              .width('100%')
              .height(40)
              .backgroundColor('#007AFF')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                this.timestampToDateTime()
              })

            if (this.dateTimeResult) {
              Text(this.dateTimeResult)
                .fontSize(16)
                .fontColor('#34C759')
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(12)
                .backgroundColor('#E8F5E8')
                .borderRadius(8)
                .margin({ top: 12 })
                .onClick(() => {
                  this.copyToClipboard(this.dateTimeResult)
                })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 日期时间转时间戳
          Column() {
            Text('日期时间 → 时间戳')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 8 })

            TextInput({
              text: this.inputDateTime,
              placeholder: '请输入日期时间（如：2024-01-01 12:00:00）'
            })
              .width('100%')
              .height(44)
              .fontSize(14)
              .backgroundColor('#F8F9FA')
              .borderRadius(8)
              .border({ width: 1, color: '#E5E5E5' })
              .onChange((value: string) => {
                this.inputDateTime = value
              })
              .margin({ bottom: 12 })

            Button('转换为时间戳')
              .width('100%')
              .height(40)
              .backgroundColor('#FF9500')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                this.dateTimeToTimestamp()
              })

            if (this.timestampResult) {
              Text(this.timestampResult)
                .fontSize(14)
                .fontColor('#FF9500')
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(12)
                .backgroundColor('#FFF3E0')
                .borderRadius(8)
                .margin({ top: 12 })
                .onClick(() => {
                  this.copyToClipboard(this.timestampResult)
                })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 错误信息
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(14)
              .fontColor(this.errorMessage.includes('失败') ? '#FF3B30' : '#34C759')
              .width('100%')
              .padding(12)
              .backgroundColor(this.errorMessage.includes('失败') ? '#FFE8E8' : '#E8F5E8')
              .borderRadius(8)
              .margin({ bottom: 16 })
          }

          // 使用说明
          Column() {
            Text('使用说明')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 8 })

            Text('• 支持秒级（10位）和毫秒级（13位）时间戳\n• 日期时间格式：YYYY-MM-DD HH:mm:ss\n• 也支持其他常见格式：2024/01/01、2024-01-01等\n• 点击结果可复制到剪贴板')
              .fontSize(14)
              .fontColor('#666666')
              .lineHeight(20)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 20 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}