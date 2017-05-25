# -*- coding: utf-8 -*-
"""
Created on Thu Aug 25 16:23:19 2016

@author: Administrator
"""

import numpy as np
from biosppy.signals.ecg import ecg
import timeit
import sys
import pdb

# obviously get rid of file name. Expects a subject id
argv = sys.argv[1:]
subjid = argv[0]

print "Starting data load"
signal = np.loadtxt('../data/ekg/'+subjid+'.txt',skiprows=1)
signal = np.nan_to_num(signal) # get rid of nans, ecg doesn't like it
print "Data load complete"

print "Starting hr calculaton..."
start_time = timeit.default_timer()
out = ecg(signal=signal,sampling_rate=500,show=False)
end_time = timeit.default_timer()

print('It took %.2fm to find heartrate' % ((end_time-start_time)/60.))

np.savetxt('../data/hr/'+subjid+'.txt',
           np.transpose([out['heart_rate_ts'], out['heart_rate']]))