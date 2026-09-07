# First, you need to install the required libraries. 
# Run this in your command prompt before running the script:
# pip install qrcode[pil]

import qrcode

# THE "PARSER TRAP" TRICK
# We format the QR code as a broken Wi-Fi network. 
# Native cameras see "WIFI:", try to find the network name (which is empty "S:;"), 
# and silently give up without showing a "Text Found" popup. 
# Your Flutter app will read the whole string and find your link at the end!
payload = "WIFI:S:;T:nopass;P:;H:true;;spire.com/meter/280w-tap"

# Configure the QR Code appearance and error correction
qr = qrcode.QRCode(
    version=1, 
    error_correction=qrcode.constants.ERROR_CORRECT_H, 
    box_size=10, 
    border=4, 
)

# add_data with standard text so Flutter ML Kit can read it perfectly
qr.add_data(payload)
qr.make(fit=True)

# Create an image from the QR Code instance using Pillow
img = qr.make_image(fill_color="black", back_color="white")

# Save the generated image to your computer
filename = "capmeter_280WTAP_invisible.png"
img.save(filename)

print(f"Success! Your completely invisible QR code was saved as {filename}")