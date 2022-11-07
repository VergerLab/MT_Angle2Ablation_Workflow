///======================MACRO=========================///
macro_name = "SimuAblation_Cell_RoiMaker_timelapse";
///====================================================///
///File author(s): Stéphane Verger=====================///

///====================Description=====================///
/*This macro allows a semi-automated segmentation and 
creation of ROI sets for 2D timelapse series. It also 
allows the identification of the Ablation ROI, cell ROIs 
which are adjacent to the ablation, refines cell ROI based 
on the ablation geometry, and generates a simulated images 
of tensile stress orientation around the ablation, based 
on the abaltion geometry.
It is made to be run on time series thus new ROI do not have 
to be created for each image in a time serie but only the 
first time point, and simply corrected for the following 
timepoints.
See https://github.com/VergerLab/MT_Angle2Ablation_Workflow 
for more detailed explanations of use.

!!!
This macro requires additional plugins to those already 
available in Fiji:
- MorpholibJ (update site IJPB-plugins)
	https://imagej.net/plugins/morpholibj
- Linear Stack Alignment with SIFT MultiChannel (update 
site PTBIOP)
	https://www.epfl.ch/research/facilities/ptbiop/
!!!!
*/
macro_source = "https://github.com/VergerLab/MT_Angle2Ablation_Workflow/";

///=========Input/output file names parameters=========///
// Input paramaters: input files suffixes
contours_suffix = "_cells.tif";
features_suffix = "_MTs.tif";

// Output paramaters: output file suffixes
contour_Roiset_suffix = "_RoiSet_cells.zip";
Ablation_Roi_suffix = "_Ablation.roi";
Simu_MT_suffix = "_MTs_Simu.tif";
original_contours_suffix = "_cells_original.tif";
original_features_suffix = "_MTs_original.tif";

///====================================================///
///====================================================///
///====================================================///

print("\\Clear");

//Do...while loop over the whole macro to process multiple folders one after another
do{ 

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

//Check if images have already been processed with the macro and reset original image (to avoid re-processing the images)
for (k=0; k<list.length; k++){ //Loop on all the images in the folder
	
	//Select original image
	if (endsWith (list[k], original_contours_suffix)){
		print("Image already processed ", dir + list[k]);
		//open the image
		open(dir + File.separator + list[k]);
		//get the base name
		File_name = substring(list[k], 0, indexOf(list[k], original_contours_suffix));
		//rename
		saveAs("tiff", dir + File.separator + File_name + contours_suffix);
		//Same for MT image
		open(dir + File.separator + File_name + original_features_suffix);
		wait(100);
		saveAs("tiff", dir + File.separator + File_name + features_suffix);
		//Close image
		run("Close All");
	}
} 

//Make a stack of the timelapse to identify cells to track
//Loop on all the images in the folder
for (k=0; k<list.length; k++){
	print(list[k]);
	
	//Select cell contour images
	if(endsWith (list[k], contours_suffix)){
		print("file_path", dir + list[k]);

		//count samples analyzed
		s++;
		
		//Extract generic name of the image serie
		File_name = substring(list[k], 0, indexOf(list[k], contours_suffix));

		//Open the cell contour image to segment and save the original image under different name
		Input_cells = list[k];
		Input_MTs = File_name + features_suffix;
		open(dir + File.separator + Input_cells);
		wait(100);
		saveAs("tiff", dir + File.separator + File_name + original_contours_suffix);
		wait(100);
		open(dir + File.separator + Input_MTs);
		wait(100);
		saveAs("tiff", dir + File.separator + File_name + original_features_suffix);
		wait(100);
		getPixelSize(unit, pixelWidth, pixelHeight);
		
		//Make channel stack
		run("Images to Stack", "name=" + s + " title=[] use");
	}
}

//Concatenate stack and make hyperstack
run("Concatenate...", "all_open open");
run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]");
rename("Timelapse");

//Register/align stack
run("Linear Stack Alignment with SIFT MultiChannel", "registration_channel=1 initial_gaussian_blur=3 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=4 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Rigid");
setBatchMode("exit and display");

//User can check the regustered 2 channel stack
waitForUser("Check timelapse", "Visually identify cells to track\n(cells visible from the begining to the end of the timelapse).\nWhen you are ready, click OK here!");

//Return stack to images to match original with transformed before saving
setBatchMode("hide");
selectWindow("Timelapse");
run("Stack to Images");
selectWindow("Aligned_Timelapse");
run("Stack to Images");

//Save aligned images using names from original images (overwrite) 
list2 = getList("image.titles");	 
half = list2.length/2;
for (l=0; l<half; l++){
	print(list2[l]);
	Ori_file_name = substring(list2[l], 0, indexOf(list2[l], "_ori"));
	selectImage(l+1+half);
	run("Grays");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=" + pixelWidth + " pixel_height=" + pixelHeight + " voxel_depth=1.0000000");
	saveAs("tiff", dir + File.separator + Ori_file_name + ".tif");
}
run("Close All");
setBatchMode("exit and display");


s = 0;
segmentation_done = false;
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
	
		if(segmentation_done == false){ //Will do the cell segmentation and generate ROIs for the first image of the timelapse only
			//Open the cell contour image to segment
			Input_cells = list[j];
			open(dir + File.separator + Input_cells);
			
			//Preprocess image
			run("8-bit");
			run("Gaussian Blur...", "sigma=2");
	
			do {
				///Ask the user segmentation method
				Dialog.create("Segmentation method");
				Dialog.addMessage("Automated Morphologial Segmentation or Interactive Marker-controlled Watershed? (MorpholibJ)");
				Dialog.addChoice("Folder\t", newArray("Morphological", "Marker watershed"));
				Dialog.show();
				SegType = Dialog.getChoice();
				
				selectWindow(Input_cells);
				
				if(SegType == "Morphological"){
					//MorpholibJ morphological segmentation
					run("Morphological Segmentation");
					wait(1000);
					call("inra.ijpb.plugins.MorphologicalSegmentation.setInputImageType", "border");
					call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance=10", "calculateDams=true", "connectivity=6");
				}else {
					//Interactive Marker-controlled Watershed
					run("Interactive Marker-controlled Watershed");
					setTool("multipoint");
				}
				//User can change segmentation parameters if necessary
				waitForUser("Watershed segmentation", "Rerun the watershed segmentation with appropriate parameters if necessary.\nCheck If label merges are needed (But process them at the next step, not here).\nWhen you are satisfied, click OK here!");
				
				//Do...while/satisfied dialog
				Dialog.create("Satisfied?");
				Dialog.addChoice("Does the segmentation look acceptable", newArray("Yes", "No"));
				Dialog.show();
				segmentation = Dialog.getChoice();
				
				if (segmentation == "Yes"){
					//Generate segmented label image
					if (SegType == "Morphological"){
						call("inra.ijpb.plugins.MorphologicalSegmentation.setDisplayFormat", "Catchment basins");
						call("inra.ijpb.plugins.MorphologicalSegmentation.createResultImage");
					}else {
						call("inra.ijpb.plugins.InteractiveMarkerControlledWatershed.setDisplayFormat", "Catchment basins");
						call("inra.ijpb.plugins.InteractiveMarkerControlledWatershed.createResultImage");
					}
				}
				//Close morpological segmentation window
				setBatchMode("show");
				if (SegType == "Morphological"){
					selectWindow("Morphological Segmentation");
				}else {
					selectWindow("Interactive Marker-controlled Watershed");
				}
				close();
			} while (segmentation == "No");
	
			//Merge labels if needed
			setBatchMode("show");
			open(dir + File.separator + Input_cells);
			selectWindow(File_name + "_cells-catchment-basins.tif");
			setTool("multipoint");

			waitForUser("Merge over-segmented area(s)?", "If there are over-segmented area(s) (often the ablation site) follow these steps (otherwise, skip!):\n1) Select the multi-point tool.\n2) Place a point on each of the two (or more) labels you want to merge.\n3) Go to Plugins>MorpholibJ>Label Images>Merge Label(s).\n4) For 'Gap management', select 'Orthogonal' and press OK. The labels should then be merged.\n5) Select the label image and press 'ctrl+shift+A' to remove the multi-points. \n6) You can then either merge other labels if needed (following the same procedure), or click OK below if you are done!");
			
			//Close cell contour image
			selectWindow(File_name + "_cells-1.tif");
			close();
			selectWindow(Input_cells);
			close();
			
			//User select ablation site
			selectWindow(File_name + "_cells-catchment-basins.tif");
			waitForUser("Ablation label"," Next you need to define the ablation:\n Simply place a point on the label corresponding to the ablation site and click OK");
			AblLabel=getValue("Mean");
			run("Select Label(s)", "label(s)=" + AblLabel);
			//Convert ablation Label to ROI (pre-processing)
			run("RGB Color");
			run("8-bit");
			setThreshold(1, 255);
			run("Convert to Mask", "method=Default background=Dark black");
			for (i = 0; i < 3; i++) {
				run("Erode");
			}
			//Generate ablation ROIs from binary image
			run("Analyze Particles...", "size=100-100000 clear add");
			
			//Extract Neighbors
			selectWindow(File_name + "_cells-catchment-basins.tif");
			run("Select Neighbor Labels", "labels=" + AblLabel+ " radius=2");
			//Convert cell Labels to ROIs (pre-processing)
			run("RGB Color");
			run("8-bit");
			setThreshold(1, 255);
			run("Convert to Mask", "method=Default background=Dark black");
			for (i = 0; i < 6; i++) {
				run("Erode");
			}
			//Generate cell ROIs from binary image
			run("Analyze Particles...", "size=100-100000 add");
	
			//Close label images
			selectWindow(File_name + "_cells-catchment-basins.tif");
			close();
			selectWindow(File_name + "_cells-catchment-basins-keepLabels");
			close();
			selectWindow(File_name + "_cells-catchment-basins-NeighborLabels");
			close();

		}else{ //If this is not the first images, segmentation has already been done, re-open ROI defined for previous image
			//clean up the ROI manager
			roiManager("reset");
			//Open cell roiset from previous processed image
			roiManager("Open", dir + File.separator + Output_Cell_ROIs);
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
	
		if(segmentation_done == false){
			//Apply generated ROIs to composite image
			roiManager("Show All");
			waitForUser("Manage ROIs", "Check (before refining based on ablation geometry)");

			//Save ablation ROI
			Output_Abl_ROI = File_name + Ablation_Roi_suffix; 
			roiManager("Select", 0);
			roiManager("save selected", dir + File.separator + Output_Abl_ROI);

			//Get ROI number
			roi_nb = roiManager("count");

			//Expand ablation ROI to define a band around the ablation to crop ROIs (restrict CMT quantification to a given distance from the ablation)
			Satisfied = false;
			while (Satisfied==false){ 
				roiManager("Select", 0);
				BandWidth=getNumber("Set Value for ablation band", 30);
				run("Enlarge...", "enlarge=" + BandWidth);
				Dialog.create("Satisfied with ablation band width?");
				Dialog.addCheckbox("Satisfied?", false);
		 		Dialog.show();
				Satisfied = Dialog.getCheckbox();
			}
			roiManager("Add");

			//Crop ROIs based on ablation band
			for (x = 1; x <roi_nb ; x++) {
				roiManager("Select", newArray(x,roi_nb));
				id = roiManager("index");
				print("index " + x + " id " + id);
				roiManager("AND");
				roiManager("Add");
			}

			//Remove original ROIs
			roi_nb = roiManager("count");
			for (x = 0; x < (roi_nb/2) ; x++) {
				roiManager("Select", 0);
				roiManager("Delete");
			}

			//Remove expanded ablation ROI
			roiManager("Select", 0);
			roiManager("Delete");
			
			//Show ROI and check
			roiManager("Show All");
			waitForUser("Manage ROIs", "Check (Cell ROIs after refining based on ablation geometry)");
			
		}else {
			//Show ROI and check
			roiManager("Show All");
			waitForUser("Manage ROIs", "Check and correct positions relative to cell outlines");
		}
		
		//Save ROIs and close images
		Output_Cell_ROIs = File_name + contour_Roiset_suffix;
		roiManager("Save", dir + File.separator + Output_Cell_ROIs);
		roiManager("reset");
		selectWindow(File_name + "Composite.tif");
		getDimensions(width, height, channels, slices, frames);
		close();
		
		
		//Simulation (geometrical) of tensile stress pattern around ablation site
		if(segmentation_done == false){
			Satisfied = false;
			while (Satisfied==false){ 
		
				//New image for geometry simulated MTs
				Output_MTSimu = File_name + Simu_MT_suffix;
				newImage(Output_MTSimu, "8-bit black", width, height, 1);

				//Re-open ablation ROI
				roiManager("Open", dir + File.separator + Output_Abl_ROI);
				roiManager("Show All");

				//Simulate MTs predicted orientation by successive enlargement, band and clearing of ablation ROI
				Iteration=getNumber("Set iteration number (how many MT-like lines will be drawn)", 10);
				Spacing=getNumber("Set spacing value", 10);
				for (i = 0; i < Iteration; i++) {
					roiManager("Select", 0);
					BandEnlarge = (1 + i) * (Spacing);
					run("Enlarge...", "enlarge=" + BandEnlarge);
					run("Make Band...", "band=1");
					run("Fill", "slice");
				}

				//Check parameters
				roiManager("Open", dir + File.separator + Output_Cell_ROIs);
				roiManager("Show All");
			
				Dialog.create("Satisfied with Simulated MT? Within ROIs?");
				Dialog.addCheckbox("Satisfied?", false);
		 		Dialog.show();
				Satisfied = Dialog.getCheckbox();
			
				//Save and close simulated MTs
				roiManager("reset");
				roiManager("show none");
				selectWindow(Output_MTSimu);
				if (Satisfied==true){
					saveAs("tiff", dir + File.separator + Output_MTSimu);
				}
				close();
			}
		}else {
			setBatchMode("hide");
			//New image for geometry simulated MTs
			Output_MTSimu = File_name + Simu_MT_suffix;
			newImage(Output_MTSimu, "8-bit black", width, height, 1);
			
			//Re-open ablation ROI
			roiManager("Open", dir + File.separator + Output_Abl_ROI);
			roiManager("Show All");
			
			//Simulate MTs predicted orientation by successive enlargement, band and clearing of ablation ROI
			for (i = 0; i < Iteration; i++) {
				roiManager("Select", 0);
				BandEnlarge = (1 + i) * (Spacing);
				run("Enlarge...", "enlarge=" + BandEnlarge);
				run("Make Band...", "band=1");
				run("Fill", "slice");
			}
			
			//Save and close simulated MTs
			Overlay.remove;
			Roi.remove;
			selectWindow(Output_MTSimu);
			saveAs("tiff", dir + File.separator + Output_MTSimu);
			close();
			setBatchMode("exit and display");
		}
		//Segmentation done on first image
		segmentation_done = true;

		//Write to log, input files used, output file generated, time and date
		File.append("\tInput :\n\t=> " + Input_cells + "\n\t=> " + Input_MTs + "\n\tOutput :\n\t<= " + Output_Cell_ROIs + "\n\t=> " + Output_Abl_ROI + "\n\t=> " + Output_MTSimu , dir + File.separator + log_file_name);
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
print("- " + log_file_name + "\n- *" + contour_Roiset_suffix + "\n- *" + Simu_MT_suffix + "\n(*) For each image analyzed");

// Dialog asking to process more folders
Dialog.create("More?");
Dialog.addMessage("Do you want to process another folder");
Dialog.addChoice("More", newArray("Yes", "No, I'm done"));
Dialog.show();
More = Dialog.getChoice();
} while (More=="Yes");
