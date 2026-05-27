class ImageUtil {
  static getGoodsImage(imageName: string | Resource | null | undefined): Resource {
    if (!imageName) {
      return $r('app.media.card');
    }

    if (typeof imageName !== 'string') {
      return imageName;
    }

    const name: string = imageName.replace('.jpg', '').replace('.png', '');

    switch (name) {
      case 'man1':
        return $r('app.media.man1');
      case 'man2':
        return $r('app.media.man2');
      case 'man3':
        return $r('app.media.man3');
      case 'man4':
        return $r('app.media.man4');
      case 'man5':
        return $r('app.media.man5');
      case 'man6':
        return $r('app.media.man6');
      case 'man7':
        return $r('app.media.man7');
      case 'man8':
        return $r('app.media.man8');
      case 'man9':
        return $r('app.media.man9');
      case 'man10':
        return $r('app.media.man10');
      case 'man11':
        return $r('app.media.man11');
      case 'man13':
        return $r('app.media.man13');
      case 'man14':
        return $r('app.media.man14');
      case 'man15':
        return $r('app.media.man15');
      default:
        return $r('app.media.card');
    }
  }

  static isLocalImage(imageName: string): boolean {
    if (!imageName || typeof imageName !== 'string') {
      return false;
    }
    return !imageName.startsWith('http');
  }
}

export default ImageUtil;
