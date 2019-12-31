<##################################################################
 TITLE: Cluster Pipeline Script                                               
 VERSION: 1
 DATE: (12/20/2019)                                                  
                                                                 
-------------------------------------------------------------------
 DESCRIPTION:                                                    
 ------------------------------------------------------------------                                                     
 This script does the following:   
                               
 1. Downloads the MS_Runs_DB via an R Script 
 2. PSCPs the following files
    a. The MS_Runs_DB.csv /home/huffman.r/
    b. Recently generated Raw files -> /scratch/huffman.r/ClusterRAW  
 3. Runs MobaXterm from command line to automatically run foo.sh  
    a. mqpar files and slurm scripts as generated for each RAW file
    b. txt folder is passed into output folder      
 5. Port files back to GDrive [NOT YET]
    a. PSCP only those folders for recently generated files
    b. GLOBUS-based sync from command line   
            
* Updated to process multiple .RAW files
* Updated to only run MQ script if one RAW file exists

###################################################################>

#------------------------------------------------------------------
#Start transcript
#------------------------------------------------------------------
Start-Transcript -Path "C:\transcripts\Cluster_Pipeline_log.txt" -Append -IncludeInvocationHeader

#function backg() {Start-Process -NoNewWindow @args}

#------------------------------------------------------------------
# Source and destination folders
#------------------------------------------------------------------
$RAW_source = "G:/My Drive/MS/RAW_DATA_SCOPE/"
#$RAW_local = "C:\Users\G.Huffman\Documents\RAW_FILES\Pipeline"
#$evidenceDestination = "G:/My Drive/MS/QEQC/QC_Standards/"

#------------------------------------------------------------------
# Pull MS_Runs_DB [WORKS!]
#------------------------------------------------------------------
# Run R script
& "C:\Program Files\R\R-3.5.2\bin\Rscript.exe" "C:\Users\G.Huffman\Documents\AutoClusterPipeline\ClusterScript_DBfetch.R"
# PSCP file to drive using MobaXterm
& "C:\Program Files (x86)\MobaTek\MobaXterm\MobaXterm.exe" -newtab "scp /drives/c/Users/G.Huffman/Documents/AutoClusterPipeline/MS_Runs_DB.csv huffman.r@xfer.discovery.neu.edu:/home/huffman.r/" -exitwhendone | Out-Null

Write-Output "Post CSV pull"

#------------------------------------------------------------------
# Dynamically formatted filenames/folders [WORKS! 3.21.18]
#------------------------------------------------------------------
# RAW file

$EndTime = Get-Date
$StartTime1 =  Get-Date 
$StartTime = $StartTime1.AddHours(-1).AddMinutes(-30)
$StartTime2 = $StartTime1.AddDays(0).AddHours(-1).AddMinutes(-30)

$folders =  Get-ChildItem -Path $RAW_source -Exclude "*blank*","*SQC*" |Where-Object { $_.LastWriteTime -gt $StartTime2 -and $_.LastWriteTime -lt $EndTime}  

foreach ($folder in $folders){

# Get RAWFile name and path
$RAWFilePath = $folder.FullName
Write-Output $RAWFilePath
$RAWFileName = $folder.Name
$localPath = "/drives/c/My_Drive/MS/RAW_DATA_SCOPE/" + $RAWFileName

$mobaPath = ("scp " + $localPath + " huffman.r@xfer.discovery.neu.edu:/scratch/huffman.r/ClusterRaw/")
& "C:\Program Files (x86)\MobaTek\MobaXterm\MobaXterm.exe" -newtab $mobaPath -exitwhendone | Out-Null



}

Write-Output "Post PSCP of Raw files"

########
# Running Batch Search Script
########

& "C:\Program Files (x86)\MobaTek\MobaXterm\MobaXterm.exe" -bookmark "login.discovery.neu.edu (huffman.r)" | Out-Null

Write-Output "Post Automated Search Script Run"

#-------------------------------------------------------------
# Pulling search results
#-------------------------------------------------------------

########
# Getting remote directory structure
########

$mobaPath_csv_pull = "scp huffman.r@xfer.discovery.neu.edu:/home/huffman.r/directory_list.csv /drives/c/Users/G.Huffman/Documents/AutoClusterPipeline/"
& "C:\Program Files (x86)\MobaTek\MobaXterm\MobaXterm.exe" -newtab $mobaPath_csv_pull -exitwhendone | Out-Null

########
# Comparing remote directory structure to G Drive Folders
########

$Remote_directory_list = Import-Csv -Path "C:\Users\G.Huffman\Documents\AutoClusterPipeline\directory_list.csv" -Header "Files"
$SearchResultDestination = Get-ChildItem "C:\My_Drive\MS\SCoPE\cluster_searches\"

$FolderOutersect = Compare-Object -ReferenceObject $Remote_directory_list -DifferenceObject $SearchResultDestination

$RAWsToCompare =  Get-ChildItem -Path $RAW_source -Exclude "*blank*","*SQC*" |Where-Object { $_.LastWriteTime -gt $StartTime2_compare -and $_.LastWriteTime -lt $EndTime_compare}  

########
# Pulling search results not in destination folder
########


foreach ($SearchResult in $FolderOutersect){

if ( $SearchResult.SideIndicator -eq "<=") {
$SearchResultFolderName = $SearchResult.InputObject.Files
$clusterPath = "huffman.r@xfer.discovery.neu.edu:/scratch/huffman.r/SearchResults_forGDrive/" + $SearchResultFolderName + "/"
$pullDest = "/drives/c/My_Drive/MS/SCoPE/cluster_searches/"

$mobaPath_for_pull = ("scp -r " + $clusterPath + " " + $pullDest)
& "C:\Program Files (x86)\MobaTek\MobaXterm\MobaXterm.exe" -newtab $mobaPath_for_pull -exitwhendone | Out-Null
} else {
Write-Output "cheers"
}
}

#---------------------------------------------------


Stop-Transcript
