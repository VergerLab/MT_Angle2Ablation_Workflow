///======================MACRO=========================///
macro_name = "Cell_AspectRatio";
///====================================================///
///File author(s): NAME TO CHANGE======================///

///====================Description=====================///
/*This macro ...
 * 
Macro description
*/
macro_source = "https://github.com/...PATH_TO_DEFINE";

///=========Input/output file names parameters=========///
// Input paramaters: input files suffixes
contours_suffix = "_cells.tif";
cell_Roiset_suffix = "_RoiSet_cells.zip";

// Output paramaters: output file suffixes
AspectRatio_file_suffix = "_CellAspectRatio.txt";
AspectRatio_Image_suffix = "_CellAspectRatio.tif";

///====================================================///
///====================================================///
///====================================================///

print("\\Clear");

//Select directory
dir = getDirectory("Choose a directory");
Folder_name = File.getName(dir);
list = getFileList(dir);

//Generate log file for record
log_file_name = "Log_" + Folder_name + "_" + macro_name + ".txt";
fLog = File.open(dir + File.separator + log_file_name);
print(fLog, "Files processed with the macro " + macro_name + ".ijm\n(" + macro_source + ")\n\n");
print(fLog, "Directory: " + dir + "\n\nFiles processed:");
File.close(fLog);

s = 0;
//Loop on all the images in the folder
for (j=0; j<list.length; j++){
	

	//Select image series to process
	if(endsWith (list[j], contours_suffix)){
		print("file_path", dir + list[j]);

		//count samples analyzed
		s++;

		//Extract generic name of the image serie
		File_name = substring(list[j], 0, indexOf(list[j], contours_suffix));

		//Write to log txt file
		File.append("- Sample number: " + s + "\n" + File_name, dir + File.separator + log_file_name);

		// clean up the ROI manager and empty results tables
		roiManager("reset");
		run("Clear Results");

		//Open the cell contour image to segment
		Input_cells = list[j];
		open(dir + File.separator + Input_cells);
		
		//Open cell ROIset
		Input_ROI_Cells = File_name + cell_Roiset_suffix;
		open(dir + File.separator + Input_ROI_Cells);

		//Generate results from ROIs
		run("Set Measurements...", "area centroid fit redirect=None decimal=1");
		roiManager("measure");

		//Count total ROI number
		tot_roi_number = roiManager("count");
		print ("Total ROIs:" + tot_roi_number);

		//Generate output file containing all the measured cell aspect ratio of the [j] analyzed images
		Output_AspectRatio = File_name + AspectRatio_file_suffix;
		fAR = File.open(dir + File.separator + Output_AspectRatio);
		print(fAR, "CellNumber" + "\t" + "Cell ellipse Angle" + "\t" + "Aspect ratio" + "\t" + "Major" + "\t" + "Minor" + "\t" + "x1" + "\t" + "y1" + "\t" + "x2" + "\t" + "y2");
		File.close(fAR);

		//Loop all ROIs
		for (i = 0; i < tot_roi_number; i++) {

			//Print cell number
			print("Cell:" + i + 1);

		    //Get cell shape parameters (elipse Major axis, minor axis, angle)
		    roiManager("select", i);
		    Major = getValue("Major");
			Minor = getValue("Minor");
			Angle = getValue("Angle");

			//Calculate Aspect ratio
			AspetRatio = Major/Minor;
		
			//Calculate Aspect Ratio lines
		    getPixelSize(unit, pixelWidth, pixelHeight); //Get pixel size to convert from micro to pixel
		    Cell_X = getValue("X")/pixelWidth;
		    Cell_Y = getValue("Y")/pixelWidth;
		    scale_factor = 4; //Scale line representation
			AR_X = (AspetRatio - 1) * Math.cos(Angle*PI/180) * scale_factor;
			AR_Y = (AspetRatio - 1) * Math.sin(Angle*PI/180) * scale_factor;
			x1 = Cell_X - AR_X;
			y1 = Cell_Y + AR_Y;
			x2 = Cell_X + AR_X;
			y2 = Cell_Y - AR_Y;

			//Draw Aspect Ratio lines
			makeLine(x1,y1,x2,y2);
			run("Add Selection...", "stroke=yellow width="+scale_factor);

			//Writes output to the *_CellAspectRatio.txt file for each image
			File.append((i + 1) + "\t" + Angle + "\t" + AspetRatio + "\t" + Major + "\t" + Minor + "\t" + x1 + "\t" + y1 + "\t" + x2 + "\t" + y2, dir + File.separator + Output_AspectRatio);
		}
		
		//Flatten overlay and save image for verification
		Overlay.flatten
		Output_overlay = File_name + AspectRatio_Image_suffix;
		saveAs("tiff", dir + File.separator + Output_overlay);
		
		//Close Images
		selectWindow(File_name + AspectRatio_Image_suffix);
		run("Close");
		selectWindow(File_name + contours_suffix);
		run("Close");

		//Write to log, input files used, output file generated, time and date
		File.append("\tInput :\n\t=> " + Input_ROI_Cells + "\n\t=> " + Input_cells + "\n\tOutput :\n\t<= " + Output_AspectRatio + "\n\t<= " + Output_overlay, dir + File.separator + log_file_name);
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		File.append("\t" + hour + ":" + minute + ":" + second + " " + dayOfMonth + "/" + month + "/" + year + "\n\n", dir + File.separator + log_file_name);
	}
}

//Close all open files
selectWindow("ROI Manager");
run("Close");
selectWindow("Results");
run("Close");

//End of the macro message
print("\n\n===>End of the " + macro_name + " macro");
print("Check output files in:\n" + dir);
print("- " + log_file_name + "\n- *" + AspectRatio_file_suffix + "\n- *" + AspectRatio_Image_suffix + "\n(*) For each image analyzed");