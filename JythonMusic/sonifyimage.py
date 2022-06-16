# Demonstrates how to create a soundscape from an image.
# It loads a jpeg image and scans it from left to right.
# Pixels are mapped to notes using these sonification rules:
# left to right column position is mapped to time,
# luminosity (pixel brightness) is mapped to pitch within a scale,
# redness (pixel R value) is mapped to duration, and
# blueness (pixel B value) is mapped to volume.

from music import *
from image import * 
from random import * 

lines = []
ins = PIANO #Assigning a piano timbre 

soundscapeScore = Score("Loutraki Soundscape", 60)
soundscapePart = Part(ins, 0)

scale = MIXOLYDIAN_SCALE 

minPitch = 0 
maxPitch = 127 

minDuration = 0.8
maxDuration = 6.0

minVolume = 0 
maxVolume = 127 

# Start time is randomly displaced by one of these durations for variety
timeDisplacement = [DEN, EN, SN, TN]

image = Image("your_file_name.jpg")

pixelRows = [0, 53, 106, 159, 212]
width = image.getWidth()
height = image.getHeight()

def sonifyPixel(pixel):

  red, green, blue = pixel 

  luminosity = (red + green + blue) / 3

  pitch = mapScale(luminosity, 0, 255, minPitch, maxPitch, scale)

  duration = mapValue(red, 0, 255, minDuration, MaxDuration)

  dynamic = mapValue(blue, 0, 255, minVolume, maxVolume)

  note = Note(pitch, duration, dynamic)

  return note  

for row in pixelRows:

  for col in range(width):

    pixel = image.getPixel(col, row)

    note = sonifyPixel(pixel)

    startTime = float(col)

    startTime = startTime + choice( timeDisplacement )

    phrase = Phrase(startTime)
    phrase.addNote(note)

    soundscapePart.addPhrase(phrase)

soundscapeScore.addPart(soundscapePart)

View.sketch(soundscapeScore)
Write.midi(soundscapeScore, "sound.mid")

