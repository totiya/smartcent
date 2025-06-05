#!/usr/bin/env python3
"""
Crop Circle Icon from User's Image
Takes the user's uploaded image, crops to circle, and creates app icons
"""

from PIL import Image, ImageDraw
import os

def crop_to_circle(image):
    """Crop image to a perfect circle"""
    # Make image square first
    width, height = image.size
    size = min(width, height)
    
    # Create square crop from center
    left = (width - size) // 2
    top = (height - size) // 2
    right = left + size
    bottom = top + size
    
    square_image = image.crop((left, top, right, bottom))
    
    # Create circular mask
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse((0, 0, size, size), fill=255)
    
    # Apply circular mask
    result = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    result.paste(square_image, (0, 0))
    result.putalpha(mask)
    
    return result

def create_app_icons_from_circle(input_path):
    """Create all app icon sizes from the cropped circle"""
    print(f"🎯 Processing your uploaded image: {input_path}")
    
    try:
        # Open the user's image
        original = Image.open(input_path)
        print(f"📏 Original size: {original.size}")
        
        # Convert to RGBA if needed
        if original.mode != 'RGBA':
            original = original.convert('RGBA')
        
        # Crop to circle
        circle_icon = crop_to_circle(original)
        print(f"✂️ Cropped to circle: {circle_icon.size}")
        
        # Save the master circle icon
        circle_icon.save("user_circle_icon_master.png", format='PNG', optimize=True)
        print(f"💎 Master circle icon saved: user_circle_icon_master.png")
        
        # Create all required sizes
        sizes = {
            # Main app icons
            'user_circle_1024': 1024,
            'user_circle_512': 512,
            'user_circle_256': 256,
            'user_circle_128': 128,
            'user_circle_64': 64,
            
            # Android sizes
            'android_circle_mdpi': 48,
            'android_circle_hdpi': 72,
            'android_circle_xhdpi': 96,
            'android_circle_xxhdpi': 144,
            'android_circle_xxxhdpi': 192,
            
            # iOS sizes
            'ios_circle_20': 20,
            'ios_circle_29': 29,
            'ios_circle_40': 40,
            'ios_circle_58': 58,
            'ios_circle_60': 60,
            'ios_circle_76': 76,
            'ios_circle_80': 80,
            'ios_circle_87': 87,
            'ios_circle_120': 120,
            'ios_circle_152': 152,
            'ios_circle_167': 167,
            'ios_circle_180': 180,
            'ios_circle_1024': 1024,
            
            # Web/PWA
            'web_circle_16': 16,
            'web_circle_32': 32,
            'web_circle_192': 192,
            'web_circle_512': 512,
        }
        
        created_count = 0
        
        for name, size in sizes.items():
            try:
                # High-quality resize
                resized = circle_icon.resize((size, size), Image.Resampling.LANCZOS)
                filename = f"{name}.png"
                resized.save(filename, format='PNG', optimize=True)
                print(f"✅ Created {filename} ({size}x{size})")
                created_count += 1
            except Exception as e:
                print(f"❌ Failed to create {name}: {e}")
        
        # Create ICO file for Windows
        try:
            ico_sizes = [16, 32, 48, 64, 128, 256]
            ico_images = []
            for ico_size in ico_sizes:
                ico_img = circle_icon.resize((ico_size, ico_size), Image.Resampling.LANCZOS)
                ico_images.append(ico_img)
            
            # Save ICO file
            ico_images[0].save("user_circle_icon.ico", format='ICO', 
                             sizes=[(img.size[0], img.size[1]) for img in ico_images])
            print(f"🪟 Created user_circle_icon.ico")
            created_count += 1
        except Exception as e:
            print(f"❌ Failed to create ICO: {e}")
        
        print(f"\n🎉 Successfully created {created_count} circle icon files!")
        print(f"📁 All files saved in: {os.getcwd()}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error processing image: {e}")
        return False

def main():
    """Main function to crop and convert user's circle icon"""
    print("🔵 Circle Icon Extractor for SmartCent")
    print("=" * 50)
    
    # Look for the user's uploaded image
    input_file = "custom_icon.png.jpg"
    
    if os.path.exists(input_file):
        print(f"📁 Found your image: {input_file}")
        success = create_app_icons_from_circle(input_file)
        
        if success:
            print("\n✨ Your circle icon is ready!")
            print("\n📱 Next steps:")
            print("1. Master circle icon: user_circle_icon_master.png")
            print("2. Copy to main location: user_circle_icon_master.png")
            print("3. Update app configuration")
        else:
            print("\n❌ Failed to process your circle icon")
    else:
        print(f"📁 Image file not found: {input_file}")
        print(f"📂 Current folder: {os.getcwd()}")

if __name__ == "__main__":
    main() 