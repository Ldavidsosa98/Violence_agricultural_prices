*******************************************************************************
*******************************************************************************
******** Project: The impact of DTO's presence on agricultural products *******
******** Author: David Sosa ***************************************************
******** Email: luis.sosa@itam.mx *********************************************
*******************************************************************************
*******************************************************************************


/*
This is the master do-file. 
Here you will be able to run the whole project 
to get from the raw data to all the results/graphs/tables.
This do-file only runs other do-files. No other coding is done here.
*/

*This is the main directory
global master "C:/Users/ldavi/My Drive/Investigación/Arturo Aguilar/Violencia/"
set scheme s1color

*Directories. If you want to reproduce the results, make sure to change these.
do "${master}code/0_directories.do"

*Import, merge and clean raw data.
do "${code}1_master.do"

*Descriptive statistics and exploratory analysis.
do "${code}2_master.do"
