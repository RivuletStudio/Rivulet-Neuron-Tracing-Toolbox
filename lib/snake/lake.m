clear all; close all; clc;
im=imread('mama07ORI.bmp');
smoothing = 1;
threshold = 0.3;
ballon = 1;
MorphGAC = snakeinitialise(gI, smoothing, threshold, ballon);
shape = size(im);