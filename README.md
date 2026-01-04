# accelerometer-based-rr-hr-estimate
Accelerometer-based Respiratory Rate and Heart Rate Detection

The goal of the project is to investigate whether the triaxial accelerometer embedded in a smartphone can be used to estimate:
- Respiratory Rate (RR)
- Heart Rate (HR)

## Project Overview

The dataset consists of accelerometer recordings collected from **3 subjects**, each performing **5 different acquisition conditions**:
- Slow breathing
- Fast breathing
- Spontaneous breathing
- Spontaneous breathing with apnea
- Spontaneous breathing with voluntary movement
The accelerometer signals are acquired using a smartphone placed on the subjects' chest.

Respiratory Rate Detection pipeline: 
- Low-pass filtering to isolate respiratory motion
- Principal Component Analysis (PCA) to obtain a 1D respiratory surrogate
- Time-domain analysis using autocorrelation
- Frequency-domain analysis using PSD (Periodogram and Welch)
- Comparison between time- and frequency-domain estimates

Heart Rate Detection pipeline: 
- Band-pass filtering to extract seismocardiographic (SCG) components
- AO peak detection using physiological constraints
- Template construction and cross-correlation for peak validation
- Beat-to-beat heart rate estimation



