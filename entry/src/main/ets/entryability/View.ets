@Builder
export function LoadingButton(width: Length = '100%', height: number = 56, enabled: boolean = false) {

    Button() {
        LoadingProgress()
            .color(Color.White)
            .height(32)
            .width(32)
    }
    .width(width)
    .height(height)
    .backgroundColor($r('app.color.primary'))
    .enabled(enabled)
    .border({width: 1, color: '#fb8c00'})
}

@Builder
export function TitleText(title: string, hideBackButton: boolean = false, menu: boolean = false) {
    Row() {
        Text(title)
            .fontSize(20)
            .textAlign(TextAlign.Center)
            .size({width: '100%', height: 56})
            .maxLines(1)
            .textOverflow({overflow: TextOverflow.Ellipsis})
    }
    .height('100%')
    .margin({right: hideBackButton ? (menu ? -72 : 0) : 64})
    .alignSelf(ItemAlign.Center)
}