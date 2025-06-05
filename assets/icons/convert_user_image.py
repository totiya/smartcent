#!/usr/bin/env python3
"""
Convert User's Custom Icon Image to App Icon Formats
Takes the user's provided image and creates all necessary icon sizes
"""

from PIL import Image
import os

def convert_user_icon_to_formats(input_image_path):
    """Convert user's icon to all required formats"""
    print(f"🖼️ Converting your custom icon: {input_image_path}")
    
    try:
        # Open the user's image
        original = Image.open(input_image_path)
        print(f"📏 Original size: {original.size}")
        
        # Convert to RGBA if needed
        if original.mode != 'RGBA':
            original = original.convert('RGBA')
        
        # Make it square if it isn't
        width, height = original.size
        if width != height:
            # Create square canvas
            size = max(width, height)
            square = Image.new('RGBA', (size, size), (0, 0, 0, 0))
            
            # Center the image
            x = (size - width) // 2
            y = (size - height) // 2
            square.paste(original, (x, y))
            original = square
            print(f"✅ Made square: {original.size}")
        
        # Save high-quality master
        original.save("user_custom_icon_master.png", format='PNG', optimize=True)
        print(f"💎 Master icon saved: user_custom_icon_master.png")
        
        # Create all required sizes
        sizes = {
            # Main app icons
            'user_icon_1024': 1024,
            'user_icon_512': 512,
            'user_icon_256': 256,
            'user_icon_128': 128,
            'user_icon_64': 64,
            
            # Android sizes
            'android_mdpi': 48,
            'android_hdpi': 72,
            'android_xhdpi': 96,
            'android_xxhdpi': 144,
            'android_xxxhdpi': 192,
            
            # iOS sizes
            'ios_20': 20,
            'ios_29': 29,
            'ios_40': 40,
            'ios_58': 58,
            'ios_60': 60,
            'ios_76': 76,
            'ios_80': 80,
            'ios_87': 87,
            'ios_120': 120,
            'ios_152': 152,
            'ios_167': 167,
            'ios_180': 180,
            'ios_1024': 1024,
            
            # Web/PWA
            'web_16': 16,
            'web_32': 32,
            'web_192': 192,
            'web_512': 512,
        }
        
        created_count = 0
        
        for name, size in sizes.items():
            try:
                # High-quality resize
                resized = original.resize((size, size), Image.Resampling.LANCZOS)
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
                ico_img = original.resize((ico_size, ico_size), Image.Resampling.LANCZOS)
                ico_images.append(ico_img)
            
            # Save ICO file
            ico_images[0].save("user_custom_icon.ico", format='ICO', 
                             sizes=[(img.size[0], img.size[1]) for img in ico_images])
            print(f"🪟 Created user_custom_icon.ico")
            created_count += 1
        except Exception as e:
            print(f"❌ Failed to create ICO: {e}")
        
        print(f"\n🎉 Successfully created {created_count} icon files!")
        print(f"📁 All files saved in: {os.getcwd()}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error processing image: {e}")
        return False

def main():
    """Main function to convert user's custom icon"""
    print("🎨 Custom Icon Converter for SmartCent")
    print("=" * 50)
    
    # Look for common image file names
    possible_files = [
        "custom_icon.png", "user_icon.png", "icon.png", 
        "app_icon.png", "smartcent_icon.png",
        "custom_icon.jpg", "user_icon.jpg", "icon.jpg"
    ]
    
    input_file = None
    
    # Check if any of these files exist
    for filename in possible_files:
        if os.path.exists(filename):
            input_file = filename
            break
    
    if input_file:
        print(f"📁 Found image file: {input_file}")
        success = convert_user_icon_to_formats(input_file)
        
        if success:
            print("\n✨ Your custom icon is ready!")
            print("\n📱 Next steps:")
            print("1. Your master icon: user_custom_icon_master.png")
            print("2. Copy to assets folder: copy user_custom_icon_master.png ../custom_smartcent_icon.png")
            print("3. Update app configuration to use your custom icon")
        else:
            print("\n❌ Failed to convert your icon")
    else:
        print("📁 No image file found. Please:")
        print("1. Save your icon image as 'custom_icon.png' in this folder")
        print("2. Run this script again")
        print(f"📂 Current folder: {os.getcwd()}")

if __name__ == "__main__":
    main() 