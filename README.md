# SR-Inpainting
## A computer vision project based on the paper "Hierarchical Super-Resolution-Based Inpainting" (1)

USE WITHOUT ANY WARRENT

## What has been achieved in this project?
The novel part of this paper was repeating image inpainting 13 times with 13 different parameter settings and using loopy belief propagation to combine them into 1. We implemented the paper's idea and also propsed our own algorithm.
In exemplar-based inpainting, we changed the texture synthesis method from the best-match-patch method to the top-K-patch method.
In loopy belief propagation, we changed both the data cost and the smoothness cost in the energy function, and added a contour-based term to encourage contour continuity. This improved the combination results especially when the image was highly structural.
We quantified the inpainting quality using our rate of correctness graph.

## How can I use the code?
Put your input images in the "Datasets/Current" folder and rename them to "input.png" and "groundTruth.png". "input.png" gives information about the filling region in the absolute white color (255, 255, 255).
Run "main" in Matlab and the output will be found in "Datasets/Current."

## What dependencies do I need?
The code for loopy belief propagation was written in C++ and compiled with clang on macOS Sierra. The OpenCV3 library is needed if you are using Linux and want to recompile the files. "main_orig.cpp" generates "bp_orig", "main_improved.cpp" generates "bp_improved", and "main_contour.cpp" generates "bp_contour."

## Acknowledgement
The code for loopy belief propagatin has referenced (2).
The code for contour detection was provided by (3).
The code for edge detection was provided by (4), it is not used in our final main function.

## Citations
(1). Le Meur, Olivier, Mounira Ebdelli, and Christine Guillemot. "Hierarchical super-resolution-based inpainting." IEEE transactions on image processing 22.10 (2013): 3779-3790.
(2). Ho, N. "Loopy belief propagation Markov Random Field stereo vision." LBP Code Example.
(3). Marius Leordeanu. "Generalized Boundary (Gb) Detector." https://sites.google.com/site/gbdetector/.
(4). UCBerkeley Computer Vision Group. "Contour Detection and Image Segmentation Resources." https://www2.eecs.berkeley.edu/Research/Projects/CS/vision/grouping/resources.html.
