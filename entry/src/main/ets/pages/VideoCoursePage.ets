import { router } from "@kit.ArkUI";

interface TutorialItem {
  id: number;
  title: string;
  description: string;
  videoSrc: string;
  thumbnail: string;
}

interface VideoState {
  isPlaying: boolean;
  currentTime: number;
  totalTime: number;
  controller: VideoController;
}

@Entry
@Component
struct VideoCoursePage {

  @State videoStates: Map<number, VideoState> = new Map();

  // 教程视频数据
  @State tutorials: TutorialItem[] = [
    {
      id: 1,
      title: '仓颉编程语言入门教程',
      description: '主讲人：仓颉编程语言布道师 - 刘俊杰',
      videoSrc: 'video/video1.mp4',
      thumbnail: 'video/video1.png'
    },
    {
      id: 2,
      title: '仓颉程序设计01课',
      description: '描述：仓颉程序设计语言快速入门',
      videoSrc: 'video/video2.mp4',
      thumbnail: 'video/video2.png'
    }
  ];

  aboutToAppear() {
    // 为每个视频初始化状态
    this.tutorials.forEach(tutorial => {
      this.videoStates.set(tutorial.id, {
        isPlaying: false,
        currentTime: 0,
        totalTime: 0,
        controller: new VideoController()
      });
    });
  }

  // 获取指定视频的状态
  getVideoState(videoId: number): VideoState {
    return this.videoStates.get(videoId) || {
      isPlaying: false,
      currentTime: 0,
      totalTime: 0,
      controller: new VideoController()
    };
  }

  // 更新指定视频的状态
  updateVideoState(videoId: number, updates: Partial<VideoState>) {
    const currentState = this.getVideoState(videoId);
    const newState: VideoState = {
      isPlaying: updates.isPlaying !== undefined ? updates.isPlaying : currentState.isPlaying,
      currentTime: updates.currentTime !== undefined ? updates.currentTime : currentState.currentTime,
      totalTime: updates.totalTime !== undefined ? updates.totalTime : currentState.totalTime,
      controller: updates.controller !== undefined ? updates.controller : currentState.controller
    };
    this.videoStates.set(videoId, newState);
    // 触发状态更新
    const newMap = new Map<number, VideoState>();
    this.videoStates.forEach((value, key) => {
      newMap.set(key, value);
    });
    this.videoStates = newMap;
  }

  // 格式化时间显示
  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  build() {
    Column() {
      // 顶部导航栏
      this.HeaderSection()
      
      // 教程列表
      List() {
        ForEach(this.tutorials, (tutorial: TutorialItem) => {
          ListItem() {
            Column() {
              // 视频标题
              Row() {
                Text(tutorial.title)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.primary_text_color'))
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 12 })

              // 视频播放器容器
              Stack({ alignContent: Alignment.Center }) {
                Video({
                  src: $rawfile(tutorial.videoSrc),
                  previewUri: $rawfile(tutorial.thumbnail),
                  controller: this.getVideoState(tutorial.id).controller
                })
                  .width('100%')
                  .height(200)
                  .autoPlay(false)
                  .controls(false)
                  .borderRadius(8)
                  .backgroundColor($r('app.color.card_background_color'))
                  .onStart(() => {
                    this.updateVideoState(tutorial.id, { isPlaying: true });
                  })
                  .onPause(() => {
                    this.updateVideoState(tutorial.id, { isPlaying: false });
                  })
                  .onFinish(() => {
                    this.updateVideoState(tutorial.id, { isPlaying: false, currentTime: 0 });
                  })
                  .onUpdate((event) => {
                    if (event) {
                      this.updateVideoState(tutorial.id, { currentTime: event.time });
                    }
                  })
                  .onPrepared((event) => {
                    if (event) {
                      this.updateVideoState(tutorial.id, { totalTime: event.duration });
                    }
                  })

                // 自定义播放控制按钮
                if (!this.getVideoState(tutorial.id).isPlaying) {
                  Button() {
                    Image($r('app.media.ic_play'))
                      .width(24)
                      .height(24)
                      .fillColor(Color.White)
                  }
                  .width(60)
                  .height(60)
                  .backgroundColor('rgba(0, 0, 0, 0.6)')
                  .borderRadius(30)
                  .onClick(() => {
                    this.getVideoState(tutorial.id).controller.start();
                  })
                }
              }
              .width('100%')
              .onClick(() => {
                const videoState = this.getVideoState(tutorial.id);
                if (videoState.isPlaying) {
                  videoState.controller.pause();
                } else {
                  videoState.controller.start();
                }
              })

              // 播放进度条
              if (this.getVideoState(tutorial.id).totalTime > 0) {
                Column() {
                  Row() {
                    Text(this.formatTime(this.getVideoState(tutorial.id).currentTime))
                      .fontSize(12)
                      .fontColor($r('app.color.secondary_text_color'))

                    Slider({
                      value: this.getVideoState(tutorial.id).currentTime,
                      min: 0,
                      max: this.getVideoState(tutorial.id).totalTime,
                      step: 1
                    })
                      .layoutWeight(1)
                      .margin({ left: 8, right: 8 })
                      .trackColor($r('app.color.background_color'))
                      .selectedColor($r('app.color.brand_color'))
                      .blockColor($r('app.color.brand_color'))
                      .onChange((value: number) => {
                        this.getVideoState(tutorial.id).controller.setCurrentTime(value);
                      })

                    Text(this.formatTime(this.getVideoState(tutorial.id).totalTime))
                      .fontSize(12)
                      .fontColor($r('app.color.secondary_text_color'))
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                }
                .width('100%')
                .margin({ top: 8 })
              }

              // 视频描述
              Text(tutorial.description)
                .fontSize(14)
                .fontColor($r('app.color.secondary_text_color'))
                .width('100%')
                .margin({ top: 12 })
                .lineHeight(20)
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.card_background_color'))
            .borderRadius(12)
            .shadow({ radius: 2, color: $r('app.color.shadow_color'), offsetX: 0, offsetY: 1 })
          }
          .margin({ bottom: 16 })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_color'))
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

      Text('视频课程')
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
  }
}