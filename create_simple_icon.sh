#!/bin/bash
# Create a simple SVG icon and convert to PNG
cat > /tmp/icon.svg << 'SVGEOF'
<svg width="512" height="512" xmlns="http://www.w3.org/2000/svg">
  <!-- Sky gradient background -->
  <defs>
    <linearGradient id="skyGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#1E90FF;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#87CEEB;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="512" height="512" fill="url(#skyGrad)"/>
  
  <!-- Clouds -->
  <ellipse cx="100" cy="85" rx="35" ry="35" fill="white" opacity="0.8"/>
  <ellipse cx="140" cy="75" rx="30" ry="30" fill="white" opacity="0.8"/>
  <ellipse cx="170" cy="90" rx="30" ry="30" fill="white" opacity="0.8"/>
  
  <ellipse cx="370" cy="420" rx="35" ry="35" fill="white" opacity="0.8"/>
  <ellipse cx="410" cy="410" rx="30" ry="30" fill="white" opacity="0.8"/>
  <ellipse cx="440" cy="425" rx="30" ry="30" fill="white" opacity="0.8"/>
  
  <!-- Airplane body -->
  <polygon points="200,256 180,240 120,240 100,256 120,272 180,272" fill="#4682B4" stroke="#1E3A5F" stroke-width="3"/>
  
  <!-- Wings -->
  <polygon points="160,256 140,200 180,210 200,256 180,302 140,312" fill="#4682B4" stroke="#1E3A5F" stroke-width="3"/>
  
  <!-- Tail -->
  <polygon points="110,256 90,220 120,230" fill="#4682B4" stroke="#1E3A5F" stroke-width="2"/>
  
  <!-- Cockpit -->
  <circle cx="183" cy="256" r="12" fill="#87CEEB" stroke="#1E3A5F" stroke-width="2"/>
  
  <!-- Engine flame -->
  <ellipse cx="92" cy="256" rx="12" ry="10" fill="#FF8C00"/>
  <ellipse cx="92" cy="256" rx="8" ry="6" fill="#FFD700"/>
  
  <!-- Text -->
  <text x="256" y="175" font-family="Arial, sans-serif" font-size="48" font-weight="bold" 
        text-anchor="middle" fill="black" opacity="0.5">SKY HAULER</text>
  <text x="256" y="172" font-family="Arial, sans-serif" font-size="48" font-weight="bold" 
        text-anchor="middle" fill="white">SKY HAULER</text>
</svg>
SVGEOF

# Try to convert SVG to PNG
if command -v rsvg-convert &> /dev/null; then
    rsvg-convert -w 512 -h 512 /tmp/icon.svg -o assets/icon.png
    echo "Icon created successfully at assets/icon.png"
elif command -v inkscape &> /dev/null; then
    inkscape /tmp/icon.svg --export-type=png --export-filename=assets/icon.png -w 512 -h 512
    echo "Icon created successfully at assets/icon.png"
else
    # Fallback: create a simple colored square as placeholder
    printf "P6\n512 512\n255\n" > assets/icon.ppm
    for i in {1..786432}; do
        printf "\x1E\x90\xFF"
    done >> assets/icon.ppm
    
    if command -v convert &> /dev/null; then
        convert assets/icon.ppm assets/icon.png
        rm assets/icon.ppm
    else
        echo "Note: Created basic icon. For better quality, please use the SVG at /tmp/icon.svg"
        cp /tmp/icon.svg assets/icon.svg
    fi
fi
