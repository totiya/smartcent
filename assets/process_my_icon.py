from PIL import Image
import os
from datetime import datetime

print("🎯 Processing your teal icon: my_new_icon.png.png")

try:
    # Check if the file exists (user saved it as my_new_icon.png.png)
    if os.path.exists('my_new_icon.png.png'):
        print("✅ Found my_new_icon.png.png!")
        
        # Get file info
        file_size = os.path.getsize('my_new_icon.png.png')
        print(f"📊 File size: {file_size:,} bytes")
        
        # Open and process the image
        new_icon = Image.open('my_new_icon.png.png')
        print(f"📐 Image size: {new_icon.width}x{new_icon.height}")
        print(f"🎨 Image mode: {new_icon.mode}")
        
        # Backup current final_smartcent_icon.png if it exists
        if os.path.exists('final_smartcent_icon.png'):
            backup_name = f"backup_final_{datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
            os.rename('final_smartcent_icon.png', backup_name)
            print(f"📦 Backed up old icon as: {backup_name}")
        
        # Convert to RGBA if needed
        if new_icon.mode != 'RGBA':
            new_icon = new_icon.convert('RGBA')
            print("🔄 Converted to RGBA format")
        
        # Save as final_smartcent_icon.png
        new_icon.save('final_smartcent_icon.png', format='PNG', optimize=True)
        print("🎉 SUCCESS! Created new final_smartcent_icon.png")
        
        # Show new file info
        new_size = os.path.getsize('final_smartcent_icon.png')
        print(f"📊 New final_smartcent_icon.png size: {new_size:,} bytes")
        
        # Create multiple sizes for the app
        sizes = [64, 128, 192, 256, 512, 1024]
        print("\n📱 Creating app icon sizes...")
        
        for size in sizes:
            resized = new_icon.resize((size, size), Image.Resampling.LANCZOS)
            resized.save(f'final_smartcent_{size}.png')
            print(f"✅ Created {size}x{size} version")
        
        print("\n🎉 COMPLETE! Your teal icon is now the app icon!")
        print("📁 Main file: final_smartcent_icon.png")
        
    else:
        print("❌ my_new_icon.png.png not found")
        print("📁 Available files:")
        for f in os.listdir('.'):
            if f.endswith(('.png', '.jpg', '.jpeg')):
                print(f"   - {f}")
                
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc() 