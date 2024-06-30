import { permissions, PermissionsType } from '../entryability/PermissionsManage';
import { ImageObserved } from '../observed/ImageObserved';
import { CropView } from './CropView';

@Entry
@Component
struct Index {

    @State avatar: string = ''
    @Provide('pathStack') pathStack: NavPathStack = new NavPathStack()
    @State observed: ImageObserved = new ImageObserved()

    build() {
        Navigation(this.pathStack) {
            Column() {
                Image(this.avatar)
                    .objectFit(ImageFit.Auto)
                    .width('90%')
                    .height('80%')
                    .backgroundColor('#FEFEFE')
                    .margin(32)
                Blank()
                Button() {
                    Text('选择图片')
                        .padding(16)
                        .fontColor(Color.White)
                }
                .width('50%')
                .margin({ bottom: 64 })
                .onClick(() => this.onButton())
            }
            .width('100%')
            .height('100%')
            .backgroundColor('#fffde7')
        }
        .title('裁切图片')
        .hideBackButton(true)
        .titleMode(NavigationTitleMode.Mini)
        .navDestination(this.PageMap)
    }

    @Builder
    PageMap(name: string, params: string) {
        if (name == 'CropView') {
            CropView({ imageURL: params as string })
        }
    }

    onButton() {
        permissions(PermissionsType.readWriteMedia, status => {
            if (status) {
                this.observed.openPhotoViewPicker(image => {
                    if (image != null) {
                        this.pathStack.pushPathByName('CropView', image, (popInfo) => {
                            let avatar = popInfo.result as string
                            if (avatar) {
                                this.avatar = 'file://' + getContext().cacheDir + '/' + avatar
                            }
                        })
                    }
                })
            }else {
                // 未获得权限提示
            }
        })
    }
}