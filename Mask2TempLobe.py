#! /home/nye/anaconda2/bin/python
import argparse
import SimpleITK as sitk
import numpy as np
import pandas as pd
import os
# template come from https://github.com/Jfortin1/EveTemplate
LobTemplate='/home/nye/Documents/VLM/Eve_Atlas/JHU_MNI_SS_WMPM_Type-II_to_MNI_brain.nii.gz'
#Use JHU_MNI_SS_T1_brain_to_MNI_brain_DRAMMS.nii.gz, which has been non-linearly transformed to MNI using DRAMMS, and thus has the dimension of the MNI template.
#Use JHU_MNI_SS_T1_brain_to_MNI_brain.nii.gz, which has been non-linearly transformed to MNI using SyN, and thus has the dimension of the MNI template.
# https://github.com/muschellij2/Eve_Atlas
LobeLabelDf=pd.read_csv('../VLM/Eve_Atlas/JHU_MNI_SS_WMPM_TypeII_label.csv').loc[:,['integer_label','structure','right_left']].rename(index=str,columns={'integer_label':'LobeLabel'})

parser = argparse.ArgumentParser()
parser.add_argument('RawMask', metavar='MaskPath', help='Mask Aligned to MNI')
parser.add_argument('FinialMaskPath', metavar='LobeMaskPath', help='File folder to store lobe mask')

def main():
        args = parser.parse_args()
        Rawmask=sitk.ReadImage(args.RawMask)
	RawFileName=args.RawMask.split('/')[-1].split('.')[0]
	try:
		os.makedirs(args.FinialMaskPath)
	except:
		pass
	FinialMaskName_pre=args.FinialMaskPath+'/'+RawFileName
        Rawmask_array=sitk.GetArrayFromImage(Rawmask)
        TempMask=sitk.ReadImage(LobTemplate)
	TempMask_array=sitk.GetArrayFromImage(TempMask)
	Use_array=Rawmask_array*TempMask_array
	LobeLabel, VoxCounts = np.unique(Use_array[Use_array!=0], return_counts=True)
	VoxelAll=np.sum(VoxCounts)
	LobeInform={}
	for n,(i,j) in enumerate(zip(LobeLabel, VoxCounts)):
		
		LobeInform[n]={ 'LobeLabel':i,
				'VoxCounts':j}
	LobeInformDf=pd.DataFrame(LobeInform).T
	FinialDf=pd.merge(LobeInformDf,LobeLabelDf,on='LobeLabel').rename(index=str,columns={'structure':'Structure','right_left':'RightLeft'})
	FinialDf.to_pickle(FinialMaskName_pre+'_2LobeInform.plk')
        MaskWithLobe=sitk.GetImageFromArray(Use_array.astype(Rawmask_array.dtype))
        MaskWithLobe.CopyInformation(Rawmask)
        sitk.WriteImage(MaskWithLobe,FinialMaskName_pre+'_2Lobe.nii.gz',True)
if __name__ == '__main__':
	main()


