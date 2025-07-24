#!/usr/bin/env python3
"""
Simple Python script to generate Hello World app icon
Requires: pip install Pillow
Usage: python generate_icon.py
"""

from PIL import Image, ImageDraw, ImageFont
import os

def generate_icon():
    # Create a new image with a white background
    size = (1024, 1024)
    img = Image.new('RGBA', size, (248, 249, 250, 255))  # Light gray background
    draw = ImageDraw.Draw(img)
    
    # Create circular background with gradient effect
    center = (512, 512)
    radius = 480
    
    # Draw circle background
    circle_bbox = [center[0] - radius, center[1] - radius, 
                   center[0] + radius, center[1] + radius]
    draw.ellipse(circle_bbox, fill=(248, 249, 250, 255), outline=(222, 226, 230, 255), width=8)
    
    # Try to load a font, fall back to default if not available
    try:
        # Try to load Arial font (Windows)
        font_large = ImageFont.truetype("arial.ttf", 140)
        font_emoji = ImageFont.truetype("arial.ttf", 40)
    except:
        try:
            # Try to load system fonts
            font_large = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 140)
            font_emoji = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 40)
        except:
            # Fall back to default font
            font_large = ImageFont.load_default()
            font_emoji = ImageFont.load_default()
    
    # Draw "Hello" text in red
    hello_text = "Hello"
    hello_color = (255, 59, 48, 255)  # Red
    
    # Get text bounding box for centering
    hello_bbox = draw.textbbox((0, 0), hello_text, font=font_large)
    hello_width = hello_bbox[2] - hello_bbox[0]
    hello_height = hello_bbox[3] - hello_bbox[1]
    
    # Position "Hello" text (slightly above center, rotated)
    hello_x = center[0] - hello_width // 2
    hello_y = 350
    
    # Create a new image for the rotated text
    hello_img = Image.new('RGBA', (hello_width + 100, hello_height + 50), (0, 0, 0, 0))
    hello_draw = ImageDraw.Draw(hello_img)
    hello_draw.text((50, 25), hello_text, font=font_large, fill=hello_color)
    
    # Rotate and paste
    hello_rotated = hello_img.rotate(-8, expand=True)
    img.paste(hello_rotated, (hello_x - 50, hello_y - 25), hello_rotated)
    
    # Draw "World" text in blue
    world_text = "World"
    world_color = (0, 122, 255, 255)  # Blue
    
    # Get text bounding box for centering
    world_bbox = draw.textbbox((0, 0), world_text, font=font_large)
    world_width = world_bbox[2] - world_bbox[0]
    world_height = world_bbox[3] - world_bbox[1]
    
    # Position "World" text (slightly below center, rotated)
    world_x = center[0] - world_width // 2
    world_y = 520
    
    # Create a new image for the rotated text
    world_img = Image.new('RGBA', (world_width + 100, world_height + 50), (0, 0, 0, 0))
    world_draw = ImageDraw.Draw(world_img)
    world_draw.text((50, 25), world_text, font=font_large, fill=world_color)
    
    # Rotate and paste
    world_rotated = world_img.rotate(5, expand=True)
    img.paste(world_rotated, (world_x - 50, world_y - 25), world_rotated)
    
    # Add decorative elements
    star_color = (255, 215, 0, 200)  # Gold with transparency
    heart_color = (255, 105, 180, 150)  # Pink with transparency
    
    # Draw stars/sparkles as simple shapes
    sparkle_positions = [
        (180, 200), (844, 180), (160, 780), (860, 820)
    ]
    
    for pos in sparkle_positions:
        # Draw a simple star shape
        star_size = 20
        points = []
        for i in range(10):
            angle = i * 36  # 360/10 = 36 degrees
            if i % 2 == 0:
                # Outer point
                r = star_size
            else:
                # Inner point
                r = star_size // 2
            import math
            x = pos[0] + r * math.cos(math.radians(angle - 90))
            y = pos[1] + r * math.sin(math.radians(angle - 90))
            points.append((x, y))
        draw.polygon(points, fill=star_color)
    
    # Draw hearts as simple circles (emoji hearts don't render well)
    heart_positions = [(240, 340), (780, 680)]
    for pos in heart_positions:
        draw.ellipse([pos[0] - 15, pos[1] - 15, pos[0] + 15, pos[1] + 15], fill=heart_color)
    
    # Save the image
    output_path = "icon.png"
    img.save(output_path, "PNG")
    print(f"Icon generated successfully as {output_path}")
    
    return output_path

if __name__ == "__main__":
    generate_icon()
