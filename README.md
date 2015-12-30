Rivulet logo
============
The reason why we choose red R is that red represents a pioneer spirit. The red is also the color of blood and sun. The blood and sun is like force awaken.  

![Build Status](https://github.com/lsqshr/Rivulet-Neuron-Tracing-Toolbox/blob/master/Rivulet_resources/icon_48.png)
=============================
Rivulet-Neuron-Tracing-Toobox
=============================

**Red Sphere** : represents the startig point of each rivulet back tracing. 
As you may already notice, most of rivulet tracing starts from the axon terminal or the dendrites termini of
neuron.

**Blue Line** : represents the traced path of neuron.

**Red Line** : represents the swc structure ignoring the radius. We ignored radius deliberately to reveal the all potential
miswiring connections.

**Soma check box under Tracing Parameters Panel** : Untick it if you do not have soma in this image. If you have soma in this image, you should do soma detection first. Although you can choose to do neuron reconstruction directly without soma detection, it is not recommended.

**Plot check box under Tracing Parameters Panel** : Basically, click it means you want to visualise the tracing process. You just want to get swc as soon as possible, you should consider untick it.

**Washaway check box** : You've got to crack a few eggs to make an omelette. There is no free lunch in comuter vision area. This button increases the tracing process dramatically, but you have suffer some loss of detailed dendrites reconstructions.

**Trace button** : Press it, Rivulet start to trace. It is that simple. Believe it or not?

**Threshold slider bar** : Drag it horizontally to achieve the segmentation result. Do not forget to press update button. 

**Friendly reminder** : If you need help about specfic button, put your mouse on the name of button. And hang on a  few seconds and magic will show.
Background
==========
To acquire profound knowledge of the neuron structure is vital for efficient and accurate diagnosis and treatment of both neurological and psychiatric disorders. Due to the increasingly relying on bioimage assistance in medical practice, 3D neuron reconstruction will provide reliable and accurate data for neuron morphology study. There are few powerful automatic algorithms to trace a complete neuron. The most current algorithms are semi-automatic, so it is significant to propose an automatic neuron reconstruction method. The reconstruction result is barely satisfactory due to the appearance of irrelevant structure, background gradients, and inhomogeneous contrast of neuron image stacks. The fuzzy and discontinuous neuron structure is another challenge. Most of the current algorithms can only achieve satisfactory reconstruction results of single neuron. When the neuron structure is complex and complicated, most current algorithms fail. For example, any close neuron structures will lead to biased reconstruction results. The new automatic and robust neuron reconstruction method is required. We propose a fast, robust and automatic algorithm, which can generate reasonable satisfactory 3D reconstructions of complex and complicated neuron structure in a short time.  

Brief theoretical description
=============================

Examples
========
The gif below show the animation of tracing process. 
  
![Build Status](https://github.com/lsqshr/Rivulet-Neuron-Tracing-Toolbox/blob/master/traceplot.gif)

The gif below show the animation of soma detection process. 
  
![Build Status](https://github.com/lsqshr/Rivulet-Neuron-Tracing-Toolbox/blob/master/somadetection.gif)
Implementation
==============

References
==========
Rivulet paper will be avaiable soon. It can be downloaded at xxxxx.(Not available yet)
The follwoing links are the libraries we are using now or used before. 

[Snake Link](https://github.com/pmneila/morphsnakes)

[Accurate fast marching](http://au.mathworks.com/matlabcentral/fileexchange/24531-accurate-fast-marching)

[Tree Toolbox](http://www.treestoolbox.org/)

[Vesselness filter](http://au.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter)

[Level set](http://uk.mathworks.com/matlabcentral/fileexchange/24998-2d-3d-image-segmentation-toolbox)

[Otsu Link](http://www.mathworks.com/matlabcentral/fileexchange/26532-image-segmentation-using-otsu-thresholding/content/otsu.m)

[Loops link](http://au.mathworks.com/matlabcentral/fileexchange/10722-count-loops-in-a-graph/)

[dir2](http://au.mathworks.com/matlabcentral/fileexchange/40016-recursive-directory-searching-for-multiple-file-specs/content/dir2.m)

[fm_tool_1.7](http://au.mathworks.com/matlabcentral/fileexchange/30853-field-mapping-toolbox)


