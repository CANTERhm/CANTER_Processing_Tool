function outStruct = ImputeBMvsDetritus(DataMatrix,BM_Mask)
    %%  UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    
    % Check arguments
    arguments
        DataMatrix (:,:) double {mustBeNumeric}
        BM_Mask (:,:) logical
    end
    
    %% Pre-define output struct
    outStruct = struct("NoNaNData",zeros(size(DataMatrix)),...
                       "TubularNeighborhoods",struct("BM_and_TN1_Mask",false(size(BM_Mask)),...
                                                     "BM_and_TN2_Mask",false(size(BM_Mask)),...
                                                     "BM_and_TN3_Mask",false(size(BM_Mask))),...
                       "DetritusDataOnly",struct("No_BM_Data",zeros(size(DataMatrix)),...
                                                 "No_BM_and_TN1_Data",zeros(size(DataMatrix)),...
                                                 "No_BM_and_TN2_Data",zeros(size(DataMatrix)),...
                                                 "No_BM_and_TN3_Data",zeros(size(DataMatrix))),...
                       "ImputedFromBoundaries",struct("Imputed_BM",struct("Step1",zeros(size(DataMatrix)),...
                                                                          "Step2",zeros(size(DataMatrix)),...
                                                                          "Step3",zeros(size(DataMatrix)),...
                                                                          "Mean",zeros(size(DataMatrix))),...
                                                      "Imputed_BM_plus_TN1",struct("Step1",zeros(size(DataMatrix)),...
                                                                                   "Step2",zeros(size(DataMatrix)),...
                                                                                   "Step3",zeros(size(DataMatrix)),...
                                                                                   "Mean",zeros(size(DataMatrix))),...
                                                      "Imputed_BM_plus_TN2",struct("Step1",zeros(size(DataMatrix)),...
                                                                                   "Step2",zeros(size(DataMatrix)),...
                                                                                   "Step3",zeros(size(DataMatrix)),...
                                                                                   "Mean",zeros(size(DataMatrix))),...
                                                      "Imputed_BM_plus_TN3",struct("Step1",zeros(size(DataMatrix)),...
                                                                                   "Step2",zeros(size(DataMatrix)),...
                                                                                   "Step3",zeros(size(DataMatrix)),...
                                                                                   "Mean",zeros(size(DataMatrix)))),...
                       "Means",table('Size',[5,5],'VariableTypes',["string","double","double","double","double"],'VariableNames',["Mean_Data","BM_Mean","BM_Std","Detritus_Mean","Detritus_Std"]),...
                       "Medians",table('Size',[5,5],'VariableTypes',["string","double","double","double","double"],'VariableNames',["Median_Data","BM_Median","BM_Std","Detritus_Median","Detritus_Std"]));

    outStruct.Means.Mean_Data = ["Original";"BM Imputed";"BM+TN1 Imputed";"BM+TN2 Imputed";"BM+TN3 Imputed"];
    outStruct.Medians.Median_Data = ["Original";"BM Imputed";"BM+TN1 Imputed";"BM+TN2 Imputed";"BM+TN3 Imputed"];

    
    %% Interpolate NaN values in DataMatrix
    DataInterpolation = DataMatrix;
    while any(isnan(DataInterpolation),"all")
        DataInterpolation = ImputeMat(DataInterpolation,1);
    end
    outStruct.NoNaNData = DataInterpolation;

    %% Create Tubular Neighborhood (TN1, TN2 and TN3) Mask for BM
    outStruct.TubularNeighborhoods.BM_and_TN1_Mask = DetTubularNBDMat(BM_Mask,1);
    outStruct.TubularNeighborhoods.BM_and_TN2_Mask = DetTubularNBDMat(BM_Mask,2);
    outStruct.TubularNeighborhoods.BM_and_TN3_Mask = DetTubularNBDMat(BM_Mask,3);

    %% Set BM positions in the interpolated data to NaN to only keep the Detritus data
    
    % (I) Original BM Mask
    outStruct.DetritusDataOnly.No_BM_Data = DataInterpolation;
    outStruct.DetritusDataOnly.No_BM_Data(BM_Mask) = NaN;

    % (II) BM + TN1 Positions = NaN
    outStruct.DetritusDataOnly.No_BM_and_TN1_Data = DataInterpolation;
    outStruct.DetritusDataOnly.No_BM_and_TN1_Data(outStruct.TubularNeighborhoods.BM_and_TN1_Mask) = NaN;

    % (III) BM + TN2 Positions = NaN
    outStruct.DetritusDataOnly.No_BM_and_TN2_Data = DataInterpolation;
    outStruct.DetritusDataOnly.No_BM_and_TN2_Data(outStruct.TubularNeighborhoods.BM_and_TN2_Mask) = NaN;

    % (IV) BM + TN3 Positions = NaN
    outStruct.DetritusDataOnly.No_BM_and_TN3_Data = DataInterpolation;
    outStruct.DetritusDataOnly.No_BM_and_TN3_Data(outStruct.TubularNeighborhoods.BM_and_TN3_Mask) = NaN;

    %% Impute the NaNs for the BM from the boundaries of the NaN area

    % (I) Original BM Mask
        % Step = 1
        outStruct.ImputedFromBoundaries.Imputed_BM.Step1 = outStruct.DetritusDataOnly.No_BM_Data;
        while any(isnan(outStruct.ImputedFromBoundaries.Imputed_BM.Step1),"all")
            outStruct.ImputedFromBoundaries.Imputed_BM.Step1 = ImputeMat(outStruct.ImputedFromBoundaries.Imputed_BM.Step1,1);
        end

        % Step = 2
        outStruct.ImputedFromBoundaries.Imputed_BM.Step2 = outStruct.DetritusDataOnly.No_BM_Data;
        while any(isnan(outStruct.ImputedFromBoundaries.Imputed_BM.Step2),"all")
            outStruct.ImputedFromBoundaries.Imputed_BM.Step2 = ImputeMat(outStruct.ImputedFromBoundaries.Imputed_BM.Step2,2);
        end

        % Step = 3
        outStruct.ImputedFromBoundaries.Imputed_BM.Step3 = outStruct.DetritusDataOnly.No_BM_Data;
        while any(isnan(outStruct.ImputedFromBoundaries.Imputed_BM.Step3),"all")
            outStruct.ImputedFromBoundaries.Imputed_BM.Step3 = ImputeMat(outStruct.ImputedFromBoundaries.Imputed_BM.Step3,3);
        end

        % Mean
        outStruct.ImputedFromBoundaries.Imputed_BM.Mean = 1/3.*(outStruct.ImputedFromBoundaries.Imputed_BM.Step1 + outStruct.ImputedFromBoundaries.Imputed_BM.Step2 + outStruct.ImputedFromBoundaries.Imputed_BM.Step3);

    % (II) BM and TN1 Mask
        % Step = 1
        outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step1 = outStruct.DetritusDataOnly.No_BM_and_TN1_Data;
        while any(isnan(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step1),"all")
            outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step1 = ImputeMat(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step1,1);
        end

        % Step = 2
        outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step2 = outStruct.DetritusDataOnly.No_BM_and_TN1_Data;
        while any(isnan(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step2),"all")
            outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step2 = ImputeMat(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step2,2);
        end

        % Step = 3
        outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step3 = outStruct.DetritusDataOnly.No_BM_and_TN1_Data;
        while any(isnan(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step3),"all")
            outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step3 = ImputeMat(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step3,3);
        end

        % Mean
        outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Mean = 1/3.*(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step1 + outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step2 + outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Step3);

    % (III) BM and TN2 Mask
        % Step = 1
        outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step1 = outStruct.DetritusDataOnly.No_BM_and_TN2_Data;
        while any(isnan(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step1),"all")
            outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step1 = ImputeMat(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step1,1);
        end

        % Step = 2
        outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step2 = outStruct.DetritusDataOnly.No_BM_and_TN2_Data;
        while any(isnan(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step2),"all")
            outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step2 = ImputeMat(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step2,2);
        end

        % Step = 3
        outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step3 = outStruct.DetritusDataOnly.No_BM_and_TN2_Data;
        while any(isnan(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step3),"all")
            outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step3 = ImputeMat(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step3,3);
        end

        % Mean
        outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Mean = 1/3.*(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step1 + outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step2 + outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Step3);

    % (IV) BM and TN3 Mask
        % Step = 1
        outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step1 = outStruct.DetritusDataOnly.No_BM_and_TN3_Data;
        while any(isnan(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step1),"all")
            outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step1 = ImputeMat(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step1,1);
        end

        % Step = 2
        outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step2 = outStruct.DetritusDataOnly.No_BM_and_TN3_Data;
        while any(isnan(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step2),"all")
            outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step2 = ImputeMat(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step2,2);
        end

        % Step = 3
        outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step3 = outStruct.DetritusDataOnly.No_BM_and_TN3_Data;
        while any(isnan(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step3),"all")
            outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step3 = ImputeMat(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step3,3);
        end

        % Mean
        outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Mean = 1/3.*(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step1 + outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step2 + outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Step3);

    %% Calculation of Mean and Median values for the differently imputed BM and Detritus values.
    
    % BM Means and Std
        % Original Data
        outStruct.Means.BM_Mean(1) = mean(DataInterpolation(BM_Mask),"all");
        outStruct.Means.BM_Std(1) = std(DataInterpolation(BM_Mask),0,"all");

        % BM Imputed Data
        outStruct.Means.BM_Mean(2) = mean(outStruct.ImputedFromBoundaries.Imputed_BM.Mean(BM_Mask),"all");
        outStruct.Means.BM_Std(2) = std(outStruct.ImputedFromBoundaries.Imputed_BM.Mean(BM_Mask),0,"all");

        % BM + TN1 Imputed Data
        outStruct.Means.BM_Mean(3) = mean(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Mean(outStruct.TubularNeighborhoods.BM_and_TN1_Mask),"all");
        outStruct.Means.BM_Std(3) = std(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Mean(outStruct.TubularNeighborhoods.BM_and_TN1_Mask),0,"all");

        % BM + TN2 Imputed Data
        outStruct.Means.BM_Mean(4) = mean(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Mean(outStruct.TubularNeighborhoods.BM_and_TN2_Mask),"all");
        outStruct.Means.BM_Std(4) = std(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Mean(outStruct.TubularNeighborhoods.BM_and_TN2_Mask),0,"all");

        % BM + TN3 Imputed Data
        outStruct.Means.BM_Mean(5) = mean(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Mean(outStruct.TubularNeighborhoods.BM_and_TN3_Mask),"all");
        outStruct.Means.BM_Std(5) = std(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Mean(outStruct.TubularNeighborhoods.BM_and_TN3_Mask),0,"all");

    % Detritus Means and Std
        % Original Data
        outStruct.Means.Detritus_Mean(1) = mean(DataInterpolation(~BM_Mask),"all");
        outStruct.Means.Detritus_Std(1) = std(DataInterpolation(~BM_Mask),0,"all");

        % BM Imputed Data
        outStruct.Means.Detritus_Mean(2) = mean(outStruct.ImputedFromBoundaries.Imputed_BM.Mean(~BM_Mask),"all");
        outStruct.Means.Detritus_Std(2) = std(outStruct.ImputedFromBoundaries.Imputed_BM.Mean(~BM_Mask),0,"all");

        % BM + TN1 Imputed Data
        outStruct.Means.Detritus_Mean(3) = mean(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Mean(~outStruct.TubularNeighborhoods.BM_and_TN1_Mask),"all");
        outStruct.Means.Detritus_Std(3) = std(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Mean(~outStruct.TubularNeighborhoods.BM_and_TN1_Mask),0,"all");

        % BM + TN2 Imputed Data
        outStruct.Means.Detritus_Mean(4) = mean(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Mean(~outStruct.TubularNeighborhoods.BM_and_TN2_Mask),"all");
        outStruct.Means.Detritus_Std(4) = std(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Mean(~outStruct.TubularNeighborhoods.BM_and_TN2_Mask),0,"all");

        % BM + TN3 Imputed Data
        outStruct.Means.Detritus_Mean(5) = mean(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Mean(~outStruct.TubularNeighborhoods.BM_and_TN3_Mask),"all");
        outStruct.Means.Detritus_Std(5) = std(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Mean(~outStruct.TubularNeighborhoods.BM_and_TN3_Mask),0,"all");

    % BM Medians and Std
        % Original Data
        outStruct.Medians.BM_Median(1) = median(DataInterpolation(BM_Mask),"all");
        outStruct.Medians.BM_Std(1) = std(DataInterpolation(BM_Mask),0,"all");

        % BM Imputed Data
        outStruct.Medians.BM_Median(2) = median(outStruct.ImputedFromBoundaries.Imputed_BM.Mean(BM_Mask),"all");
        outStruct.Medians.BM_Std(2) = std(outStruct.ImputedFromBoundaries.Imputed_BM.Mean(BM_Mask),0,"all");

        % BM + TN1 Imputed Data
        outStruct.Medians.BM_Median(3) = median(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Mean(outStruct.TubularNeighborhoods.BM_and_TN1_Mask),"all");
        outStruct.Medians.BM_Std(3) = std(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Mean(outStruct.TubularNeighborhoods.BM_and_TN1_Mask),0,"all");

        % BM + TN2 Imputed Data
        outStruct.Medians.BM_Median(4) = median(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Mean(outStruct.TubularNeighborhoods.BM_and_TN2_Mask),"all");
        outStruct.Medians.BM_Std(4) = std(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Mean(outStruct.TubularNeighborhoods.BM_and_TN2_Mask),0,"all");

        % BM + TN3 Imputed Data
        outStruct.Medians.BM_Median(5) = median(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Mean(outStruct.TubularNeighborhoods.BM_and_TN3_Mask),"all");
        outStruct.Medians.BM_Std(5) = std(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Mean(outStruct.TubularNeighborhoods.BM_and_TN3_Mask),0,"all");

    % Detritus Medians and Std
        % Original Data
        outStruct.Medians.Detritus_Median(1) = median(DataInterpolation(~BM_Mask),"all");
        outStruct.Medians.Detritus_Std(1) = std(DataInterpolation(~BM_Mask),0,"all");

        % BM Imputed Data
        outStruct.Medians.Detritus_Median(2) = median(outStruct.ImputedFromBoundaries.Imputed_BM.Mean(~BM_Mask),"all");
        outStruct.Medians.Detritus_Std(2) = std(outStruct.ImputedFromBoundaries.Imputed_BM.Mean(~BM_Mask),0,"all");

        % BM + TN1 Imputed Data
        outStruct.Medians.Detritus_Median(3) = median(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Mean(~outStruct.TubularNeighborhoods.BM_and_TN1_Mask),"all");
        outStruct.Medians.Detritus_Std(3) = std(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN1.Mean(~outStruct.TubularNeighborhoods.BM_and_TN1_Mask),0,"all");

        % BM + TN2 Imputed Data
        outStruct.Medians.Detritus_Median(4) = median(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Mean(~outStruct.TubularNeighborhoods.BM_and_TN2_Mask),"all");
        outStruct.Medians.Detritus_Std(4) = std(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN2.Mean(~outStruct.TubularNeighborhoods.BM_and_TN2_Mask),0,"all");

        % BM + TN3 Imputed Data
        outStruct.Medians.Detritus_Median(5) = median(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Mean(~outStruct.TubularNeighborhoods.BM_and_TN3_Mask),"all");
        outStruct.Medians.Detritus_Std(5) = std(outStruct.ImputedFromBoundaries.Imputed_BM_plus_TN3.Mean(~outStruct.TubularNeighborhoods.BM_and_TN3_Mask),0,"all");

    %% Nested functions (Utility functions)

    % Function 1
    function nbd = GetSquareNBD(mat,pix,step)
        % The function returns a neighborhood nbd which is a small square
        % centered at pixel, of, if pixel position is near the edge of the data
        % matrix the nbd is adjusted to stop at this edge.
        %
        % mat  = data matrix showing measured levels
        % pix  = pixel location: pix = c(i,j) position in the matrix,
        %                        corresponding to a specific pixel
        % step = number of positions to travel along the data matrix, up, down,
        %        right, left, to genrate a small square matrix centered at pixel
        
        Nrow = size(mat,1);
        Ncol = size(mat,2);
        xlo = max([pix(1) - step, 1]);
        xhi = min([pix(1) + step, Nrow]);
        ylo = max([pix(2) - step, 1]);
        yhi = min([pix(2) + step, Ncol]);
        nbd = mat(xlo:xhi,ylo:yhi);
    end
    
    % Function 2
    function ImMat = ImputeMat(mat,step)
        % The function finds pixel positions for NaN's in the data matrix,
        % builds a SquareNBd around each NaN pixel, and imputes the NaN by
        % taking the average of all non-NaN positions in the square. Finally,
        % the function returns data matrix with the imputed value for each of
        % the NaN's in the original data matrix.
        %
        % mat  = data matrix showing measured levels including NaN's
        % step = number of positions to travel along the data matrix, up, down,
        %        right, levt, to generate a small square matrix centered at pixel
    
        [trueNArow,trueNAcol] = find(isnan(mat));
        trueNA = [trueNArow,trueNAcol];
        ImMat = mat;
        for i = 1:size(trueNA,1)
            position = trueNA(i,:);
            TrueNA_NBD = GetSquareNBD(ImMat,position,step);
            NewVal = mean(TrueNA_NBD,"all","omitnan");
            ImMat(position(1),position(2)) = NewVal;
        end
    end
    
    % Function 3
    function IntersectBM = GetTubNbdPix(mat, pix, step)
        % The funciton first generates a small (size=step) square
        % (GetSquareNBD) in the original logical matrix, then returns True if
        % the SquareNBD intersechts the Basement Membrane area, False
        % otherwise.
        %
        % mat  = logical matrix showing True for Basement Membrane pixels and
        %        false for Detritus pixels
        % pix  = pixel locaion: pix = c(i,j) position in the matrix,
        %                       corresponding to a specific pixel
        % step = number of positions to travel along the data matrix, up, down,
        %        right, levt, to generate a small square matrix centered at pixel
        %        (default value = 2)
    
        if nargin < 2
            step = 2;
        end
    
        MatSqr = GetSquareNBD(mat,pix,step);
        IntersectBM = any(MatSqr,"all");
    end
    
    % Function 4
    function TubularNBDMat = DetTubularNBDMat(mat, step)
        % Pixels whose SquareNBD intersect the BM region become True. Therefore
        % the original pixels in the BM remain True, and pixels outside the BM
        % whose TubularNbdPix intersect BM turn True.
        %
        % mat  = logical matrix showing True for Basement Membrane pixels and
        %        false for Detritus pixels
        % step = number of positions to travel along the data matrix, up, down,
        %        right, levt, to generate a small square matrix centered at pixel
        %        (default value = 2)
    
        if nargin < 2
            step = 2;
        end
        
        MAT = mat;
        % MAT(~mat) = NaN;
        M = size(mat,1);
        N = size(mat,2);
        for i = 1:M
            for j = 1:N
                MAT(i,j) = GetTubNbdPix(mat,[i,j],step);
            end
        end
        TubularNBDMat = MAT;
    end

end