#import "UIImage+Resize.h"

@implementation UIImage (Resize)

/**
 * Método responsável por alterar o tamanho de uma figura mantendo seu aspecto.
 **/

- (UIImage*)scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end