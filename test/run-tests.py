#!/usr/bin/env python
# Copyright 2019 nomennescio
# MIT license

import glob, os, re

passed, failed = 0, 0

def run (forthfile):
    return os.popen ("gforth ../ttester-codewars.4th " + forthfile + " -e bye").readlines ()

def timeless (lines):
    return [re.sub(r'\d+', '0', l) if "<COMPLETEDIN::>" in l else l for l in lines]

def test (base):
    global passed, failed
    if (timeless (run (base + ".4th")) == timeless (open (base + ".expected").readlines ())):
        print ("Pass: " + base)
        passed += 1
    else:
        print ("Fail: " + base)
        failed += 1

prevdir = os.getcwd ()
os.chdir (os.path.dirname (os.path.abspath (__file__)))

files = [os.path.splitext (f) for f in glob.glob ("*.4th")]
for f,_ in files:
    test (f)

if (failed==0):
    print ("All {0} tests were successful".format (passed))
else:
    print ("{0} out of {1} tests failed".format (failed, failed+passed))
    
os.chdir (prevdir)
