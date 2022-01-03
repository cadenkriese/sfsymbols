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
          UIColor* primaryColor = [UIColor colorWithRed:[rgbaValuesList[i] doubleValue]
                                         green:[rgbaValuesList[i+1] doubleValue]
                                          blue:[rgbaValuesList[i+2] doubleValue]
                                         alpha:[rgbaValuesList[i+3] doubleValue]];
          [colorArray addObject:primaryColor];
      }

      UIImageSymbolScale scale = UIImageSymbolScaleDefault;

      switch ([scaleIndex integerValue]) {
        case 0:
          scale = UIImageSymbolScaleSmall;
          break;
        case 1:
          scale = UIImageSymbolScaleMedium;
          break;
        case 2:
          scale = UIImageSymbolScaleLarge;
          break;
        default:
          scale = UIImageSymbolScaleDefault;
          break;
      }

      UIImageSymbolWeight weight = UIImageSymbolWeightRegular;

      switch ([weightIndex integerValue]) {
        case 0:
          weight = UIImageSymbolWeightUltraLight;
          break;
        case 1:
          weight = UIImageSymbolWeightThin;
          break;
        case 2:
          weight = UIImageSymbolWeightLight;
          break;
        // 3 is regular
        case 4:
          weight = UIImageSymbolWeightMedium;
          break;
        case 5:
          weight = UIImageSymbolWeightSemibold;
          break;
        case 6:
          weight = UIImageSymbolWeightBold;
          break;
        case 7:
          weight = UIImageSymbolWeightHeavy;
          break;
        case 8:
          weight = UIImageSymbolWeightBlack;
          break;
        default:
          weight = UIImageSymbolWeightRegular;
          break;
      }

      UIImageSymbolConfiguration* pointSizeConfig = [UIImageSymbolConfiguration
                                            configurationWithPointSize:pointSize
                                            weight:weight
                                            scale:scale];
                                          
      UIImageSymbolConfiguration* colorConfig = [UIImageSymbolConfiguration configurationWithPaletteColors:colorArray];
      UIImageSymbolConfiguration* combinedConfig = [pointSizeConfig configurationByApplyingConfiguration:colorConfig];

      UIImage* image = [UIImage systemImageNamed:name withConfiguration:combinedConfig];
      NSData* data = UIImagePNGRepresentation(image);
      if (data) {
        result(@{
          @"scale" : @(image.scale),
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
