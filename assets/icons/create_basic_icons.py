#!/usr/bin/env python3
"""
Basic Icon Generator for SmartCent App
Creates essential PNG icons for Flutter app
"""

import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_gradient_background(size, color1, color2):
    """Create a gradient background"""
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    for y in range(size):
        # Calculate blend ratio
        ratio = y / size
        r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
        g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
        b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
        
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    return image

def create_smartcent_icon(size):
    """Create SmartCent app icon"""
    # Colors
    blue_dark = (30, 60, 114)  # #1e3c72
    blue_light = (59, 130, 246)  # #3b82f6
    green = (16, 185, 129)  # #10b981
    white = (255, 255, 255)
    
    # Create base image with gradient
    image = create_gradient_background(size, blue_dark, blue_light)
    draw = ImageDraw.Draw(image)
    
    # Draw main circle background
    margin = int(size * 0.05)
    circle_size = size - (margin * 2)
    circle_pos = margin
    
    # Main background circle
    draw.ellipse([margin, margin, size-margin, size-margin], 
                fill=blue_light, outline=None)
    
    # Inner circle for coin
    coin_margin = int(size * 0.2)
    coin_size = size - (coin_margin * 2)
    draw.ellipse([coin_margin, coin_margin, size-coin_margin, size-coin_margin],
                fill=green, outline=white, width=int(size*0.01))
    
    # Draw cent symbol (¢)
    center_x, center_y = size // 2, size // 2
    cent_size = int(size * 0.25)
    
    # Cent symbol circle (incomplete)
    cent_thickness = int(size * 0.02)
    cent_radius = int(size * 0.15)
    
    # Draw cent arc (right side open)
    bbox = [center_x - cent_radius, center_y - cent_radius,
            center_x + cent_radius, center_y + cent_radius]
    
    # Create cent symbol by drawing arcs
    draw.arc(bbox, start=30, end=330, fill=white, width=cent_thickness)
    
    # Vertical line through cent
    line_start_y = center_y - int(size * 0.2)
    line_end_y = center_y + int(size * 0.2)
    draw.line([(center_x, line_start_y), (center_x, line_end_y)], 
              fill=white, width=cent_thickness)
    
    # Add small smart dots around
    dot_radius = int(size * 0.01)
    for angle in range(0, 360, 45):
        x = center_x + int(math.cos(math.radians(angle)) * size * 0.35)
        y = center_y + int(math.sin(math.radians(angle)) * size * 0.35)
        draw.ellipse([x-dot_radius, y-dot_radius, x+dot_radius, y+dot_radius],
                    fill=white)
    
    return image

def create_icons():
    """Create all required icons"""
    print("🎨 Creating SmartCent Basic Icons...")
    
    # Icon sizes needed
    sizes = {
        # Android
        'android/mipmap-mdpi': 48,
        'android/mipmap-hdpi': 72,
        'android/mipmap-xhdpi': 96,
        'android/mipmap-xxhdpi': 144,
        'android/mipmap-xxxhdpi': 192,
        
        # iOS
        'ios': 1024,  # App Store
        'ios/Icon-App-20x20@1x': 20,
        'ios/Icon-App-20x20@2x': 40,
        'ios/Icon-App-20x20@3x': 60,
        'ios/Icon-App-29x29@1x': 29,
        'ios/Icon-App-29x29@2x': 58,
        'ios/Icon-App-29x29@3x': 87,
        'ios/Icon-App-40x40@1x': 40,
        'ios/Icon-App-40x40@2x': 80,
        'ios/Icon-App-40x40@3x': 120,
        'ios/Icon-App-60x60@2x': 120,
        'ios/Icon-App-60x60@3x': 180,
        'ios/Icon-App-76x76@1x': 76,
        'ios/Icon-App-76x76@2x': 152,
        'ios/Icon-App-83.5x83.5@2x': 167,
        
        # Web/Flutter
        'web/favicon': 32,
        'web/icon-192': 192,
        'web/icon-512': 512,
        'flutter': 1024,
    }
    
    created_count = 0
    
    for path, size in sizes.items():
        try:
            # Create directory if needed
            dir_path = os.path.dirname(path) if '/' in path else ''
            if dir_path and not os.path.exists(dir_path):
                os.makedirs(dir_path)
            
            # Create icon
            icon = create_smartcent_icon(size)
            
            # Save with proper filename
            if path.endswith('favicon'):
                filename = f"{path}.ico"
                icon.save(filename, format='ICO', sizes=[(32, 32)])
            else:
                filename = f"{path}.png" if not path.endswith('.png') else path
                if '/' in filename:
                    filename = filename.replace('/', '_') + '.png'
                
                icon.save(filename, format='PNG', optimize=True)
            
            created_count += 1
            print(f"✅ Created {filename} ({size}x{size})")
            
        except Exception as e:
            print(f"❌ Failed to create {path}: {e}")
    
    print(f"\n🎉 Successfully created {created_count} icons!")
    print("\n📱 Integration steps:")
    print("1. Copy Android icons to android/app/src/main/res/")
    print("2. Copy iOS icons to ios/Runner/Assets.xcassets/AppIcon.appiconset/")
    print("3. Update pubspec.yaml with icon references")
    print("4. Run 'flutter clean && flutter build' to apply changes")

if __name__ == "__main__":
    create_icons() 