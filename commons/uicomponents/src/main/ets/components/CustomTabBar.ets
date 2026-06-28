@ComponentV2
export struct CustomTabBar {
  @Param currentTab: number = 0;
  @Param tabLabels: string[] = ["工作台", "数据", "工单", "我的"];
  @Param tabIcons: Resource[][] = [];
  @Event onTabChange?: (index: number) => void;

  build() {
    Stack() {
      Row() {
        ForEach(this.tabLabels, (label: string, index: number) => {
          Column() {
            if (this.tabIcons.length > index && this.tabIcons[index].length === 2) {
              Image(this.currentTab === index ? this.tabIcons[index][1] : this.tabIcons[index][0])
                .width("24vp")
                .height("24vp")
                .objectFit(ImageFit.Contain)
            }

            Text(label)
              .fontSize("12fp")
              .fontColor(this.currentTab === index ? "#007DFF" : "#999999")
              .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
              .margin({ top: this.tabIcons.length > 0 ? "2vp" : "0vp" })

            if (this.currentTab === index) {
              Divider()
                .width("24vp")
                .height("3vp")
                .color("#007DFF")
                .margin({ top: "4vp" })
            }
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .layoutWeight(1)
          .height("100%")
          .onClick(() => {
            if (this.onTabChange) {
              this.onTabChange(index);
            }
          })
        })
      }
      .width("100%")
      .height("100%")
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Center)
      .backgroundColor("#FFFFFF")
    }
    .width("100%")
    .height("56vp")
    .shadow({ radius: 8, color: "#10000000", offsetY: -2 })
  }
}
