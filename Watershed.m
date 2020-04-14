%ENGO 559 PROJECT

%IMAGE SEGMENTATION

close all

%Load Image
img = imread('oranges.jpg');

%Convert to greyscale
img = rgb2gray(img);

%Display Image
imshow(img); title('Original Image');

%Image Processing~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%Watershed Segmentation~~~~~~~~~~~~~~~~~
%gradient magnitude
gmag = imgradient(img);
%Watershed transform
L = watershed(gmag);
Lrgb = label2rgb(L);
%Foreground objects marking
se = strel('disk',20);  %creates disk-shaped structuring element with radius 20
io = imopen(img,se);    %removes obects less than radius
%opening-by-reconstruction
ie = imerode(img,se);    %erode greyscale to simplify objects
obr = imreconstruct(ie,img);    %constuct result from eroded and original img
%morphological closing
ioc = imclose(io,se);   %merges objects together
%opening-closing by reconstruction
iobrd = imdilate(obr,se);
iobrcbr = imreconstruct(imcomplement(iobrd),imcomplement(obr));
iobrcbr = imcomplement(iobrcbr);
%regional maxima
fgm = imregionalmax(iobrcbr);
%modified regional maxima
se2 = strel(ones(5,5));
fgm2 = imclose(fgm,se2);
fgm3 = imclose(fgm2,se2);
fgm4 = bwareaopen(fgm3,20);
%background markers
bw = imbinarize(iobrcbr); %convert to binary
%watershed ridge lines
d = bwdist(bw); %euclidian distance transform
dl = watershed(d);
bgm = dl == 0;
%watershed transform
gmag2 = imimposemin(gmag, bgm | fgm4);%impose minima
L = watershed(gmag2);
%create labels
labels = imdilate(L==0,ones(3,3)) + 2*bgm + 3*fgm4;
%label matrix
Lrgb = label2rgb(L,'jet','w','shuffle');

%Export Image/Data~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%Watershed Segmentation
imshow(gmag,[]); title('Gradient Magnitude');
imshow(Lrgb); title('Watershed Transform of Gradient Magnitude');
imshow(io); title('Opening');
imshow(obr); title('Opening-by-Reconstruction');
imshow(ioc); title('Opening-Closing');
imshow(iobrcbr); title('Opening-Closing by Reconstruction');
imshow(labeloverlay(img,fgm)); title('Regional Maxima Superimposed on Original Image');
imshow(labeloverlay(img,fgm4)); title('Modified Regional Maxima on Original Image');
imshow(bw); title('Thresholded O-C by Reconstruction');
imshow(bgm); title('Watershed Ridge Lines');
%final output option 1:
imshow(labeloverlay(img,labels)); title('Markers & Object Boundaries on Original Image');
%option 2:
figure;
imshow(img);hold on; 
himage = imshow(Lrgb);
himage.AlphaData = 0.3;
title('Colored Labels Superimposed on Original Image');