import 'package:flutter/material.dart';
import 'dart:io';

class ResponsiveUtils {
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getDevicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  static double getAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.height / size.width;
  }

  // Comprehensive mobile brand detection
  static MobileBrand getMobileBrand(BuildContext context) {
    try {
      if (Platform.isIOS) {
        return _detectiPhoneModel(context);
      } else if (Platform.isAndroid) {
        return _detectAndroidBrand(context);
      }
    } catch (e) {
      // Fallback for web or other platforms
    }
    return MobileBrand.generic;
  }

  static MobileBrand _detectiPhoneModel(BuildContext context) {
    final width = getWidth(context);
    final height = getHeight(context);
    final aspectRatio = getAspectRatio(context);
    
    // iPhone detection based on screen dimensions and aspect ratios
    if (width == 428 || (width >= 420 && aspectRatio > 2.1)) {
      return MobileBrand.iPhoneProMax; // iPhone 14 Pro Max, 13 Pro Max
    } else if (width == 414 || (width >= 410 && aspectRatio > 2.0)) {
      return MobileBrand.iPhonePlus; // iPhone 14 Plus, older Plus models
    } else if (width == 393 || (width >= 390 && aspectRatio > 2.1)) {
      return MobileBrand.iPhonePro; // iPhone 14 Pro, 13 Pro
    } else if (width == 390 || (width >= 385 && aspectRatio > 2.0)) {
      return MobileBrand.iPhoneRegular; // iPhone 14, 13, 12
    } else if (width <= 375) {
      return MobileBrand.iPhoneMini; // iPhone 13 mini, 12 mini, SE
    }
    
    return MobileBrand.iPhoneRegular;
  }

  static MobileBrand _detectAndroidBrand(BuildContext context) {
    final width = getWidth(context);
    final height = getHeight(context);
    final aspectRatio = getAspectRatio(context);
    final pixelRatio = getDevicePixelRatio(context);
    
    // Samsung detection (enhanced)
    if (width >= 360 && width <= 430 && aspectRatio > 2.0) {
      if (aspectRatio > 2.2) {
        return MobileBrand.samsungTall; // Galaxy S series flagship
      } else {
        return MobileBrand.samsungRegular; // Galaxy A series, standard S
      }
    }
    
    // Google Pixel detection
    if ((width >= 360 && width <= 400) && aspectRatio > 1.9 && pixelRatio >= 2.6) {
      if (aspectRatio > 2.2) {
        return MobileBrand.pixelTall; // Pixel 6 Pro, 7 Pro
      } else {
        return MobileBrand.pixelRegular; // Pixel 6, 7, 8
      }
    }
    
    // OnePlus detection (often high pixel ratio, tall screens)
    if (width >= 380 && width <= 430 && aspectRatio > 2.1 && pixelRatio >= 3.0) {
      return MobileBrand.onePlus;
    }
    
    // Xiaomi detection (wide variety, often high pixel ratios)
    if (width >= 360 && width <= 430 && pixelRatio >= 2.75) {
      if (aspectRatio > 2.2) {
        return MobileBrand.xiaomiTall; // Mi series, Redmi Note
      } else {
        return MobileBrand.xiaomiRegular; // Standard Xiaomi devices
      }
    }
    
    // Huawei detection
    if (width >= 360 && width <= 420 && aspectRatio > 2.0) {
      return MobileBrand.huawei; // P series, Mate series
    }
    
    // Oppo/Vivo detection (similar characteristics)
    if (width >= 360 && width <= 400 && aspectRatio > 2.0 && pixelRatio >= 2.5) {
      return MobileBrand.oppoVivo; // Oppo, Vivo, Realme
    }
    
    // Sony detection (cinematic 21:9 screens)
    if (aspectRatio > 2.3 && width >= 360) {
      return MobileBrand.sony; // Xperia series
    }
    
    // Generic Android fallback
    if (width < 360) return MobileBrand.smallAndroid;
    if (width < 390) return MobileBrand.regularAndroid;
    if (width < 430) return MobileBrand.largeAndroid;
    return MobileBrand.tabletAndroid;
  }

  // Universal device type based on brand and characteristics
  static DeviceType getDeviceType(BuildContext context) {
    final brand = getMobileBrand(context);
    final width = getWidth(context);
    
    switch (brand) {
      case MobileBrand.iPhoneMini:
        return DeviceType.iPhoneMini;
      case MobileBrand.iPhoneRegular:
      case MobileBrand.iPhonePro:
        return DeviceType.iPhoneRegular;
      case MobileBrand.iPhonePlus:
      case MobileBrand.iPhoneProMax:
        return DeviceType.iPhoneLarge;
        
      case MobileBrand.samsungRegular:
        return DeviceType.samsungRegular;
      case MobileBrand.samsungTall:
        return DeviceType.samsungTall;
        
      case MobileBrand.pixelRegular:
        return DeviceType.pixelRegular;
      case MobileBrand.pixelTall:
        return DeviceType.pixelTall;
        
      case MobileBrand.onePlus:
        return DeviceType.onePlus;
      case MobileBrand.xiaomiRegular:
        return DeviceType.xiaomiRegular;
      case MobileBrand.xiaomiTall:
        return DeviceType.xiaomiTall;
      case MobileBrand.huawei:
        return DeviceType.huawei;
      case MobileBrand.oppoVivo:
        return DeviceType.oppoVivo;
      case MobileBrand.sony:
        return DeviceType.sony;
        
      case MobileBrand.smallAndroid:
        return DeviceType.smallPhone;
      case MobileBrand.regularAndroid:
        return DeviceType.regularPhone;
      case MobileBrand.largeAndroid:
        return DeviceType.largePhone;
      case MobileBrand.tabletAndroid:
        return DeviceType.tablet;
        
      default:
        // Fallback logic
        if (width < 360) return DeviceType.smallPhone;
        if (width < 390) return DeviceType.regularPhone;
        if (width < 430) return DeviceType.largePhone;
        if (width < 600) return DeviceType.largePhone;
        return DeviceType.tablet;
    }
  }

  // Brand-optimized font sizes
  static double getHeadingFontSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    final pixelRatio = getDevicePixelRatio(context);
    
    double baseSize = switch (deviceType) {
      // iPhone sizes
      DeviceType.iPhoneMini => 20,
      DeviceType.iPhoneRegular => 24,
      DeviceType.iPhoneLarge => 26,
      
      // Samsung sizes
      DeviceType.samsungRegular => 23,
      DeviceType.samsungTall => 24,
      
      // Google Pixel sizes
      DeviceType.pixelRegular => 23,
      DeviceType.pixelTall => 25,
      
      // OnePlus sizes (clean design)
      DeviceType.onePlus => 24,
      
      // Xiaomi sizes
      DeviceType.xiaomiRegular => 22,
      DeviceType.xiaomiTall => 23,
      
      // Huawei sizes
      DeviceType.huawei => 23,
      
      // Oppo/Vivo sizes
      DeviceType.oppoVivo => 22,
      
      // Sony sizes (cinematic)
      DeviceType.sony => 25,
      
      // Generic sizes
      DeviceType.smallPhone => 20,
      DeviceType.regularPhone => 22,
      DeviceType.largePhone => 24,
      DeviceType.tablet => 26,
    };
    
    // High-density display adjustment
    if (pixelRatio > 3.0) {
      baseSize *= 1.1;
    } else if (pixelRatio > 2.5) {
      baseSize *= 1.05;
    }
    
    return baseSize;
  }

  static double getTitleFontSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    final pixelRatio = getDevicePixelRatio(context);
    
    double baseSize = switch (deviceType) {
      // iPhone sizes
      DeviceType.iPhoneMini => 16,
      DeviceType.iPhoneRegular => 20,
      DeviceType.iPhoneLarge => 22,
      
      // Samsung sizes
      DeviceType.samsungRegular => 19,
      DeviceType.samsungTall => 20,
      
      // Google Pixel sizes
      DeviceType.pixelRegular => 19,
      DeviceType.pixelTall => 21,
      
      // OnePlus sizes
      DeviceType.onePlus => 20,
      
      // Xiaomi sizes
      DeviceType.xiaomiRegular => 18,
      DeviceType.xiaomiTall => 19,
      
      // Huawei sizes
      DeviceType.huawei => 19,
      
      // Oppo/Vivo sizes
      DeviceType.oppoVivo => 18,
      
      // Sony sizes
      DeviceType.sony => 21,
      
      // Generic sizes
      DeviceType.smallPhone => 16,
      DeviceType.regularPhone => 18,
      DeviceType.largePhone => 20,
      DeviceType.tablet => 22,
    };
    
    if (pixelRatio > 3.0) {
      baseSize *= 1.05;
    }
    
    return baseSize;
  }

  static double getBodyFontSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    final pixelRatio = getDevicePixelRatio(context);
    
    double baseSize = switch (deviceType) {
      // iPhone sizes (iOS default scaling)
      DeviceType.iPhoneMini => 15,
      DeviceType.iPhoneRegular => 17,
      DeviceType.iPhoneLarge => 18,
      
      // Samsung sizes
      DeviceType.samsungRegular => 16,
      DeviceType.samsungTall => 16,
      
      // Google Pixel sizes (Material Design)
      DeviceType.pixelRegular => 16,
      DeviceType.pixelTall => 17,
      
      // OnePlus sizes
      DeviceType.onePlus => 16,
      
      // Xiaomi sizes (MIUI)
      DeviceType.xiaomiRegular => 15,
      DeviceType.xiaomiTall => 16,
      
      // Huawei sizes
      DeviceType.huawei => 16,
      
      // Oppo/Vivo sizes
      DeviceType.oppoVivo => 15,
      
      // Sony sizes
      DeviceType.sony => 17,
      
      // Generic sizes
      DeviceType.smallPhone => 14,
      DeviceType.regularPhone => 15,
      DeviceType.largePhone => 16,
      DeviceType.tablet => 17,
    };
    
    if (pixelRatio > 3.0) {
      baseSize *= 1.05;
    }
    
    return baseSize;
  }

  static double getSmallFontSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    return switch (deviceType) {
      // iPhone sizes
      DeviceType.iPhoneMini => 13,
      DeviceType.iPhoneRegular => 15,
      DeviceType.iPhoneLarge => 16,
      
      // Samsung sizes
      DeviceType.samsungRegular => 14,
      DeviceType.samsungTall => 14,
      
      // Google Pixel sizes
      DeviceType.pixelRegular => 14,
      DeviceType.pixelTall => 15,
      
      // OnePlus sizes
      DeviceType.onePlus => 14,
      
      // Xiaomi sizes
      DeviceType.xiaomiRegular => 13,
      DeviceType.xiaomiTall => 14,
      
      // Huawei sizes
      DeviceType.huawei => 14,
      
      // Oppo/Vivo sizes
      DeviceType.oppoVivo => 13,
      
      // Sony sizes
      DeviceType.sony => 15,
      
      // Generic sizes
      DeviceType.smallPhone => 12,
      DeviceType.regularPhone => 13,
      DeviceType.largePhone => 14,
      DeviceType.tablet => 15,
    };
  }

  // Brand-optimized icon sizes
  static double getIconSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    return switch (deviceType) {
      // iPhone sizes (iOS standards)
      DeviceType.iPhoneMini => 22,
      DeviceType.iPhoneRegular => 24,
      DeviceType.iPhoneLarge => 28,
      
      // Samsung sizes
      DeviceType.samsungRegular => 26,
      DeviceType.samsungTall => 28,
      
      // Google Pixel sizes (Material Design)
      DeviceType.pixelRegular => 24,
      DeviceType.pixelTall => 26,
      
      // OnePlus sizes
      DeviceType.onePlus => 26,
      
      // Xiaomi sizes
      DeviceType.xiaomiRegular => 24,
      DeviceType.xiaomiTall => 26,
      
      // Huawei sizes
      DeviceType.huawei => 24,
      
      // Oppo/Vivo sizes
      DeviceType.oppoVivo => 24,
      
      // Sony sizes
      DeviceType.sony => 26,
      
      // Generic sizes
      DeviceType.smallPhone => 20,
      DeviceType.regularPhone => 24,
      DeviceType.largePhone => 28,
      DeviceType.tablet => 32,
    };
  }

  static double getLargeIconSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    return switch (deviceType) {
      // iPhone sizes
      DeviceType.iPhoneMini => 36,
      DeviceType.iPhoneRegular => 40,
      DeviceType.iPhoneLarge => 44,
      
      // Samsung sizes
      DeviceType.samsungRegular => 40,
      DeviceType.samsungTall => 44,
      
      // Google Pixel sizes
      DeviceType.pixelRegular => 38,
      DeviceType.pixelTall => 42,
      
      // OnePlus sizes
      DeviceType.onePlus => 42,
      
      // Xiaomi sizes
      DeviceType.xiaomiRegular => 38,
      DeviceType.xiaomiTall => 40,
      
      // Huawei sizes
      DeviceType.huawei => 40,
      
      // Oppo/Vivo sizes
      DeviceType.oppoVivo => 38,
      
      // Sony sizes
      DeviceType.sony => 42,
      
      // Generic sizes
      DeviceType.smallPhone => 32,
      DeviceType.regularPhone => 36,
      DeviceType.largePhone => 40,
      DeviceType.tablet => 48,
    };
  }

  // Brand-aware padding with edge considerations
  static double getPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    final safeArea = MediaQuery.of(context).padding;
    
    double basePadding = switch (deviceType) {
      // iPhone padding (iOS safe areas)
      DeviceType.iPhoneMini => 16,
      DeviceType.iPhoneRegular => 20,
      DeviceType.iPhoneLarge => 24,
      
      // Samsung padding
      DeviceType.samsungRegular => 18,
      DeviceType.samsungTall => 20,
      
      // Google Pixel padding (Material Design)
      DeviceType.pixelRegular => 16,
      DeviceType.pixelTall => 18,
      
      // OnePlus padding
      DeviceType.onePlus => 18,
      
      // Xiaomi padding
      DeviceType.xiaomiRegular => 16,
      DeviceType.xiaomiTall => 18,
      
      // Huawei padding
      DeviceType.huawei => 16,
      
      // Oppo/Vivo padding
      DeviceType.oppoVivo => 16,
      
      // Sony padding (cinematic)
      DeviceType.sony => 20,
      
      // Generic padding
      DeviceType.smallPhone => 12,
      DeviceType.regularPhone => 16,
      DeviceType.largePhone => 20,
      DeviceType.tablet => 24,
    };
    
    // Edge display compensation for various brands
    if (_hasEdgeDisplay(deviceType)) {
      if (safeArea.left > 0 || safeArea.right > 0) {
        basePadding += 4;
      }
    }
    
    return basePadding;
  }

  static bool _hasEdgeDisplay(DeviceType deviceType) {
    return deviceType == DeviceType.samsungTall ||
           deviceType == DeviceType.onePlus ||
           deviceType == DeviceType.oppoVivo ||
           deviceType == DeviceType.huawei;
  }

  static double getSmallPadding(BuildContext context) {
    return getPadding(context) * 0.5;
  }

  static double getLargePadding(BuildContext context) {
    return getPadding(context) * 1.5;
  }

  // Brand-aware card padding
  static EdgeInsets getCardPadding(BuildContext context) {
    final padding = getPadding(context);
    final deviceType = getDeviceType(context);
    
    // Extra horizontal padding for tall/cinematic screens
    if (deviceType == DeviceType.samsungTall ||
        deviceType == DeviceType.pixelTall ||
        deviceType == DeviceType.sony ||
        deviceType == DeviceType.iPhoneLarge) {
      return EdgeInsets.symmetric(
        horizontal: padding * 1.2,
        vertical: padding,
      );
    }
    
    return EdgeInsets.all(padding);
  }

  // Brand-optimized spacing
  static Widget getVerticalSpace(BuildContext context, {double factor = 1.0}) {
    final deviceType = getDeviceType(context);
    double spacing = getPadding(context) * factor;
    
    // Adjust spacing for tall screens
    if (deviceType == DeviceType.samsungTall ||
        deviceType == DeviceType.pixelTall ||
        deviceType == DeviceType.sony ||
        deviceType == DeviceType.iPhoneLarge) {
      spacing *= 1.1;
    }
    
    return SizedBox(height: spacing);
  }

  static Widget getHorizontalSpace(BuildContext context, {double factor = 1.0}) {
    return SizedBox(width: getPadding(context) * factor);
  }

  // Brand-optimized button sizes
  static double getButtonHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    return switch (deviceType) {
      // iPhone button heights (iOS standards)
      DeviceType.iPhoneMini => 44, // iOS minimum
      DeviceType.iPhoneRegular => 50,
      DeviceType.iPhoneLarge => 54,
      
      // Samsung button heights
      DeviceType.samsungRegular => 48,
      DeviceType.samsungTall => 52,
      
      // Google Pixel heights (Material Design)
      DeviceType.pixelRegular => 48,
      DeviceType.pixelTall => 52,
      
      // OnePlus heights
      DeviceType.onePlus => 50,
      
      // Xiaomi heights
      DeviceType.xiaomiRegular => 46,
      DeviceType.xiaomiTall => 48,
      
      // Huawei heights
      DeviceType.huawei => 48,
      
      // Oppo/Vivo heights
      DeviceType.oppoVivo => 46,
      
      // Sony heights
      DeviceType.sony => 52,
      
      // Generic heights
      DeviceType.smallPhone => 40,
      DeviceType.regularPhone => 44,
      DeviceType.largePhone => 48,
      DeviceType.tablet => 52,
    };
  }

  static double getBorderRadius(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    return switch (deviceType) {
      // iPhone border radius (iOS design)
      DeviceType.iPhoneMini => 10,
      DeviceType.iPhoneRegular => 12,
      DeviceType.iPhoneLarge => 14,
      
      // Samsung border radius
      DeviceType.samsungRegular => 16,
      DeviceType.samsungTall => 18,
      
      // Google Pixel radius (Material Design)
      DeviceType.pixelRegular => 12,
      DeviceType.pixelTall => 14,
      
      // OnePlus radius
      DeviceType.onePlus => 16,
      
      // Xiaomi radius
      DeviceType.xiaomiRegular => 14,
      DeviceType.xiaomiTall => 16,
      
      // Huawei radius
      DeviceType.huawei => 14,
      
      // Oppo/Vivo radius
      DeviceType.oppoVivo => 14,
      
      // Sony radius
      DeviceType.sony => 16,
      
      // Generic radius
      DeviceType.smallPhone => 8,
      DeviceType.regularPhone => 12,
      DeviceType.largePhone => 16,
      DeviceType.tablet => 20,
    };
  }

  // Brand-optimized toolbar height
  static double getToolbarHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    return switch (deviceType) {
      // iPhone toolbar heights
      DeviceType.iPhoneMini => 44, // iOS standard
      DeviceType.iPhoneRegular => 44,
      DeviceType.iPhoneLarge => 44,
      
      // Samsung toolbar heights
      DeviceType.samsungRegular => 56,
      DeviceType.samsungTall => 60,
      
      // Google Pixel heights
      DeviceType.pixelRegular => 56, // Material Design
      DeviceType.pixelTall => 60,
      
      // OnePlus heights
      DeviceType.onePlus => 58,
      
      // Xiaomi heights
      DeviceType.xiaomiRegular => 54,
      DeviceType.xiaomiTall => 56,
      
      // Huawei heights
      DeviceType.huawei => 56,
      
      // Oppo/Vivo heights
      DeviceType.oppoVivo => 54,
      
      // Sony heights
      DeviceType.sony => 60,
      
      // Generic heights
      DeviceType.smallPhone => 48,
      DeviceType.regularPhone => 52,
      DeviceType.largePhone => 56,
      DeviceType.tablet => 60,
    };
  }

  // Enhanced device detection methods
  static bool isSmallPhone(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.smallPhone ||
           deviceType == DeviceType.iPhoneMini;
  }

  static bool isRegularPhone(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.regularPhone ||
           deviceType == DeviceType.iPhoneRegular ||
           deviceType == DeviceType.samsungRegular ||
           deviceType == DeviceType.pixelRegular ||
           deviceType == DeviceType.xiaomiRegular;
  }

  static bool isLargePhone(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.largePhone ||
           deviceType == DeviceType.iPhoneLarge ||
           deviceType == DeviceType.samsungTall ||
           deviceType == DeviceType.pixelTall ||
           deviceType == DeviceType.onePlus ||
           deviceType == DeviceType.xiaomiTall ||
           deviceType == DeviceType.sony;
  }

  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  // Brand-specific detection methods
  static bool isiPhone(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.iPhoneMini ||
           deviceType == DeviceType.iPhoneRegular ||
           deviceType == DeviceType.iPhoneLarge;
  }

  static bool isSamsungPhone(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.samsungRegular ||
           deviceType == DeviceType.samsungTall;
  }

  static bool isPixelPhone(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.pixelRegular ||
           deviceType == DeviceType.pixelTall;
  }

  static bool isOnePlusPhone(BuildContext context) {
    return getDeviceType(context) == DeviceType.onePlus;
  }

  static bool isXiaomiPhone(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.xiaomiRegular ||
           deviceType == DeviceType.xiaomiTall;
  }

  static bool isHuaweiPhone(BuildContext context) {
    return getDeviceType(context) == DeviceType.huawei;
  }

  static bool isOppoVivoPhone(BuildContext context) {
    return getDeviceType(context) == DeviceType.oppoVivo;
  }

  static bool isSonyPhone(BuildContext context) {
    return getDeviceType(context) == DeviceType.sony;
  }

  // Safe area with brand considerations
  static double getSafeAreaTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getSafeAreaBottom(BuildContext context) {
    final padding = MediaQuery.of(context).padding.bottom;
    final deviceType = getDeviceType(context);
    
    // Extra bottom padding for gesture navigation on various brands
    if ((deviceType == DeviceType.samsungTall ||
         deviceType == DeviceType.pixelTall ||
         deviceType == DeviceType.onePlus ||
         deviceType == DeviceType.xiaomiTall) && padding < 20) {
      return padding + 8;
    }
    
    // iPhone home indicator
    if (isiPhone(context) && padding < 34) {
      return padding + 6;
    }
    
    return padding;
  }

  // Universal device frame logic
  static bool shouldShowDeviceFrame(BuildContext context) {
    final deviceType = getDeviceType(context);
    final width = getWidth(context);
    
    // Don't show device frame on mobile devices to maximize space
    if (deviceType == DeviceType.samsungRegular ||
        deviceType == DeviceType.samsungTall ||
        deviceType == DeviceType.iPhoneMini ||
        deviceType == DeviceType.iPhoneRegular ||
        deviceType == DeviceType.iPhoneLarge ||
        deviceType == DeviceType.pixelRegular ||
        deviceType == DeviceType.pixelTall ||
        deviceType == DeviceType.onePlus ||
        deviceType == DeviceType.xiaomiRegular ||
        deviceType == DeviceType.xiaomiTall ||
        deviceType == DeviceType.huawei ||
        deviceType == DeviceType.oppoVivo ||
        deviceType == DeviceType.sony) {
      return false;
    }
    
    // Show on tablets and large devices only
    return width > 600;
  }

  // Universal frame size calculation
  static Size getFrameSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = getDeviceType(context);
    
    // Use actual screen size for all mobile devices
    if (!shouldShowDeviceFrame(context)) {
      return Size(screenSize.width, screenSize.height);
    }
    
    // Standard frame sizing for tablets
    return Size(
      screenSize.width * 0.9,
      screenSize.height * 0.9,
    );
  }
}

// Comprehensive mobile brand enumeration
enum MobileBrand {
  // iPhone models
  iPhoneMini,
  iPhoneRegular,
  iPhonePro,
  iPhonePlus,
  iPhoneProMax,
  
  // Samsung models
  samsungRegular,
  samsungTall,
  
  // Google Pixel models
  pixelRegular,
  pixelTall,
  
  // Other Android brands
  onePlus,
  xiaomiRegular,
  xiaomiTall,
  huawei,
  oppoVivo, // Covers Oppo, Vivo, Realme
  sony,
  
  // Generic categories
  smallAndroid,
  regularAndroid,
  largeAndroid,
  tabletAndroid,
  
  // Fallback
  generic,
}

// Enhanced device type enumeration
enum DeviceType {
  // iPhone types
  iPhoneMini,
  iPhoneRegular,
  iPhoneLarge,
  
  // Samsung types
  samsungRegular,
  samsungTall,
  
  // Google Pixel types
  pixelRegular,
  pixelTall,
  
  // Other brand types
  onePlus,
  xiaomiRegular,
  xiaomiTall,
  huawei,
  oppoVivo,
  sony,
  
  // Generic types
  smallPhone,
  regularPhone,
  largePhone,
  tablet,
} 