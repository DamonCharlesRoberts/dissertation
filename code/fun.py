# Title: functions

# Notes:
    #* Description: Script to define the functions
    #* Updated: 2022-11-11
    #* Updated by: dcr

# Dependencies
import numpy as np # for array management
import pandas as pd # for dataframe management
import re # for regex
import cv2 # for image detection

# CAPD ANALYSIS

#* Dealing with names
def names(df):
    """
    Description: Function to extract last names of candidate

    Parameters: df: pandas dataFrame object

    Depends on pandas and re
    """
    lastName = df["Candidate_Name"].str.extract(r"([^\s]+)\s*(?=Jr\.|Sr\.|sr|jr|ii|iii|iv|IV|$)")
    return lastName

#* Image pre-processing

def preProcess(img = None, size = [224, 224], inter = cv2.INTER_AREA):
    """
    Description: Function to do the resizing of the images
    
    Parameters: Tuple of pixel size to be passed along to cv2.resize function 
    
    Depends on: cv2
    """
    resized = cv2.resize(img, size, inter)
    return(resized)

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
    ## return percentage
        return percent