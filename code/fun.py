"""
Title: Functions for dissertation

Notes:
    - Description: Script containing all the functions used in dissertation
    - Updated: 2022-12-09
    - Updated by: dcr
"""

# Importing dependencies
    #* COVER
import random # to generate distributions
import math # for useful math operators
    #* CAPD ANALYSIS
import numpy as np # for array management
import polars as pl # for dataframe management
import re # for regex
import cv2 # for image detection

# COVER
    #* Defining vectors
def f1(x,y):
    """
        Description: To create the first vector for cover image

        Parameters: x,y

        Depends on: random, math
    """
    result = random.uniform(-100,100) * x**2  - math.sin(y**2) + abs(y-x)
    return result
def f2(x, y):
    """
        Description: To create the second vector for cover image
        
        Parameters: x,y

        Depends on: random, math
    """
    result = random.uniform(-1,1) * y**3 - math.cos(x**2) + 2*x
    return result

# CAPD ANALYSIS
#* Dealing with names
def names(col):
    """
    Description: Function to extract last names of candidate

    Parameters: df: pandas dataFrame object

    Depends on pandas and re
    """
    Name = col.str.replace(r"Jr\.|Sr\.|Jr|Sr|JR|SR|III|\sIV|\sVI", "")
    Stripped = Name.str.rstrip()
    lastName = Stripped.str.split(" ").arr.get(-1)
    return lastName

#* Image pre-processing

def preProcess(img, size = [224, 224], inter = cv2.INTER_AREA):
    """
    Description: Function to do the resizing of the images
    
    Parameters: Tuple of pixel size to be passed along to cv2.resize function 
    
    Depends on: cv2
    """
    resized = cv2.resize(img, size, inter)
    return resized

#* Color detection

def colorDetector(img, color_upper = [255,255,255], color_lower = [255,255,255]):
    """
    Description: Function that preprocesses the image and calculates the percentage of a particular color in it.

    Parameters: Original img, and the RBG upper and lower limits of color I want to detect. Defaults for color_upper and color_lower is white.
    
    Depends on: fun.py module, and cv2
    """
    # create boundaries 
    boundaries = [([color_lower[2], color_lower[1], color_lower[0]],[color_upper[2], color_upper[1], color_upper[0]])]
    # Transform image
    img_transformed = preProcess(img)
    # calculate scale
    scale = ((img_transformed.shape[0]/img.shape[0]) + (img_transformed.shape[1]/img.shape[1]))/2
    for (lower, upper) in boundaries:
    # adjust color_upper and color_lower to specific type
        lower = np.array(lower, dtype = np.uint8)
        upper = np.array(upper, dtype = np.uint8)
    # take all values within color range and make it white; everything else black
        mask = cv2.inRange(img_transformed, lower, upper)
    # take all white values and put it on original image. keep black pixels black
        result = cv2.bitwise_and(img_transformed, img_transformed, mask = mask)
    # get ratio of non-black pixels
        ratio = cv2.countNonZero(mask)/(img_transformed.size/(1/scale))
    # calculate percentage of non-black pixels
        percent = (ratio * 100)/scale
    # return percentage, img_transformed, and result
        return percent, img_transformed, result