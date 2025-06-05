from PIL import Image
import os

def convert_png_to_ico(png_path, ico_path):
    """Convert PNG to ICO format with multiple sizes"""
    try:
        print(f"🔄 Converting {png_path} to {ico_path}")
        
        # Open the PNG image
        img = Image.open(png_path)
        print(f"📐 Original size: {img.width}x{img.height}")
        
        # Convert to RGBA if needed
        if img.mode != 'RGBA':
            img = img.convert('RGBA')
        
        # ICO files can contain multiple sizes
        # Common Windows icon sizes
        sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
        
        # Create resized versions
        resized_images = []
        for size in sizes:
            resized = img.resize(size, Image.Resampling.LANCZOS)
            resized_images.append(resized)
            print(f"✅ Created {size[0]}x{size[1]} version")
        
        # Save as ICO with multiple sizes
        img.save(ico_path, format='ICO', sizes=sizes)
        print(f"🎉 Successfully created {ico_path}")
        
        # Show file size
        if os.path.exists(ico_path):
            size = os.path.getsize(ico_path)
            print(f"📊 ICO file size: {size:,} bytes")
        
        return True
        
    except Exception as e:
        print(f"❌ Error converting to ICO: {e}")
        return False

if __name__ == "__main__":
    # Convert your new icon to ICO format
    png_file = "my_new_icon.png.png"
    ico_file = "windows_app_icon.ico"
    
    if os.path.exists(png_file):
        if convert_png_to_ico(png_file, ico_file):
            print(f"\n🎯 ICO file created: {ico_file}")
            print("📁 Ready to copy to windows/runner/resources/app_icon.ico")
        else:
            print("\n❌ Failed to create ICO file")
    else:
        print(f"❌ {png_file} not found")
        print("📁 Available PNG files:")
        for f in os.listdir('.'):
            if f.lower().endswith('.png'):
                print(f"   - {f}") 