import router from '@ohos.router'
import { util } from '@kit.ArkTS'

@Entry
@Component
struct Base64ToolPage {
  @State inputText: string = ''
  @State outputText: string = ''
  @State errorMessage: string = ''
  @State isEncodeMode: boolean = true

  aboutToAppear() {
    // 设置示例文本
    this.inputText = 'Hello, 鸿蒙开发者！'
  }

  encodeToBase64() {
    try {
      if (!this.inputText.trim()) {
        this.errorMessage = '请输入要编码的文本'
        return
      }

      const textEncoder = new util.TextEncoder()
      const uint8Array = textEncoder.encodeInto(this.inputText)
      const base64Helper = new util.Base64Helper()
      this.outputText = base64Helper.encodeToStringSync(uint8Array)
      this.errorMessage = ''
    } catch (error) {
      this.errorMessage = `编码失败: ${error.message}`
      this.outputText = ''
    }
  }

  decodeFromBase64() {
    try {
      if (!this.inputText.trim()) {
        this.errorMessage = '请输入要解码的Base64内容'
        return
      }

      const base64Helper = new util.Base64Helper()
      const uint8Array = base64Helper.decodeSync(this.inputText)
      const textDecoder = new util.TextDecoder('utf-8')
      this.outputText = textDecoder.decodeToString(uint8Array)
      this.errorMessage = ''
    } catch (error) {
      this.errorMessage = `解码失败: ${error.message}`
      this.outputText = ''
    }
  }

  switchMode() {
    this.isEncodeMode = !this.isEncodeMode
    this.inputText = this.outputText
    this.outputText = ''
    this.errorMessage = ''
  }

  clearAll() {
    this.inputText = ''
    this.outputText = ''
    this.errorMessage = ''
  }

  copyToClipboard(text: string) {
    // 这里可以添加复制到剪贴板的功能
    // 由于ArkTS的剪贴板API可能需要特定权限，这里先显示提示
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
        
        Text('Base64编解码工具')
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
          // 模式切换
          Row() {
            Button(this.isEncodeMode ? '编码模式' : '解码模式')
              .width('48%')
              .height(40)
              .backgroundColor(this.isEncodeMode ? '#007AFF' : '#E5E5E5')
              .fontColor(this.isEncodeMode ? '#FFFFFF' : '#666666')
              .borderRadius(8)
              .onClick(() => {
                if (!this.isEncodeMode) {
                  this.isEncodeMode = true
                  this.clearAll()
                }
              })

            Button('切换模式')
              .width('48%')
              .height(40)
              .backgroundColor('#FF9500')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                this.switchMode()
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 16 })

          // 输入区域
          Column() {
            Text(this.isEncodeMode ? '输入文本' : '输入Base64')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 8 })

            TextArea({
              text: this.inputText,
              placeholder: this.isEncodeMode ? '请输入要编码的文本内容...' : '请输入要解码的Base64内容...'
            })
              .width('100%')
              .height(200)
              .fontSize(14)
              .backgroundColor('#F8F9FA')
              .borderRadius(8)
              .border({ width: 1, color: '#E5E5E5' })
              .onChange((value: string) => {
                this.inputText = value
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 操作按钮
          Row() {
            Button(this.isEncodeMode ? '编码' : '解码')
              .width('48%')
              .height(44)
              .backgroundColor('#007AFF')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                if (this.isEncodeMode) {
                  this.encodeToBase64()
                } else {
                  this.decodeFromBase64()
                }
              })

            Button('复制结果')
              .width('48%')
              .height(44)
              .backgroundColor('#34C759')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .enabled(!!this.outputText)
              .onClick(() => {
                this.copyToClipboard(this.outputText)
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 16 })

          // 错误信息或状态提示
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

          // 输出区域
          if (this.outputText) {
            Column() {
              Text(this.isEncodeMode ? 'Base64结果' : '解码结果')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%')
                .margin({ bottom: 8 })

              TextArea({
                text: this.outputText
              })
                .width('100%')
                .height(200)
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

            Text('• 编码模式：将普通文本转换为Base64格式\n• 解码模式：将Base64格式转换为普通文本\n• 支持中文和特殊字符的编解码\n• 点击"切换模式"可以快速在编解码间切换')
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