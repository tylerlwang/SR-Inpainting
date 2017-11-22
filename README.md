# SR-Inpainting

Our GitHub repository: https://github.com/tylerlwang/SR-Inpainting.

This is Jiacheng Guo and Tyler Wang's project for ENGN2560 Computer Vision based on the paper "Hierarchical Super-Resolution-Based Inpainting" (1).

USE WITHOUT ANY WARRENTY

## Overview
The novel part of this paper was repeating image inpainting 13 times with 13 different parameter settings and using loopy belief propagation to combine them into 1. We implemented the paper's idea and also propsed our own algorithm.

In exemplar-based inpainting, we changed the texture synthesis method from the best-match-patch method to the top-K-patch method. We also implemented 3 different methods to calculate the priority during the texture synthesis process.

In loopy belief propagation, we changed both the data cost and the smoothness cost in the energy function, and added a contour-based term to encourage contour continuity. This improved the combination results especially when the image was highly structural.

We quantified the inpainting quality using our rate of correctness graph.

## Usage
Put your input images in the `Datasets/Current` folder and rename them to `groundTruth.png` and `input.png.` `groundTruth.png` is an original image file, and `input.png` gives information about the filling region in the white color (255, 255, 255) by default. (If you intend to change it, you need to modify `fillColor = [255 255 255]` in all of the 3 files: `main.m`, `Calculate_ROC.m`, and `Contour_Gb/calculate_cost.m`.) Sample inputs are provided in `Datasets/Current`.

Run "main" in Matlab. It uses 3 different methods of loopy belief propagation to combine 13 inpainted images: the paper's energy function called "original," our improved energy function called "improved," and our function plus a contour-based term called "contour."

When "main" is run, a "rate of correctness" graph will be drawn automatically in Matlab. Output images will be stored in the "Datasets/Current" folder (same as input). 13 images inpainted with the best-match-patch method will be saved as "orig1," ... "orig13," and 13 images inpainted with the top-k-patch method will be saved as "topk1," ... "topk13." The final combination results of these 13 images using the "original" method, the "improved" method, and the "contour" method will be saved as `output_orig.png,` `output_improved,` and `output_contour,` respectively.

To change the inpainting parameters, you can modify the patch size `w`, data term `dataTerm`, and number of best-match patches `K` in `main.m.`

If you would like to down-sample the images before the inpainting, and upscale to its native resolution after the combination, you could use the functions `Down_Sampling/startdownsample.m` and `Super_Resolustion/SuperresCode.m.` They are not called in `main.m.`

## Compilation
All C++ code has been compiled with clang on macOS Sierra. You should be fine if you are using a 64-bit macOS. Please continue reading if you are using Linux.

You might need to recompile the code for exemplar-based inpainting. In the folder `Exemplar-Based_Inpainting/`, run `mex bestexemplarhelperK.c` on Matlab.

You might need to recompile the code for loopy belief propagation. The `OpenCV3` library is needed. Adjust `Makefile` flags to find your `OpenCV3` library. "main_orig.cpp" should generate "bp_orig", "main_improved.cpp" should generate "bp_improved", and "main_contour.cpp" should generate "bp_contour."

## Datasets
We tested our program on the `TUM-Image Inpainting Database.` It can be downloaded here: https://www.mmk.ei.tum.de/tumiid/. 

You need to use `processMask.m` to pre-process the mask files in this dataset, because they only have 1 color channel whereas our program requires 3.

## Acknowledgement
The code for loopy belief propagatin has referenced (2).

The code for contour detection was provided by (3).

The code for super-resolution inpainting was provided by (4). 

## Citations
(1). Le Meur, Olivier, Mounira Ebdelli, and Christine Guillemot. "Hierarchical super-resolution-based inpainting." IEEE transactions on image processing 22.10 (2013): 3779-3790.

(2). Ho, N. "Loopy belief propagation Markov Random Field stereo vision." http://nghiaho.com/?page_id=1366.

(3). Marius Leordeanu. "Generalized Boundary (Gb) Detector." https://sites.google.com/site/gbdetector/.

(4). Kwang In Kim and Younghee Kwon. "Example-based Learning for Single-Image Super-resolution." https://people.mpi-inf.mpg.de/~kkim/supres/supres.htm.
