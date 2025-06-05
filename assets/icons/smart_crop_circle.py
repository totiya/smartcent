from PIL import Image, ImageDraw
import numpy as np

print("🎯 Smart cropping - removing black space and creating perfect circle...")

try:
    # Open your uploaded image
    img = Image.open('../custom_icon.png.jpg')
    print(f"📏 Original size: {img.size}")

    # Convert to RGBA if needed
    if img.mode != 'RGBA':
        img = img.convert('RGBA')
    
    # Convert to numpy array for easier processing
    img_array = np.array(img)
    
    # Find non-black pixels (allowing for some tolerance)
    # Black pixels are close to (0,0,0) in RGB
    tolerance = 30  # Adjust if needed
    non_black_mask = (
        (img_array[:,:,0] > tolerance) | 
        (img_array[:,:,1] > tolerance) | 
        (img_array[:,:,2] > tolerance)
    )
    
    # Find the bounding box of non-black content
    rows = np.any(non_black_mask, axis=1)
    cols = np.any(non_black_mask, axis=0)
    
    if np.any(rows) and np.any(cols):
        # Get the bounding box coordinates
        top, bottom = np.where(rows)[0][[0, -1]]
        left, right = np.where(cols)[0][[0, -1]]
        
        print(f"📦 Found content area: {left},{top} to {right},{bottom}")
        
        # Add small padding around the content
        padding = 10
        left = max(0, left - padding)
        top = max(0, top - padding)
        right = min(img.size[0] - 1, right + padding)
        bottom = min(img.size[1] - 1, bottom + padding)
        
        # Crop to remove black space
        cropped = img.crop((left, top, right, bottom))
        print(f"✂️ Cropped to content: {cropped.size}")
        
    else:
        print("⚠️ No non-black content found, using original image")
        cropped = img
    
    # Now make it square by expanding the smaller dimension
    width, height = cropped.size
    size = max(width, height)
    
    # Create square canvas with transparent background
    square = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    # Center the cropped image in the square
    x_offset = (size - width) // 2
    y_offset = (size - height) // 2
    square.paste(cropped, (x_offset, y_offset))
    
    print(f"📐 Made square: {square.size}")
    
    # Create circular mask
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse((0, 0, size, size), fill=255)
    
    # Apply circular mask
    result = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    result.paste(square, (0, 0))
    result.putalpha(mask)
    
    # Save the clean circle icon
    result.save('clean_circle_icon.png', format='PNG', optimize=True)
    print(f"✅ Clean circle icon created: clean_circle_icon.png")
    
    # Create different sizes
    sizes = [64, 128, 256, 512, 1024]
    for s in sizes:
        resized = result.resize((s, s), Image.Resampling.LANCZOS)
        resized.save(f'clean_circle_{s}.png')
        print(f"✅ Created clean {s}x{s} version")
    
    print("🎉 Your clean circle icon (no black space) is ready!")
    print("📁 Main icon: clean_circle_icon.png")

except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc() 