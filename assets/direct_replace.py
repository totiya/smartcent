from PIL import Image
import os
from datetime import datetime

print("🎯 Direct replacement of final_smartcent_icon.png")

# Show current files
print("📁 Current image files in assets:")
for f in sorted(os.listdir('.')):
    if f.endswith(('.png', '.jpg', '.jpeg')):
        size = os.path.getsize(f)
        modified = datetime.fromtimestamp(os.path.getmtime(f))
        print(f"   - {f} ({size:,} bytes, {modified.strftime('%Y-%m-%d %H:%M')})")

print(f"\n📍 Current directory: {os.getcwd()}")
print("\n🎯 To replace final_smartcent_icon.png:")
print("1. Save your uploaded teal icon as 'my_new_icon.png' in this folder")
print("2. Or tell me which existing file to use as the new icon")
print("3. I'll immediately replace final_smartcent_icon.png with your choice")

# Check if user saved a new icon
if os.path.exists('my_new_icon.png'):
    print("\n✅ Found my_new_icon.png! Processing...")
    try:
        # Backup current icon
        if os.path.exists('final_smartcent_icon.png'):
            backup_name = f"backup_final_{datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
            os.rename('final_smartcent_icon.png', backup_name)
            print(f"📦 Backed up old icon as: {backup_name}")
        
        # Replace with new icon
        new_icon = Image.open('my_new_icon.png')
        if new_icon.mode != 'RGBA':
            new_icon = new_icon.convert('RGBA')
        
        # Save as final_smartcent_icon.png
        new_icon.save('final_smartcent_icon.png', format='PNG', optimize=True)
        print("🎉 SUCCESS! Replaced final_smartcent_icon.png with your teal icon!")
        
        new_size = os.path.getsize('final_smartcent_icon.png')
        print(f"📊 New icon size: {new_size:,} bytes")
        
    except Exception as e:
        print(f"❌ Error processing: {e}")
        
elif input("Type filename to use (or press Enter to skip): ").strip():
    filename = input("Type filename to use (or press Enter to skip): ").strip()
    if os.path.exists(filename):
        print(f"Using {filename} as new icon...")
        # Process the specified file
    else:
        print(f"File {filename} not found")
        
print("\n💡 Once you save your teal icon, run this script again!") 