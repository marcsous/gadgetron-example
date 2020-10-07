# gadgetron-example

An example of how to use gadgetron to execute your own ```matlab_recon.m``` reconstruction.

1. Start by installing this [old version](https://github.com/marcsous/gadgetron) of gadgetron

2. Open a shell and launch ```gadgetron```

3. Open another shell and ```cd ~/gadgetron3.17/example```

4. Convert the .dat file into .h5 format. This is a mysterious process involving HDF5 and parameter maps

```siemens_to_ismrmrd -f meas_flash3d.dat -o testdata.h5 -z 2 --user-map ./IsmrmrdParameterMap_Siemens.xml --user-stylesheet ./IsmrmrdParameterMap_Siemens.xsl```

5. Send ```testdata.h5``` to gadgetron using the ```matlab_recon.xml``` pipeline which points to the ```matlab_recon.m``` script.

```gadgetron_ismrmrd_client -p 9001 -f testdata.h5 -C ./matlab_recon.xml```

6. Hopefully now the ```gadgetron``` server will spring to life
```
03-11 17:39:58.315 INFO [main.cpp:101] Starting Gadgetron (version 3.17.0)
03-11 17:39:58.315 INFO [main.cpp:193] Starting ReST interface on port 9080
03-11 17:39:58.325 INFO [main.cpp:205] Starting cloudBus: localhost:8002
03-11 17:39:58.326 INFO [main.cpp:253] Configuring services, Running on port 9002
03-11 17:40:02.858 INFO [GadgetStreamController.cpp:48] Connection from 127.0.0.1:48474
03-11 17:40:02.858 INFO [GadgetStreamController.cpp:226] Found 1 readers
03-11 17:40:02.858 INFO [GadgetStreamController.cpp:227] Found 1 writers
03-11 17:40:02.858 INFO [GadgetStreamController.cpp:228] Found 4 gadgets
03-11 17:40:02.858 INFO [GadgetStreamController.cpp:244] --Found reader declaration
03-11 17:40:02.858 INFO [GadgetStreamController.cpp:245]   Reader dll: gadgetron_mricore
03-11 17:40:02.858 INFO [GadgetStreamController.cpp:246]   Reader class: GadgetIsmrmrdAcquisitionMessageReader
03-11 17:40:02.858 INFO [GadgetStreamController.cpp:247]   Reader slot: 1008
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:277] --Found writer declaration
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:278]   Writer dll: gadgetron_mricore
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:279]   Writer class: MRIImageWriter
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:280]   Writer slot: 1022
03-11 17:40:02.865 DEBUG [GadgetStreamController.cpp:296] Processing 4 gadgets in reverse order
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:310] --Found gadget declaration
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:311]   Gadget Name: ImageFinish
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:312]   Gadget dll: gadgetron_mricore
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:313]   Gadget class: ImageFinishGadget
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:328]   Gadget parameters: 0
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:310] --Found gadget declaration
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:311]   Gadget Name: FloatToShort
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:312]   Gadget dll: gadgetron_mricore
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:313]   Gadget class: FloatToUShortGadget
03-11 17:40:02.865 INFO [GadgetStreamController.cpp:328]   Gadget parameters: 0
03-11 17:40:02.866 INFO [GadgetStreamController.cpp:310] --Found gadget declaration
03-11 17:40:02.866 INFO [GadgetStreamController.cpp:311]   Gadget Name: Extract
03-11 17:40:02.866 INFO [GadgetStreamController.cpp:312]   Gadget dll: gadgetron_mricore
03-11 17:40:02.866 INFO [GadgetStreamController.cpp:313]   Gadget class: ComplexToFloatGadget
03-11 17:40:02.866 INFO [GadgetStreamController.cpp:328]   Gadget parameters: 0
03-11 17:40:02.866 INFO [GadgetStreamController.cpp:310] --Found gadget declaration
03-11 17:40:02.866 INFO [GadgetStreamController.cpp:311]   Gadget Name: MatlabAcquisition
03-11 17:40:02.866 INFO [GadgetStreamController.cpp:312]   Gadget dll: gadgetron_matlab
03-11 17:40:02.866 INFO [GadgetStreamController.cpp:313]   Gadget class: AcquisitionMatlabGadget
03-11 17:40:02.912 DEBUG [MatlabGadget.h:44] Starting MATLAB engine
03-11 17:40:06.353 DEBUG [MatlabGadget.h:60] Initialized matlab_text_buffer (size 1000000 chars).
03-11 17:40:06.485 DEBUG [MatlabGadget.h:78] 03-11 17:40:06.485 INFO [GadgetStreamController.cpp:328]   Gadget parameters: 4
03-11 17:40:06.485 INFO [GadgetStreamController.cpp:335] Setting parameter matlab_path = ~/example
03-11 17:40:06.485 INFO [GadgetStreamController.cpp:335] Setting parameter matlab_classname = matlab_recon
03-11 17:40:06.485 INFO [GadgetStreamController.cpp:335] Setting parameter matlab_port = 3001
03-11 17:40:06.485 INFO [GadgetStreamController.cpp:335] Setting parameter matlab_buffer_time_ms = 100
03-11 17:40:06.485 INFO [GadgetStreamController.cpp:356] Gadget Stream configured
03-11 17:40:06.486 DEBUG [MatlabGadget.h:122] MATLAB Class Name : matlab_recon
03-11 17:40:06.486 DEBUG [MatlabGadget.h:123] MATLAB buffer_time_ms = 100
03-11 17:40:06.731 DEBUG [MatlabGadget.h:175] MATLAB output >>
matlab_recon: started config
03-11 17:40:06.731 DEBUG [MatlabGadget.h:217] Matlab buffer initialized (1000 elements)
03-11 17:40:06.733 DEBUG [MatlabGadget.h:309] Flush: time (501.0 ms), count (1), total (1)
03-11 17:40:06.799 DEBUG [MatlabGadget.h:175] MATLAB output >>
matlab_recon: noise scan received
03-11 17:40:06.814 DEBUG [MatlabGadget.h:309] Flush: time (12.4 ms), count (1000), total (1001)
03-11 17:40:07.050 DEBUG [MatlabGadget.h:309] Flush: time (16.7 ms), count (1000), total (2001)
03-11 17:40:07.247 DEBUG [Gadget.h:174] Gadget (MatlabAcquisition) Close Called with flags = 1
03-11 17:40:07.247 DEBUG [Gadget.h:184] Gadget (MatlabAcquisition) waiting for thread to finish
03-11 17:40:07.248 DEBUG [MatlabGadget.h:309] Flush: time (5.2 ms), count (48), total (2049)
03-11 17:40:07.387 DEBUG [MatlabGadget.h:175] MATLAB output >>
matlab_recon: raw size = [128    1   64   32]
matlab_recon: image size = [64  64  32]
matlab_recon: maximum pixel value = 1272.4
03-11 17:40:07.389 DEBUG [MatlabGadget.cpp:230] Received 32 images from matgadget Queue
03-11 17:40:07.389 DEBUG [Gadget.h:174] Gadget (MatlabAcquisition) Close Called with flags = 0
03-11 17:40:07.389 DEBUG [Gadget.h:186] Gadget (MatlabAcquisition) thread finished
03-11 17:40:07.389 DEBUG [MatlabGadget.h:87] Closing down Matlab
03-11 17:40:10.642 DEBUG [Gadget.h:123] Shutting down Gadget (MatlabAcquisition)
```

7. There should be a new file ```out.h5``` in the current directory

8. Read it into Matlab - again using the mysterious HDF5 - and take a look.
```
>> info = h5info('~/gadgetron3.17/example/out.h5');
>> im = h5read('~/gadgetron3.17/example/out.h5',strcat(info.Groups.Groups(1).Name,'/data'));
>> imagesc(im(:,:,17))
```
9. If this works then it's time to do it on the scanner - [email me](mailto:markbydder@gmail.com).
