///======================MACRO=========================///
macro_name = "TmlpsCellSeg_Preprocessing";
///====================================================///
///File author(s): Stéphane Verger=====================///

///====================Description=====================///
/*This macro uses a time series (from individual tiff 
images)to improve cell contour detection for further 
automated cell segmentation.
It opens, group as stack and registers/aligns each image 
of the time series to the first image. It then performs an 
average projection and saves the newly generate image, 
replacing the first image of the time series.
See https://github.com/VergerLab/MT_Angle2Ablation_Workflow 
for more detailed explanations of use.
*/
macro_source = "https://github.com/VergerLab/Todo";

///=========Input/output file names parameters=========///
// Input paramaters: input files suffixes
contours_suffix = "_cells.tif";

// Output paramaters: output file suffixes
original_contours_suffix = "_cells_original.tif";

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

setBatchMode("hide");
//Make a stack of the timelapse
//Loop on all the images in the folder
for (k=0; k<list.length; k++){
	print(list[k]);
	
	//Select cell contour images
	if(endsWith (list[k], contours_suffix)){
		print("file_path", dir + list[k]);

		//count samples analyzed
		s++;
		
		//Open the cell contour image to segment
		Input_cells = list[k];
		open(dir + File.separator + Input_cells);
		
		if(s==1){
			//Record name and pixel size of first image of the time series
			ImageOne = list[k];
			getPixelSize(unit, pixelWidth, pixelHeight);
			
			//Extract generic name of the image serie and save with new suffix
			File_name = substring(list[k], 0, indexOf(list[k], contours_suffix));
			saveAs("tiff", dir + File.separator + File_name + original_contours_suffix);
		}
	}
}

//Make stack, Register/align, project, enhance contrast
run("Images to Stack", "name=Stack title=[] use");
run("Linear Stack Alignment with SIFT", "initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=4 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Affine interpolate");
run("Z Project...", "projection=[Average Intensity]");
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");

//Close intermediate images
selectWindow("Stack");
close();
selectWindow("Aligned 13 of 13");
close();

//Save/replace original first images
selectWindow("AVG_Aligned 13 of 13");
run("Properties...", "channels=1 slices=1 frames=1 pixel_width=" + pixelWidth + " pixel_height=" + pixelHeight + " voxel_depth=1.0000000");
saveAs("tiff", dir + File.separator + ImageOne);
close();

//End of the macro message
print("\n\n===>End of the " + macro_name + " macro");
print("Check output files in:\n" + dir);
print("- " + log_file_name + "\n- *" + contours_suffix + "\n(*) For each image analyzed");

