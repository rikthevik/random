
"""
        double speed = frame->data[speed_pos] << 8;
        speed += frame->data[speed_pos + 1];
        speed = speed / 100;
        speed = speed * 0.6213751;
"""

for l in open("values"):
    i = int(l.strip(), base=16)

    data = i
    speed = data 
    # print(speed)
    speed = speed / 100.0
    speed = speed * 0.6213751
    print(speed, i, l.strip())


