import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit'

let context = getContext(this) as common.UIAbilityContext

export function permissions(type: PermissionsType, callback: (status: boolean) => void) {

    let manager = abilityAccessCtrl.createAtManager()
    
    let permissions: Permissions[] = []
    if (type == PermissionsType.readWriteMedia) {
        permissions = ['ohos.permission.READ_MEDIA', 'ohos.permission.WRITE_MEDIA']

    }else if (type == PermissionsType.camera) {
        permissions = ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE']

    }

    manager.requestPermissionsFromUser(context, permissions, (error, data) => {
        if (error) {
            callback(false)
        }else {
            let grantStatus: Array<number> = data.authResults
            let status = grantStatus.findIndex(status => status == -1) // 未找到说明全通过返回-1
            callback(status == -1)
        }
    })
}

export enum PermissionsType {
    readImageVideo,
    location,
    readWriteMedia,
    camera,
    writeImageVideo,
    microphone,
    distributedDataSync,
    locationApproximatelyLocation
}