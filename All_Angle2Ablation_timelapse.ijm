///======================MACRO=========================///
macro_name = "All_Angle2Ablation_timelapse";
///====================================================///
///File author(s): Stéphane Verger=====================///

///====================Description=====================///
/*This macro allows an automated calculation of angles 
between the output of fibrilTool_Batch_workflow.ijm and
manually drawn lines corresponding to an ablation. 
Alternatively, it allows calculation of angles 
between the output of fibrilTool_Batch_workflow.ijm from 
real and "simulated" MTs.It natively uses as input, output 
from the fibrilTool_Batch_workflow.ijm macro as well as 
from the Line_RoiMaker_timelapse.ijm macro.
It is meant to be run on a folder architecture from a whole 
experiment.

See https://github.com/VergerLab/MT_Angle2Ablation_Workflow 
for more detailed explanations of use.
*/
macro_source = "https://github.com/VergerLab/MT_Angle2Ablation_Workflow/Angle2Ablation_timelapse.ijm";

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

///Ask the user about fibril tool parameters
Dialog.create("Fibril Tool");
Dialog.addMessage("Choose angle comparison target\n(Manually drawn lines or simulated MTs)");
Dialog.addChoice("Target\t", newArray("Simu", "Lines"));
/// Add someting to test on single folder or on whole experiment...
Dialog.show();
Target = Dialog.getChoice();

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
Output_angles_all = "All_" + UpDirName + Angles_file_suffix; ///Change is single folder...
fAll = File.open(UpDirPath + File.separator + Output_angles_all);
print(fAll, "Genotype/condition" + "\t" + "Sample Number" + "\t" + "Timepoint" + "\t" + "CellNumber" + "\t" + "FibrilTool Angle" + "\t" + "Comparison Angle" + "\t" + "Raw angle" + "\t" + "Absolute angle" + "\t" + "Acute absolute angle to ablation" + "\t" + "Anisotropy");
File.close(fAll);

//Loop through Genotype/conditions folders
for (a=0; a<ListUpDir.length; a++){
	print("Geno " + ListUpDir[a]);
	GenoDirPath = UpDirPath + ListUpDir[a];
	print("GenoDir " + GenoDirPath);
	if(File.isDirectory(GenoDirPath)){
		print("Geno " + ListUpDir[a]);
		GenoDirName = File.getName(GenoDirPath);
		print(GenoDirName);
		listGenoDir = getFileList(GenoDirPath);
	
	
		//Loop through Sample folders
		for (b=0; b<listGenoDir.length; b++){
			print("sample " + listGenoDir[b]);
			SampleDirPath = GenoDirPath + listGenoDir[b];
			print("sampleDir " + SampleDirPath);
			if(File.isDirectory(SampleDirPath)){
				print("Geno " + listGenoDir[b]);
				SampleDirName = File.getName(SampleDirPath);
				print(SampleDirName);
				list = getFileList(SampleDirPath);

s = 0;
//Loop on all the images in the folder
for (j=0; j<list.length; j++){

	//Select image series to process
	if(endsWith (list[j], microtubule_image_suffix)){
		print("file_path ", SampleDirPath + list[j]);

		//count samples analyzed
		s++;
		
		//Extract generic name of the image serie
		File_name = substring(list[j], 0, indexOf(list[j], microtubule_image_suffix));

		//Write to log txt file
		File.append("- Sample number: " + s + "\n" + File_name, UpDirPath + File.separator + log_file_name);

		//Open Microtubule image
		Input_MTs = File_name + microtubule_image_suffix;
	    open(SampleDirPath + File.separator + Input_MTs);

		// clean up the ROI manager and empty results tables
		roiManager("reset");
		run("Clear Results");
	
		//Open FibrilTool output ROI 
		Input_ROI_FT = File_name + FT_RoiSet_suffix;
		roiManager("Open", SampleDirPath + File.separator + Input_ROI_FT);

		//Count FibrilTool ROI number
		ft_roi_number = roiManager("count");
		print ("FT ROIs:" + ft_roi_number);

		//Open Lines ROI
		Input_ROI_lines = File_name + Line_RoiSet_suffix;
		roiManager("Open", SampleDirPath + File.separator + Input_ROI_lines);

		//Count total ROI number
		tot_roi_number = roiManager("count");
		print ("Total ROIs:" + tot_roi_number);

		//calculate line ROI number
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
		    Overlay.addSelection();

		    //Get line ROI angle (and convert to 0/180 degrees angle values)
		    roiManager("select", i + ft_roi_number);
		    LineAngle = getResult("Angle", i + ft_roi_number);
		    if (LineAngle < 0){
		    	LineAngle = LineAngle + 180;
		    }
		    print ("Line Angle:" + LineAngle);
		    Overlay.addSelection();

		    //Draw link between FT and line to check correspondance in angle calculation
		    getPixelSize(unit, pixelWidth, pixelHeight); //Get pixel size to convert from micro to pixel
		    
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
	run("Images to Stack", "name=" + outputType[t] + " title=[] use");
	run("RGB Color");
}
//Assemble in hyperstack
run("Concatenate...", "all_open open");
saveAs("tiff", SampleDirPath + File.separator + GenoDirName + "_" + SampleDirName + "_Results.tif");
selectWindow(GenoDirName + "_" + SampleDirName + "_Results.tif");
close();

			}//End of folder architecture loops and if statements
		}//End of folder architecture loops and if statements
	}//End of folder architecture loops and if statements
}//End of folder architecture loops and if statements

//End of the macro message
print("\n\n===> End of the Angle2Ablation macro");
print("Check output files in:\n" + UpDirPath);
print("- " + log_file_name + "\n- All_" + UpDirName + Angles_file_suffix + "\n- *" + Angles_file_suffix + "\n- *_Angle2Ablation.tif\n(*) For each image analyzed");
