#!/usr/bin/env python3
"""
Premium Professional Icon Generator for SmartCent
Creates elegant, chic icon with sophisticated colors
"""

from PIL import Image, ImageDraw, ImageFilter
import math

def create_elegant_gradient(size, start_color, end_color, style="linear"):
    """Create sophisticated gradient backgrounds"""
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    if style == "radial":
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
    else:
        # Linear gradient
        draw = ImageDraw.Draw(image)
        for y in range(size):
            ratio = y / size
            r = int(start_color[0] * (1 - ratio) + end_color[0] * ratio)
            g = int(start_color[1] * (1 - ratio) + end_color[1] * ratio)
            b = int(start_color[2] * (1 - ratio) + end_color[2] * ratio)
            draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    return image

def add_luxury_shadow(image, offset=(8, 8), blur=16, opacity=0.3):
    """Add elegant drop shadow"""
    # Create shadow
    shadow = Image.new('RGBA', (image.size[0] + offset[0]*2, image.size[1] + offset[1]*2), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    
    # Draw shadow shape
    margin = 20
    shadow_draw.ellipse([
        margin + offset[0], margin + offset[1], 
        shadow.size[0] - margin + offset[0], shadow.size[1] - margin + offset[1]
    ], fill=(0, 0, 0, int(255 * opacity)))
    
    # Blur shadow
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    
    # Composite
    result = Image.new('RGBA', shadow.size, (0, 0, 0, 0))
    result.paste(shadow, (0, 0))
    result.paste(image, (offset[0], offset[1]), image)
    
    return result

def create_premium_smartcent_icon(size):
    """Create premium SmartCent icon with chic colors"""
    
    # Sophisticated color palette
    colors = {
        # Deep luxury navy to royal blue
        'bg_start': (15, 23, 42),      # slate-900 #0f172a
        'bg_end': (30, 58, 138),       # blue-800 #1e3a8a
        
        # Premium accent colors
        'coin_gradient_start': (6, 182, 212),   # cyan-500 #06b6d4
        'coin_gradient_end': (14, 116, 144),    # cyan-700 #0e7490
        
        # Elegant highlights
        'premium_gold': (251, 191, 36),  # amber-400 #fbbf24
        'pure_white': (255, 255, 255),
        'soft_white': (248, 250, 252),  # slate-50 #f8fafc
        
        # Sophisticated accent
        'accent_purple': (139, 92, 246), # violet-500 #8b5cf6
        'accent_emerald': (16, 185, 129), # emerald-500 #10b981
    }
    
    # Create base with radial gradient
    base = create_elegant_gradient(size, colors['bg_start'], colors['bg_end'], "radial")
    draw = ImageDraw.Draw(base)
    
    # Add subtle outer glow
    margin = int(size * 0.03)
    outer_ring = int(size * 0.02)
    
    # Outer elegant border with gradient effect
    for i in range(outer_ring):
        alpha = int(50 * (1 - i / outer_ring))
        color = (*colors['coin_gradient_start'], alpha)
        draw.ellipse([
            margin + i, margin + i, 
            size - margin - i, size - margin - i
        ], outline=color, width=1)
    
    # Main premium circle background
    circle_margin = int(size * 0.08)
    circle_bg = create_elegant_gradient(
        size - circle_margin * 2, 
        colors['coin_gradient_start'], 
        colors['coin_gradient_end'], 
        "radial"
    )
    
    # Add metallic effect to coin
    metallic_overlay = Image.new('RGBA', circle_bg.size, (0, 0, 0, 0))
    met_draw = ImageDraw.Draw(metallic_overlay)
    
    # Create metallic highlight
    highlight_size = int(circle_bg.size[0] * 0.3)
    highlight_pos = int(circle_bg.size[0] * 0.2)
    met_draw.ellipse([
        highlight_pos, highlight_pos,
        highlight_pos + highlight_size, highlight_pos + highlight_size
    ], fill=(*colors['soft_white'], 40))
    
    # Blend metallic effect
    circle_bg = Image.alpha_composite(circle_bg, metallic_overlay)
    
    # Paste coin background
    base.paste(circle_bg, (circle_margin, circle_margin), circle_bg)
    
    # Inner premium border
    inner_margin = int(size * 0.12)
    draw.ellipse([
        inner_margin, inner_margin,
        size - inner_margin, size - inner_margin
    ], outline=colors['premium_gold'], width=max(2, int(size * 0.004)))
    
    # Secondary inner border
    inner_margin2 = int(size * 0.15)
    draw.ellipse([
        inner_margin2, inner_margin2,
        size - inner_margin2, size - inner_margin2
    ], outline=(*colors['pure_white'], 180), width=max(1, int(size * 0.002)))
    
    # Central elegant cent symbol
    center_x, center_y = size // 2, size // 2
    
    # Premium cent symbol with gradient effect
    cent_radius = int(size * 0.18)
    cent_thickness = max(3, int(size * 0.025))
    
    # Create cent symbol with premium styling
    cent_bbox = [
        center_x - cent_radius, center_y - cent_radius,
        center_x + cent_radius, center_y + cent_radius
    ]
    
    # Main cent arc with golden accent
    draw.arc(cent_bbox, start=25, end=335, 
             fill=colors['premium_gold'], width=cent_thickness)
    
    # Inner cent arc for depth
    inner_cent_bbox = [
        center_x - cent_radius + 2, center_y - cent_radius + 2,
        center_x + cent_radius - 2, center_y + cent_radius - 2
    ]
    draw.arc(inner_cent_bbox, start=25, end=335, 
             fill=colors['pure_white'], width=max(1, cent_thickness-2))
    
    # Elegant vertical line through cent
    line_start_y = center_y - int(size * 0.22)
    line_end_y = center_y + int(size * 0.22)
    line_thickness = max(3, int(size * 0.025))
    
    # Golden line
    draw.line([
        (center_x, line_start_y), (center_x, line_end_y)
    ], fill=colors['premium_gold'], width=line_thickness)
    
    # White inner line for elegance
    draw.line([
        (center_x, line_start_y + 2), (center_x, line_end_y - 2)
    ], fill=colors['pure_white'], width=max(1, line_thickness-2))
    
    # Sophisticated corner accents
    corner_size = int(size * 0.08)
    corner_thickness = max(2, int(size * 0.008))
    corner_offset = int(size * 0.15)
    
    accent_positions = [
        (corner_offset, corner_offset),  # Top-left
        (size - corner_offset - corner_size, corner_offset),  # Top-right
        (corner_offset, size - corner_offset - corner_size),  # Bottom-left
        (size - corner_offset - corner_size, size - corner_offset - corner_size),  # Bottom-right
    ]
    
    for i, (x, y) in enumerate(accent_positions):
        accent_color = colors['accent_emerald'] if i % 2 == 0 else colors['accent_purple']
        
        # Corner accent lines
        draw.rectangle([
            x, y, x + corner_size, y + corner_thickness
        ], fill=accent_color)
        draw.rectangle([
            x, y, x + corner_thickness, y + corner_size
        ], fill=accent_color)
    
    # Premium smart dots constellation
    if size >= 64:  # Only for larger sizes
        dot_radius = max(2, int(size * 0.012))
        orbit_radius = int(size * 0.38)
        
        # Create constellation pattern
        star_angles = [0, 45, 90, 135, 180, 225, 270, 315]
        
        for i, angle in enumerate(star_angles):
            x = center_x + int(math.cos(math.radians(angle)) * orbit_radius)
            y = center_y + int(math.sin(math.radians(angle)) * orbit_radius)
            
            # Alternating premium colors
            dot_color = colors['premium_gold'] if i % 2 == 0 else colors['pure_white']
            
            # Main dot
            draw.ellipse([
                x - dot_radius, y - dot_radius,
                x + dot_radius, y + dot_radius
            ], fill=dot_color)
            
            # Subtle glow around dots
            if size >= 128:
                glow_radius = dot_radius + 2
                draw.ellipse([
                    x - glow_radius, y - glow_radius,
                    x + glow_radius, y + glow_radius
                ], fill=(*dot_color, 50))
    
    # Final premium touch - subtle vignette
    vignette = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    vig_draw = ImageDraw.Draw(vignette)
    
    # Create soft vignette effect
    vignette_strength = 0.15
    center = size // 2
    for y in range(size):
        for x in range(size):
            distance = math.sqrt((x - center) ** 2 + (y - center) ** 2)
            max_distance = math.sqrt(2 * (center ** 2))
            
            if distance > center * 0.7:  # Only apply to edges
                alpha = int(255 * vignette_strength * min((distance - center * 0.7) / (max_distance - center * 0.7), 1.0))
                vignette.putpixel((x, y), (0, 0, 0, alpha))
    
    # Apply vignette
    base = Image.alpha_composite(base, vignette)
    
    return base

def create_premium_icon():
    """Create and save premium icon"""
    print("✨ Creating Premium SmartCent Icon with Chic Colors...")
    
    # Create high-quality icon
    size = 512  # High resolution for quality
    icon = create_premium_smartcent_icon(size)
    
    # Save premium version
    icon.save("premium_smartcent_icon.png", format='PNG', optimize=True)
    print(f"🎨 Premium icon created: premium_smartcent_icon.png")
    print(f"📏 Size: {size}x{size} pixels")
    print(f"🎯 Features: Elegant gradients, premium gold accents, sophisticated styling")
    
    # Create additional sizes
    sizes = [64, 128, 256, 1024]
    for s in sizes:
        resized = icon.resize((s, s), Image.Resampling.LANCZOS)
        resized.save(f"premium_smartcent_{s}.png", format='PNG', optimize=True)
        print(f"📱 Created {s}x{s} version")
    
    print("\n🏆 Premium SmartCent Icon Collection Created!")
    return icon

if __name__ == "__main__":
    create_premium_icon() 