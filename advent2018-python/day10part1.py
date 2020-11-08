#!/usr/bin/env python3

""" https://adventofcode.com/2018/day/2 """


inputstr = """
position=< 9,  1> velocity=< 0,  2>
position=< 7,  0> velocity=<-1,  0>
position=< 3, -2> velocity=<-1,  1>
position=< 6, 10> velocity=<-2, -1>
position=< 2, -4> velocity=< 2,  2>
position=<-6, 10> velocity=< 2, -2>
position=< 1,  8> velocity=< 1, -1>
position=< 1,  7> velocity=< 1,  0>
position=<-3, 11> velocity=< 1, -2>
position=< 7,  6> velocity=<-1, -1>
position=<-2,  3> velocity=< 1,  0>
position=<-4,  3> velocity=< 2,  0>
position=<10, -3> velocity=<-1,  1>
position=< 5, 11> velocity=< 1, -2>
position=< 4,  7> velocity=< 0, -1>
position=< 8, -2> velocity=< 0,  1>
position=<15,  0> velocity=<-2,  0>
position=< 1,  6> velocity=< 1,  0>
position=< 8,  9> velocity=< 0, -1>
position=< 3,  3> velocity=<-1,  1>
position=< 0,  5> velocity=< 0, -1>
position=<-2,  2> velocity=< 2,  0>
position=< 5, -2> velocity=< 1,  2>
position=< 1,  4> velocity=< 2,  1>
position=<-2,  7> velocity=< 2, -2>
position=< 3,  6> velocity=<-1, -1>
position=< 5,  0> velocity=< 1,  0>
position=<-6,  0> velocity=< 2,  0>
position=< 5,  9> velocity=< 1, -2>
position=<14,  7> velocity=<-2,  0>
position=<-3,  6> velocity=< 2, -1>
"""

import json, re, collections, itertools, os

def display(positions):
    for row, points in itertools.groupby(sorted(positions, key=lambda p: (p.y, p.x)), key=lambda p: p.y):
        print(list(points)) 


def main():
    positions = []
    velocities = []
    f = open("part10.html", "w")
    for l in inputstr.strip().splitlines():
        left, right = l.split("> velocity=<")
        pos = [ int(s.strip()) for s in left[10:].split(",") ]
        vel = [ int(s.strip()) for s in right[:-1].split(",") ]
        positions.append(pos)
        velocities.append(vel)
    
    horiz_values = [ p[0] for p in positions ]
    horiz_offset = min(horiz_values)
    total_width = max(horiz_values) - min(horiz_values)
    horiz_scale = 800.0 / total_width * 0.5

    vert_values = [ p[1] for p in positions ]
    vert_offset = min(vert_values)
    total_height = max(vert_values) - min(vert_values)
    vert_scale = 800.0 / total_height * 0.5

    for p in positions:
        p[0] = (p[0] - horiz_offset) * horiz_scale
        p[1] = (p[1] - vert_offset) * vert_scale

    for p in velocities:
        p[0] *= horiz_scale
        p[1] *= vert_scale

    info = {}

    print("width", total_width, "height", total_height)


    print('''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <title>Canvas tutorial</title>
    <script type="text/javascript">
      var ctx;
      var positions = %s;
      var velocities = %s;
      var info = %s;
      function draw() {
        var canvas = document.getElementById('tutorial');
        ctx = canvas.getContext('2d');
        alert('hello');
        drawPositions();
        setInterval(loop, 100);
      }
      function loop() {
        console.log("looping");
        move();
        drawPositions();
      }
      function move() {
        for (var i=0; i < positions.length; ++i) {
            positions[i][0] += velocities[i][0] * 0.1;
            positions[i][1] += velocities[i][1] * 0.1;
        }
      }
      function drawPositions() {
        ctx.clearRect(0, 0, 800, 800);
        for (var i=0; i < positions.length; ++i) {
          ctx.fillRect(positions[i][0], positions[i][1], 2, 2);
        }
      }
    </script>
    <style type="text/css">
      canvas { border: 1px solid black; }
    </style>
  </head>
  <body onload="draw();">
    <canvas id="tutorial" width="400" height="400"></canvas>
  </body>
</html>
''' % (json.dumps(positions), json.dumps(velocities), json.dumps(info)), file=f)
    os.system("open part10.html")






if __name__ == '__main__':
    main()
