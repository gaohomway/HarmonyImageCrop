import { LoadingButton, TitleText } from '../entryability/View'
import CropObserved from './CropObserved'

@Entry
@Component
export struct CropView {

    @State avatar: string = ''
    @State imageURL: string = ''
    @State observed: CropObserved = new CropObserved()
    @Consume('pathStack') pathStack: NavPathStack

    private settings: RenderingContextSettings = new RenderingContextSettings(true)
    private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

    build() {
        NavDestination() {
            Stack({alignContent: Alignment.Bottom}) {
                Stack() {
                    CropImageView({observed: this.observed })
                    RoundHoleView({context: this.context, action: (width) => {
                        this.observed.holeWidth = width
                    }})
                }
                .padding({bottom: 48})
                MiniToolbarView({ observed: this.observed })
                CropToolbarView({ cropLoading: this.observed.cropLoading, action: action => {
                    this.onToolbar(action)
                }})
            }
            .width('100%')
            .height('100%')
        }
        .title(TitleText('编辑头像'))
        .backgroundColor(Color.Black)
    }

    aboutToAppear() {
        setTimeout(() => {
            this.observed.getPixel(this.imageURL)
        }, 100)
    }

    onToolbar(action: number) {
        if (action == 0) {
            this.pathStack.pop()
        }else {
            this.observed.crop(filename => {
                this.pathStack.pop(filename)
            })
        }
    }
}

@Component
struct CropImageView {

    @State offsetX: number = 0;
    @State offsetY: number = 0;

    @ObjectLink observed: CropObserved

    build() {
        Stack() {
            Image(this.observed.pixelMap)
                .width(this.observed.imageSize.width)
                .height(this.observed.imageSize.height)
                .translate({ x: this.offsetX, y: this.offsetY})
                .gesture(PanGesture().onActionStart((event: GestureEvent|undefined) => {
                    console.info('Pan start');
                }).onActionUpdate((event: GestureEvent|undefined) => {
                    if(event){
                        this.offsetX = this.observed.positionX + event.offsetX
                        this.offsetY = this.observed.positionY + event.offsetY
                    }
                }).onActionEnd(() => this.onEnd()))
        }
    }

    onEnd() {
        animateTo({duration: 200}, () => {
            if (this.observed.horizontalImage) {
                this.offsetY = 0
                let excess = this.calculateExcess()
                this.offsetX = Math.min(Math.max(this.offsetX, -excess), excess)
            }else {
                this.offsetX = 0
                let excess = this.calculateExcess()
                this.offsetY = Math.min(Math.max(this.offsetY, -excess), excess)
            }
            this.observed.positionX = this.offsetX;
            this.observed.positionY = this.offsetY;
        })
    }

    calculateExcess() {
        if (this.observed.horizontalImage) {
            return (this.observed.imageSize.width - this.observed.holeWidth) / 2;
        } else {
            return (this.observed.imageSize.height - this.observed.holeWidth) / 2;
        }
    }
}

@Component
struct MiniToolbarView {

    @ObjectLink observed: CropObserved

    build() {
        Row({space: 32}) {
            Button() {
                Image($r('app.media.vertical_flip'))
                    .size({width: 24, height: 24})
            }
            .padding(16)
            .onClick(async () => this.onButton(0))
            .backgroundColor(this.observed.verticalFlip ? $r('app.color.primary') : $r('app.color.darkGray'))

            Button() {
                Image($r('app.media.horizontal_flip'))
                    .size({width: 24, height: 24})
            }
            .padding(16)
            .backgroundColor(this.observed.horizontalFlip ? $r('app.color.primary') : $r('app.color.darkGray'))

            .onClick(async () => this.onButton(1))

            Button() {
                Image($r('app.media.rotate_right'))
                    .rotate({angle: this.observed.rotationAngle})
                    .size({width: 32, height: 32})
            }
            .padding(12)
            .backgroundColor(this.observed.rotationAngle % 360 == 0 ? $r('app.color.darkGray') : $r('app.color.primary'))
            .onClick(async () => this.onButton(2))
        }
        .margin({bottom: 96})
    }

    onButton(action: number) {
        this.observed.onMiniToolbar(action)
    }
}

@Component
struct CropToolbarView {

    @Prop cropLoading: boolean
    action: (action: number) => void = (_action) => {}

    build() {
        Row() {
            Button() {
                Text('取消')
                    .fontSize(14)
                    .fontColor(Color.White)
            }
            .height(32)
            .padding({left: 16, right: 16})
            .backgroundColor(Color.Transparent)
            .onClick(() => this.action(0))
            Blank()

            if (this.cropLoading) {
                LoadingButton(32, 32)
            }else {
                Button() {
                    Text('完成')
                        .fontSize(14)
                        .fontColor(Color.White)
                }
                .height(32)
                .padding({left: 16, right: 16})
                .backgroundColor($r('app.color.primary'))
                .onClick(() => this.action(1))
            }
        }
        .padding({left: 16, right: 16, top: 16})
        .width('100%')
        .backgroundBlurStyle(BlurStyle.BACKGROUND_ULTRA_THICK)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
}

@Component
struct RoundHoleView {

    context: CanvasRenderingContext2D | null = null
    action: (width: number) => void = () => {}

    build() {
        Canvas(this.context)
            .width('100%')
            .height('100%')
            .backgroundColor(Color.Transparent)
            .onReady(() => {

                if (this.context == null) {
                    return
                }

                let height = this.context.height
                let width = this.context.width
                let radius = (width - 64) / 2

                this.action(width - 64)

                this.context.fillStyle= '#6b000000'
                this.context.fillRect(0,0, width, height)

                this.context.globalCompositeOperation='destination-out'

                this.context.fillStyle = 'white'
                this.context.beginPath();
                this.context.arc(32 + radius, height/2, radius, 0, Math.PI*2)
                this.context.closePath();
                this.context.fill();

                this.context.globalCompositeOperation='source-over';
            })
            .enabled(false)
    }
}
