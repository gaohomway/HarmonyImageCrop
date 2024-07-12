import image from '@ohos.multimedia.image';
import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import { promptAction, Size } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { filename, savePixelMapToCache } from '../entryability/FileManage';

@Observed
export default class CropObserved {

    holeWidth: number = 0
    pixelMap?: image.PixelMap = undefined
    imageSize: Size = {
        width: 0, height: 0
    }
    ratio: number = 0
    verticalFlip: boolean = false
    horizontalFlip: boolean = false
    rotationAngle: number = 0
    horizontalImage: boolean = false
    positionX: number = 0
    positionY: number = 0

    async getPixel(imageURI: string) {

        let context = getContext(this) as common.UIAbilityContext
        let cacheDir = context.cacheDir

        try {
            let file = fs.openSync(imageURI, fs.OpenMode.CREATE)
            fs.copyFileSync(file.fd, cacheDir + '/avatar.jpg')

            const path = cacheDir + "/avatar.jpg"
            let imageSource = image.createImageSource(path)
            this.pixelMap = await imageSource.createPixelMap({
                editable: true,
                desiredPixelFormat: image.PixelMapFormat.BGRA_8888
            })

            this.getImageSize()
        } catch (error) {
            console.log('error: ' + error)
        }
    }

    getImageSize() {

        if (!this.pixelMap) return

        this.pixelMap.getImageInfo((error, info) => {
            let size = info.size
            this.horizontalImage = size.width >= size.height

            if (this.horizontalImage) {
                this.ratio = size.width / size.height
                this.imageSize = { width: this.holeWidth * this.ratio, height: this.holeWidth }
            } else {
                this.ratio = size.height / size.width
                this.imageSize = { width: this.holeWidth, height: this.holeWidth * this.ratio }
            }
        })
    }

    onMiniToolbar(action: number) {

        if (this.pixelMap == undefined) {
            return
        }

        if (action == 0) {
            this.verticalFlip = !this.verticalFlip
            this.pixelMap.flip(false, true, (error: BusinessError) => {
                this.pixelMapChange()
            })
        } else if (action == 1) {
            this.horizontalFlip = !this.horizontalFlip
            this.pixelMap.flip(true, false, () => {
                this.pixelMapChange()
            })
        } else {
            this.rotationAngle += 90
            this.pixelMap.rotate(90, (error) => {
                this.getImageSize()
            })
        }
    }

    pixelMapChange() {
        let size = this.imageSize
        this.imageSize = { width: 300, height: 300 }
        animateTo({duration: 16}, () => {
            this.imageSize = size
        })
    }

    cropLoading: boolean = false

    async crop(callback: (filename: string) => void) {

        this.cropLoading = true
        if (this.pixelMap == undefined) {
            return
        }

        let imageInfo: image.ImageInfo = await this.pixelMap.getImageInfo()
        let height = imageInfo.size.height
        let width = imageInfo.size.width
        let imageWidth = this.imageSize.width
        let imageHeight = this.imageSize.height

        let x = 0
        let y = 0
        let w = 0
        let h = 0

        if (height > width) {
            x = 0
            y = Math.abs(this.positionY - ((imageHeight - imageWidth) / 2))
            w = width
            h = width
        } else if (height < width) {
            x = Math.abs(this.positionX - (imageWidth - imageHeight) / 2)
            y = 0
            w = height
            h = height
        } else {
            w = width
            h = height
        }

        let region: image.Region = {
            x: x,
            y: y,
            size: {
                height: h,
                width: w
            }
        }

        this.copyPixelMap(this.pixelMap).then(pixelMap => {
            pixelMap.crop(region, (error: BusinessError) => {
                if (error) {
                    promptAction.showToast({message: '裁切头像出现错误请重新尝试'})
                } else {
                    let name = filename(10000)  // User Id Number
                    if (!pixelMap) return
                    savePixelMapToCache(name, pixelMap, status => {
                        if (status) {
                            setTimeout(() => {
                                this.cropLoading = false
                                callback(name)
                            }, 1000)
                        }
                    })
                }
            })
        })
    }

    async copyPixelMap(pixelMap: PixelMap): Promise<PixelMap> {

        const imageInfo: image.ImageInfo = await pixelMap.getImageInfo()
        const buffer: ArrayBuffer = new ArrayBuffer(pixelMap.getPixelBytesNumber())

        await pixelMap.readPixelsToBuffer(buffer)

        // 知识点：通过readPixelsToBuffer实现PixelMap的深拷贝，其中readPixelsToBuffer输出为BGRA_8888
        // 知识点：readPixelsToBuffer输出为BGRA_8888,此处createPixelMap需转为RGBA_8888
        const options: image.InitializationOptions = {
            editable: true,
            pixelFormat: image.PixelMapFormat.RGBA_8888,
            size: {
                height: imageInfo.size.height,
                width: imageInfo.size.width
            }
        }
        return await image.createPixelMap(buffer, options)
    }
}