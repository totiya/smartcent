from PIL import Image, ImageDraw
import os

print("🔵 Cropping your image to circle...")

# Open your uploaded image
img = Image.open('custom_icon.png.jpg')
print(f"📏 Original size: {img.size}")

# Convert to RGBA if needed
if img.mode != 'RGBA':
    img = img.convert('RGBA')

# Make it square by cropping to center
width, height = img.size
size = min(width, height)
left = (width - size) // 2
top = (height - size) // 2
square = img.crop((left, top, left + size, top + size))

# Create circular mask
mask = Image.new('L', (size, size), 0)
draw = ImageDraw.Draw(mask)
draw.ellipse((0, 0, size, size), fill=255)

# Apply mask to create circle
result = Image.new('RGBA', (size, size), (0, 0, 0, 0))
result.paste(square, (0, 0))
result.putalpha(mask)

# Save the circle icon
result.save('your_circle_icon.png', format='PNG', optimize=True)
print(f"✅ Circle icon created: your_circle_icon.png")

# Create different sizes
sizes = [64, 128, 256, 512, 1024]
for s in sizes:
    resized = result.resize((s, s), Image.Resampling.LANCZOS)
    resized.save(f'circle_icon_{s}.png')
    print(f"✅ Created {s}x{s} version")

print("🎉 Your circle icon is ready!") 