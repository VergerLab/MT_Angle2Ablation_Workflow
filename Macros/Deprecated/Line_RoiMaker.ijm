///======================MACRO=========================///
macro_name = "Line_RoiMaker";
///====================================================///
///File author(s): Stéphane Verger=====================///

///====================Description=====================///
/*This macro allows a semi-automated creation of line ROI 
sets that are used for angle calculation between the output 
of FibrilTool_Batch_Workflow.ijm and the ablation site. 
It uses as input, the output files from the 
FibrilTool_Batch_Workflow.ijm macro.

See https://github.com/VergerLab/MT_Angle2Ablation_Workflow 
for more detailed explanations of use.
*/
macro_source = "https://github.com/VergerLab/MT_Angle2Ablation_Workflow/Line_RoiMaker.ijm";

///=========Input/output file names parameters=========///
// Input paramaters: input files suffixes
contours_suffix = "_cells.tif";
features_suffix = "_MTs.tif";
cell_Roiset_suffix = "_RoiSet_cells.zip";

// Output paramaters: output file suffixes
line_Roiset_suffix = "_RoiSet_lines.zip";

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
		print("file_path",dir + list[j]);

		//count samples analyzed
		s++;
		
		//Extract generic name of the image serie
		File_name = substring(list[j], 0, indexOf(list[j], contours_suffix));

		//Write to log txt file
		File.append("- Sample number: " + s + "\n" + File_name, dir + File.separator + log_file_name);
		
		//Open cell contour image
		Input_cells = list[j];
		open( dir + File.separator + Input_cells);
		
		//Open Microtubules image
		Input_MTs = File_name + features_suffix;
		open(dir + File.separator + Input_MTs);
	    
		//Create RGB composite image
		run("Merge Channels...", "c1=&Input_cells c4=&Input_MTs create");
		rename(File_name+"Composite.tif");
		run("RGB Color");
		rename(File_name+"CompositeRGB.tif");
		selectWindow(File_name+"Composite.tif");
		close();

		// clean up the ROI manager
		roiManager("reset");
	
		//Open cell contour ROI and flatten
		Input_ROI_cells = File_name + cell_Roiset_suffix;
		roiManager("Open", dir + File.separator + Input_ROI_cells);
		roiManager("show all with labels");
		run("Flatten");
		selectWindow(File_name + "CompositeRGB.tif");
		close();
	
		// clean up the ROI manager
		roiManager("reset");
	
		//Manual ROI generation
		waitForUser("Create line ROIs", "Select the Straight line tool.\nPlace new lines corresponding, and in the same order as the displayed cell contour ROIs\nHit ctrl+T to add successively each line to ROI manager\nWhen done, click OK here.");

		//Save ROIs and close images
		Output_ROI_lines = File_name + line_Roiset_suffix;
		roiManager("Save", dir + File.separator + Output_ROI_lines);
		selectWindow(File_name + "CompositeRGB-1.tif");
		close();

		//Write to log, input files used and output file generated
		File.append("\tInput :\n\t=> " + Input_cells + "\n\t=> " + Input_MTs + "\n\t=> " + Input_ROI_cells + "\n\tOutput :\n\t<= " + Output_ROI_lines, dir + File.separator + log_file_name);
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		File.append("\t" + hour + ":" + minute + ":" + second + " " + dayOfMonth + "/" + month + "/" + year + "\n\n", dir + File.separator + log_file_name);
	}
}
//Close ROI manager
selectWindow("ROI Manager");
run("Close");

//End of the macro message
print("\n\n===>End of the " + macro_name + " macro");
print("Check output files in:\n" + dir);
print("- " + log_file_name + "\n- *" + line_Roiset_suffix + "\n(*) For each image analyzed");
