% Set the path of 64 bit NetSim Binaries to be used for simulation.
NETSIM_PATH = "C:\Users\User\Documents\NetSim\Workspaces\Default_V14\bin_x64";

LICENSE_ARG = "5053@192.168.0.9"; %Floating license
%LICENSE_ARG = """C:\Program Files\NetSim\Standard_v13_2\bin"""; %Node Locked license

% Set NETSIM_AUTO environment variable to avoid keyboard interrupt at the end of each simulation
setenv('NETSIM_AUTO','1');

% Create IOPath directory to store the input Configuration.netsim file and
% the simulation output files during each iteration
if(~isfolder('IOPath'))
    mkdir IOPath
end

% Create Data directory to store the Configuration.netsim and the
% Metrics.xml files associated with each iteration
if(~isfolder('Data'))
    mkdir Data
end

% Clear the IOPath folder if it has any files created during previous
delete('IOPath\*')

% Delete result.csv file if it already exists
if(isfile('result.csv'))
    delete result.csv
end

% create a csv file to log the output metrics for analysis csvfile
fileid=fopen('result.csv','w');

% Add headings to the CSV file
fprintf(fileid,'X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12,X13,X14,X15,X16,X17,X18,X19,X20,Range,Packets Received');
fclose(fileid);

rng('default')
ran_arr = 1000*rand(100,20);
ran_arr = sort(ran_arr,2);

% create a folder with name as year-month-day-hour.minute.seconds inside the data folder
today = datestr(now,'dd-mm-yyyy-HH.MM.SS');
mkdir('Data',today)

% Iterate based on the number of time simulation needs to be run and the
for j = 50:50:1000

    for i = 1:100
    
        if(isfile('Configuration.netsim'))
            delete Configuration.netsim
        end
        
        if(isfile("IOPath\\Configuration.netsim"))
            delete('IOPath\Configuration.netsim')
        end
        
        if(isfile('IOPath\Metrics.xml'))
            delete('IOPath\Metrics.xml')
        end
        
        %Call ConfigWriter.exe with arguments as per the number of variable parameters in the input.xml file
        cmd="ConfigWriter.exe " + string(ran_arr(i,1)) + " "  + string(ran_arr(i,2)) + " " + string(ran_arr(i,3)) + " "  + string(ran_arr(i,4))+ " "+ string(ran_arr(i,5)) + " " + string(ran_arr(i,6)) + " "  + string(ran_arr(i,7)) + " " + string(ran_arr(i,8)) + " "  + string(ran_arr(i,9)) +" "+ string(ran_arr(i,10)) + " " + string(ran_arr(i,11)) + " "  + string(ran_arr(i,12)) + " " + string(ran_arr(i,13)) + " "  + string(ran_arr(i,14))+ " "+ string(ran_arr(i,15)) + " " + string(ran_arr(i,16)) + " "  + string(ran_arr(i,17)) + " " + string(ran_arr(i,18)) + " "  + string(ran_arr(i,19)) + " " + string(ran_arr(i,20)) + " " +  string(j);    
        disp(cmd)
        system(cmd);
        
        %Copy the Configuration.netsim file generated by ConfigWriter.exe to IOPath directory
        if(isfile('Configuration.netsim'))
            copyfile('Configuration.netsim','IOPath');
            copyfile('ConfigSupport\*', 'IOPath\ConfigSupport');
        end
        
        strIOPATH=pwd+"\IOPath";
        
        %Run NetSim via CLI mode by passing the apppath iopath and license information to the NetSimCore.exe
        cmd="start ""NetSim_Multi_Parameter_Sweeper"" /wait /d "...
        +""""... 
        +NETSIM_PATH...
        + """ "... 
        + "NetSimcore.exe -apppath """...
        +NETSIM_PATH...
        + """ -iopath """... 
        +strIOPATH... 
        +""" -license "...
        +LICENSE_ARG;
            
        %disp(cmd)
        system(cmd);
        
        %Create a copy of the output Metrics.xml file for writing the result log
        if(isfile('IOPath\Metrics.xml'))
            copyfile('IOPath\Metrics.xml','Metrics.xml');
            system("MetricsCsv.exe IOPath");
        end    
      
        %If only one output parameter is to be read only one Script text file with name Script.txt to be provided
        %If more than one output parameter is to be read, multiple Script text file with name Script1.txt, Script2.txt,...
        %...,Scriptn.txt to be provided
        
        OUTPUT_PARAM_COUNT=1;
        
        %changes reqiured starts
        if(isfile('IOPath\Metrics.xml'))
            
            fileid=fopen('result.csv','a');
            if(fileid)
                fprintf(fileid,'\n%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,',ran_arr(i,1),ran_arr(i,2),ran_arr(i,3),ran_arr(i,4),ran_arr(i,5),ran_arr(i,6),ran_arr(i,7),ran_arr(i,8),ran_arr(i,9),ran_arr(i,10),ran_arr(i,11),ran_arr(i,12),ran_arr(i,13),ran_arr(i,14),ran_arr(i,15),ran_arr(i,16),ran_arr(i,17),ran_arr(i,18),ran_arr(i,19),ran_arr(i,20),j);
                fclose(fileid);
            end
            if(OUTPUT_PARAM_COUNT==1)
                system("MetricsReader.exe result.csv");
            else
                for n = 1 : OUTPUT_PARAM_COUNT
                    filename='Script'+string(n)+'.txt';
                    movefile(filename,'Script.txt');
                    system("MetricsReader.exe result.csv");
                    fileid=fopen('result.csv','a');
                    if(fileid)
                        fprintf(fileID,',');
                        fclose(fileid);
                    end
                    movefile('Script.txt',filename);             
                end
            end
        else
            %Update the output Metric as crash if Metrics.xml file is missing
            fileid=fopen('result.csv','a');
            if(fileid)
                fprintf(fileid,'\n%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,crash',ran_arr(i,1),ran_arr(i,2),ran_arr(i,3),ran_arr(i,4),ran_arr(i,5),ran_arr(i,6),ran_arr(i,7),ran_arr(i,8),ran_arr(i,9),ran_arr(i,10),ran_arr(i,11),ran_arr(i,12),ran_arr(i,13),ran_arr(i,14),ran_arr(i,15),ran_arr(i,16),ran_arr(i,17),ran_arr(i,18),ran_arr(i,19),ran_arr(i,20),j);
                fclose(fileid);
            end
        end
    
        % Name of the Output folder to which the result will be saved
        OUTPUT_PATH = "Data\"+today+"\Range_"+string(j)+"\Output_"+string(i);
        
        if(~isfolder(OUTPUT_PATH))
            mkdir(OUTPUT_PATH)
        end
        
        % Create a copy of result.csv file present in sweep folder to date-time
        if(isfile('result.csv'))
            copyfile('result.csv', "Data\"+today)
        end
        
        % Create a copy of all files that is present in IOPATH to the desired output location
        movefile('IOPath\*',OUTPUT_PATH)
        
        % Delete Configuration.netsim file created during the last iteration
        if(isfile("Configuration.netsim"))
            delete('Configuration.netsim')
        end
        
        if(isfile('Metrics.xml'))
            delete('Metrics.xml')
        end
    end
end


