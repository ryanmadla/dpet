//
//  PlaneDetector.h
//  DPET
//
//  Reference: https://github.com/TBXark/Ruler
//


#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface PlaneDetector : NSObject

+ (SCNVector4)detectPlaneWithPoints:(NSArray <NSValue* >*)points;

@end
