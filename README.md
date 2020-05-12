# Cmask
This tool called Cmask (Cirrus cloud mask)  is used for **cirrus cloud detection** in Landsat 8 imagery using a time series of data from the Cirrus Band (1.36 – 1.39 µm).

**Note:** The Matlab code will be uploaded soon...

**Note:** We recommend combining Cmask and another cloud detection algorithm (e.g., [Fmask](https://github.com/GERSL/Fmask)) to detect all kinds of clouds in Landsat Time Series (LTS) since Cmask is designed for detecting cirrus clouds solely (It cannot detect non-cirrus clouds). 


The GIFs below illustrate the comparisons between Cmask and USGS Cirrus QA for all Landsat 8 images (central subset images with 500 pixels X 500 pixels) with disagreement >= 5% from 2013 to 2018. The UPPER LEFT image is a false color composite provided for perspective (SWIR1, NIR, and Red bands). The UPPER RIGHT image is the Cirrus Band TOA reflectance (Unit: X 10000). The LOWER LEFT image is the USGS Cirrus QA flag results (White color). The LOWER RIGHT image is the Cmask results (Variable threshold: Red >= 0.8, Orange >= 0.7, Yellow >= 0.6, Green >= 0.5 (Default)). Considering that any kind of clouds need to be excluded for further applications, the commission error from other non-cirrus clouds located in high altitudes (e.g., top of cumulus cloud) is not particularly harmful.
<table style="width:100%" border="0">
  <tr>
    <th><img src="https://github.com/GERSL/Cmask/blob/master/Animation_Cmask_USGSQA_P020R046.gif"/></th>
    <th><img src="https://github.com/GERSL/Cmask/blob/master/Animation_Cmask_USGSQA_P050R017.gif"/></th>
    <th><img src="https://github.com/GERSL/Cmask/blob/master/Animation_Cmask_USGSQA_P215R071.gif"/></th>
  </tr>
</table>


Cmask validation data can be found at this [Google Drive](https://drive.google.com/open?id=1b-U2bxf3l2b2w3meSFcVwYZJiCt25VeO).
