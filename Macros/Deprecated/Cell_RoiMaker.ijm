///======================MACRO=========================///
macro_name = "Cell_RoiMaker";
///====================================================///
///File author(s): Stéphane Verger=====================///

///====================Description=====================///
/*This macro allows a semi-automated segmentation and 
creation of ROI sets for 2D Cell contour images.

See https://github.com/VergerLab/MT_Angle2Ablation_Workflow 
for more detailed explanations of use.
*/
macro_source = "https://github.com/VergerLab/MT_Angle2Ablation_Workflow/Cell_RoiMaker.ijm";

///=========Input/output file names parameters=========///
// Input paramaters: input files suffixes
contours_suffix = "_cells.tif";
features_suffix = "_MTs.tif";

// Output paramaters: output file suffixes
contour_Roiset_suffix = "_RoiSet_cells.zip";

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

		//Open the cell contour image to segment
		Input_cells = list[j];
		open(dir + File.separator + Input_cells);
		
		//Preprocess image
		run("8-bit");
		run("Gaussian Blur...", "sigma=3");
	    
		//MorpholibJ morphological segmentation
		run("Morphological Segmentation");
		wait(1000);
		call("inra.ijpb.plugins.MorphologicalSegmentation.setInputImageType", "border");
		call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=10", "calculateDams=true", "connectivity=6");
	    
		//User can change segmentation parameters if necessary
		waitForUser("Watershed segmentation", "Rerun the watershed segmentation with appropriate parameters if necessary.\nWhen you are satisfied, click OK here!");

		//Generate segmented binary image
		call("inra.ijpb.plugins.MorphologicalSegmentation.setDisplayFormat", "Watershed lines");
		call("inra.ijpb.plugins.MorphologicalSegmentation.createResultImage");
	    
		//Close cell contour image and morpological segmentation window
		selectWindow("Morphological Segmentation");
		close();
		selectWindow(list[j]);
		close();

		//Erode binary image to widen segmented cell contours
		selectWindow(File_name + "_cells-watershed-lines.tif");
		run("Invert");
		run("Erode");
		run("Erode");
		run("Erode");
		run("Erode");

		// clean up the ROI manager
		roiManager("reset");

		//Generate ROIs from segmented image
		run("Analyze Particles...", "size=1000-100000 clear add");

		//User can change Analyze Particles settings if necessary	
		Dialog.create("Satisfied with ROI sizes");
		Dialog.addCheckbox("Satisfied?", true);
		Dialog.show();
		Satisfied = Dialog.getCheckbox();
		while (Satisfied==false){ 
			run("Analyze Particles...");
			Dialog.create("Satisfied with ROI sizes");
			Dialog.addCheckbox("Satisfied?", false);
		 	Dialog.show();
	 		Dialog.addCheckbox("Satisfied?", false);
			Satisfied = Dialog.getCheckbox();
		}

		//Open cell contour image
		Input_cells = list[j];
		open( dir + File.separator + Input_cells);
		
		//Open Microtubules image
		Input_MTs = File_name + features_suffix;
		open(dir + File.separator + Input_MTs);
	    
		//Create composite image
		run("Merge Channels...", "c1=&Input_cells c4=&Input_MTs create");
		rename(File_name+"Composite.tif");

		//Apply generated ROIs to composite image
		roiManager("Show All");

		//User can check ROI alignment, delete ROIs and create new ones manually
		waitForUser("Manage ROIs", "If needed, move or remove some ROIs to fit your needs\nSome ROIs may not be well aligned with the cells on the MTs images\nWhen you are satisfied, click OK here.");
		
		//Save ROIs and close images
		Output_ROIs = File_name + contour_Roiset_suffix;
		roiManager("Save", dir + File.separator + Output_ROIs);
		selectWindow(File_name + "Composite.tif");
		close();
		selectWindow(File_name + "_cells-watershed-lines.tif");
		close();

		//Write to log, input files used, output file generated, time and date
		File.append("\tInput :\n\t=> " + Input_cells + "\n\t=> " + Input_MTs + "\n\tOutput :\n\t<= " + Output_ROIs , dir + File.separator + log_file_name);
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
print("- " + log_file_name + "\n- *" + contour_Roiset_suffix + "\n(*) For each image analyzed");
