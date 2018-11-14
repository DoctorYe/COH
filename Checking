ROOTPATH='/Volumes/G-DRIVE Thunderbolt 3/ZH/RawDicom'
RESULTPATH='./'

import SimpleITK as sitk
import numpy as np
import os
import pandas as pd
import re
import datetime

InformationNeed=[["0008|0020",'StudyDate_0008_0020'],
                 ["0008|0050",'AccessionNumber_0008_0050'],
                 ["0008|0070",'Manufacturer_0008_0070'],
                 ["0008|103e",'SeriesDescription_0008_103e'],
                 ["0018|0023",'MRAcquisitionType_0018_0023'],
                 ["0018|0025",'AngioFlag_0018_0025'],["0018|1314",'FlipAngle_0018_1314'],
                 ["0018|0050",'SliceThickness_0018_0050'],
                 ["0018|0080",'RepetitionTime_0018_0080'],
                 ["0018|0081",'EchoTime_0018_0081'],
                 ["0018|0082",'InversionTime_0018_0082'],
                 ["0018|0084",'ImagingFrequency_0018_0084'],
                 ["0018|0087",'MagneticFieldStrength_0018_0087'],
                 ["0020|0011",'SeriesNumber_0020_0011'],
                 ["0010|0030",'DOB_0010_0030'],
                 ["0010|0040",'Gender_0010_0040'],['0010|0020','PatientID_0010_0040'],['0028|0010','Rows_0028_0010'],
                 ['0028|0011','Columns_0028_0011'],['0028|0030','PixelSpacing_0028_0030']]
ResultList=[]
CheckList=[]
for root,folder,files in os.walk(ROOTPATH):
    
    Files=list(filter(lambda x:'dcm' in x and 'Error' not in x, files))
    if Files!=[] and len(Files)>3:
        NeedCheck={}
        Result={}
        try:
            reader = sitk.ImageSeriesReader()
            series_found = reader.GetGDCMSeriesIDs(root)
            if len(series_found):
                ImageList=[]
                for serie in series_found:
                    dicom_names = reader.GetGDCMSeriesFileNames(root, serie)
                    reader.SetFileNames(dicom_names)
                    image = reader.Execute()
                    ImageList.append((image,dicom_names))
                for image,dicom_names in ImageList:
                    Array=sitk.GetArrayFromImage(image)
                    ShapeString='_'.join(np.array(Array.shape).flatten().astype(str))
                    I=int(Array.shape[0]/2)
                    ArrayUse=Array[I,:,:]
                    String='_'.join(ArrayUse.flatten().astype('str'))
                    Result.update({'FullArrayShape':ShapeString,
                                   'SlicedArray_String':String,'SlicedArray_ID':I,
                                   'DicomFileList':dicom_names,'DicomPathRoot':root})

                    Dicom1=sitk.ReadImage(dicom_names[0])
                    for HeadID,tag in InformationNeed:
                        try:
                            Result.update({tag:Dicom1.GetMetaData(HeadID)})
                        except:
                            pass
        
        except Exception as e:
            NeedCheck.update({'DicomPathRoot':root,'Error':e})
        CheckList.append(NeedCheck)
        ResultList.append(Result)
NeedCheckDf=pd.DataFrame(dict(enumerate(list(filter(lambda x:x!={},CheckList))))).T

DicomDf=pd.DataFrame(dict(enumerate(list(filter(lambda x:x!={},ResultList))))).T


CheckList1=[]
ResultList1=[]
for i in NeedCheckDf.index:
    root=NeedCheckDf.DicomPathRoot[i]
    NeedCheck={}
    Result={}
    try:
        reader = sitk.ImageSeriesReader()
        series_found = reader.GetGDCMSeriesIDs(root)

        for serie in series_found:
            dicom_names = reader.GetGDCMSeriesFileNames(root, serie)
            ImageShapeDict={}
            for d in dicom_names:
                temp=sitk.ReadImage(d)
                shape=sitk.GetArrayFromImage(temp).shape

                ImageShapeDict.setdefault('_'.join([str(s) for s in shape ]),[]).append(d)
            if len(ImageShapeDict.keys())!=1:
                dicom_names=sorted(ImageShapeDict.items(),key=lambda x:len(x[1]))[-1][1]
            reader.SetFileNames(dicom_names)
            image = reader.Execute()
            ImageList.append((image,dicom_names))

        for image,dicom_names in ImageList:
            Array=sitk.GetArrayFromImage(image)
            ShapeString='_'.join(np.array(Array.shape).flatten().astype(str))
            I=int(Array.shape[0]/2)
            ArrayUse=Array[I,:,:]
            String='_'.join(ArrayUse.flatten().astype('str'))
            Result.update({'FullArrayShape':ShapeString,
                           'SlicedArray_String':String,'SlicedArray_ID':I,
                           'DicomFileList':dicom_names,'DicomPathRoot':root})

            Dicom1=sitk.ReadImage(dicom_names[0])
            for HeadID,tag in InformationNeed:
                try:
                    Result.update({tag:Dicom1.GetMetaData(HeadID)})
                except:
                    pass
    except Exception as e:
        NeedCheck.update({'DicomPathRoot':root,'Error':e})
    ResultList1.append(Result)
    CheckList1.append(NeedCheck)
NeedCheckDfFinial=pd.DataFrame(dict(enumerate(list(filter(lambda x:x!={},CheckList1))))).T
DicomDf1=pd.DataFrame(dict(enumerate(list(filter(lambda x:x!={},ResultList1))))).T

# Write Result
Time=datetime.date.today().strftime("%Y%m%d")
NeedCheckDfFinial.to_excel(os.path.join(RESULTPATH,'NeedCheckDf_Finial%s.xlsx' % Time))
DicomDf1.to_pickle(os.path.join(RESULTPATH,'DicomDf1_%s.plk' % Time)')
DicomDf.to_pickle(os.path.join(RESULTPATH,'DicomDf_%s.plk' % Time)')

