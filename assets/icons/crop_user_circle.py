from PIL import Image, ImageDraw

print("🔵 Cropping your uploaded image to a perfect circle...")

try:
    # Open your uploaded image
    img = Image.open('../custom_icon.png.jpg')
    print(f"📏 Original size: {img.size}")

    # Convert to RGBA if needed
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    # Make it square by cropping from center
    width, height = img.size
    size = min(width, height)
    left = (width - size) // 2
    top = (height - size) // 2
    square = img.crop((left, top, left + size, top + size))

    # Create circular mask
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse((0, 0, size, size), fill=255)

    # Apply mask to create perfect circle
    result = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    result.paste(square, (0, 0))
    result.putalpha(mask)

    # Save the main circle icon
    result.save('user_perfect_circle.png', format='PNG', optimize=True)
    print(f"✅ Perfect circle icon created: user_perfect_circle.png")

    # Create app icon sizes
    sizes = [64, 128, 256, 512, 1024]
    for s in sizes:
        resized = result.resize((s, s), Image.Resampling.LANCZOS)
        resized.save(f'user_circle_{s}.png')
        print(f"✅ Created {s}x{s} version")

    print("🎉 Your perfect circle icon is ready!")
    print("📁 Main icon: user_perfect_circle.png")

except Exception as e:
    print(f"❌ Error: {e}")
    print("Make sure custom_icon.png.jpg exists in the assets folder") 