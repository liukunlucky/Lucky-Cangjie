import { router } from '@kit.ArkUI';
import { DatabaseManager } from '../common/DatabaseManager';
import { OfferModel, OfferStatus } from '../model/OfferModel';

@Entry
@Component
struct OfferComparisonPage {
  @State selectedOffers: OfferModel[] = [];
  @State allOffers: OfferModel[] = [];
  @State showOfferSelector: boolean = false;
  @State isLoading: boolean = true;
  @State tempSelectedOffers: OfferModel[] = []; // 临时选择状态，用于弹窗中的选择
  private databaseManager: DatabaseManager = DatabaseManager.getInstance()


  aboutToAppear() {
    this.loadOffers();
  }

  private async loadOffers() {
    try {
      this.isLoading = true;
      // 获取所有offer，不限制状态
      this.allOffers = await this.databaseManager.getAllOffers();
      
      // 默认选择前两个Offer进行对比
      if (this.allOffers.length >= 2) {
        this.selectedOffers = [this.allOffers[0], this.allOffers[1]];
      }
    } catch (error) {
      console.error('Failed to load offers:', error);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          Image($r('app.media.icon_back'))
            .width(24)
            .height(24)
            .fillColor('#333333')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Text('Offer对比')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)

      Divider()
        .color('#F1F3F5')

      if (this.isLoading) {
        // 加载状态
        Column({ space: 16 }) {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#007DFF')

          Text('正在加载Offer数据...')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.allOffers.length === 0) {
        // 没有可对比的offer
        Column({ space: 16 }) {
          Image($r('app.media.icon_vs'))
            .width(80)
            .height(80)
            .fillColor('#CCCCCC')

          Text('暂无可对比的Offer')
            .fontSize(16)
            .fontColor('#999999')

          Text('请先添加一些待定或已接受的Offer')
            .fontSize(14)
            .fontColor('#CCCCCC')

          Button('去添加Offer')
            .backgroundColor('#007DFF')
            .fontColor('#FFFFFF')
            .borderRadius(20)
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddOfferPage' });
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.selectedOffers.length === 0) {
        // 有offer但未选择
        Column({ space: 16 }) {
          Image($r('app.media.icon_vs'))
            .width(80)
            .height(80)

          Text('请选择要对比的Offer')
            .fontSize(16)
            .fontColor('#999999')

          Button('选择Offer')
            .backgroundColor('#007DFF')
            .fontColor('#FFFFFF')
            .borderRadius(20)
            .onClick(() => {
              this.tempSelectedOffers = [...this.selectedOffers]; // 初始化临时选择状态
              this.showOfferSelector = true;
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 对比内容
        Scroll() {
          Column({ space: 16 }) {
            // Offer选择器
            this.buildOfferSelector()

            // 基本信息对比
            this.buildBasicComparisonSection()

            // 薪资对比
            this.buildSalaryComparisonSection()

            // 工作信息对比
            this.buildWorkComparisonSection()

            // 福利对比
            this.buildBenefitsComparisonSection()

            // 综合评分
            this.buildScoreComparisonSection()
          }
          .padding(16)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .bindSheet($$this.showOfferSelector, this.buildOfferSelectorSheet(), {
      height: 400,
      dragBar: true
    })
  }

  @Builder
  buildOfferSelector() {
    Row({ space: 12 }) {
      ForEach(this.selectedOffers, (offer: OfferModel, index: number) => {
        Column({ space: 4 }) {
          Text(offer.company)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(offer.position)
            .fontSize(12)
            .fontColor('#666666')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Button() {
            Image($r('sys.media.ohos_ic_public_cancel'))
              .width(12)
              .height(12)
              .fillColor('#999999')
          }
          .width(20)
          .height(20)
          .backgroundColor('#F0F0F0')
          .borderRadius(10)
          .onClick(() => {
            this.selectedOffers = this.selectedOffers.filter((_, i) => i !== index);
          })
        }
        .width(0)
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Center)
      }, (offer: OfferModel) => offer.id.toString())

      if (this.selectedOffers.length < 2) {
        Button() {
          Image($r('sys.media.ohos_ic_public_add'))
            .width(20)
            .height(20)
            .fillColor('#007DFF')
        }
        .width(60)
        .height(60)
        .backgroundColor('#E3F2FD')
        .borderRadius(8)
        .onClick(() => {
          this.tempSelectedOffers = [...this.selectedOffers]; // 初始化临时选择状态
          this.showOfferSelector = true;
        })
      }
    }
    .width('100%')
  }

  @Builder
  buildBasicComparisonSection() {
    Column({ space: 12 }) {
      Text('基本信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .alignSelf(ItemAlign.Start)

      Column() {
        this.buildBasicComparison()
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(16)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildSalaryComparisonSection() {
    Column({ space: 12 }) {
      Text('薪资对比')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .alignSelf(ItemAlign.Start)

      Column() {
        this.buildSalaryComparison()
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(16)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildWorkComparisonSection() {
    Column({ space: 12 }) {
      Text('工作信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .alignSelf(ItemAlign.Start)

      Column() {
        this.buildWorkComparison()
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(16)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildBenefitsComparisonSection() {
    Column({ space: 12 }) {
      Text('福利对比')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .alignSelf(ItemAlign.Start)

      Column() {
        this.buildBenefitsComparison()
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(16)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildScoreComparisonSection() {
    Column({ space: 12 }) {
      Text('综合评分')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .alignSelf(ItemAlign.Start)

      Column() {
        this.buildScoreComparison()
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(16)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildBasicComparison() {
    this.buildComparisonRow('公司', (offer: OfferModel) => offer.company)
    this.buildComparisonRow('职位', (offer: OfferModel) => offer.position)
    this.buildComparisonRow('工作地点', (offer: OfferModel) => offer.location || '-')
    this.buildComparisonRow('状态', (offer: OfferModel) => this.getStatusText(offer.status))
  }

  @Builder
  buildSalaryComparison() {
    this.buildComparisonRow('基本薪资', (offer: OfferModel) => `${offer.baseSalary}万/年`)
    this.buildComparisonRow('年终奖', (offer: OfferModel) => `${offer.bonus}万`)
    this.buildComparisonRow('股票期权', (offer: OfferModel) => `${offer.stockOptions}万`)
    this.buildComparisonRow('总薪资', (offer: OfferModel) => `${offer.getTotalCompensation().toFixed(1)}万/年`, true)
  }

  @Builder
  buildWorkComparison() {
    this.buildComparisonRow('入职日期', (offer: OfferModel) => offer.startDate || '-')
    this.buildComparisonRow('截止日期', (offer: OfferModel) => offer.expiryDate || '-')
  }

  @Builder
  buildBenefitsComparison() {
    Row({ space: 16 }) {
      ForEach(this.selectedOffers, (offer: OfferModel, index: number) => {
        Column({ space: 4 }) {
          Text(`${offer.company} 福利`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')

          if (offer.benefits && offer.benefits.length > 0) {
            Text(`• ${offer.benefits}`)
              .fontSize(12)
              .fontColor('#666666')
              .alignSelf(ItemAlign.Center)
          } else {
            Text('暂无福利信息')
              .fontSize(12)
              .fontColor('#999999')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }, (offer: OfferModel) => offer.id.toString())
    }
    .width('100%')
  }

  @Builder
  buildScoreComparison() {
    Row({ space: 16 }) {
      ForEach(this.selectedOffers, (offer: OfferModel) => {
        Column({ space: 8 }) {
          Text(offer.company)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')

          // 简单的评分算法
          Text(`${this.calculateOfferScore(offer)}分`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.calculateOfferScore(offer) >= 80 ? '#4CAF50' : this.calculateOfferScore(offer) >= 60 ? '#FF9800' : '#F44336')

          Progress({ value: this.calculateOfferScore(offer), total: 100 })
            .width(80)
            .height(8)
            .color(this.calculateOfferScore(offer) >= 80 ? '#4CAF50' : this.calculateOfferScore(offer) >= 60 ? '#FF9800' : '#F44336')
            .backgroundColor('#E0E0E0')

          Text(this.getScoreLevel(this.calculateOfferScore(offer)))
            .fontSize(12)
            .fontColor('#666666')
        }
        .width(0)
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }, (offer: OfferModel) => offer.id.toString())
    }
    .width('100%')
  }

  @Builder
  buildComparisonRow(label: string, valueExtractor: (offer: OfferModel) => string, highlight: boolean = false) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .width(80)

      Row({ space: 16 }) {
        ForEach(this.selectedOffers, (offer: OfferModel, index: number) => {
          Text(valueExtractor(offer))
            .fontSize(14)
            .fontColor(highlight ? '#FF6B35' : '#182431')
            .fontWeight(highlight ? FontWeight.Medium : FontWeight.Normal)
            .width(0)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }, (offer: OfferModel) => offer.id.toString())
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height(40)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildOfferSelectorSheet() {
    Column({ space: 16 }) {
      Text('选择要对比的Offer')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')

      Text('最多可选择2个Offer进行对比')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 8 })

      List({ space: 8 }) {
        ForEach(this.allOffers, (offer: OfferModel) => {
          ListItem() {
            Row({ space: 12 }) {
              Checkbox()
                .select(this.tempSelectedOffers.some(selected => selected.id === offer.id))
                .enabled(this.tempSelectedOffers.length < 2 || this.tempSelectedOffers.some(selected => selected.id === offer.id))
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    if (this.tempSelectedOffers.length < 2 && !this.tempSelectedOffers.some(selected => selected.id === offer.id)) {
                      this.tempSelectedOffers = [...this.tempSelectedOffers, offer];
                    }
                  } else {
                    this.tempSelectedOffers = this.tempSelectedOffers.filter(selected => selected.id !== offer.id);
                  }
                })

              Column({ space: 4 }) {
                Text(offer.company)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#182431')
                  .alignSelf(ItemAlign.Start)

                Text(offer.position)
                  .fontSize(14)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.Start)

                Text(`${offer.getTotalCompensation().toFixed(1)}万/年`)
                  .fontSize(14)
                  .fontColor('#FF6B35')
                  .alignSelf(ItemAlign.Start)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
          }
        }, (offer: OfferModel) => offer.id.toString())
      }
      .layoutWeight(1)

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .borderRadius(8)
          .onClick(() => {
            this.showOfferSelector = false;
          })

        Button('确定')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .onClick(() => {
            this.selectedOffers = [...this.tempSelectedOffers]; // 确定时才更新实际选择
            this.showOfferSelector = false;
          })
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }

  private getStatusText(status: OfferStatus): string {
    switch (status) {
      case OfferStatus.PENDING:
        return '待处理';
      case OfferStatus.ACCEPTED:
        return '已接受';
      case OfferStatus.REJECTED:
        return '已拒绝';
      case OfferStatus.EXPIRED:
        return '已过期';
      default:
        return '未知';
    }
  }

  private calculateOfferScore(offer: OfferModel): number {
    // 简单的评分算法，可以根据实际需求调整
    let score = 0;
    
    // 薪资评分 (40%)
    const salaryScore = Math.min(offer.getTotalCompensation() / 500000 * 40, 40);
    score += salaryScore;
    
    // 公司评分 (30%) - 这里可以根据公司知名度等因素评分
    const companyScore = 25; // 默认给25分
    score += companyScore;
    
    // 福利评分 (20%)
    const benefitsScore = (offer.benefits?.length || 0) * 4;
    score += Math.min(benefitsScore, 20);
    
    // 其他因素 (10%)
    const otherScore = 10;
    score += otherScore;
    
    return Math.round(score);
  }

  private getScoreLevel(score: number): string {
    if (score >= 90) return '优秀';
    if (score >= 80) return '良好';
    if (score >= 70) return '一般';
    if (score >= 60) return '较差';
    return '很差';
  }
}