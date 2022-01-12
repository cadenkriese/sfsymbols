#import "SFSymbolsPlugin.h"

#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

@interface SFSymbolsPlugin ()
@end

@implementation SFSymbolsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/sfsymbols"
                                  binaryMessenger:[registrar messenger]];

  [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"loadSymbol" isEqualToString:call.method]) {
      NSString* name = call.arguments[0];
      NSNumber* pointSizeWithDouble = call.arguments[1];
      double pointSize = [pointSizeWithDouble doubleValue];
      NSNumber* weightIndex = call.arguments[2];
      NSNumber* scaleIndex = call.arguments[3];

      // Up to 3 rgb values for primary, seconday and tertiary colors.
      // see https://developer.apple.com/documentation/uikit/uiimagesymbolconfiguration/3810054-configurationwithpalettecolors
      NSArray* rgbaValuesList = call.arguments[4];

      NSMutableArray* colorArray = [[NSMutableArray alloc]init]; 

      for (int i = 0; i < [rgbaValuesList count]; i+= 4) {
          NSColor* color = [NSColor colorWithRed:[rgbaValuesList[i] doubleValue]
                                         green:[rgbaValuesList[i+1] doubleValue]
                                          blue:[rgbaValuesList[i+2] doubleValue]
                                         alpha:[rgbaValuesList[i+3] doubleValue]];
          [colorArray addObject:color];
      }

      NSImageSymbolScale scale = NSImageSymbolScaleMedium;

      switch ([scaleIndex integerValue]) {
        case 0:
          scale = NSImageSymbolScaleSmall;
          break;
        case 1:
          scale = NSImageSymbolScaleMedium;
          break;
        case 2:
          scale = NSImageSymbolScaleLarge;
          break;
        default:
          scale = NSImageSymbolScaleMedium;
          break;
      }

      NSFontWeight weight = NSFontWeightRegular;

      switch ([weightIndex integerValue]) {
        case 0:
          weight = NSFontWeightUltraLight;
          break;
        case 1:
          weight = NSFontWeightThin;
          break;
        case 2:
          weight = NSFontWeightLight;
          break;
        // 3 is regular
        case 4:
          weight = NSFontWeightMedium;
          break;
        case 5:
          weight = NSFontWeightSemibold;
          break;
        case 6:
          weight = NSFontWeightBold;
          break;
        case 7:
          weight = NSFontWeightHeavy;
          break;
        case 8:
          weight = NSFontWeightBlack;
          break;
        default:
          weight = NSFontWeightRegular;
          break;
      }

      NSImageSymbolConfiguration* pointSizeConfig = [NSImageSymbolConfiguration
                                            configurationWithPointSize:pointSize
                                            weight:weight
                                            scale:scale];
                                          
      NSImageSymbolConfiguration* colorConfig = [NSImageSymbolConfiguration configurationWithPaletteColors:colorArray];
      NSImageSymbolConfiguration* combinedConfig = [pointSizeConfig configurationByApplyingConfiguration:colorConfig];

      NSImage* image = [NSImage imageWithSystemSymbolName:name accessibilityDescription:@""];
      image = [image imageWithSymbolConfiguration:combinedConfig];

      // CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
      // CGColorSpaceRef colorspace2 = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);

      CGImageRef CGImage = [image CGImageForProposedRect:nil context:nil hints:nil];
      NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:CGImage];
      NSData* data = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];

      if (data) {
        result(@{
          @"scale" : @([image recommendedLayerContentsScale:0.0]),
          @"data" : [FlutterStandardTypedData typedDataWithBytes:data],
        });
      } else {
        result(nil);
      }
      return;
    }
    result(FlutterMethodNotImplemented);
  }];
}

@end
