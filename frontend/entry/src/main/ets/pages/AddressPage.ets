import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { HttpUtil } from '../utils/HttpUtil'

interface AddressItem {
  id: number
  userId: number
  receiverName: string
  receiverPhone: string
  province: string
  city: string
  district: string
  detailAddress: string
  postalCode: string
  isDefault: number
}

interface AddressFormData {
  receiverName: string
  receiverPhone: string
  province: string
  city: string
  district: string
  detailAddress: string
  postalCode: string
  isDefault: boolean
}

interface AddressSubmitData {
  id?: number
  receiverName: string
  receiverPhone: string
  province: string
  city: string
  district: string
  detailAddress: string
  postalCode: string
  isDefault: number
}

interface AddressPageParams {
  mode?: string
  currentAddressId?: number
}

@Entry
@ComponentV2
struct AddressPage {
  @Local addressList: AddressItem[] = []
  @Local isLoading: boolean = false
  @Local showAddSheet: boolean = false
  @Local showDeleteDialog: boolean = false
  @Local deleteTargetId: number = -1

  @Local formData: AddressFormData = {
    receiverName: '',
    receiverPhone: '',
    province: '',
    city: '',
    district: '',
    detailAddress: '',
    postalCode: '',
    isDefault: false
  }

  @Local editingId: number = -1
  @Local formTitle: string = '新增收货地址'

  // ✅ 新增：选择模式相关状态
  @Local selectMode: boolean = false // 是否为选择模式（从订单确认页进入）
  @Local currentAddressId: number = 0 // 当前已选中的地址ID（用于高亮显示）

  async aboutToAppear() {
    // ✅ 检查是否为选择模式
    const params: AddressPageParams | undefined =
      router.getParams() as AddressPageParams | undefined;
    
    if (params && params.mode === 'select') {
      this.selectMode = true;
      console.info('✅ [AddressPage] 进入选择模式');
      
      if (params.currentAddressId && params.currentAddressId > 0) {
        this.currentAddressId = params.currentAddressId;
        console.info('✅ [AddressPage] 当前选中地址ID:', this.currentAddressId);
      }
    }
    
    await this.loadAddressList()
  }

  async loadAddressList() {
    this.isLoading = true
    try {
      const token: string = await (await import('../utils/StorageUtil')).StorageUtil.getToken()
      console.info('🔍 [AddressPage] 当前Token:', token ? '存在(' + token.substring(0, 20) + '...)' : '❌ 空值')
      
      console.info('🔍 [AddressPage] 开始请求地址列表...')
      const addressData: AddressItem[] = await HttpUtil.request<AddressItem[]>({
        method: 'GET',
        path: '/api/address/list'
      })
      
      console.info('🔍 [AddressPage] 地址数据:', JSON.stringify(addressData))
      console.info('🔍 [AddressPage] 地址数量:', addressData ? addressData.length : 0)
      
      this.addressList = addressData || []
      
      if (this.addressList.length === 0) {
        console.warn('⚠️ [AddressPage] 地址列表为空！可能原因：1.未登录 2.Token无效 3.后端返回空数据 4.数据库无数据')
      }
    } catch (e) {
      console.error('❌ [AddressPage] 加载地址列表失败:', e)
      console.error('❌ [AddressPage] 错误详情:', JSON.stringify(e))
      promptAction.showToast({ message: '加载失败' })
    } finally {
      this.isLoading = false
    }
  }


  resetForm(): void {
    this.formData = {
      receiverName: '',
      receiverPhone: '',
      province: '',
      city: '',
      district: '',
      detailAddress: '',
      postalCode: '',
      isDefault: false
    }
  }

  openAddForm() {
    this.editingId = -1
    this.resetForm()
    this.formTitle = '新增收货地址'
    this.showAddSheet = true
  }

  openEditForm(item: AddressItem) {
    this.editingId = item.id
    this.formData.receiverName = item.receiverName
    this.formData.receiverPhone = item.receiverPhone
    this.formData.province = item.province
    this.formData.city = item.city
    this.formData.district = item.district
    this.formData.detailAddress = item.detailAddress
    this.formData.postalCode = item.postalCode || ''
    this.formData.isDefault = item.isDefault === 1
    this.formTitle = '编辑收货地址'
    this.showAddSheet = true
  }

  validateForm(): boolean {
    if (!this.formData.receiverName || this.formData.receiverName.trim() === '') {
      promptAction.showToast({ message: '请输入收件人姓名' })
      return false
    }
    if (!this.formData.receiverPhone || !/^1[3-9]\d{9}$/.test(this.formData.receiverPhone)) {
      promptAction.showToast({ message: '请输入正确的手机号' })
      return false
    }
    if (!this.formData.province || !this.formData.city || !this.formData.district) {
      promptAction.showToast({ message: '请选择省市区' })
      return false
    }
    if (!this.formData.detailAddress || this.formData.detailAddress.trim() === '') {
      promptAction.showToast({ message: '请输入详细地址' })
      return false
    }
    return true
  }

  async saveAddress() {
    if (!this.validateForm()) {
      return
    }

    try {
      const submitData: AddressSubmitData = {
        receiverName: this.formData.receiverName.trim(),
        receiverPhone: this.formData.receiverPhone.trim(),
        province: this.formData.province.trim(),
        city: this.formData.city.trim(),
        district: this.formData.district.trim(),
        detailAddress: this.formData.detailAddress.trim(),
        postalCode: this.formData.postalCode.trim(),
        isDefault: this.formData.isDefault ? 1 : 0
      }

      if (this.editingId > 0) {
        const submitDataWithId: AddressSubmitData = {
          id: this.editingId,
          receiverName: this.formData.receiverName.trim(),
          receiverPhone: this.formData.receiverPhone.trim(),
          province: this.formData.province.trim(),
          city: this.formData.city.trim(),
          district: this.formData.district.trim(),
          detailAddress: this.formData.detailAddress.trim(),
          postalCode: this.formData.postalCode.trim(),
          isDefault: this.formData.isDefault ? 1 : 0
        }
        await HttpUtil.request<void>({
          method: 'PUT',
          path: '/api/address/update',
          body: submitDataWithId
        })
        promptAction.showToast({ message: '修改成功' })
      } else {
        await HttpUtil.request<void>({
          method: 'POST',
          path: '/api/address/add',
          body: submitData
        })
        promptAction.showToast({ message: '添加成功' })
      }

      this.showAddSheet = false
      await this.loadAddressList()
      
    } catch (e) {
      console.error('保存地址失败:', e)
      const errorMsg: string = e instanceof Error ? e.message : '操作失败'
      promptAction.showToast({ message: `操作失败: ${errorMsg}` })
    }
  }

  confirmDelete(id: number) {
    this.deleteTargetId = id
    this.showDeleteDialog = true
  }

  async executeDelete() {
    try {
      await HttpUtil.request<void>({
        method: 'DELETE',
        path: `/api/address/${this.deleteTargetId}`
      })
      promptAction.showToast({ message: '删除成功' })
      this.showDeleteDialog = false
      await this.loadAddressList()
    } catch (e) {
      console.error('删除地址失败:', e)
      promptAction.showToast({ message: '删除失败' })
    }
  }

  async setAsDefault(id: number) {
    try {
      await HttpUtil.request<void>({
        method: 'PUT',
        path: `/api/address/setDefault/${id}`
      })
      promptAction.showToast({ message: '已设为默认地址' })
      await this.loadAddressList()
    } catch (e) {
      console.error('设置默认地址失败:', e)
      promptAction.showToast({ message: '设置失败' })
    }
  }

  build() {
    Column() {
      this.buildNavigationBar()
      
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (this.addressList.length === 0) {
        this.buildEmptyView()
      } else {
        this.buildAddressListView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet($$this.showAddSheet, this.buildAddressForm(), {
      height: '70%',
      dragBar: true,
      backgroundColor: '#FFFFFF',
      onDisappear: () => {
        console.info('地址表单关闭')
      }
    })
  }

  @Builder
  buildNavigationBar() {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .width(24)
        .height(24)
        .fontColor(['#333333', '#FFFFFF'])
        .onClick(() => {
          if (this.selectMode) {
            // ✅ 选择模式下：返回上一页（不携带数据）
            router.back();
          } else {
            router.back()
          }
        })

      Text(this.selectMode ? '选择收货地址' : '收货地址管理')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // ✅ 选择模式和管理模式都显示"新增地址"按钮
      Text('+ 新增')
        .fontSize(14)
        .fontColor('#FF2D55')
        .onClick(() => {
          this.openAddForm()
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .color('#FF2D55')
        .width(40)
        .height(40)
      Text('加载中...')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmptyView() {
    Column() {
      Text('📍')
        .fontSize(60)
      if (this.selectMode) {
        Text('暂无收货地址')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 20 })
        Text('请先添加收货地址后再选择')
          .fontSize(13)
          .fontColor('#BBBBBB')
          .margin({ top: 8 })

        // ✅ 新增：空状态下的新增按钮
        Button('+ 新增收货地址')
          .width('80%')
          .height(44)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF2D55')
          .borderRadius(22)
          .margin({ top: 30 })
          .onClick(() => {
            this.openAddForm()
          })
      } else {
        Text('暂无收货地址')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 20 })
        Text('点击右上角添加您的第一个收货地址')
          .fontSize(13)
          .fontColor('#BBBBBB')
          .margin({ top: 8 })
      }
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * ✅ 新增：选择地址并返回上一页
   */
  private selectAndReturn(addressId: number): void {
    console.info('✅ [AddressPage] 选择地址ID:', addressId);
    
    // 返回上一页并携带选中的地址ID
    router.back({
      url: 'pages/ConfirmOrderPage',
      params: {
        addressId: addressId
      }
    });
  }

  @Builder
  buildAddressListView() {
    List({ space: 12 }) {
      ForEach(this.addressList, (item: AddressItem) => {
        ListItem() {
          this.buildAddressCard(item)
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding(16)
    .alignListItem(ListItemAlign.Start)
  }

  @Builder
  buildAddressCard(item: AddressItem) {
    Column() {
      // ✅ 选择模式下：显示支持编辑的卡片
      if (this.selectMode) {
        this.buildSelectableAddressCard(item)
      } else {
        this.buildManageableAddressCard(item)
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(16)
    .shadow({
      radius: 8,
      color: '#12000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  /**
   * ✅ 新增：选择模式的地址卡片UI（支持编辑）
   */
  @Builder
  buildSelectableAddressCard(item: AddressItem) {
    Column() {
      Row() {
        // ✅ 选中状态指示器
        Column() {
          if (this.currentAddressId === item.id) {
            Text('✓')
              .fontSize(12)
              .fontColor('#FFFFFF')
          }
        }
        .width(22)
        .height(22)
        .borderRadius(11)
        .backgroundColor(this.currentAddressId === item.id ? '#FF2D55' : '#E5E5EA')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Row() {
            Text(`${item.receiverName} ${item.receiverPhone}`)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')

            Blank()

            if (item.isDefault === 1) {
              Text('默认')
                .fontSize(11)
                .fontColor('#FF2D55')
                .backgroundColor('#FFF0F3')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(4)
            }
          }
          .width('100%')

          Text(`${item.province}${item.city}${item.district}${item.detailAddress}`)
            .fontSize(13)
            .fontColor('#666666')
            .margin({ top: 8 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .width(16)
          .height(16)
          .fontColor(['#CCCCCC', '#FFFFFF'])
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // ✅ 新增：操作按钮栏（编辑 + 选择）
      Row() {
        Button('编辑')
          .type(ButtonType.Normal)
          .fontSize(13)
          .fontColor('#FF2D55')
          .backgroundColor('#FFFFFF')
          .height(32)
          .onClick(() => {
            this.openEditForm(item)
          })

        Blank()

        Button(this.currentAddressId === item.id ? '已选择' : '选择此地址')
          .type(ButtonType.Normal)
          .fontSize(13)
          .fontColor(this.currentAddressId === item.id ? '#FFFFFF' : '#FF2D55')
          .backgroundColor(this.currentAddressId === item.id ? '#FF2D55' : '#FFFFFF')
          .height(32)
          .onClick(() => {
            this.selectAndReturn(item.id);
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
  }

  /**
   * 管理模式的地址卡片UI（原有逻辑）
   */
  @Builder
  buildManageableAddressCard(item: AddressItem) {
    Column() {
      Row() {
        Text(`${item.receiverName} ${item.receiverPhone}`)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Blank()

        if (item.isDefault === 1) {
          Text('默认')
            .fontSize(11)
            .fontColor('#FF2D55')
            .backgroundColor('#FFF0F3')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(4)
        }
      }
      .width('100%')

      Text(`${item.province}${item.city}${item.district}${item.detailAddress}`)
        .fontSize(13)
        .fontColor('#666666')
        .margin({ top: 8 })
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Divider()
        .strokeWidth(1)
        .color('#EEEEEE')
        .margin({ top: 12 })

      Row() {
        Button('编辑')
          .type(ButtonType.Normal)
          .fontSize(13)
          .fontColor('#FF2D55')
          .backgroundColor('#FFFFFF')
          .height(32)
          .onClick(() => {
            this.openEditForm(item)
          })

        Blank()

        Button('删除')
          .type(ButtonType.Normal)
          .fontSize(13)
          .fontColor('#FF3B30')
          .backgroundColor('#FFFFFF')
          .height(32)
          .onClick(() => {
            this.confirmDelete(item.id)
          })

        if (item.isDefault !== 1) {
          Blank()
          Button('设为默认')
            .type(ButtonType.Normal)
            .fontSize(13)
            .fontColor('#FF2D55')
            .backgroundColor('#FFFFFF')
            .height(32)
            .onClick(() => {
              this.setAsDefault(item.id)
            })
        }
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(16)
    .shadow({
      radius: 8,
      color: '#12000000',
      offsetX: 0,
      offsetY: 1
    })
  }

  @Builder
  buildAddressForm() {
    Column() {
      Text(this.formTitle)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 24 })
      
      Scroll() {
        Column({ space: 20 }) {
          this.buildFormItem('收件人姓名', '请输入姓名', this.formData.receiverName, 
            (value: string) => { this.formData.receiverName = value })
          
          this.buildFormItem('联系电话', '请输入手机号', this.formData.receiverPhone,
            (value: string) => { this.formData.receiverPhone = value })
          
          this.buildFormItem('省份', '请输入省份', this.formData.province,
            (value: string) => { this.formData.province = value })
          
          this.buildFormItem('城市', '请输入城市', this.formData.city,
            (value: string) => { this.formData.city = value })
          
          this.buildFormItem('区/县', '请输入区县', this.formData.district,
            (value: string) => { this.formData.district = value })
          
          this.buildFormItem('详细地址', '街道/门牌号', this.formData.detailAddress,
            (value: string) => { this.formData.detailAddress = value }, true)
          
          this.buildFormItem('邮政编码', '选填', this.formData.postalCode,
            (value: string) => { this.formData.postalCode = value })
          
          Row() {
            Text('设为默认地址')
              .fontSize(15)
              .fontColor('#333333')
            
            Toggle({ type: ToggleType.Switch, isOn: this.formData.isDefault })
              .onChange((isOn: boolean) => {
                this.formData.isDefault = isOn
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
        }
        .padding({ bottom: 20 })
      }
      .layoutWeight(1)
      
      Button(this.editingId > 0 ? '保存修改' : '保存地址')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF2D55')
        .borderRadius(24)
        .onClick(() => {
          this.saveAddress()
        })
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 30 })
  }

  @Builder
  buildFormItem(label: string, placeholder: string, currentValue: string, 
                onChange: (value: string) => void, multiLine?: boolean) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
      
      TextInput({ text: currentValue, placeholder: placeholder })
        .width('100%')
        .height(multiLine ? 80 : 44)
        .fontSize(14)
        .fontColor('#333333')
        .placeholderColor('#CCCCCC')
        .backgroundColor('#F8F8F8')
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          onChange(value)
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
