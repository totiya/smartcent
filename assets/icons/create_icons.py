#!/usr/bin/env python3
"""
SmartCent App Icon Generator
Generates all required icon sizes for Android and iOS from the master SVG icon.

Usage: python create_icons.py

Requirements:
- Inkscape (for SVG to PNG conversion)
- PIL/Pillow (for image processing)

Install requirements:
pip install Pillow
"""

import os
import subprocess
import sys
from PIL import Image, ImageDraw, ImageFilter

def check_inkscape():
    """Check if Inkscape is available in PATH"""
    try:
        subprocess.run(['inkscape', '--version'], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Inkscape not found. Please install Inkscape for SVG conversion.")
        print("Download from: https://inkscape.org/release/")
        return False

def create_directories():
    """Create necessary directories for icons"""
    directories = [
        'android/app/src/main/res/mipmap-hdpi',
        'android/app/src/main/res/mipmap-mdpi', 
        'android/app/src/main/res/mipmap-xhdpi',
        'android/app/src/main/res/mipmap-xxhdpi',
        'android/app/src/main/res/mipmap-xxxhdpi',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset',
        'web/icons',
        'assets/icons/generated'
    ]
    
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        print(f"✅ Created directory: {directory}")

def convert_svg_to_png(svg_path, output_path, size):
    """Convert SVG to PNG using Inkscape"""
    try:
        cmd = [
            'inkscape',
            '--export-type=png',
            f'--export-filename={output_path}',
            f'--export-width={size}',
            f'--export-height={size}',
            svg_path
        ]
        subprocess.run(cmd, check=True, capture_output=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error converting {svg_path} to {output_path}: {e}")
        return False

def create_android_icons():
    """Create Android app icons in various densities"""
    print("\n🤖 Creating Android Icons...")
    
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    svg_path = 'assets/icons/app_icon.svg'
    
    for density, size in android_sizes.items():
        output_path = f'android/app/src/main/res/{density}/ic_launcher.png'
        if convert_svg_to_png(svg_path, output_path, size):
            print(f"✅ Created {density}/ic_launcher.png ({size}x{size})")
        
        # Also create round icon
        round_output_path = f'android/app/src/main/res/{density}/ic_launcher_round.png'
        if convert_svg_to_png(svg_path, round_output_path, size):
            print(f"✅ Created {density}/ic_launcher_round.png ({size}x{size})")

def create_ios_icons():
    """Create iOS app icons in various sizes"""
    print("\n🍎 Creating iOS Icons...")
    
    ios_sizes = [
        20, 29, 40, 58, 60, 76, 80, 87, 114, 120, 152, 167, 180, 1024
    ]
    
    svg_path = 'assets/icons/app_icon.svg'
    
    for size in ios_sizes:
        output_path = f'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-{size}x{size}@1x.png'
        if convert_svg_to_png(svg_path, output_path, size):
            print(f"✅ Created iOS icon {size}x{size}")

def create_web_icons():
    """Create web app icons"""
    print("\n🌐 Creating Web Icons...")
    
    web_sizes = [16, 32, 48, 72, 96, 144, 192, 512]
    svg_path = 'assets/icons/app_icon.svg'
    
    for size in web_sizes:
        output_path = f'web/icons/Icon-{size}.png'
        if convert_svg_to_png(svg_path, output_path, size):
            print(f"✅ Created web icon {size}x{size}")
    
    # Create favicon
    favicon_path = 'web/favicon.png'
    if convert_svg_to_png(svg_path, favicon_path, 32):
        print(f"✅ Created favicon.png")

def create_flutter_assets():
    """Create Flutter asset icons"""
    print("\n📱 Creating Flutter Assets...")
    
    flutter_sizes = [36, 48, 72, 96, 144, 192, 256, 512]
    svg_path = 'assets/icons/app_icon.svg'
    
    for size in flutter_sizes:
        output_path = f'assets/icons/generated/app_icon_{size}.png'
        if convert_svg_to_png(svg_path, output_path, size):
            print(f"✅ Created Flutter asset {size}x{size}")

def create_adaptive_icon():
    """Create Android adaptive icon components"""
    print("\n🎨 Creating Android Adaptive Icons...")
    
    # Create foreground (main icon)
    svg_path = 'assets/icons/app_icon.svg'
    foreground_path = 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png'
    
    if convert_svg_to_png(svg_path, foreground_path, 432):  # 432 for xxxhdpi adaptive
        print("✅ Created adaptive icon foreground")
    
    # Create simple background
    background_path = 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_background.png'
    create_adaptive_background(background_path, 432)

def create_adaptive_background(output_path, size):
    """Create a simple gradient background for adaptive icon"""
    try:
        # Create image with gradient background
        img = Image.new('RGB', (size, size), color='#1e3c72')
        draw = ImageDraw.Draw(img)
        
        # Create a subtle radial gradient effect
        center = size // 2
        for i in range(center):
            alpha = 1 - (i / center) * 0.3
            color = (
                int(30 + i * 0.1),   # R
                int(60 + i * 0.15),  # G  
                int(114 + i * 0.2)   # B
            )
            draw.ellipse([center-i, center-i, center+i, center+i], fill=color)
        
        img.save(output_path, 'PNG')
        print("✅ Created adaptive icon background")
        return True
    except Exception as e:
        print(f"❌ Error creating background: {e}")
        return False

def create_ios_contents_json():
    """Create Contents.json for iOS AppIcon.appiconset"""
    contents = {
        "images": [
            {"size": "20x20", "idiom": "iphone", "filename": "Icon-App-20x20@2x.png", "scale": "2x"},
            {"size": "20x20", "idiom": "iphone", "filename": "Icon-App-20x20@3x.png", "scale": "3x"},
            {"size": "29x29", "idiom": "iphone", "filename": "Icon-App-29x29@1x.png", "scale": "1x"},
            {"size": "29x29", "idiom": "iphone", "filename": "Icon-App-29x29@2x.png", "scale": "2x"},
            {"size": "29x29", "idiom": "iphone", "filename": "Icon-App-29x29@3x.png", "scale": "3x"},
            {"size": "40x40", "idiom": "iphone", "filename": "Icon-App-40x40@2x.png", "scale": "2x"},
            {"size": "40x40", "idiom": "iphone", "filename": "Icon-App-40x40@3x.png", "scale": "3x"},
            {"size": "60x60", "idiom": "iphone", "filename": "Icon-App-60x60@2x.png", "scale": "2x"},
            {"size": "60x60", "idiom": "iphone", "filename": "Icon-App-60x60@3x.png", "scale": "3x"},
            {"size": "20x20", "idiom": "ipad", "filename": "Icon-App-20x20@1x.png", "scale": "1x"},
            {"size": "20x20", "idiom": "ipad", "filename": "Icon-App-20x20@2x.png", "scale": "2x"},
            {"size": "29x29", "idiom": "ipad", "filename": "Icon-App-29x29@1x.png", "scale": "1x"},
            {"size": "29x29", "idiom": "ipad", "filename": "Icon-App-29x29@2x.png", "scale": "2x"},
            {"size": "40x40", "idiom": "ipad", "filename": "Icon-App-40x40@1x.png", "scale": "1x"},
            {"size": "40x40", "idiom": "ipad", "filename": "Icon-App-40x40@2x.png", "scale": "2x"},
            {"size": "76x76", "idiom": "ipad", "filename": "Icon-App-76x76@1x.png", "scale": "1x"},
            {"size": "76x76", "idiom": "ipad", "filename": "Icon-App-76x76@2x.png", "scale": "2x"},
            {"size": "83.5x83.5", "idiom": "ipad", "filename": "Icon-App-83.5x83.5@2x.png", "scale": "2x"},
            {"size": "1024x1024", "idiom": "ios-marketing", "filename": "Icon-App-1024x1024@1x.png", "scale": "1x"}
        ],
        "info": {
            "version": 1,
            "author": "SmartCent Icon Generator"
        }
    }
    
    import json
    with open('ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json', 'w') as f:
        json.dump(contents, f, indent=2)
    
    print("✅ Created iOS Contents.json")

def create_web_manifest_icons():
    """Create web app manifest with icon references"""
    manifest = {
        "name": "SmartCent",
        "short_name": "SmartCent",
        "description": "Smart family budget and financial education app",
        "start_url": "/",
        "display": "standalone",
        "background_color": "#1e3c72",
        "theme_color": "#3b82f6",
        "icons": [
            {"src": "icons/Icon-192.png", "sizes": "192x192", "type": "image/png"},
            {"src": "icons/Icon-512.png", "sizes": "512x512", "type": "image/png"},
            {"src": "icons/Icon-maskable-192.png", "sizes": "192x192", "type": "image/png", "purpose": "maskable"},
            {"src": "icons/Icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable"}
        ]
    }
    
    import json
    with open('web/manifest.json', 'w') as f:
        json.dump(manifest, f, indent=2)
    
    print("✅ Created web manifest.json")

def main():
    """Main function to generate all icons"""
    print("🎨 SmartCent Icon Generator")
    print("=" * 50)
    
    # Check if Inkscape is available
    if not check_inkscape():
        print("\n💡 Alternative: You can manually convert the SVG using online tools:")
        print("   - https://convertio.co/svg-png/")
        print("   - https://cloudconvert.com/svg-to-png")
        return
    
    # Check if SVG exists
    if not os.path.exists('assets/icons/app_icon.svg'):
        print("❌ SVG icon not found at assets/icons/app_icon.svg")
        return
    
    print("📁 Creating directories...")
    create_directories()
    
    print("\n🚀 Generating icons...")
    create_android_icons()
    create_ios_icons()
    create_web_icons()
    create_flutter_assets()
    create_adaptive_icon()
    
    print("\n📝 Creating configuration files...")
    create_ios_contents_json()
    create_web_manifest_icons()
    
    print("\n✨ Icon generation complete!")
    print("\n📋 Next steps:")
    print("1. Update android/app/src/main/AndroidManifest.xml with icon references")
    print("2. Update ios/Runner/Info.plist with icon references")
    print("3. Add web icons to web/index.html")
    print("4. Update pubspec.yaml with Flutter asset references")
    
    print("\n🎉 Your professional SmartCent icons are ready!")

if __name__ == "__main__":
    main() 