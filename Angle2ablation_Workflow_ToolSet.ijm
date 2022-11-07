var ImageOne;
macro "FolderMaker Action Tool - C000 T0508F T4508o T9508l Tb508d Tg508r T0h08M T4h08a T9h08k Teh08e Tjh08r" {
///======================MACRO=========================///
macro_name = "FolderMaker";
///====================================================///
///File author(s): Stéphane Verger=====================///

///====================Description=====================///
/*This macro allows to automatically generate a folder 
architecture for batch analysis of multiple genotypes,
samples and timepoints in the frame of the 
MT_Angle2Ablation_Workflow.

See https://github.com/VergerLab/MT_Angle2Ablation_Workflow 
for more detailed explanations of use.
*/
macro_source = "https://github.com/VergerLab/MT_Angle2Ablation_Workflow/";

///=========Input/output file names parameters=========///
//None
///====================================================///
///====================================================///
///====================================================///

//Get date to propose as part of the folder name
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

//Dialog for folder architecture
Dialog.create("Folder architecture definition");
Dialog.addMessage("Define the name of the folder to be created that will contain the rest of the analysis (Genotpes/conditions, samples, timepoints)");
Dialog.addString("Experiment name", year + "-" + month + "-" + dayOfMonth + "_Tmlps_MT_Angle2ablationAnalysis", 40);
Dialog.addDirectory("Where to put this folder?", "Choose/a/directory");
Dialog.addMessage("Below, enter the names of each genotype or condition analyzed. Each name separated by a coma and a space.\nDo not put spaces or / in the name, use _ instead. e.g. GFP-MBD, GFP-MBD_bot1-7");
Dialog.addString("Genotpes/conditions names", "(e.g. GFP-MBD, GFP-MBD_bot1-7)", 40);
Dialog.addNumber("How many samples per genotypes/conditions?", "9");
Dialog.show();
ExpName = Dialog.getString();
dir = Dialog.getString();
GenoNames = Dialog.getString();
SampleNb = Dialog.getNumber();

//Create array for genotypes/conditions names
GenoNamesArray = split(GenoNames, ", ");

//Generate the experiment folders
File.makeDirectory(dir+File.separator+ExpName);

//Generate the genotype/condition folders
for (a=0; a<GenoNamesArray.length; a++){
	print(GenoNamesArray[a]);
	File.makeDirectory(dir+File.separator+ExpName+File.separator+GenoNamesArray[a]);
	
	//Generate the Sample folders
	for (b=0; b<SampleNb; b++){
		bb = b + 1;
		print(bb);
		File.makeDirectory(dir+File.separator+ExpName+File.separator+GenoNamesArray[a]+File.separator+bb);
	}
}

//End of the macro message
print("\n\n===> End of the FolderMaker macro");
print("Check new folder architecture created in:\n" + dir);
};
 
macro "TmlpsCellContour_Preprocessing Action Tool - C000 T0308C T6308e Tc308l Tf308l T0b08P T5b08r Tab08e T0h08p T6h08r Tah08o Tfh08c" {
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
};
 
macro "SimuAblationCell_RoiMaker_timelapse Action Tool - C000 T0508R T6508O Td508I T0h08M T4h08a T9h08k Teh08e Tjh08r" {
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
};
 
macro "FibrilTool_Batch_Workflow Action Tool - C000 T0508F T4508i T7508b Tb508r Tf508i Tj508l T0h08T T4h08o T9h08o Teh08l" {
///======================MACRO=========================///
macro_name = "FibrilTool_Batch_Workflow";
///====================================================///
///File author(s): Stephane Verger, 
//                 Marion Louveaux, 
//                 Arezki Boudaoud=====================///

///====================Description=====================///
/*The original FibrilTool.ijm macro was written by Arezki 
Boudaoud (see Boudaoud et al., Nature Protocols 2014).
An automated/batch version of this macro, 
FibrilTool_Batch.ijm, has been implemented by Marion 
Louveaux (https://github.com/marionlouveaux/FibrilTool_Batch).
This version has been slightly modified by Stéphane Verger 
to ease it's incorporation into an image analysis workflow.

See https://github.com/VergerLab/MT_Angle2Ablation_Workflow 
for more detailed explanations of use.
*/
macro_source = "https://github.com/VergerLab/MT_Angle2Ablation_Workflow/FibrilTool_Batch_Workflow.ijm";

///=========Input/output file names parameters=========///
// Input paramaters: input files suffixes
Fibril_image_suffix = "_MTs.tif";
cell_Roiset_suffix = "_RoiSet_cells.zip";

// Output paramaters: output file suffixes
Fibril_Roiset_suffix = "_RoiSet_FT.zip";
Overlay_image_suffix = "_FT.tif";
Result_text_suffix = "_FT.txt";

///====================================================///
///====================================================///
///====================================================///


// the log output gives the average properties of the region
// 0) 	image title
//		cell number
// 1) 	x-coordinate of region centroid (scaled)
// 		y-coordinate of region centroid (scaled)
// 	 	area (scaled)
// 2)  nematic tensor
//		average orientation (angle in -90:90 in degrees)
// 		quality of the orientation (score between 0 and 1)
// The results are drawn on an overlay
// 3)  coordinates of polygon vertices for record



//threshold for flat regions
var thresh = 2;

//default for font size
var fsize = 15;

// number for cells
var num;

//default for width of ROI lines
var lwidth = 2;

var pi = 3.14159265;

print("\\Clear");
roiManager("reset");

dir = getDirectory("Choose a folder")
Folder_name = File.getName(dir);
list = getFileList(dir);

///Ask the user about fibril tool parameters
  Dialog.create("Fibril Tool");
  Dialog.addMessage("Choose the target\n(Real or simulated MTs)");
  Dialog.addChoice("Target for fibrils?\t", newArray("Real", "Simu"));
  Dialog.addChoice("Channel for drawing\t", newArray( "R", "G", "B", "No"));
  Dialog.addNumber("Multiply line length by\t", 1);
  Dialog.addNumber("Line thickness\t", 2);
  Dialog.addChoice("Numbering of fibrils?\t", newArray("no", "yes"));
  Dialog.show();
  fib = Dialog.getChoice();
  drw = Dialog.getChoice();
  norm_constant = Dialog.getNumber(); // scaling factor for drawing of segments
  width = Dialog.getNumber();
  numbering = Dialog.getChoice();

//Define which target
if(fib == "Simu"){
	Fibril_image_suffix = "_MTs_Simu.tif";
	Fibril_Roiset_suffix = "_RoiSet_FTSimu.zip";
	Overlay_image_suffix = "_FTSimu.tif";
	Result_text_suffix = "_FTSimu.txt";
}

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
	if(endsWith (list[j], Fibril_image_suffix)){
		
		//count samples analyzed
		s++;
		
		//Extract generic name of the image serie
		File_name = substring(list[j], 0, indexOf(list[j], Fibril_image_suffix));

		//Open Microtubules image
		Input_MTs = list[j];
		open(dir + File.separator + Input_MTs);

		//Open corresponding RoiSet
		Input_ROI_Cells = File_name + cell_Roiset_suffix;
		open(dir + File.separator + Input_ROI_Cells);

		//Write to log txt file
		File.append("- Sample number: " + s + "\n" + File_name, dir + File.separator + log_file_name);

		//Make headers for output txt file 
		print ("Sample\tROI\tX\tY\tArea\tAngle\tAnisotropy");

		//
		id = getImageID(); 
		title = getTitle();
		
		getPixelSize(unit,pixelWidth,pixelHeight);
		if (pixelWidth != pixelHeight) exit("Rectangular pixels!");
		scale = pixelWidth;
		
		
		//properties of selection
		num++ ;
		selectImage(id);
		
		///ROI selection
		n = roiManager("count");
		for (cell=0; cell<n; cell++) {

			setBatchMode(true);
			
			roiManager("select", cell);
			ROI_nm = Roi.getName(); 
			
			getSelectionCoordinates(vertx, verty);
			c = polygonCentre(vertx,verty);
			c0s = c[0]*scale ;
			c1s = c[1]*scale ;
			getRawStatistics(area);
			areas = area*scale*scale;
			pr = 2;
			sortie = title+"\t"+ROI_nm;
			sortie = sortie+"\t"+d2s(c0s,pr)+"\t"+d2s(c1s,pr)+"\t"+d2s(areas,pr);
			
			//extract fibril signal
			selectImage(id);
			run("Duplicate...", "title=Temp");
			run("Crop"); 
			getSelectionCoordinates(vertxloc, vertyloc);
			run("8-bit");
			
			//compute x-gradient in "x"
			selectWindow("Temp");
			run("Duplicate...","title=x");
			run("32-bit");
			run("Translate...", "x=-0.5 y=0 interpolation=Bicubic");
			run ("Duplicate...","title=x1");
			run("Translate...", "x=1 y=0 interpolation=None");
			imageCalculator("substract","x","x1");
			selectWindow("x1");
			close();
			
			//compute y-gradient in "y"
			selectWindow("Temp");
			run ("Duplicate...","title=y");
			run("32-bit");
			run("Translate...", "x=0 y=-0.5 interpolation=Bicubic");
			run ("Duplicate...","title=y1");
			run("Translate...", "x=0 y=1 interpolation=None");
			imageCalculator("substract","y","y1");
			selectWindow("y1");
			close();
			
			
			//compute norm of gradient in "g"
			selectWindow("x");
			run("Duplicate...","title=g");
			imageCalculator("multiply","g","x");
			selectWindow("y");
			run("Duplicate...","title=gp");
			imageCalculator("multiply","gp","y");
			imageCalculator("add","g","gp");
			selectWindow("gp");
			close();
			selectWindow("g");
			w = getWidth(); h = getHeight();
			for (y=0; y<h; y++) {
				for (x=0; x<w; x++){
					setPixel(x, y, sqrt( getPixel(x, y)));
				}
			}
			//set the effect of the gradient to 1/255 when too low ; threshold = thresh
			selectWindow("g");
			for (y=0; y<h; y++) {
				for (x=0; x<w; x++){
					if (getPixel(x,y) < thresh) 
						setPixel(x, y, 255);
				}
			}
			
			//normalize "x" and "y" to components of normal
			imageCalculator("divide","x","g");
			imageCalculator("divide","y","g");
			
			//compute nxx
			selectWindow("x");
			run("Duplicate...","title=nxx");
			imageCalculator("multiply","nxx","x");
			//compute nxy
			selectWindow("x");
			run("Duplicate...","title=nxy");
			imageCalculator("multiply","nxy","y");
			//compute nyy
			selectWindow("y");
			run("Duplicate...","title=nyy");
			imageCalculator("multiply","nyy","y");
			
			//closing
			selectWindow("Temp");
			close();
			selectWindow("x");
			close();
			selectWindow("y");
			close();
			selectWindow("g");
			close();
			
			//averaging nematic tensor
			selectWindow("nxx");
			makeSelection("polygon",vertxloc,vertyloc);
			getRawStatistics(area,xx);
			selectWindow("nxx");
			close();
			
			selectWindow("nxy");
			makeSelection("polygon",vertxloc,vertyloc);
			getRawStatistics(area,xy);
			selectWindow("nxy");
			close();
			
			selectWindow("nyy");
			makeSelection("polygon",vertxloc,vertyloc);
			getRawStatistics(area,yy);
			selectWindow("nyy");
			close();
			
			//eigenvalues and eigenvector of texture tensor
			m = (xx + yy) / 2;
			d = (xx - yy) / 2;
			v1 = m + sqrt(xy*xy + d*d);
			v2 = m - sqrt(xy*xy + d*d);
			//direction
			tn = - atan((v2 - xx) / xy);
			//score
			scoren = abs((v1-v2) / 2 / m);
			
			//output
			tsn=tn*180/pi;
			//nematic tensor tensor
			sortie = sortie+"\t"+d2s(tsn,pr)+"\t"+d2s(scoren,2*pr);
			
			//polygon coordinates
			np = vertx.length;
			for (i=0; i<np; i++){
				xp = vertx[i]; yp = verty[i];
				//sortie = sortie+"\t"+d2s(xp,pr)+"\t"+d2s(yp,pr);
			}
			
			
			
			//
			//print output
			print(sortie);
			
			
			//
			//drawing of directions and cell contour
			selectImage(id);
			run("Add Selection...", "stroke=yellow width="+lwidth);
			
			
			// drawing nematic tensor
			if ( drw != "No" ) {
			u1 = norm_constant*sqrt(area)*cos(tn)*scoren + c[0];
			v1 = - norm_constant*sqrt(area)*sin(tn)*scoren + c[1];
			u2 = - norm_constant*sqrt(area)*cos(tn)*scoren + c[0];
			v2 =  norm_constant*sqrt(area)*sin(tn)*scoren + c[1];
			if (drw == "R") stroke = "red";
				else if (drw == "G") stroke = "green"; 
				else if (drw =="B") stroke = "blue";
				else exit("Drawing color undefined");
			makeLine(u1,v1,u2,v2);
			run("Add Selection...", "stroke="+stroke+" width=" + width);
			}
			
			
			//print number at center
			if (numbering == "yes") { makeText(ROI_nm,c[0],c[1]);
				run("Add Selection...", "stroke="+stroke+" font="+fsize+" fill=none");
			}
		} //end of ROI selection
		setBatchMode("exit and display");
		selectWindow("ROI Manager");
		run("Close"); //Close the ROI manager
		
		wait(1000); //To give enough time to close and reopen the ROI manager
		
		//Send cell contours ROIs and FibrilTool output to the ROI manager
		run("To ROI Manager");
		wait(1000); //To give enough time to close and reopen the ROI manager
		roiManager("Show None");
		roiManager("Show all without labels"); //OR roiManager("Show All");
		
		//Identification of ROI of cell contour
		N = roiManager("count");
		
		if (numbering == "yes") {
			step = 3;
		}else{
			step = 2;
		}
		
		a1 = newArray(N/step);
		for (i=0; i<a1.length; i++){
			a1[i] = i*step;
		}
		
		//Delete ROI(s)
		roiManager("select", a1);
		roiManager("Delete");
		
		//Save microtubules orientation
		Output_ROI_FT = File_name + Fibril_Roiset_suffix;
		roiManager("Save", dir + File.separator + Output_ROI_FT);
		roiManager("Show all without labels");
		run("Flatten"); //Flatten the overlay
		Output_overlay = File_name + Overlay_image_suffix;
		saveAs("Tiff", dir + File.separator + Output_overlay);
		run("Close"); //Close the .tif image
		close();
		
		selectWindow("ROI Manager");
		run("Close");

		
		//Save the final log and close it
		selectWindow("Log");
		Output_text_FT = File_name + Result_text_suffix;
		saveAs("text", dir + File.separator + Output_text_FT);
		run("Close");

		//Write to log, input files used and output file generated
		File.append("\tInput :\n\t=> " + Input_MTs + "\n\t=> " + Input_ROI_Cells + "\n\tOutput :\n\t<= " + Output_ROI_FT + "\n\t<= " + Output_overlay + "\n\t<= " + Output_text_FT, dir + File.separator + log_file_name);
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		File.append("\t" + hour + ":" + minute + ":" + second + " " + dayOfMonth + "/" + month + "/" + year + "\n\n", dir + File.separator + log_file_name);
	} //end of if endswith (list[j], format)

} // end of for j=0; j<list.length; j++

//End of the macro message
print("\n\n===> End of the " + macro_name + " macro");
print("Check output files in:\n" + dir);
print("- " + log_file_name + "\n- *" + Fibril_Roiset_suffix + "\n- *" + Overlay_image_suffix + "\n- *" + Result_text_suffix + "\n(*) For each image analyzed");


// centroid of a polygon
function polygonCentre(x,y){
     n =x.length;
     area1 = 0;
     xc = 0; yc = 0;
     for (i=1; i<n; i++){
		  inc = x[i-1]*y[i] - x[i]*y[i-1];
         area1 += inc;
		  xc += (x[i-1]+x[i])*inc; 
		  yc += (y[i-1]+y[i])*inc;
     }
     inc = x[n-1]*y[0] - x[0]*y[n-1];
     area1 += inc;
     xc += (x[n-1]+x[0])*inc; 
     yc += (y[n-1]+y[0])*inc;    
     area1 *= 3;
     xc /= area1;
     yc /= area1;
     return newArray(xc,yc);
}



//distance between two points (x1,y1) et (x2,y2)
function distance(x1,y1,x2,y2) {
	return sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
   }


function printArray(a) {
  print("");
  for (i=0; i<a.length; i++)
      print(i+": "+a[i]);
}
};
 
macro "Angle2Ablation_timelapse Action Tool - C000 T0c10A T6c102 Tcc10A" {
///======================MACRO=========================///
macro_name = "Angle2Ablation_timelapse";
///====================================================///
///File author(s): Stéphane Verger=====================///

///====================Description=====================///
/*This macro allows an automated calculation of angles 
between the output of fibrilTool_Batch_workflow.ijm and
manually drawn lines corresponding to an ablation. 
Alternatively, it allows calculation of angles 
between the output of fibrilTool_Batch_workflow.ijm from 
real and "simulated" MTs. It natively uses as input, output 
from the fibrilTool_Batch_workflow.ijm macro as well as 
from the Line_RoiMaker_timelapse.ijm macro.

See https://github.com/VergerLab/MT_Angle2Ablation_Workflow 
for more detailed explanations of use.
*/
macro_source = "https://github.com/VergerLab/MT_Angle2Ablation_Workflow/";

///=========Input/output file names parameters=========///
// Input paramaters: input files suffixes
microtubule_image_suffix = "_MTs.tif";
FT_RoiSet_suffix = "_RoiSet_FT.zip";
Line_RoiSet_suffix = "_RoiSet_FTSimu.zip";
Anisotropy_suffix = "_FT.txt";

// Output paramaters: output file suffixes
Angles_file_suffix = "_Angle2Ablation.txt";
Angles_image_suffix = "_Angle2Ablation.tif";

///====================================================///
///====================================================///
///====================================================///

///Ask the user about angle to ablation calculation parameters
Dialog.create("Angle to ablation");
Dialog.addMessage("Choose angle comparison target\n(Manually drawn lines or simulated MTs)");
Dialog.addChoice("Target\t", newArray("Simu", "Lines"));
Dialog.addMessage("Run calculation on a single folder of the whole experiment?");
Dialog.addChoice("Folder\t", newArray("Single", "all"));
Dialog.show();
Target = Dialog.getChoice();
Folder = Dialog.getChoice();

//Define which angle target
if(Target == "Lines"){
	Line_RoiSet_suffix = "_RoiSet_lines.zip";
}


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

//Generate output file containing all the measured angles of all the images analyzed in this file
Output_angles_all = "All_" + UpDirName + Angles_file_suffix;
fAll = File.open(UpDirPath + File.separator + Output_angles_all);
print(fAll, "Genotype/condition" + "\t" + "Sample Number" + "\t" + "Timepoint" + "\t" + "CellNumber" + "\t" + "FibrilTool Angle" + "\t" + "Comparison Angle" + "\t" + "Raw angle" + "\t" + "Absolute angle" + "\t" + "Acute absolute angle to ablation" + "\t" + "Anisotropy");
File.close(fAll);

//Run the angle to ablation calculation for the selected folder
if (Folder=="Single"){
	Angle2ablationFolder(ListUpDir, UpDirPath, "Single", UpDirName);
}else {
	//Loop through Genotype/conditions/samples folders architecture
	for (a=0; a<ListUpDir.length; a++){
		print("Geno " + ListUpDir[a]);
		GenoDirPath = UpDirPath + ListUpDir[a];
		print("GenoDir " + GenoDirPath);
		if(File.isDirectory(GenoDirPath)){
			print("Geno " + ListUpDir[a]);
			GenoDirName = File.getName(GenoDirPath);
			print(GenoDirName);
			listGenoDir = getFileList(GenoDirPath);
			//Loop through sample folders
			for (b=0; b<listGenoDir.length; b++){
				print("sample " + listGenoDir[b]);
				SampleDirPath = GenoDirPath + listGenoDir[b];
				print("sampleDir " + SampleDirPath);
				if(File.isDirectory(SampleDirPath)){
					print("Geno " + listGenoDir[b]);
					SampleDirName = File.getName(SampleDirPath);
					print(SampleDirName);
					list = getFileList(SampleDirPath);
					
					//Run the angle to ablation calculation for the selected folder
					Angle2ablationFolder(list, SampleDirPath, GenoDirName, SampleDirName);
					
				}
			}
		}
	}
}//End of folder architecture loops and if statements

//End of the macro message
print("\n\n===> End of the Angle2Ablation macro");
print("Check output files in:\n" + UpDirPath);
print("- " + log_file_name + "\n- All_" + UpDirName + Angles_file_suffix + "\n- *" + Angles_file_suffix + "\n- *_Angle2Ablation.tif\n(*) For each image analyzed");


///=========Function=========///
function Angle2ablationFolder(list, SampleDirPath, GenoDirName, SampleDirName) { // Runs the angle to ablation calculation on a single folder
	s = 0;
	//Loop on all the images in the folder
	for (j=0; j<list.length; j++){
	
		//Select image series to process
		if (endsWith (list[j], microtubule_image_suffix)){
			print("file_path ", SampleDirPath + list[j]);
	
			//count samples analyzed
			s++;
			
			//Extract generic name of the image serie
			File_name = substring(list[j], 0, indexOf(list[j], microtubule_image_suffix));
	
			//Write to log txt file
			File.append("- Sample number: " + s + "\n" + File_name, UpDirPath + File.separator + log_file_name);
	
			//Open microtubule image
			Input_MTs = File_name + microtubule_image_suffix;
		    open(SampleDirPath + File.separator + Input_MTs);
	
			//Clean up the ROI manager and empty results tables
			roiManager("reset");
			run("Clear Results");
		
			//Open FibrilTool output ROI 
			Input_ROI_FT = File_name + FT_RoiSet_suffix;
			roiManager("Open", SampleDirPath + File.separator + Input_ROI_FT);
	
			//Count FibrilTool ROI number
			ft_roi_number = roiManager("count");
			print ("FT ROIs:" + ft_roi_number);
	
			//Open Lines (simu) ROI
			Input_ROI_lines = File_name + Line_RoiSet_suffix;
			roiManager("Open", SampleDirPath + File.separator + Input_ROI_lines);
	
			//Count total ROI number
			tot_roi_number = roiManager("count");
			print ("Total ROIs:" + tot_roi_number);
	
			//calculate line (Simu) ROI number
			line_roi_number = tot_roi_number - ft_roi_number;
			print ("Line ROIs:" + line_roi_number);
	
			//Error message if ROI numbers are not equal
			if (ft_roi_number != line_roi_number){
				exit ("ROI number for FibrilTool and drawn lines not equal in sample " + File_name);  
			}
	
			//Generate results from ROIs (including angles)
			run("Set Measurements...", "area mean min centroid redirect=None decimal=1");
			roiManager("measure");
	
			//Loop all corresponding FibrilTool and line ROIs
			for (i = 0; i < ft_roi_number; i++) {
	
				//Print cell number
				print("Cell:" + i + 1);
	
			    //Get FibrilTool ROI angle (and convert form -90/90 to 0/180 degrees angle values)
			    roiManager("select", i);
			    FTAngle = getResult("Angle", i);
			    if (FTAngle < 0){
			    	FTAngle = FTAngle + 180;
			    }
			    print ("FibrilTool Angle:" + FTAngle);
			    //Add overlay while selecting color and line width
			    Overlay.addSelection("Magenta", 4);
	
			    //Get line ROI angle (and convert to 0/180 degrees angle values)
			    roiManager("select", i + ft_roi_number);
			    LineAngle = getResult("Angle", i + ft_roi_number);
			    if (LineAngle < 0){
			    	LineAngle = LineAngle + 180;
			    }
			    print ("Line Angle:" + LineAngle);
			    //Add overlay while selecting color and line width
			    Overlay.addSelection("green", 2);
	
			    //Draw link between FT and line to check correspondance in angle calculation
			    getPixelSize(unit, pixelWidth, pixelHeight); //Get pixel size to convert from micron to pixel
			    
			    FT_X = getResult("X", i)/pixelWidth;
			    FT_Y = getResult("Y", i)/pixelWidth;
			    Line_X = getResult("X", i + ft_roi_number)/pixelWidth;
			    Line_Y = getResult("Y", i + ft_roi_number)/pixelWidth;
			    setColor("blue");
			    Overlay.drawLine(FT_X, FT_Y, Line_X, Line_Y);
	
				//Calculate "raw" angle difference (Ang2Abl)
				Ang2Abl = FTAngle - LineAngle;
				print("Raw angle:" + Ang2Abl);
	
				//Calculate absolute angle difference (AbsAng2Abl)
				AbsAng2Abl = abs(Ang2Abl);
				print("Abs angle:" + AbsAng2Abl);
	
				//Calculate acute absolute angle between both lines (AcAbsAng2Abl)
				AcAbsAng2Abl = AbsAng2Abl;
				if (AbsAng2Abl > 90){
			    	AcAbsAng2Abl = 180 - AbsAng2Abl;
			    }
			    print("Acute absolute angle to ablation:" + AcAbsAng2Abl);
	
				//Retrieve anisotopy value from FibrilTool output file
				Input_anisotropy = File_name + Anisotropy_suffix;
				filestring = File.openAsString(SampleDirPath + File.separator + Input_anisotropy); 
				rows=split(filestring, "\n"); 
				x=newArray(rows.length); 
				for(k=0; k<rows.length; k++){ 
					columns=split(rows[k],"\t"); 
					x[k]=parseFloat(columns[6]); 
				} 
				Anisotropy = x[(i+1)];
				print("Anisotropy :" + Anisotropy);
	
				//Writes output to the All_*_Angle2Ablation.txt file for all the images of the folder
				File.append(GenoDirName + "\t" + SampleDirName + "\t" + s + "\t" + (i + 1) + "\t" +  FTAngle + "\t" + LineAngle + "\t" + Ang2Abl + "\t" + AbsAng2Abl + "\t" + AcAbsAng2Abl + "\t" + Anisotropy, UpDirPath + File.separator + Output_angles_all);
	
			    //write angles on image (one decimal)
			    setColor("yellow");
			    setFont("SansSerif", 20);
			    Overlay.drawString(d2s(AcAbsAng2Abl,1), FT_X, FT_Y);
				Overlay.add;
			}
			//Flatten overlay and save image for verification
			Overlay.flatten
			Output_overlay = File_name + Angles_image_suffix;
			saveAs("tiff", SampleDirPath + File.separator + Output_overlay);
			
			//Close files corresponding to analyzed image
			selectWindow(File_name + Angles_image_suffix);
			run("Close");
			selectWindow(File_name + microtubule_image_suffix);
			run("Close");
			
			//Write to log, input files used and output file generated
			File.append("\tInput :\n\t=> " + Input_ROI_FT + "\n\t=> " + Input_ROI_lines + "\n\t=> " + Input_MTs + "\n\t=> " + Input_anisotropy + "\n\tOutput :\n\t<= " + Output_overlay + "\n\t<= " + Output_angles_all, UpDirPath + File.separator + log_file_name);
			getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
			File.append("\t" + hour + ":" + minute + ":" + second + " " + dayOfMonth + "/" + month + "/" + year + "\n\n", UpDirPath + File.separator + log_file_name);
		}
	}
	
	//Close all open files
	selectWindow("ROI Manager");
	run("Close");
	selectWindow("Results");
	run("Close");
	run("Close All");
	
	//Create time series stack
	outputType = newArray("_MTs.tif", "_FT.tif", "_Angle2Ablation.tif");
	
	//Nested loops
	//loop between types of output
	for (t=0; t<outputType.length; t++){ 
	
		//Loop on all the images in the folder
		for (j=0; j<list.length; j++){
	
			//Select image series to process
			if (endsWith (list[j], outputType[t])){
	
				//Open image
		    	open(SampleDirPath + File.separator + list[j]);
			}
		}
		//Image to stack
		wait(100);
		run("Images to Stack", "name=" + outputType[t] + " title=[] use");
		run("RGB Color");
	}
	//Assemble in hyperstack and save
	run("Concatenate...", "all_open open");
	saveAs("tiff", SampleDirPath + File.separator + GenoDirName + "_" + SampleDirName + "_Results.tif");
	selectWindow(GenoDirName + "_" + SampleDirName + "_Results.tif");
	close();
}};
