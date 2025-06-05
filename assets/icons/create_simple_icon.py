#!/usr/bin/env python3
"""
Simple SmartCent Icon Generator
Creates a basic PNG version of the SmartCent app icon using PIL/Pillow only.
No external dependencies like Inkscape required.

Usage: python create_simple_icon.py

Requirements:
pip install Pillow
"""

import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_gradient_background(size, color1, color2):
    """Create a simple linear gradient background"""
    img = Image.new('RGB', (size, size))
    draw = ImageDraw.Draw(img)
    
    for y in range(size):
        # Linear interpolation between colors
        ratio = y / size
        r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
        g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
        b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
        
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    return img

def create_simple_smartcent_icon(size=512):
    """Create a simplified version of the SmartCent icon"""
    
    # Colors
    bg_color1 = (30, 60, 114)    # Deep blue
    bg_color2 = (59, 130, 246)   # Bright blue
    coin_color1 = (16, 185, 129) # Green
    coin_color2 = (5, 150, 105)  # Dark green
    white = (255, 255, 255)
    
    # Create base image with gradient
    img = create_gradient_background(size, bg_color1, bg_color2)
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    
    # Draw outer circle (coin background)
    coin_radius = int(size * 0.35)
    coin_bbox = [
        center - coin_radius,
        center - coin_radius,
        center + coin_radius,
        center + coin_radius
    ]
    
    # Create coin gradient effect
    for i in range(coin_radius, 0, -2):
        ratio = (coin_radius - i) / coin_radius
        r = int(coin_color1[0] * (1 - ratio) + coin_color2[0] * ratio)
        g = int(coin_color1[1] * (1 - ratio) + coin_color2[1] * ratio)
        b = int(coin_color1[2] * (1 - ratio) + coin_color2[2] * ratio)
        
        draw.ellipse([
            center - i,
            center - i,
            center + i,
            center + i
        ], fill=(r, g, b))
    
    # Draw coin border
    border_width = max(2, size // 100)
    draw.ellipse(coin_bbox, outline=white, width=border_width)
    
    # Draw inner border
    inner_radius = coin_radius - 10
    inner_bbox = [
        center - inner_radius,
        center - inner_radius,
        center + inner_radius,
        center + inner_radius
    ]
    draw.ellipse(inner_bbox, outline=white, width=border_width//2)
    
    # Draw smart brain at top
    brain_y = center - coin_radius // 2
    brain_size = coin_radius // 3
    
    # Brain outline
    brain_bbox = [
        center - brain_size//2,
        brain_y - brain_size//3,
        center + brain_size//2,
        brain_y + brain_size//3
    ]
    draw.ellipse(brain_bbox, fill=white)
    
    # Brain connections (simple lines)
    line_width = max(1, size // 200)
    draw.line([center - brain_size//3, brain_y, center + brain_size//3, brain_y], fill=coin_color1, width=line_width)
    draw.line([center - brain_size//4, brain_y + 5, center + brain_size//4, brain_y + 5], fill=coin_color1, width=line_width)
    
    # Central processing dot
    dot_radius = max(2, size // 150)
    draw.ellipse([
        center - dot_radius,
        brain_y - dot_radius,
        center + dot_radius,
        brain_y + dot_radius
    ], fill=coin_color1)
    
    # Draw cent symbol (¢) in center
    cent_y = center + coin_radius // 6
    
    # Try to use a font, fallback to drawing if not available
    try:
        font_size = max(24, size // 8)
        font = ImageFont.truetype("arial.ttf", font_size)
        draw.text((center, cent_y), "¢", font=font, fill=white, anchor="mm")
    except:
        # Fallback: draw cent symbol manually
        cent_radius = coin_radius // 3
        
        # Draw the C part
        cent_bbox = [
            center - cent_radius,
            cent_y - cent_radius,
            center + cent_radius//2,
            cent_y + cent_radius
        ]
        
        # Draw arc for C (approximate with polygon)
        points = []
        for angle in range(45, 315, 10):  # 270 degrees for C shape
            x = center + (cent_radius * 0.8) * math.cos(math.radians(angle))
            y = cent_y + (cent_radius * 0.8) * math.sin(math.radians(angle))
            points.append((x, y))
        
        if len(points) > 1:
            for i in range(len(points) - 1):
                draw.line([points[i], points[i+1]], fill=white, width=max(3, size//60))
        
        # Draw vertical line through cent
        line_height = cent_radius * 1.5
        draw.line([
            center + cent_radius//4,
            cent_y - line_height//2,
            center + cent_radius//4,
            cent_y + line_height//2
        ], fill=white, width=max(2, size//80))
    
    # Draw decorative dots around coin
    dot_distance = coin_radius + 20
    dot_radius = max(2, size // 150)
    
    for angle in range(0, 360, 45):
        x = center + dot_distance * math.cos(math.radians(angle))
        y = center + dot_distance * math.sin(math.radians(angle))
        
        draw.ellipse([
            x - dot_radius,
            y - dot_radius,
            x + dot_radius,
            y + dot_radius
        ], fill=white)
    
    # Draw corner accents
    accent_size = size // 20
    accent_thickness = max(2, size // 100)
    
    corners = [
        (accent_size, accent_size),              # Top left
        (size - accent_size * 2, accent_size),   # Top right  
        (accent_size, size - accent_size * 2),   # Bottom left
        (size - accent_size * 2, size - accent_size * 2)  # Bottom right
    ]
    
    for x, y in corners:
        # Draw L-shaped accent
        draw.rectangle([x, y, x + accent_size, y + accent_thickness], fill=coin_color1)
        draw.rectangle([x, y, x + accent_thickness, y + accent_size], fill=coin_color1)
    
    return img

def create_all_sizes():
    """Create icons in common sizes"""
    sizes = [16, 32, 48, 72, 96, 144, 192, 256, 512, 1024]
    
    # Create output directory
    os.makedirs('assets/icons/generated', exist_ok=True)
    
    print("🎨 Creating SmartCent Icons...")
    
    for size in sizes:
        img = create_simple_smartcent_icon(size)
        filename = f'assets/icons/generated/smartcent_icon_{size}.png'
        img.save(filename, 'PNG')
        print(f"✅ Created {filename} ({size}×{size})")
    
    # Create a special app icon
    app_icon = create_simple_smartcent_icon(512)
    app_icon.save('assets/icons/app_icon.png', 'PNG')
    print(f"✅ Created assets/icons/app_icon.png (512×512)")
    
    print("\n🎉 Simple SmartCent icons created successfully!")
    print("💡 For higher quality icons, use the SVG version with the full generator.")

if __name__ == "__main__":
    try:
        create_all_sizes()
    except ImportError:
        print("❌ PIL/Pillow not found. Please install it:")
        print("pip install Pillow")
    except Exception as e:
        print(f"❌ Error creating icons: {e}")
        print("Make sure you have write permissions in the assets directory.") 