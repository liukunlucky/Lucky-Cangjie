import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { OfferModel, OfferStatus, JobType, WorkMode } from '../model/OfferModel';
import { AppButton, AppButtonType } from '../component/AppButton';
import { AppLoading } from '../component/AppLoading';
import { DatabaseManager, OfferStatistics } from '../common/DatabaseManager';

interface GroupedOffers {
  pending: OfferModel[];
  accepted: OfferModel[];
  rejected: OfferModel[];
  expired: OfferModel[];
}

@Entry
@Component
struct MyOfferPage {
  @State private offers: OfferModel[] = [];
  @State private filteredOffers: OfferModel[] = [];
  @State private groupedOffers: GroupedOffers = {
    pending: [],
    accepted: [],
    rejected: [],
    expired: []
  };
  @State private isLoading: boolean = true;
  @State private searchText: string = '';
  @State private selectedStatus: string = 'all';
  @State private selectedJobType: string = 'all';
  @State private showGroupedView: boolean = true;
  @State private statistics: OfferStatistics = {
    total: 0,
    pending: 0,
    accepted: 0,
    rejected: 0,
    expired: 0,
    avgSalary: 0,
    maxSalary: 0
  };

  private databaseManager: DatabaseManager = DatabaseManager.getInstance()

  @State private currentTab: number = 0;

  private tabTitles: string[] = ['全部', '紧急', '已收到', '待定', '已接受', '已拒绝', '已过期'];


  onPageShow() {
    // 页面显示时重新加载数据，确保从其他页面返回时数据是最新的
    this.loadData();
  }

  private async loadData(): Promise<void> {
    try {
      this.isLoading = true;
      await this.loadOffers();
      await this.calculateStatistics();
      this.filterOffers();
    } catch (error) {
      console.error('Failed to load offers:', error);
    } finally {
      this.isLoading = false;
    }
  }

  private async loadOffers(): Promise<void> {
    this.offers = await this.databaseManager.getAllOffers();
    
    // 按状态分组
    const pendingOffers = await this.databaseManager.getOffersByStatus(OfferStatus.PENDING);
    const acceptedOffers = await this.databaseManager.getOffersByStatus(OfferStatus.ACCEPTED);
    const rejectedOffers = await this.databaseManager.getOffersByStatus(OfferStatus.REJECTED);
    const expiredOffers = await this.databaseManager.getOffersByStatus(OfferStatus.EXPIRED);
    
    this.groupedOffers = {
      pending: pendingOffers,
      accepted: acceptedOffers,
      rejected: rejectedOffers,
      expired: expiredOffers
    };
  }

  private async calculateStatistics(): Promise<void> {
    this.statistics = await this.databaseManager.getOfferStats();
  }

  private filterOffers() {
    let filtered = this.offers;

    // 按状态筛选
    if (this.selectedStatus !== 'all') {
      if (this.selectedStatus === 'urgent') {
        // 紧急状态：待定且回复截止日期在7天内
        filtered = this.getUrgentOffers();
      } else {
        filtered = filtered.filter(offer => offer.status === this.selectedStatus);
      }
    }

    // 按工作类型筛选
    if (this.selectedJobType !== 'all') {
      filtered = filtered.filter(offer => offer.jobType === this.selectedJobType);
    }

    // 按搜索文本筛选
    if (this.searchText.trim()) {
      const searchLower = this.searchText.toLowerCase();
      filtered = filtered.filter(offer => 
        offer.company.toLowerCase().includes(searchLower) ||
        offer.position.toLowerCase().includes(searchLower) ||
        offer.department.toLowerCase().includes(searchLower)
      );
    }

    // 按优先级和薪资排序
    filtered.sort((a, b) => {
      const priorityDiff = b.getPriority() - a.getPriority();
      if (priorityDiff !== 0) return priorityDiff;
      return b.getTotalCompensation() - a.getTotalCompensation();
    });

    this.filteredOffers = filtered;
  }

  private onSearchTextChange(value: string) {
    this.searchText = value;
    this.filterOffers();
  }

  private onStatusFilterChange(status: string) {
    this.selectedStatus = status;
    this.filterOffers();
  }

  private onJobTypeFilterChange(jobType: string) {
    this.selectedJobType = jobType;
    this.filterOffers();
  }

  private onTabChange(index: number) {
    this.currentTab = index;
    switch (index) {
      case 0: // 全部
        this.selectedStatus = 'all';
        break;
      case 1: // 紧急
        this.selectedStatus = 'urgent';
        break;
      case 2: // 已收到
        this.selectedStatus = OfferStatus.RECEIVED;
        break;
      case 3: // 待定
        this.selectedStatus = OfferStatus.PENDING;
        break;
      case 4: // 已接受
        this.selectedStatus = OfferStatus.ACCEPTED;
        break;
      case 5: // 已拒绝
        this.selectedStatus = OfferStatus.REJECTED;
        break;
      case 6: // 已过期
        this.selectedStatus = OfferStatus.EXPIRED;
        break;
    }
    this.filterOffers();
  }

  private navigateToEdit(offer: OfferModel) {
    router.pushUrl({
      url: 'pages/AddOfferPage',
      params: { offer: offer }
    }).catch((error: Error) => {
      console.error('Failed to navigate to edit:', error);
    });
  }

  private navigateToAdd() {
    router.pushUrl({
      url: 'pages/AddOfferPage'
    }).catch((error: Error) => {
      console.error('Failed to navigate to add:', error);
    });
  }

  private navigateToComparison() {
    router.pushUrl({
      url: 'pages/OfferComparisonPage'
    }).catch((error: Error) => {
      console.error('Failed to navigate to comparison:', error);
    });
  }

  private async deleteOffer(offer: OfferModel) {
    try {
      // 从持久化数据中删除
      await this.databaseManager.deleteOffer(offer.id);
      await this.loadOffers();
      
      // 重新计算统计数据
      await this.calculateStatistics();
      
      // 重新筛选数据
      this.filterOffers();
      
      // 显示删除成功提示
      promptAction.showToast({
        message: '删除成功',
        duration: 2000
      });
    } catch (error) {
      console.error('Delete offer failed:', error);
      promptAction.showToast({
        message: '删除失败',
        duration: 2000
      });
    }
  }

  build() {
    Column() {
      // 标题栏
      this.buildHeader()
      
      if (this.isLoading) {
        this.buildLoadingState()
      } else {
        Column() {
          // 统计卡片
          this.buildStatisticsCard()
          
          // Tab栏
          this.buildTabBar()
          
          // 筛选栏
          this.buildFilterBar()
          
          // Offer列表
          this.buildOfferList()
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder
  buildHeader() {
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

      Text('我的offer')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button() {
        Image($r('app.media.icon_add'))
          .width(36)
          .height(36)
          .fillColor('#FF6B35')
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.navigateToAdd();
      })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#ffffff')
  }

  @Builder
  buildLoadingState() {
    Column({ space: 16 }) {
      AppLoading({ loadingText: '正在加载Offer信息...' })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildStatisticsCard() {
    Column({ space: 16 }) {
      Text('Offer概览')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)

      // 第一行统计
      Row({ space: 20 }) {
        this.buildStatItem('总计', this.statistics.total.toString(), '#1890ff')
        this.buildStatItem('待处理', this.statistics.pending.toString(), '#52c41a')
        this.buildStatItem('已接受', this.statistics.accepted.toString(), '#722ed1')
        this.buildStatItem('已过期', this.statistics.expired.toString(), '#ff4d4f')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)

      // 第二行统计
      Row({ space: 20 }) {
        this.buildSalaryStatItem('最高薪资', this.formatSalary(this.statistics.maxSalary), '#fa8c16')
        this.buildSalaryStatItem('平均薪资', this.formatSalary(this.statistics.avgSalary), '#13c2c2')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16, top: 12 })
    .backgroundColor('#ffffff')
    .borderRadius(8)
  }

  @Builder
  buildStatItem(title: string, value: string, color: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(title)
        .fontSize(12)
        .fontColor('#666666')
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildSalaryStatItem(title: string, value: string, color: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(title)
        .fontSize(12)
        .fontColor('#666666')
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }

  @Builder
  buildTabBar() {
    Row() {
      ForEach(this.tabTitles, (title: string, index: number) => {
        Column({ space: 4 }) {
          Text(title)
            .fontSize(14)
            .fontColor(this.currentTab === index ? '#1890ff' : '#666666')
            .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)

          if (this.currentTab === index) {
            Column()
              .width(20)
              .height(2)
              .backgroundColor('#1890ff')
              .borderRadius(1)
          }
        }
        .layoutWeight(1)
        .padding({ top: 12, bottom: 12 })
        .onClick(() => {
          this.onTabChange(index);
        })
      }, (title: string, index: number) => index.toString())
    }
    .width('100%')
    .backgroundColor('#ffffff')
    .margin({ left: 16, right: 16, top: 8 })
    .borderRadius(8)
  }

  @Builder
  buildFilterBar() {
    Column({ space: 12 }) {
      // 搜索框
      Row({ space: 12 }) {
        Image($r('app.media.icon_search'))
          .width(20)
          .height(20)

        TextInput({ placeholder: '搜索公司、职位或部门' })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('transparent')
          .border({ width: 0 })
          .onChange((value: string) => {
            this.onSearchTextChange(value);
          })
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#f8f9fa')
      .borderRadius(8)
      .visibility(Visibility.None)

      // 筛选芯片
      Row({ space: 8 }) {
        Text('类型:')
          .fontSize(14)
          .fontColor('#666666')

        this.buildJobTypeFilterChip('全部', 'all')
        this.buildJobTypeFilterChip('全职', JobType.FULL_TIME)
        this.buildJobTypeFilterChip('实习', JobType.INTERN)
        this.buildJobTypeFilterChip('兼职', JobType.PART_TIME)
      }
      .width('100%').visibility(Visibility.None)
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16, top: 8 })
    .backgroundColor('#ffffff')
    .borderRadius(8)
  }

  @Builder
  buildJobTypeFilterChip(text: string, value: string) {
    Text(text)
      .fontSize(12)
      .fontColor(this.selectedJobType === value ? '#ffffff' : '#666666')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.selectedJobType === value ? '#1890ff' : '#f0f0f0')
      .borderRadius(16)
      .onClick(() => {
        this.onJobTypeFilterChange(value);
      })
  }

  @Builder
  buildOfferList() {
    if (this.currentTab === 1) {
      // 紧急处理Tab
      List({ space: 8 }) {
        ForEach(this.getUrgentOffers(), (offer: OfferModel) => {
          ListItem() {
            this.buildUrgentOfferCard(offer)
          }
          .swipeAction({ end: this.buildSwipeAction(offer) })
        }, (offer: OfferModel) => offer.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8 })
    } else {
      // 其他Tab
      if (this.filteredOffers.length === 0) {
        this.buildEmptyState('暂无Offer记录')
      } else {
        List({ space: 8 }) {
          ForEach(this.filteredOffers, (offer: OfferModel) => {
            ListItem() {
              this.buildOfferCard(offer)
            }
            .swipeAction({ end: this.buildSwipeAction(offer) })
          }, (offer: OfferModel) => offer.id.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8 })
      }
    }
  }



  @Builder
  buildUrgentOfferCard(offer: OfferModel) {
    Column({ space: 12 }) {
      // 紧急标识
      Row() {
        Text('🚨 紧急处理')
          .fontSize(12)
          .fontColor('#ffffff')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#ff4d4f')
          .borderRadius(12)

        Blank()

        Text(offer.getRemainingDaysText())
          .fontSize(12)
          .fontColor('#ff4d4f')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')

      this.buildOfferCardContent(offer)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .border({ width: 2, color: '#ff4d4f' })
    .onClick(() => {
      this.navigateToEdit(offer);
    })
  }

  @Builder
  buildOfferCard(offer: OfferModel) {
    Column({ space: 12 }) {
      this.buildOfferCardContent(offer)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .onClick(() => {
      this.navigateToEdit(offer);
    })
  }

  @Builder
  buildOfferCardContent(offer: OfferModel) {
    Column({ space: 12 }) {
      // 头部信息
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text(offer.company)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text(offer.position)
            .fontSize(14)
            .fontColor('#666666')

          if (offer.department) {
            Text(offer.department)
              .fontSize(12)
              .fontColor('#999999')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 4 }) {
          Text(offer.getStatusText())
            .fontSize(12)
            .fontColor('#ffffff')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(offer.getStatusColor())
            .borderRadius(12)

          Text(offer.getSalaryLevel())
            .fontSize(12)
            .fontColor('#ffffff')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(offer.getSalaryLevelColor())
            .borderRadius(12)
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      // 薪资信息
      Row({ space: 16 }) {
        Column({ space: 4 }) {
          Text('总包薪资')
            .fontSize(12)
            .fontColor('#666666')

          Text(offer.getFormattedTotalCompensation())
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1890ff')
        }
        .alignItems(HorizontalAlign.Start)

        if (offer.stockOptions) {
          Column({ space: 4 }) {
            Text('股票期权')
              .fontSize(12)
              .fontColor('#666666')

            Text('有')
              .fontSize(14)
              .fontColor('#52c41a')
          }
          .alignItems(HorizontalAlign.Start)
        }

        Blank()

        Column({ space: 4 }) {
          Text(offer.getJobTypeText())
            .fontSize(12)
            .fontColor('#666666')

          Text(offer.getWorkModeText())
            .fontSize(12)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      // 地点和时间
      Row({ space: 16 }) {
        if (offer.location) {
          Row({ space: 4 }) {
            Image($r('app.media.map_icon'))
              .width(16)
              .height(16)

            Text(offer.location)
              .fontSize(12)
              .fontColor('#666666')
          }
        }

        if (offer.offerDate) {
          Row({ space: 4 }) {
            Image($r('app.media.calendar_icon'))
              .width(16)
              .height(16)

            Text(offer.getFormattedDate(offer.offerDate))
              .fontSize(12)
              .fontColor('#666666')
          }
        }

        Blank()

        if (offer.satisfactionScore > 0) {
          Text(offer.getSatisfactionStars())
            .fontSize(12)
            .fontColor('#faad14')
        }
      }
      .width('100%')

      // 备注
      if (offer.notes) {
        Text(offer.notes)
          .fontSize(12)
          .fontColor('#999999')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
  }

  @Builder
  buildEmptyState(message: string) {
    Column({ space: 16 }) {
      Image($r('app.media.icon_empty'))
        .width(58)
        .height(42)
        .opacity(0.5)

      Text(message)
        .fontSize(16)
        .fontColor('#999999')

      AppButton({
        buttonText: '添加Offer',
        type: AppButtonType.PRIMARY,
        onButtonClick: () => {
          this.navigateToAdd();
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  private formatSalary(amount: number): string {
    if (amount === 0) return '0';
    return `${amount.toFixed(1)}万`;
  }

  @Builder
  buildSwipeAction(offer: OfferModel) {
    Row() {
      Button() {
        Column() {
          Image($r('app.media.icon_delete'))
            .width(24)
            .height(24)
            .fillColor('#FF6B35')
          Text('删除')
            .fontSize(12)
            .fontColor('#FF6B35')
            .margin({ top: 4 })
        }
      }
      .width(80)
      .backgroundColor(Color.Transparent)
      .height('100%')
      .borderRadius(0)
      .onClick(() => {
        AlertDialog.show({
          title: '确认删除',
          message: '确定要删除这个记录吗？\n删除后无法恢复。',
          primaryButton: {
            value: '取消',
            action: () => {
              console.info('取消删除');
            }
          },
          secondaryButton: {
            value: '删除',
            fontColor: '#FF4444',
            action: () => {
              this.deleteOffer(offer);
            }
          }
        });
      })
    }
    .height('100%')
  }

  private getUrgentOffers(): OfferModel[] {
    return this.offers.filter(offer => {
      if (offer.status === OfferStatus.PENDING && offer.responseDate) {
        const deadline = new Date(offer.responseDate);
        const now = new Date();
        const diffDays = Math.ceil((deadline.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
        return diffDays <= 7 && diffDays >= 0;
      }
      return false;
    });
  }
}