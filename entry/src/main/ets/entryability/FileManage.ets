import fs from '@ohos.file.fs'
import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';

let context = getContext(this) as common.UIAbilityContext

export enum Format {
    JPG = 'jpg',
    M4A = 'm4a',
    MP4 = 'mp4'
}

export function filename(number: number, index: number = 0, format: Format = Format.JPG) {
    let millisecond = new Date().getTime()
    return `${ number }-${ millisecond }-${ index }.${ format.valueOf() }`
}

export function savePixelMapToCache(filename: string, pixelMap: image.PixelMap, callback: (status: boolean) => void) {

    const imagePacker = image.createImagePacker()
    const options: image.PackingOption = { format: 'image/jpeg', quality: 100 }
    imagePacker.packing(pixelMap, options, (error, buffer) => {
        if (error) {
            callback(false)
        }else {
            saveBufferToCache(filename, buffer, callback)
        }
    })
}

export function saveBufferToCache(filename: string, buffer: ArrayBuffer, callback: (status: boolean) => void) {

    let path = context.cacheDir + '/' + filename
    let file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)

    fs.write(file.fd, buffer, (error, writeLen) => {
        if (error) {
            callback(false)
        } else {
            fs.closeSync(file)
            callback(true)
        }
    })
}