#!/usr/bin/env python3
"""
Generate simple sound effects for the game using numpy and scipy
Install dependencies: pip install numpy scipy
"""

import numpy as np
from scipy.io import wavfile
import os

# Output directory
OUTPUT_DIR = "assets/sounds"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Sample rate
SAMPLE_RATE = 44100

def generate_button_click():
    """Generate a short click sound"""
    duration = 0.1  # seconds
    frequency = 800  # Hz
    
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration))
    # Short beep with quick decay
    envelope = np.exp(-t * 50)
    audio = np.sin(2 * np.pi * frequency * t) * envelope
    audio = (audio * 32767).astype(np.int16)
    
    wavfile.write(f"{OUTPUT_DIR}/button_click.wav", SAMPLE_RATE, audio)
    print("✓ Generated button_click.wav")

def generate_plane_engine():
    """Generate engine sound"""
    duration = 2.0
    
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration))
    # Combine multiple frequencies for engine rumble
    audio = (np.sin(2 * np.pi * 80 * t) * 0.3 +
             np.sin(2 * np.pi * 120 * t) * 0.2 +
             np.sin(2 * np.pi * 160 * t) * 0.15 +
             np.random.randn(len(t)) * 0.1)  # Add noise
    
    audio = (audio / np.max(np.abs(audio)) * 32767 * 0.6).astype(np.int16)
    
    wavfile.write(f"{OUTPUT_DIR}/plane_engine.wav", SAMPLE_RATE, audio)
    print("✓ Generated plane_engine.wav")

def generate_cargo_pickup():
    """Generate cargo pickup sound"""
    duration = 0.4
    
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration))
    # Rising tone
    frequency = 400 + t * 300
    envelope = np.exp(-t * 5)
    audio = np.sin(2 * np.pi * frequency * t) * envelope
    
    audio = (audio * 32767 * 0.7).astype(np.int16)
    
    wavfile.write(f"{OUTPUT_DIR}/cargo_pickup.wav", SAMPLE_RATE, audio)
    print("✓ Generated cargo_pickup.wav")

def generate_cargo_delivery():
    """Generate cargo delivery sound"""
    duration = 0.5
    
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration))
    # Multiple tones for success
    audio = (np.sin(2 * np.pi * 523 * t) * 0.4 +  # C5
             np.sin(2 * np.pi * 659 * t) * 0.3 +  # E5
             np.sin(2 * np.pi * 784 * t) * 0.3)   # G5
    envelope = np.exp(-t * 4)
    audio = audio * envelope
    
    audio = (audio * 32767 * 0.6).astype(np.int16)
    
    wavfile.write(f"{OUTPUT_DIR}/cargo_delivery.wav", SAMPLE_RATE, audio)
    print("✓ Generated cargo_delivery.wav")

def generate_crash():
    """Generate crash sound"""
    duration = 0.8
    
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration))
    # Low frequency rumble with noise
    audio = (np.sin(2 * np.pi * 100 * t) * 0.3 +
             np.sin(2 * np.pi * 50 * t) * 0.2 +
             np.random.randn(len(t)) * 0.5)
    envelope = np.exp(-t * 3)
    audio = audio * envelope
    
    audio = (audio / np.max(np.abs(audio)) * 32767 * 0.8).astype(np.int16)
    
    wavfile.write(f"{OUTPUT_DIR}/crash.wav", SAMPLE_RATE, audio)
    print("✓ Generated crash.wav")

def generate_achievement():
    """Generate achievement sound"""
    duration = 0.8
    
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration))
    # Ascending arpeggio
    notes = [523, 659, 784, 1047]  # C5, E5, G5, C6
    audio = np.zeros_like(t)
    
    for i, freq in enumerate(notes):
        start = int(len(t) * i / len(notes))
        end = int(len(t) * (i + 1.5) / len(notes))
        if end > len(t):
            end = len(t)
        segment = t[start:end] - t[start]
        envelope = np.exp(-segment * 8)
        audio[start:end] += np.sin(2 * np.pi * freq * segment) * envelope
    
    audio = (audio / np.max(np.abs(audio)) * 32767 * 0.6).astype(np.int16)
    
    wavfile.write(f"{OUTPUT_DIR}/achievement.wav", SAMPLE_RATE, audio)
    print("✓ Generated achievement.wav")

def generate_whoosh():
    """Generate whoosh sound"""
    duration = 0.3
    
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration))
    # Descending frequency sweep with noise
    frequency = 1000 - t * 2000
    audio = np.sin(2 * np.pi * frequency * t) * 0.3 + np.random.randn(len(t)) * 0.4
    envelope = np.exp(-t * 8)
    audio = audio * envelope
    
    audio = (audio / np.max(np.abs(audio)) * 32767 * 0.5).astype(np.int16)
    
    wavfile.write(f"{OUTPUT_DIR}/whoosh.wav", SAMPLE_RATE, audio)
    print("✓ Generated whoosh.wav")

def generate_coin_collect():
    """Generate coin collection sound"""
    duration = 0.3
    
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration))
    # High pitched ding
    audio = np.sin(2 * np.pi * 1200 * t) + np.sin(2 * np.pi * 1600 * t)
    envelope = np.exp(-t * 15)
    audio = audio * envelope
    
    audio = (audio / np.max(np.abs(audio)) * 32767 * 0.5).astype(np.int16)
    
    wavfile.write(f"{OUTPUT_DIR}/coin_collect.wav", SAMPLE_RATE, audio)
    print("✓ Generated coin_collect.wav")

def generate_level_up():
    """Generate level up sound"""
    duration = 1.0
    
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration))
    # Rising notes
    notes = [392, 494, 587, 784]  # G4, B4, D5, G5
    audio = np.zeros_like(t)
    
    for i, freq in enumerate(notes):
        start = int(len(t) * i / len(notes))
        end = int(len(t) * (i + 1.2) / len(notes))
        if end > len(t):
            end = len(t)
        segment = t[start:end] - t[start]
        envelope = np.exp(-segment * 6)
        audio[start:end] += np.sin(2 * np.pi * freq * segment) * envelope
    
    audio = (audio / np.max(np.abs(audio)) * 32767 * 0.6).astype(np.int16)
    
    wavfile.write(f"{OUTPUT_DIR}/level_up.wav", SAMPLE_RATE, audio)
    print("✓ Generated level_up.wav")

def generate_warning():
    """Generate warning sound"""
    duration = 0.5
    
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration))
    # Alternating tones
    frequency = 600 + 200 * np.sin(2 * np.pi * 8 * t)
    audio = np.sin(2 * np.pi * frequency * t)
    envelope = 0.5 + 0.5 * np.sin(2 * np.pi * 8 * t)
    audio = audio * envelope
    
    audio = (audio * 32767 * 0.5).astype(np.int16)
    
    wavfile.write(f"{OUTPUT_DIR}/warning.wav", SAMPLE_RATE, audio)
    print("✓ Generated warning.wav")

def generate_menu_music():
    """Generate simple menu music"""
    duration = 10.0
    
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration))
    # Simple melody with chords
    audio = (np.sin(2 * np.pi * 262 * t) * 0.15 +  # C4
             np.sin(2 * np.pi * 330 * t) * 0.15 +  # E4
             np.sin(2 * np.pi * 392 * t) * 0.15)   # G4
    
    # Add some variation
    audio += np.sin(2 * np.pi * 524 * t) * 0.1 * (1 + np.sin(2 * np.pi * 0.5 * t))
    
    audio = (audio * 32767 * 0.4).astype(np.int16)
    
    wavfile.write(f"{OUTPUT_DIR}/menu_music.wav", SAMPLE_RATE, audio)
    print("✓ Generated menu_music.wav")

def generate_gameplay_music():
    """Generate simple gameplay music"""
    duration = 15.0
    
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration))
    # Rhythmic beat with melody
    beat = np.sin(2 * np.pi * 2 * t)  # 2 Hz beat
    beat = (beat > 0.5).astype(float) * 0.2
    
    melody = (np.sin(2 * np.pi * 294 * t) * 0.15 +  # D4
              np.sin(2 * np.pi * 370 * t) * 0.15)    # F#4
    
    audio = beat + melody
    audio = (audio * 32767 * 0.4).astype(np.int16)
    
    wavfile.write(f"{OUTPUT_DIR}/gameplay_music.wav", SAMPLE_RATE, audio)
    print("✓ Generated gameplay_music.wav")

def convert_wav_to_mp3():
    """Convert WAV files to MP3 using ffmpeg"""
    print("\nConverting WAV files to MP3...")
    wav_files = [f for f in os.listdir(OUTPUT_DIR) if f.endswith('.wav')]
    
    for wav_file in wav_files:
        wav_path = os.path.join(OUTPUT_DIR, wav_file)
        mp3_file = wav_file.replace('.wav', '.mp3')
        mp3_path = os.path.join(OUTPUT_DIR, mp3_file)
        
        cmd = f'ffmpeg -i "{wav_path}" -codec:a libmp3lame -qscale:a 2 "{mp3_path}" -y -loglevel error'
        result = os.system(cmd)
        
        if result == 0:
            print(f"✓ Converted {wav_file} to {mp3_file}")
            # Remove WAV file after successful conversion
            os.remove(wav_path)
        else:
            print(f"✗ Failed to convert {wav_file}")

if __name__ == "__main__":
    print("Generating game sound effects...")
    print("=" * 50)
    
    # Generate all sound effects
    generate_button_click()
    generate_plane_engine()
    generate_cargo_pickup()
    generate_cargo_delivery()
    generate_crash()
    generate_achievement()
    generate_whoosh()
    generate_coin_collect()
    generate_level_up()
    generate_warning()
    generate_menu_music()
    generate_gameplay_music()
    
    print("\n" + "=" * 50)
    print("All WAV files generated successfully!")
    
    # Try to convert to MP3
    try:
        convert_wav_to_mp3()
        print("\n" + "=" * 50)
        print("All sound files ready!")
    except Exception as e:
        print(f"\nNote: Could not convert to MP3. You can use WAV files or install ffmpeg.")
        print("To install ffmpeg: sudo apt-get install ffmpeg")
