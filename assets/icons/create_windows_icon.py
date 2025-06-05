#!/usr/bin/env python3
"""
Windows Icon Generator for SmartCent App
Creates ICO file for Windows application
"""

import os
from PIL import Image, ImageDraw
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
    
    # Main background circle
    draw.ellipse([margin, margin, size-margin, size-margin], 
                fill=blue_light, outline=None)
    
    # Inner circle for coin
    coin_margin = int(size * 0.2)
    draw.ellipse([coin_margin, coin_margin, size-coin_margin, size-coin_margin],
                fill=green, outline=white, width=max(1, int(size*0.01)))
    
    # Draw cent symbol (¢)
    center_x, center_y = size // 2, size // 2
    
    # Cent symbol circle (incomplete)
    cent_thickness = max(2, int(size * 0.02))
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
    
    # Add small smart dots around (only for larger sizes)
    if size >= 32:
        dot_radius = max(1, int(size * 0.01))
        for angle in range(0, 360, 45):
            x = center_x + int(math.cos(math.radians(angle)) * size * 0.35)
            y = center_y + int(math.sin(math.radians(angle)) * size * 0.35)
            draw.ellipse([x-dot_radius, y-dot_radius, x+dot_radius, y+dot_radius],
                        fill=white)
    
    return image

def create_windows_ico():
    """Create Windows ICO file with multiple sizes"""
    print("🪟 Creating SmartCent Windows Icon...")
    
    # Common ICO sizes
    ico_sizes = [16, 24, 32, 48, 64, 128, 256]
    
    # Create icons at different sizes
    icons = []
    for size in ico_sizes:
        icon = create_smartcent_icon(size)
        icons.append(icon)
        print(f"✅ Created {size}x{size} icon")
    
    # Save as ICO with multiple sizes
    ico_path = "app_icon.ico"
    icons[0].save(ico_path, format='ICO', sizes=[(icon.size[0], icon.size[1]) for icon in icons])
    
    print(f"🎉 Successfully created {ico_path}!")
    print(f"📁 Location: {os.path.abspath(ico_path)}")
    
    return ico_path

if __name__ == "__main__":
    create_windows_ico() 