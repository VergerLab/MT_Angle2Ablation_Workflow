# How to install and run the different components of the workflow

In the simplest version of the installation you only need to have Fiji, the few macros listed below and the plug-in MorpholibJ.

Then, data analysis can be performed with any appropriate software, but here we propose a user-friendly python __Jupyter notebook__ with predefined graph output and statistical analysis to ease a robust analysis of the results.
This notebook can be run locally on your computer after installing the required software and python libraries, __or with no install using binder directly from your web browser__. 

The detailed explanation for the installation of these components is presented below.

## - Fiji: 
Most of the workflow is designed to run on Fiji. If you don’t already have it, download it and install it following the procedure describe at https://fiji.sc/.

## - Macros: 
You will need (available for download at): 
- SurfCut2.ijm (https://github.com/VergerLab/SurfCut2) 
- Cell_ROIMaker.ijm (https://github.com/VergerLab/MT_Angle2Ablation_Workflow)
- FibrilTool_Batch_Workflow.ijm (https://github.com/VergerLab/FibrilTool_Batch_Workflow)
- Line_ROIMaker.ijm (https://github.com/VergerLab/MT_Angle2Ablation_Workflow)
- Angle2Ablation.ijm (https://github.com/VergerLab/MT_Angle2Ablation_Workflow)

Each of these macro can be directly downloaded in the folder of your choice.

  To run the macro: 
  1. Drag and drop the macro file into Fiji to open it.
  2. Click run in the editor window to run it.
  
Then follow the userguide understand how to operate the workflow.

## - Plugins: 
The macro “Cell_ROIMaker.ijm” uses the plug-in MorpholibJ (Legland et al., 2016; https://imagej.net/MorphoLibJ).

  To install it: 
  1. Go in the “Help” menu of Fiji and click on “Update…”. This will open the “ImageJ updater”. 
  2. In “ImageJ updater”, click on “Manage update sites”.
  3. In the list, find “IJPB-Plugins” and click in the square next to it to add it. 
  4. Then close the window and apply changes on “ImageJ updater”. 
  5. Once this is done, Fiji needs to be restarted. 

## - Jupyter notebook: 

The following video provides a very useful introduction to the use of Python an jupyter notebooks for bioimage analysis. In particular for running a notebook on Binder (38:10 --> 41:47) for the No-install approach. as well as how to insatll miniconda (49:34 --> 51:16).

https://www.youtube.com/watch?v=2KF8vBrp3Zw

We also recommand the very useful lecture series on BioImage Analysis from Robert Haase (https://www.youtube.com/playlist?list=PL5ESQNfM5lc7SAMstEu082ivW4BDMvd0U), in particular the lecture 9 to 11 about the use of python for data analysis and hypothesis testing. In addition some help can be found for the local install of miniconda in lecture 9b (https://youtu.be/MOEPe9TGBK0?t=1807)

### No-install Jupyter notebook online through Binder:
A temporary version of the Jupyter notebook can be used on your web browser using binder.

1. __To start it__ click here [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/VergerLab/MT_Angle2Ablation_Workflow/master)

It can take a few minutes to start it. Ultimately you will see the "home page" with all the content of the Github repository.

2. You can first __test the Notebook with the pre-loaded data__. To do this, click on “Stats_Angle2Ablation.ipynb”. This will start a new tab on your browser with the Jupyter notebook named “Statistics for Angle to ablation Analysis”. Then, follow the instructions in the notebook itself.

3. To perform your own analysis, __upload your own data__. 
 	- On the "home page", click "New" and "Folder" in the top right corner.
 	- Tick the box next to the newly created "Untitled Folder".
 	- Click on "rename" above, and rename the folder "MyData" (or anything else of your choice).
 	- Enter the "MyData" folder and at the top right corner click "Upload".
 	- From the output of the Angle2Ablation.ijm macro, you only need to upload the file called All_….txt. Each genotype and timepoint analyzed generate one such file. Each of these file has to be put in a separate folder under the "MyData" directory. As an exemple you can look at the content of the "TestData" directory containing the pre-loaded test data.

4. You can then __perform your own analysis__ using the notebook, in the same manner as with the pre-loaded data. Don't forget to define the correct path to your own data in the notebook. Also don't forget to download the generate dtat at the end of the analysis, as the session will be erased when you are done.

For additional help on how to perform these step, the video mentioned above shows how to start the notebook (https://youtu.be/2KF8vBrp3Zw?t=2289), run it (https://youtu.be/2KF8vBrp3Zw?t=2365), as well as how to upload you own data (https://youtu.be/2KF8vBrp3Zw?t=2427).

### Local installation:
For additional help on how to perform the steps below, one of the video mentioned above shows how to install miniconda for windows (https://youtu.be/MOEPe9TGBK0?t=1807) and how to start it and activate an environment (https://youtu.be/MOEPe9TGBK0?t=2051). The instructions are not exactly the same as the ones described below but they can help you better understand how to perform them.

1. __Download the miniconda installer__ from the official website repo.continuum.io\
	LINUX: https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh \
	MAC: https://repo.continuum.io/miniconda/Miniconda2-latest-MacOSX-x86_64.sh \
	Windows: https://repo.continuum.io/miniconda/Miniconda2-latest-Windows-x86_64.exe

	You can also use wget to perform this download from a terminal (LINUX or MAC):
	
       wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh

2. __Install miniconda__ by running the installer:
   
   LINUX: Open a new terminal window, go to the directory where you downloaded the installer and run:
   > Note: To navigate to a specific directory, you can do it in the terminal with the "cd" (Change directory) command. 
   Alternatively, on linux you can simply navigate with your regular graphical interface file manager (e.g. Nautilus). 
   Then, right-click in the folder of interest and select "Open in terminal".
   You can then directly paste the commands below into the terminal and press enter.
  
       bash Miniconda2-latest-Linux-x86_64.sh
       rm Miniconda2-latest-Linux-x86_64.sh
      
	MAC: Open a new terminal window, go to the directory where you downloaded the installer and run:
 
       bash Miniconda2-latest-MacOSX-x86_64.sh
       rm Miniconda2-latest-MacOSX-x86_64.sh
	
   Windows: Execute the ".exe" installer and follow the instructions.
	
   During the installation you will be asked a number of choices. You can set up the directory of your choice when asked, e.g. ~/.miniconda. Make sure to answer YES when asked to add conda to your PATH.

3. You should now have miniconda properly installed; __test your installation__ by running "conda" in a terminal to make sure the command is found. 
To do this, on LINUX and MAC, you can directly copy and paste the commands below into the terminal and press enter. On Windows, look for "Miniconda prompt" in the search bar (next to the windows icon, bottom left of the desktop screen). Open the "Miniconda prompt" and directly continue to step 4.

	   conda


4. __Download and extract the "MT_Angle2Ablation" repository__ to the location of your choice.
   To do this, click on the green "code" icon on the top right side of the repository page (https://github.com/VergerLab/MT_Angle2Ablation_Workflow/). Then "Download ZIP". 
   Finally extract the content of the zip to the location of your choice. 

5. __Create and activate a conda environment__. To do this, first, in your terminal (LINUX and MAC) or Miniconda Prompt (Windows), navigate to the "/MT_Angle2Ablation" folder that you have downloaded and extracted in the previous step.
  > Note: To navigate to a specific directory, you can do it in the terminal (LINUX and MAC) or Miniconda Prompt (Windows) with the "cd" (Change directory) command. On Windows if you need to navigate to a different drive (e.g. D:\ instead of C:\), first write the name of the drive before the cd commande (i.e. "D: cd \\...).
   Alternatively, on linux you can simply navigate with your regular graphical interface file manager (e.g. Nautilus). 
   Then, right-click in the folder of interest and select "Open in terminal".
   You can then directly paste the commands below into the terminal and press enter.
   

6. __Define a new conda environment__. To do this you can directly copy and paste the commands below into the terminal or Miniconda Prompt and press enter.

       conda env create -f environment.yml
   
 This should take a few seconds.

7. __Activate the environment__.

       conda activate Stats_Angle2Abaltion

8. __Start Jupyter__.

		jupyter lab

A page called "JupyterLab" should open automatically on your web browser.

9. __Open the Python notebook__. To do that, in the menu on the left, double click on "Stats_Angle2Abaltion.ipynb".

10. Finally, __to run the notebook__, follow the instructions in the notebook itself.

When you are done with the analysis, you can close the web page and the terminal or Miniconda prompt that was used to launch Jupyter lab.

Later on, to restart an analysis, you only need to follow steps 7 to 10.
  
  > Conda tips:
  >
  > Get out of the current conda environment : 
  
	conda deactivate
  
  > View the available environments : 

	conda env list
