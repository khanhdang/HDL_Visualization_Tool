from svglib.svglib import svg2rlg
from reportlab.graphics import renderPDF
import sys; # supporting I/O access

drawing = svg2rlg(sys.argv[1])
renderPDF.drawToFile(drawing, sys.argv[2])
