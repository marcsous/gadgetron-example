% This is a class definition. The object is named "g" and it has the
% methods and properties defined below. All methods must have "g" as
% the first argument, but you call them without it, e.g. function
% myfunc(g,arg) would be called using myfunc(arg).

% The config() and process() functions are called from C++ (MatlabGadget.h
% and MatlabGadget.cpp). The process() function put the variable Q on the queue
% (putQ) to read data back into C++. The queue contains a header and the images
% you want on the scanner - they should be complex single type.

classdef matlab_recon < handle & BaseGadget
    
    properties
        
        raw; % kspace
        noise; % noise
        counter; % counter
        FFTScaleFactor = 3200; % ICE K_ICE_AMPL_SCALE_FACTOR=3200
        
    end
    
    methods
        
        % set up function (if any required)
        function g = config(g)
            
            fprintf('%s: started config\n',mfilename);
            
        end
        
        % process function called every TR receives header and readout
        function g = process(g, head, data)

            % extract size info
            [nx nc] = size(data); % readout pts / no. coils            
            ny = g.xml.encoding.encodingLimits.kspace_encoding_step_1.maximum+1; % phase
            nz = g.xml.encoding.encodingLimits.kspace_encoding_step_2.maximum+1; % partition
            ne = g.xml.encoding.encodingLimits.contrast.maximum+1; % no. echos
            na = g.xml.encoding.encodingLimits.average.maximum+1; % no. averages
            nr = g.xml.encoding.encodingLimits.repetition.maximum+1; % repetitions
            
            % set up arrays to store raw data
            if head.flagIsSet(head.FLAGS.ACQ_IS_NOISE_MEASUREMENT)
                fprintf('%s: noise scan received\n',mfilename);
                g.noise = data; return; % just keep one
            end
            if isempty(g.raw)
                fprintf('%s: started %s process\n',mfilename);
                g.counter = zeros(ny,nz,ne,'single'); % counter
                g.raw = zeros(nx,nc,ny,nz,ne,'single'); % kspace
            end
            
            % acquisition header details
            y = head.idx.kspace_encode_step_1+1;
            z = head.idx.kspace_encode_step_2+1;
            e = head.idx.contrast+1;
            a = head.idx.average+1;
            r = head.idx.repetition+1;
            
            % print updates to screen (debugging)
            %fprintf('%s: counter=%i y=%i z=%i e=%i a=%i r=%i flags=%u\n',mfilename,head.scan_counter,y,z,e,a,r,head.flags);

            % save raw data for reconstruction
            g.counter(y,z,e) = g.counter(y,z,e) + 1;
            g.raw(:,:,y,z,e) = g.raw(:,:,y,z,e) + data;

            % trigger reconstruction
            if head.flagIsSet(head.FLAGS.ACQ_LAST_IN_MEASUREMENT)

                fprintf('%s: raw size = [%s]\n',mfilename,num2str(size(g.raw)));
               
                % check all data were acquired
                if nnz(g.counter~=na)
                    fprintf('%s: warning not all data were acquired\n',mfilename);
                end
                
                % a basic reconstruction (full sampling)
                img = g.raw(:,:,:,:,e) * g.FFTScaleFactor / na;
                img = permute(img,[1 3 4 2]); % xyzc
                img = fft(fft2(img),[],3); % 3D fft
                img = sqrt(sum(abs(img).^2,4)); % sos
                
                % remove oversampling
                osf(1) = g.xml.encoding.encodedSpace.matrixSize.x/g.xml.encoding.reconSpace.matrixSize.x;
                osf(2) = g.xml.encoding.encodedSpace.matrixSize.y/g.xml.encoding.reconSpace.matrixSize.y;
                osf(3) = g.xml.encoding.encodedSpace.matrixSize.z/g.xml.encoding.reconSpace.matrixSize.z;
                img = circshift(img,[nx ny nz].*(1+0.5./osf));
                img = img(1:nx/osf(1),1:ny/osf(2),1:nz/osf(3));
                fprintf('%s: image size = [%s]\n',mfilename,num2str(size(img)));                         
 
                % create image header
                img_head = ismrmrd.ImageHeader;
                img_head.slice(1) = head.idx.slice;
                img_head.channels(1) = 1; % we combined coils, right?
                img_head.position(:) = head.position;
                img_head.field_of_view(1) = g.xml.encoding.reconSpace.fieldOfView_mm.x; % mm
                img_head.field_of_view(2) = g.xml.encoding.reconSpace.fieldOfView_mm.y; % mm
                slice_thickness = g.xml.encoding.reconSpace.fieldOfView_mm.z/nz; % mm
                img_head.field_of_view(3) = slice_thickness; % mm
                img_head.read_dir(:) = -head.read_dir;
                img_head.phase_dir(:) = -head.phase_dir;
                img_head.slice_dir(:) = +head.slice_dir;
                img_head.patient_table_position(:) = head.patient_table_position;
                img_head.acquisition_time_stamp(1) = head.acquisition_time_stamp;
                img_head.matrix_size(1) = size(img,1);
                img_head.matrix_size(2) = size(img,2);
                img_head.matrix_size(3) = 1; % 2D image
                img_head.set(1) = 0;
                img_head.contrast(1) = e-1;
                
                % image scaling is a mess...
                if g.FFTScaleFactor==3200
					maximum_pixel_value = max(abs(img(:)));
					if (maximum_pixel_value>0 && maximum_pixel_value < 10) || (maximum_pixel_value > 4095)
						fprintf('%s: maximum pixel (%.1e) in a bad range\n',mfilename,maximum_pixel_value)
						g.FFTScaleFactor = g.FFTScaleFactor * 1000 / maximum_pixel_value;
						fprintf('%s: changing FFTScaleFactor to %.1e\n',mfilename,g.FFTScaleFactor)            
                        img = img * 1000 / maximum_pixel_value; % max pixel value is 1000
					 end
                end
                fprintf('%s: maximum pixel value = %.1f\n',mfilename,max(abs(img(:))));
                
                % send images slice by slice
                for z = 1:size(img,3)
                    
                    % set header properties
                    img_head.image_index(1) = z + (e-1)*nz;
                    img_head.position(:) = head.position + img_head.slice_dir * slice_thickness * (z-nz/2-1/2);
                    
                    % put on the queue (Q)
                    img_head.image_type(1) = img_head.IMAGE_TYPE.MAGNITUDE;
                    img_head.image_series_index(1) = 0;
                    g.putQ(img_head,img(:,:,z));
                    
                end % z loop
                
            end % ACQ_LAST_IN_MEASUREMENT
            
        end % process
        
    end % methods
    
end % class
