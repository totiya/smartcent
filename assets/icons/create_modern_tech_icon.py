#!/usr/bin/env python3
"""
Modern Tech Icon Generator for SmartCent
Creates sleek icon with dollar sign and circuit elements like the reference image
"""

from PIL import Image, ImageDraw
import math

def create_modern_gradient(size, start_color, end_color):
    """Create modern gradient background"""
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    # Radial gradient from center
    center = size // 2
    max_distance = math.sqrt(2 * (center ** 2))
    
    for y in range(size):
        for x in range(size):
            # Calculate distance from center
            distance = math.sqrt((x - center) ** 2 + (y - center) ** 2)
            ratio = min(distance / max_distance, 1.0)
            
            # Blend colors
            r = int(start_color[0] * (1 - ratio) + end_color[0] * ratio)
            g = int(start_color[1] * (1 - ratio) + end_color[1] * ratio)
            b = int(start_color[2] * (1 - ratio) + end_color[2] * ratio)
            
            image.putpixel((x, y), (r, g, b, 255))
    
    return image

def create_modern_smartcent_icon(size):
    """Create modern SmartCent icon with dollar sign and tech elements"""
    
    # Modern color palette (like the reference image)
    colors = {
        # Teal gradient background
        'bg_start': (56, 178, 172),    # teal-500 #38b2ac
        'bg_end': (49, 130, 206),      # blue-500 #3182ce
        
        # Clean whites
        'pure_white': (255, 255, 255),
        'soft_white': (248, 250, 252),
        
        # Tech accents
        'tech_blue': (99, 179, 237),   # light blue
        'tech_green': (72, 187, 120),  # green-400
    }
    
    # Create base with modern gradient
    base = create_modern_gradient(size, colors['bg_start'], colors['bg_end'])
    draw = ImageDraw.Draw(base)
    
    # Main circle with clean white border
    border_width = max(3, int(size * 0.015))
    margin = int(size * 0.05)
    
    # Outer white border
    draw.ellipse([
        margin, margin, 
        size - margin, size - margin
    ], outline=colors['pure_white'], width=border_width)
    
    # Inner clean area
    inner_margin = margin + border_width + 2
    draw.ellipse([
        inner_margin, inner_margin,
        size - inner_margin, size - inner_margin
    ], fill=None, outline=colors['soft_white'], width=1)
    
    # Central dollar sign ($)
    center_x, center_y = size // 2, size // 2
    
    # Dollar sign dimensions
    dollar_width = int(size * 0.35)
    dollar_height = int(size * 0.45)
    dollar_thickness = max(4, int(size * 0.035))
    
    # Create dollar sign path
    # Top curve
    top_start_x = center_x - dollar_width // 3
    top_start_y = center_y - dollar_height // 2
    top_end_x = center_x + dollar_width // 2
    top_end_y = center_y - dollar_height // 4
    
    # Bottom curve  
    bottom_start_x = center_x + dollar_width // 3
    bottom_start_y = center_y + dollar_height // 2
    bottom_end_x = center_x - dollar_width // 2
    bottom_end_y = center_y + dollar_height // 4
    
    # Draw dollar sign curves
    # Top S curve
    draw.arc([
        center_x - dollar_width//2, center_y - dollar_height//2,
        center_x + dollar_width//2, center_y
    ], start=180, end=0, fill=colors['pure_white'], width=dollar_thickness)
    
    # Bottom S curve
    draw.arc([
        center_x - dollar_width//2, center_y,
        center_x + dollar_width//2, center_y + dollar_height//2
    ], start=180, end=0, fill=colors['pure_white'], width=dollar_thickness)
    
    # Vertical line through dollar sign
    line_start_y = center_y - int(dollar_height * 0.65)
    line_end_y = center_y + int(dollar_height * 0.65)
    
    draw.line([
        (center_x, line_start_y), (center_x, line_end_y)
    ], fill=colors['pure_white'], width=dollar_thickness)
    
    # Tech circuit elements around the dollar
    circuit_radius = int(size * 0.38)
    
    # Circuit connection points
    circuit_angles = [30, 60, 120, 150, 210, 240, 300, 330]
    
    for angle in circuit_angles:
        # Calculate position
        x = center_x + int(math.cos(math.radians(angle)) * circuit_radius)
        y = center_y + int(math.sin(math.radians(angle)) * circuit_radius)
        
        # Draw circuit node (small circle)
        node_radius = max(2, int(size * 0.015))
        draw.ellipse([
            x - node_radius, y - node_radius,
            x + node_radius, y + node_radius
        ], fill=colors['pure_white'])
        
        # Draw connection lines to center area
        inner_x = center_x + int(math.cos(math.radians(angle)) * circuit_radius * 0.7)
        inner_y = center_y + int(math.sin(math.radians(angle)) * circuit_radius * 0.7)
        
        line_width = max(1, int(size * 0.004))
        draw.line([
            (x, y), (inner_x, inner_y)
        ], fill=colors['pure_white'], width=line_width)
    
    # Add tech pattern lines (dashed border effect)
    dash_radius = int(size * 0.42)
    dash_length = int(size * 0.02)
    dash_gap = int(size * 0.015)
    dash_width = max(1, int(size * 0.006))
    
    # Create dashed circle pattern
    num_dashes = 24
    for i in range(num_dashes):
        angle = (360 / num_dashes) * i
        
        # Start point
        start_x = center_x + int(math.cos(math.radians(angle)) * dash_radius)
        start_y = center_y + int(math.sin(math.radians(angle)) * dash_radius)
        
        # End point
        end_angle = angle + (360 / num_dashes) * 0.6  # 60% of segment
        end_x = center_x + int(math.cos(math.radians(end_angle)) * dash_radius)
        end_y = center_y + int(math.sin(math.radians(end_angle)) * dash_radius)
        
        # Draw dash
        draw.line([
            (start_x, start_y), (end_x, end_y)
        ], fill=colors['pure_white'], width=dash_width)
    
    # Add subtle tech details on the right side
    tech_x = center_x + int(size * 0.25)
    tech_y = center_y
    
    # Horizontal tech lines
    line_length = int(size * 0.08)
    line_spacing = int(size * 0.02)
    
    for i in range(4):
        y_pos = tech_y - (2 * line_spacing) + (i * line_spacing)
        draw.line([
            (tech_x, y_pos), (tech_x + line_length, y_pos)
        ], fill=colors['pure_white'], width=max(1, int(size * 0.003)))
        
        # Small connection circles
        circle_radius = max(1, int(size * 0.008))
        draw.ellipse([
            tech_x + line_length - circle_radius, y_pos - circle_radius,
            tech_x + line_length + circle_radius, y_pos + circle_radius
        ], fill=colors['pure_white'])
    
    return base

def create_modern_tech_icon():
    """Create and save modern tech icon"""
    print("🚀 Creating Modern Tech SmartCent Icon...")
    
    # Create high-quality icon
    size = 512  # High resolution
    icon = create_modern_smartcent_icon(size)
    
    # Save main version
    icon.save("modern_smartcent_icon.png", format='PNG', optimize=True)
    print(f"💎 Modern tech icon created: modern_smartcent_icon.png")
    print(f"📏 Size: {size}x{size} pixels")
    print(f"🎯 Features: Dollar sign, teal gradient, circuit elements")
    
    # Create additional sizes
    sizes = [64, 128, 256, 1024]
    for s in sizes:
        resized = icon.resize((s, s), Image.Resampling.LANCZOS)
        resized.save(f"modern_smartcent_{s}.png", format='PNG', optimize=True)
        print(f"📱 Created {s}x{s} version")
    
    print("\n🎉 Modern Tech SmartCent Icon Collection Created!")
    print("✨ Style: Clean, modern, tech-focused like your reference image")
    return icon

if __name__ == "__main__":
    create_modern_tech_icon() 