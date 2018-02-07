#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
from itertools import count

# buzzergen that wakes up each X secs..
# source: https://stackoverflow.com/questions/510348/how-can-i-make-a-time-delay-in-python
def buzzergen(period):
    nexttime = time.time() + period
    for i in count():
        now = time.time()
        tosleep = nexttime - now
        if tosleep > 0:
            time.sleep(tosleep)
            nexttime += period
        else:
            nexttime = now + period
        yield i, nexttime
