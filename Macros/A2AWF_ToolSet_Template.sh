#!/bin/bash
# Generates The toolSet macro file from the individaal macros of the Angle2Ablation Timelapse workflow
# To run, open a terminal where this file and where the individual macro files are located and run the line: $ bash A2AWF_ToolSet_Template.sh > Angle2ablation_Workflow_ToolSet.ijm

echo 'var ImageOne;'

echo 'macro "SurfCut2 Action Tool - C000 T0508S T4508u T9508r Tb508f T0h08C T6h08u Tbh08t Teh082" {'
cat SurfCut2.ijm
echo '};'

echo ' '

echo 'macro "FolderMaker Action Tool - C000 T0508F T4508o T9508l Tb508d Tg508r T0h08M T4h08a T9h08k Teh08e Tjh08r" {'
cat FolderMaker.ijm
echo '};'

echo ' '

echo 'macro "TmlpsCellContour_Preprocessing Action Tool - C000 T0308C T6308e Tc308l Tf308l T0b08P T5b08r Tab08e T0h08p T6h08r Tah08o Tfh08c" {'
cat TmlpsCellContour_Preprocessing.ijm
echo '};'

echo ' '

echo 'macro "SimuAblationCell_RoiMaker_timelapse Action Tool - C000 T0508R T6508O Td508I T0h08M T4h08a T9h08k Teh08e Tjh08r" {'
cat SimuAblation-Cell_RoiMaker_timelapse.ijm
echo '};'

echo ' '

echo 'macro "FibrilTool_Batch_Workflow Action Tool - C000 T0508F T4508i T7508b Tb508r Tf508i Tj508l T0h08T T4h08o T9h08o Teh08l" {'
cat FibrilTool_Batch_Workflow.ijm
echo '};'

echo ' '

echo 'macro "Angle2Ablation_timelapse Action Tool - C000 T0c10A T6c102 Tcc10A" {'
cat Angle2Ablation_timelapse.ijm
echo '};'

echo ' '

echo 'macro "StatsLink Action Tool - C000 T0b09S T5b09t T9b09a Teb09t Tib09s" {'
cat A2A_StatsLink.ijm
echo '};'



