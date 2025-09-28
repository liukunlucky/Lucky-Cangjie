import { router, promptAction } from '@kit.ArkUI';
import { DatabaseManager } from '../common/DatabaseManager';
import { OfferModel, OfferStatus } from '../model/OfferModel';

interface SelectOption<T> {
  label: string;
  value: T;
}

interface OfferRouteParams {
  offer?: OfferModel;
}

@Entry
@Component
struct AddOfferPage {
  @State companyName: string = '';
  @State jobPosition: string = '';
  @State baseSalary: number = 0;
  @State bonus: number = 0;
  @State stockOptions: number = 0;
  @State benefits: string = '';
  @State workLocation: string = '';
  @State startDate: string = '';
  @State expiryDate: string = '';
  @State status: OfferStatus = OfferStatus.PENDING;
  @State notes: string = '';
  @State workingHours: string = '';
  @State vacationDays: number = 0;

  
  // 编辑模式相关状态
  @State isEditMode: boolean = false;
  private editingOffer: OfferModel | null = null;
  
  // 选择器弹窗状态
  @State showStatusDialog: boolean = false;
  private databaseManager: DatabaseManager = DatabaseManager.getInstance()

  private statusOptions: Array<SelectOption<OfferStatus>> = [
    { label: '待定', value: OfferStatus.PENDING },
    { label: '已收到', value: OfferStatus.RECEIVED },
    { label: '已接受', value: OfferStatus.ACCEPTED },
    { label: '已拒绝', value: OfferStatus.REJECTED },
    { label: '已过期', value: OfferStatus.EXPIRED }
  ];

  aboutToAppear() {
    // 检查是否是编辑模式
    const params = router.getParams() as OfferRouteParams;
    if (params && params.offer) {
      this.isEditMode = true;
      this.editingOffer = params.offer;
      this.loadOfferData(params.offer);
    }
  }

  private loadOfferData(offer: OfferModel) {
    this.companyName = offer.company || '';
    this.jobPosition = offer.position || '';
    this.baseSalary = offer.baseSalary || 0;
    this.bonus = offer.bonus || 0;
    this.stockOptions = Number(offer.stockOptions) || 0;
    this.benefits = offer.benefits || '';
    this.workLocation = offer.location || '';
    this.startDate = offer.startDate || '';
    this.expiryDate = offer.expiryDate || '';
    this.status = offer.status || OfferStatus.PENDING;
    this.notes = offer.notes || '';
    this.workingHours = offer.workingHours || '';
    this.vacationDays = offer.vacationDays || 0;
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

        Text(this.isEditMode ? '编辑Offer' : '添加Offer')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button() {
          Text('保存')
            .fontSize(16)
            .fontColor('#007DFF')
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.saveOffer();
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)

      Divider()
        .color('#F1F3F5')

      // 表单内容
      Scroll() {
        Column({ space: 20 }) {
          // 基本信息
          this.buildSectionWithBasicInfo()

          // 薪资信息
          this.buildSectionWithSalaryInfo()

          // 工作信息
          this.buildSectionWithWorkInfo()

          // 公司信息
          // this.buildSectionWithCompanyInfo()

          // 其他信息
          this.buildSectionWithOtherInfo()
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .bindSheet($$this.showStatusDialog, this.buildStatusSheet(), {
      height: 300,
      showClose: true,
      dragBar: true
    })
    

  }

  @Builder
  buildSectionWithBasicInfo() {
    Column({ space: 12 }) {
      Text('基本信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .alignSelf(ItemAlign.Start)

      Column({ space: 16 }) {
        this.buildBasicInfo()
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(16)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildSectionWithSalaryInfo() {
    Column({ space: 12 }) {
      Text('薪资信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .alignSelf(ItemAlign.Start)

      Column({ space: 16 }) {
        this.buildSalaryInfo()
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(16)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildSectionWithWorkInfo() {
    Column({ space: 12 }) {
      Text('工作信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .alignSelf(ItemAlign.Start)

      Column({ space: 16 }) {
        this.buildWorkInfo()
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(16)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildSectionWithCompanyInfo() {
    Column({ space: 12 }) {
      Text('公司信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .alignSelf(ItemAlign.Start)

      Column({ space: 16 }) {
        this.buildCompanyInfo()
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(16)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildSectionWithOtherInfo() {
    Column({ space: 12 }) {
      Text('其他信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .alignSelf(ItemAlign.Start)

      Column({ space: 16 }) {
        this.buildOtherInfo()
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(16)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildBasicInfo() {
    this.buildInputItem('公司名称', this.companyName, (value: string) => {
      this.companyName = value;
    }, true)

    this.buildInputItem('职位', this.jobPosition, (value: string) => {
          this.jobPosition = value;
    }, true)

    this.buildSelectItem('Offer状态', this.statusOptions, (value: OfferStatus) => {
      this.status = value;
    })
  }

  @Builder
  buildSalaryInfo() {
    this.buildSalaryItem('基本薪资(万/年)', this.baseSalary, (value: number) => {
      this.baseSalary = value;
    })

    this.buildSalaryItem('年终奖(万)', this.bonus, (value: number) => {
      this.bonus = value;
    })

    this.buildSalaryItem('股票期权(万)', this.stockOptions, (value: number) => {
      this.stockOptions = value;
    })

    Row() {
      Text('总薪资: ')
        .fontSize(14)
        .fontColor('#666666')

      Text(`${(this.baseSalary + this.bonus + this.stockOptions).toFixed(1)}万/年`)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FF6B35')
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  buildWorkInfo() {
    this.buildInputItem('工作地点', this.workLocation, (value: string) => {
      this.workLocation = value;
    })

    this.buildDateItem('入职日期', (value: string) => {
      this.startDate = value;
    })

    this.buildDateItem('Offer截止日期', (value: string) => {
      this.expiryDate = value;
    })

    this.buildInputItem('工作时间', this.workingHours, (value: string) => {
      this.workingHours = value;
    })

    this.buildNumberItem('年假天数', this.vacationDays, (value: number) => {
      this.vacationDays = value;
    })
  }

  @Builder
  buildCompanyInfo() {
    // 暂时移除公司规模和行业字段，因为OfferModel中没有这些属性
    Text('公司信息功能待完善')
      .fontSize(14)
      .fontColor('#999999')
      .textAlign(TextAlign.Center)
      .width('100%')
      .height(40)
  }

  @Builder
  buildOtherInfo() {
    this.buildTextAreaItem('福利待遇', this.benefits, (value: string) => {
      this.benefits = value;
    })

    this.buildTextAreaItem('备注', this.notes, (value: string) => {
      this.notes = value;
    })
  }

  @Builder
  buildInputItem(label: string, value: string, onChange: (value: string) => void, required: boolean = false) {
    Column({ space: 8 }) {
      Row() {
        Text(label)
          .fontSize(14)
          .fontColor('#666666')
        if (required) {
          Text(' *')
            .fontSize(14)
            .fontColor('#FF0000')
        }
      }
      .alignSelf(ItemAlign.Start)

      TextInput({ placeholder: `请输入${label}`, text: value })
        .width('100%')
        .height(44)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          onChange(value);
        })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildSalaryItem(label: string, value: number, onChange: (value: number) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)

      TextInput({ placeholder: `请输入${label}`, text: value > 0 ? value.toString() : '' })
        .width('100%')
        .height(44)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .type(InputType.Number)
        .onChange((value: string) => {
          const num = parseFloat(value) || 0;
          onChange(num);
        })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildNumberItem(label: string, value: number, onChange: (value: number) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)

      TextInput({ placeholder: `请输入${label}`, text: value > 0 ? value.toString() : '' })
        .width('100%')
        .height(44)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .type(InputType.Number)
        .onChange((value: string) => {
          const num = parseInt(value) || 0;
          onChange(num);
        })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildSelectItem<T>(label: string, options: Array<SelectOption<T>>, onChange: (value: T) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)

      Row() {
        Text(options.find(option => option.value === this.status)?.label || '请选择')
          .fontSize(16)
          .fontColor('#182431')
          .layoutWeight(1)

        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(16)
          .height(16)
          .fillColor('#999999')
      }
      .width('100%')
      .height(44)
      .backgroundColor('#F8F9FA')
      .borderRadius(8)
      .padding({ left: 12, right: 12 })
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        if (label === 'Offer状态') {
          this.showStatusDialog = true;
        }
      })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildDateItem(label: string, onChange: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)

      Row() {
        Text(label === '入职日期' ? 
          (this.startDate || '请选择日期') :
          label === 'Offer截止日期' ? 
          (this.expiryDate || '请选择日期') :
          '请选择日期')
          .fontSize(16)
          .fontColor(label === '入职日期' ? 
            (this.startDate ? '#182431' : '#999999') :
            label === 'Offer截止日期' ? 
            (this.expiryDate ? '#182431' : '#999999') :
            '#999999')
          .layoutWeight(1)

        Image($r('app.media.icon_rl'))
          .width(16)
          .height(16)
          .fillColor('#999999')
      }
      .width('100%')
      .height(44)
      .backgroundColor('#F8F9FA')
      .borderRadius(8)
      .padding({ left: 12, right: 12 })
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        if (label === '入职日期') {
          DatePickerDialog.show({
            start: new Date('2020-01-01'),
            end: new Date('2030-12-31'),
            selected: this.startDate ? new Date(this.startDate) : new Date(),
            onAccept: (value: DatePickerResult) => {
              // DatePickerResult的month实际上是从0开始的（与JavaScript Date一致）
              const date = new Date(value.year!, value.month!, value.day!);
              this.startDate = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
            }
          });
        } else if (label === 'Offer截止日期') {
          DatePickerDialog.show({
            start: new Date('2020-01-01'),
            end: new Date('2030-12-31'),
            selected: this.expiryDate ? new Date(this.expiryDate) : new Date(),
            onAccept: (value: DatePickerResult) => {
              // DatePickerResult的month实际上是从0开始的（与JavaScript Date一致）
              const date = new Date(value.year!, value.month!, value.day!);
              this.expiryDate = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
            }
          });
        }
      })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildTextAreaItem(label: string, value: string, onChange: (value: string) => void) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)

      TextArea({ placeholder: `请输入${label}`, text: value })
        .width('100%')
        .height(80)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          onChange(value);
        })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildStatusSheet() {
    Column({ space: 16 }) {
      Text('选择Offer状态')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16, bottom: 8 })

      ForEach(this.statusOptions, (option: SelectOption<OfferStatus>) => {
        Row() {
          Text(option.label)
            .fontSize(16)
            .fontColor('#182431')
            .layoutWeight(1)
          
          if (this.status === option.value) {
            Image($r('sys.media.ohos_ic_public_ok'))
              .width(20)
              .height(20)
              .fillColor('#007DFF')
          }
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.status = option.value;
          this.showStatusDialog = false;
        })
      })
    }
    .width('100%')
    .padding(16)
  }

  private async saveOffer() {
    // 验证必填字段
    const trimmedCompanyName = this.companyName?.trim();
    const trimmedJobPosition = this.jobPosition?.trim();
    
    if (!trimmedCompanyName) {
      promptAction.showToast({
        message: '请填写公司名称',
        duration: 2000
      });
      return;
    }
    
    if (!trimmedJobPosition) {
      promptAction.showToast({
        message: '请填写职位名称',
        duration: 2000
      });
      return;
    }

    try {

      if (this.isEditMode && this.editingOffer) {
        // 编辑模式：更新现有Offer
        const updatedOffer = new OfferModel();
        // 保留原有的ID和时间戳
        updatedOffer.id = this.editingOffer.id;
        updatedOffer.createdAt = this.editingOffer.createdAt;
        updatedOffer.updatedAt = new Date().toISOString();
        
        // 更新表单数据
        updatedOffer.company = trimmedCompanyName;
        updatedOffer.position = trimmedJobPosition;
        updatedOffer.baseSalary = this.baseSalary;
        updatedOffer.bonus = this.bonus;
        updatedOffer.stockOptions = this.stockOptions.toString();
        updatedOffer.benefits = this.benefits?.trim() || '';
        updatedOffer.location = this.workLocation?.trim() || '';
        updatedOffer.startDate = this.startDate;
        updatedOffer.expiryDate = this.expiryDate;
        updatedOffer.status = this.status;
        updatedOffer.notes = this.notes?.trim() || '';
        updatedOffer.workingHours = this.workingHours?.trim() || '';
        updatedOffer.vacationDays = this.vacationDays;
        
        await this.databaseManager.updateOffer(updatedOffer);
        console.log('Offer更新成功:', updatedOffer);
        
        promptAction.showToast({
          message: 'Offer信息更新成功',
          duration: 2000
        });
      } else {
        // 新增模式：创建新Offer
        const newOffer = new OfferModel();
        newOffer.id = Date.now(); // 简单的ID生成
        newOffer.company = trimmedCompanyName;
        newOffer.position = trimmedJobPosition;
        newOffer.baseSalary = this.baseSalary;
        newOffer.bonus = this.bonus;
        newOffer.stockOptions = this.stockOptions.toString();
        newOffer.benefits = this.benefits?.trim() || '';
        newOffer.location = this.workLocation?.trim() || '';
        newOffer.startDate = this.startDate;
        newOffer.expiryDate = this.expiryDate;
        newOffer.status = this.status;
        newOffer.notes = this.notes?.trim() || '';
        newOffer.workingHours = this.workingHours?.trim() || '';
        newOffer.vacationDays = this.vacationDays;
        
        // 设置Offer发放日期为当前日期
        newOffer.offerDate = new Date().toISOString().split('T')[0];
        
        await this.databaseManager.insertOffer(newOffer);
        console.log('Offer保存成功:', newOffer);
        
        promptAction.showToast({
          message: 'Offer信息保存成功',
          duration: 2000
        });
      }
      
      // 返回上一页
      router.back();
    } catch (error) {
      console.error('保存Offer失败:', error);
      promptAction.showToast({
        message: '保存失败，请重试',
        duration: 2000
      });
    }
  }
}