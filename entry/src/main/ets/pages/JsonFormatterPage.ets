import router from '@ohos.router'

@Entry
@Component
struct JsonFormatterPage {
  @State inputJson: string = ''
  @State outputJson: string = ''
  @State errorMessage: string = ''
  @State isValid: boolean = true

  aboutToAppear() {
    // 设置示例JSON
    this.inputJson = '{"name":"张三","age":25,"skills":["JavaScript","TypeScript","ArkTS"],"address":{"city":"北京","district":"朝阳区"}}'
  }

  formatJson() {
    try {
      if (!this.inputJson.trim()) {
        this.errorMessage = '请输入JSON内容'
        this.isValid = false
        return
      }

      const parsed: object = JSON.parse(this.inputJson)
      this.outputJson = JSON.stringify(parsed, null, 2)
      this.errorMessage = ''
      this.isValid = true
    } catch (error) {
      this.errorMessage = `JSON格式错误: ${error.message}`
      this.isValid = false
      this.outputJson = ''
    }
  }

  compressJson() {
    try {
      if (!this.inputJson.trim()) {
        this.errorMessage = '请输入JSON内容'
        this.isValid = false
        return
      }

      const parsed: object = JSON.parse(this.inputJson)
      this.outputJson = JSON.stringify(parsed)
      this.errorMessage = ''
      this.isValid = true
    } catch (error) {
      this.errorMessage = `JSON格式错误: ${error.message}`
      this.isValid = false
      this.outputJson = ''
    }
  }

  validateJson() {
    try {
      if (!this.inputJson.trim()) {
        this.errorMessage = '请输入JSON内容'
        this.isValid = false
        return
      }

      JSON.parse(this.inputJson)
      this.errorMessage = 'JSON格式正确 ✓'
      this.isValid = true
      this.outputJson = ''
    } catch (error) {
      this.errorMessage = `JSON格式错误: ${error.message}`
      this.isValid = false
      this.outputJson = ''
    }
  }

  clearAll() {
    this.inputJson = ''
    this.outputJson = ''
    this.errorMessage = ''
    this.isValid = true
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
        
        Text('JSON格式化工具')
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
          // 输入区域
          Column() {
            Text('输入JSON')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 8 })

            TextArea({
              text: this.inputJson,
              placeholder: '请输入要格式化的JSON内容...'
            })
              .width('100%')
              .height(200)
              .fontSize(14)
              .backgroundColor('#F8F9FA')
              .borderRadius(8)
              .border({ width: 1, color: '#E5E5E5' })
              .onChange((value: string) => {
                this.inputJson = value
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 操作按钮
          Row() {
            Button('格式化')
              .width('30%')
              .height(40)
              .backgroundColor('#007AFF')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                this.formatJson()
              })

            Button('压缩')
              .width('30%')
              .height(40)
              .backgroundColor('#34C759')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                this.compressJson()
              })

            Button('验证')
              .width('30%')
              .height(40)
              .backgroundColor('#FF9500')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                this.validateJson()
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 16 })

          // 错误信息或状态提示
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(14)
              .fontColor(this.isValid ? '#34C759' : '#FF3B30')
              .width('100%')
              .padding(12)
              .backgroundColor(this.isValid ? '#E8F5E8' : '#FFE8E8')
              .borderRadius(8)
              .margin({ bottom: 16 })
          }

          // 输出区域
          if (this.outputJson) {
            Column() {
              Text('格式化结果')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%')
                .margin({ bottom: 8 })

              TextArea({
                text: this.outputJson
              })
                .width('100%')
                .height(300)
                .fontSize(14)
                .backgroundColor('#F8F9FA')
                .borderRadius(8)
                .border({ width: 1, color: '#E5E5E5' })
                .enabled(false)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
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

            Text('• 格式化：将JSON内容美化，增加缩进和换行\n• 压缩：移除JSON中的空格和换行，减小体积\n• 验证：检查JSON格式是否正确')
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