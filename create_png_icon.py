import struct
import math

def create_simple_png(width, height, filename):
    # Create a simple PNG with sky blue gradient
    def write_chunk(f, chunk_type, data):
        length = len(data)
        f.write(struct.pack('>I', length))
        f.write(chunk_type)
        f.write(data)
        crc = 0xFFFFFFFF
        for b in chunk_type + data:
            crc ^= b
            for _ in range(8):
                if crc & 1:
                    crc = (crc >> 1) ^ 0xEDB88320
                else:
                    crc >>= 1
        f.write(struct.pack('>I', crc ^ 0xFFFFFFFF))
    
    with open(filename, 'wb') as f:
        # PNG signature
        f.write(b'\x89PNG\r\n\x1a\n')
        
        # IHDR chunk
        ihdr = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
        write_chunk(f, b'IHDR', ihdr)
        
        # IDAT chunk - create gradient image data
        import zlib
        raw_data = bytearray()
        for y in range(height):
            raw_data.append(0)  # Filter type
            # Gradient from sky blue to light blue
            r = 30 + int((135 - 30) * y / height)
            g = 144 + int((206 - 144) * y / height)
            b = 255
            for x in range(width):
                raw_data.extend([r, g, b])
        
        compressed = zlib.compress(bytes(raw_data), 9)
        write_chunk(f, b'IDAT', compressed)
        
        # IEND chunk
        write_chunk(f, b'IEND', b'')

create_simple_png(512, 512, 'assets/icon.png')
print("Created basic PNG icon at assets/icon.png")
