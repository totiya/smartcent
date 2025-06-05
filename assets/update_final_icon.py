from PIL import Image
import os

print("🎯 Updating final_smartcent_icon.png with your new uploaded icon...")

try:
    # First, you need to save your uploaded image as 'new_icon_upload.png'
    # Then this script will process it
    
    if os.path.exists('new_icon_upload.png'):
        print("📷 Found your new uploaded icon!")
        
        # Open your new uploaded icon
        new_icon = Image.open('new_icon_upload.png')
        print(f"📐 Your new icon size: {new_icon.size}")
        
        # Convert to RGBA if needed
        if new_icon.mode != 'RGBA':
            new_icon = new_icon.convert('RGBA')
        
        # Replace the final_smartcent_icon.png with your new design
        new_icon.save('final_smartcent_icon.png', format='PNG', optimize=True)
        print("✅ Replaced final_smartcent_icon.png with your new design!")
        
        # Create all required sizes for the app
        sizes = [64, 128, 192, 256, 512, 1024]
        
        for size in sizes:
            resized = new_icon.resize((size, size), Image.Resampling.LANCZOS)
            resized.save(f'final_smartcent_{size}.png')
            print(f"✅ Created {size}x{size} version")
        
        print("🎉 Successfully updated with your beautiful new icon!")
        print("📁 Main file: final_smartcent_icon.png")
        
        # Show file info
        file_size = os.path.getsize('final_smartcent_icon.png')
        print(f"📊 File size: {file_size:,} bytes")
        
    else:
        print("❌ Please save your uploaded icon as 'new_icon_upload.png' first")
        print("💡 Or I can help you with an alternative method")
        
        # Show current icon info
        if os.path.exists('final_smartcent_icon.png'):
            current_size = os.path.getsize('final_smartcent_icon.png')
            print(f"📁 Current final_smartcent_icon.png: {current_size:,} bytes")

except Exception as e:
    print(f"❌ Error: {e}")
    print("📁 Available files:")
    for f in sorted(os.listdir('.')):
        if f.endswith(('.png', '.jpg', '.jpeg')):
            size = os.path.getsize(f)
            print(f"  - {f} ({size:,} bytes)") 