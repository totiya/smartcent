from PIL import Image
import os

print("🎯 Using YOUR exact uploaded image...")

try:
    # Open YOUR uploaded image exactly as you provided it
    your_image = Image.open('custom_icon.png.jpg')
    print(f"📷 Your image size: {your_image.size}")
    
    # Just convert to PNG format (no modification to your design)
    if your_image.mode != 'RGBA':
        your_image = your_image.convert('RGBA')
    
    # Save your exact image as the app icon
    your_image.save('your_exact_smartcent_icon.png', format='PNG', optimize=True)
    print(f"✅ Saved your exact image as: your_exact_smartcent_icon.png")
    
    # Create required sizes from YOUR exact image
    sizes = [64, 128, 256, 512, 1024]
    for size in sizes:
        resized = your_image.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(f'your_exact_{size}.png')
        print(f"✅ Created {size}x{size} from your image")
    
    print("🎉 Using YOUR exact uploaded image!")
    print("📁 Main: your_exact_smartcent_icon.png")

except Exception as e:
    print(f"❌ Error: {e}")
    print("Current files:")
    for f in os.listdir('.'):
        if f.endswith(('.png', '.jpg', '.jpeg')):
            print(f"  - {f}") 