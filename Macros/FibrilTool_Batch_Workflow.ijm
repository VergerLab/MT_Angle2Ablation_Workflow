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
