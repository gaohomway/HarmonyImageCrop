import { picker } from '@kit.CoreFileKit'
import { BusinessError } from '@kit.BasicServicesKit'

@Observed
export class ImageObserved {

    async openPhotoViewPicker(callback: (image: string | null) => void) {
        try {
            let photoPicker = new picker.PhotoViewPicker()
            let options = new picker.PhotoSelectOptions()
            options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
            options.maxSelectNumber = 1

            photoPicker.select(options).then(result => {
                if (result.photoUris.length == 0) {
                    callback(null)
                }else {
                    callback(result.photoUris[0])
                }
            }).catch((error: BusinessError) => {
                callback(null)
            })
        } catch (error) {
            callback(null)
        }
    }
}