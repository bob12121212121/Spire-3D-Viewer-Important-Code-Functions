import sys
from PIL import Image

try:
    img = Image.open('MODEL_ASSET_LOCATION')
    
    # We want a square image with a generous margin to fit in the safe zone.
    # The original width is 1024. Let's make the new canvas 1536x1536.
    new_size = 1536
    new_img = Image.new("RGBA", (new_size, new_size), (0, 0, 0, 255))
    
    # Calculate position to paste the original image (centered)
    paste_x = (new_size - img.width) // 2
    paste_y = (new_size - img.height) // 2
    
    new_img.paste(img, (paste_x, paste_y))
    
    new_img.save('MODEL_ASSET_LOCATION')
    print("Success")
except Exception as e:
    print(f"Error: {e}")
