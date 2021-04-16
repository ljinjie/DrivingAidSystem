%clear all;
inputSize = [224 224 3];

pretrained = load('ourdetector.mat');
vehicleDetector = pretrained.vehicleDetector;

vidObj = VideoReader('1.mp4');
outObj = VideoWriter('output2');
open(outObj);

counter1 = 0;
pending1 = 0;
counter2 = 0;
pending2 = 0;
counter3 = 0;
pending3 = 0;


color1='green';
color2='green';
color3='green';

area = [];
prediction = [];
car_vel = [];
car_accel = [];

while hasFrame(vidObj)
    I = readFrame(vidObj);
    I = imresize(I,inputSize(1:2));
    [bboxes,scores] = detect(vehicleDetector,I);
    if size(bboxes) ~= 0
        delete_index = [];
        
        for i = 1:size(bboxes, 1)
            for j = 1:size(bboxes, 1)
                if i ~= j
                    if bboxes(i, 1) <= bboxes(j, 1) && (bboxes(i, 1) + bboxes(i, 3) >= bboxes(j, 1) + bboxes(j, 3))
                        delete_index = [delete_index j];
                    end
                end
            end
        end
        
        bboxes(delete_index, :) = [];
        scores(delete_index, :) = [];

        I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
    end
    
    
    
    if counter1 == 50
        color1='green';
        pending1 = 0;
        counter1 = 0;
    end
    if counter2 == 50
        color2='green';
        pending2 = 0;
        counter2 = 0;
    end
    if counter3 == 50
        color3='green';
        pending3 = 0;
        counter3 = 0;
    end
    s = size(bboxes);
    n = s(1,1);

    if pending1 == 0
        for i=1:n
            if bboxes(i,1)+bboxes(i,3) < inputSize(1,1)/2
                color1 = 'red';
                pending1 = 1;
            end
        end
    end
    
    if pending2 == 0
        for i=1:n
            if bboxes(i,1) > inputSize(1,1)/2
                color2 = 'red';
                pending2 = 1;
            end
        end 
    end
    
    if pending1 == 1
        counter1 = counter1 + 1;
    end
    if pending2 == 1
        counter2 = counter2 + 1;
    end
    
    for i = 1:size(bboxes, 1)
        if pending3 ~= 2
            if bboxes(i,1) < inputSize(1,1)/2 && bboxes(i,1) + bboxes(i,3) > inputSize(1,1)/2
                color3 = 'yellow';
                pending3 = 1;
                area = [area (bboxes(i,3) * bboxes(i,4))];
            end
        end   
    end
    if pending3 == 1 || pending3 == 2
        counter3 = counter3 + 1;
    end
    
    smoothed_area = smooth(area);
    for i = 1:10
        smoothed_area = smooth(smoothed_area, 'sgolay', 2); 
    end

    car_vel = difFilter(sqrt(smoothed_area.'),car_vel);
    car_accel = difFilter(car_vel,car_accel);
    
    %for i = 1:3
        %car_vel = smooth(car_vel);
    %    car_accel = smooth(car_accel);
    %end
    
    for i = 1:2
        car_accel = smooth(car_accel); 
    end
    car_accel(car_accel == 0) = [];
    
    if (size(car_accel, 1) > 120)
        if car_accel(size(car_accel, 1), 1) >= 0.1
            color3 = 'red';
            pending3 = 2;
        end
    end
    
    %I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
    position=[inputSize(1,1)/4 inputSize(1,2)/4 10; inputSize(1,1)/2 inputSize(1,2)/4 10; 3*inputSize(1,1)/4 inputSize(1,2)/4 10];
    label={'right', 'rear', 'left'};

    I = insertObjectAnnotation(I,'circle',position,label,'LineWidth',19,'Color',{color1,color3,color2},'TextColor','black');
    writeVideo(outObj, I);
end






close(outObj);