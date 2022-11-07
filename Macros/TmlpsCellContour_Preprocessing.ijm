///======================MACRO=========================///
macro_name = "TmlpsCellContour_Preprocessing";
///====================================================///
///File author(s): Stéphane Verger=====================///

///====================Description=====================///
/*This macro uses a time series (from individual tiff 
images) to improve cell contour detection for further 
automated cell segmentation.
It opens, group as stack and registers/aligns each image 
of the time series to the first image. It then performs an 
average projection and saves the newly generate image, 
replacing the first image of the time series.
See https://github.com/VergerLab/MT_Angle2Ablation_Workflow 
for more detailed explanations of use.
*/
macro_source = "https://github.com/VergerLab/MT_Angle2Ablation_Workflow/";

///=========Input/output file names parameters=========///
// Input paramaters: input files suffixes
contours_suffix = "_cells.tif";

// Output paramaters: output file suffixes
original_contours_suffix = "_cells_1st_original.tif";

///====================================================///
///====================================================///
///====================================================///
var ImageOne

///Ask the user single vs multiple folders
Dialog.create("TmlpsCellContour_Preprocessing");
Dialog.addMessage("Run pre-processing on a single folder (test parameters), or the whole experiment?");
Dialog.addChoice("Folder\t", newArray("Single", "all"));
Dialog.show();
Folder = Dialog.getChoice();

print("\\Clear");

//Select whole experiment directory
UpDirPath = getDirectory("Choose a directory");
UpDirName = File.getName(UpDirPath);
ListUpDir = getFileList(UpDirPath);

//Generate log file for record
log_file_name = "Log_" + UpDirName + "_" + macro_name + ".txt";
fLog = File.open(UpDirPath + File.separator + log_file_name);
print(fLog, "Files processed with the macro " + macro_name + ".ijm\n(" + macro_source + ")\n\n");
print(fLog, "Directory: " + UpDirPath + "\n\nFiles processed:");
File.close(fLog);

//Show log to track progress (batch mode)
selectWindow("Log");

//Run the macro on the selected folder
if (Folder=="Single"){
	do{ 
		//Run preprocessing
		TmlpsCellCont_preproc(ListUpDir, UpDirPath);
		//Re-opens image
		setBatchMode("exit and display");
		open(UpDirPath + File.separator + ImageOne);
		//Run test segmentation
		TestSegmentation();
		//Close morpological segmentation window and imageOne
		selectWindow("Morphological Segmentation");
		close();
		selectWindow(ImageOne);
		close();
		//Do...while dialog
		Dialog.create("Satisfied?");
		Dialog.addChoice("Does the segmentation look acceptable", newArray("Yes", "No"));
		Dialog.show();
		More = Dialog.getChoice();
	} while (More=="No");
}else {
	//Loop through Genotype/conditions/samples folders architecture
	for (a=0; a<ListUpDir.length; a++){
		GenoDirPath = UpDirPath + ListUpDir[a];
		if(File.isDirectory(GenoDirPath)){
			GenoDirName = File.getName(GenoDirPath);
			listGenoDir = getFileList(GenoDirPath);
			//Loop through sample folders
			for (b=0; b<listGenoDir.length; b++){
				SampleDirPath = GenoDirPath + listGenoDir[b];
				if(File.isDirectory(SampleDirPath)){
					print("\n----> Geno " + ListUpDir[a]);
					print ("----> sample " + listGenoDir[b]);
					SampleDirName = File.getName(SampleDirPath);
					list = getFileList(SampleDirPath);
					
					//Run the angle to ablation calculation for the selected folder
					TmlpsCellCont_preproc(list, SampleDirPath);
					
				}
			}
		}
	}
}//End of folder architecture loops and if statements

//End of the macro message
print("\n\n===>End of the " + macro_name + " macro");
print("Check output files in:\n" + UpDirPath);
print("- " + log_file_name + "\n- *" + contours_suffix);

///=========Function=========///
function TmlpsCellCont_preproc(list, SampleDirPath) { // Runs the angle to ablation calculation on a single folder
	///Ask the user number of slices to use
	Dialog.create("Registration");
	Dialog.addMessage("Choose how many images to use for the registration/alignment.");
	Dialog.addNumber("Use image 1 to", ListUpDir.length/2);
	Dialog.show();
	ImgNb = Dialog.getNumber();
	
	s = 0;
	setBatchMode("hide");
	//Check if first image has already been processed with the macro and reset original image (to avoid re-processing the first image)
	for (k=0; k<list.length; k++){ //Loop on all the images in the folder
		
		//Select original image
		if (endsWith (list[k], original_contours_suffix)){
			print("First image already processed ", SampleDirPath + list[k]);
			//open the image
			open(SampleDirPath + File.separator + list[k]);
			//get the base name
			File_name = substring(list[k], 0, indexOf(list[k], original_contours_suffix));
			//rename
			saveAs("tiff", SampleDirPath + File.separator + File_name + contours_suffix);
			//Close image
			run("Close All");
		}
	}
	
	//Make a stack of the timelapse
	for (k=0; k<(ImgNb*2); k++){ //Loop on all the images in the folder
	//for (k=0; k<((ImgNb*2)+1); k++){ //Loop on all the images in the folder
		
		//Select cell contour images
		if (endsWith (list[k], contours_suffix)){
			print("file_path", SampleDirPath + list[k]);
	
			//count samples analyzed
			s++;
			
			//Open the cell contour image to segment
			Input_cells = list[k];
			open(SampleDirPath + File.separator + Input_cells);
			
			if (s==1){
				//Record name and pixel size of first image of the time series
				ImageOne = list[k];
				getPixelSize(unit, pixelWidth, pixelHeight);
				
				//Extract generic name of the image serie and save with new suffix
				File_name = substring(list[k], 0, indexOf(list[k], contours_suffix));
				saveAs("tiff", SampleDirPath + File.separator + File_name + original_contours_suffix);
			}
		}
	}
	
	//Make stack, Register/align, project, enhance contrast
	run("Images to Stack", "name=Stack title=[] use");
	run("Linear Stack Alignment with SIFT", "initial_gaussian_blur=3 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=2048 feature_descriptor_size=4 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Affine");
	run("Z Project...", "projection=[Average Intensity]");
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT");
	
	//Close intermediate images
	selectWindow("Stack");
	close();
	selectWindow("Aligned " + s + " of " + s);
	close();
	
	//Save/replace original first images
	selectWindow("AVG_Aligned " + s + " of " + s);
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=" + pixelWidth + " pixel_height=" + pixelHeight + " voxel_depth=1.0000000");
	saveAs("tiff", SampleDirPath + File.separator + ImageOne);
	close();
}

function TestSegmentation() { // Runs a test segmentation to assess the quality/usefulness of the preprocessing
	//Preprocess image for test segmentation
	run("Gaussian Blur...", "sigma=2");
	//MorpholibJ morphological segmentation
	run("Morphological Segmentation");
	wait(1000);
	call("inra.ijpb.plugins.MorphologicalSegmentation.setInputImageType", "border");
	call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=10", "calculateDams=true", "connectivity=6");
	//User can change segmentation parameters if necessary
	waitForUser("Watershed segmentation", "Rerun the watershed segmentation with appropriate parameters if necessary.");
}
