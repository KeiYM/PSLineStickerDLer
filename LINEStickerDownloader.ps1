# Version 1.1.1
# Author: KeiYM
# PowerShell LINE Sticker Downloader
# Simple PS Script that takes in a LINE Store URL, gets the metadata and downloads the stickers from their site

Function Get-LINEStickers
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$URLInput,
        [Parameter(Mandatory=$true)]
        [string]$SavePath
        )

        $LineSource = Invoke-WebRequest $URLInput;

        # Get LINE Package ID
        $PIDPattern = "'packageId':(.*?),";

        $LinePID = [regex]::Match($LineSource, $PIDPattern).Groups[1].Value

        # Craft metadata URL
        $LineMetaURL = "http://dl.stickershop.line.naver.jp/products/0/0/1/" + $LinePID + "/android/productInfo.meta";

        # Get metadata
        $LineMetaSource = Invoke-WebRequest $LineMetaURL;

        # Get all stickers' ID
        $StickerIDPattern = '"id":(.*?),"width"';

        # Download each sticker from metadata
        $LineMetaSource | 
            Select-string -Pattern $StickerIDPattern -AllMatches | 
            % { $_.Matches } | 
            % { 
            # Craft sticker URL
            $TempStickerURL = "http://dl.stickershop.line.naver.jp/products/0/0/1/" + $LinePID + "/android/stickers/" + $_.Groups[1].Value + ".png";
            
            # Craft local save path for sticker
            $TempStickerSavePath = $SavePath + "\" + $_.Groups[1].Value + ".png";
            
            Invoke-WebRequest $TempStickerURL -OutFile $TempStickerSavePath;
            };

    Write-Host "-----Completed !-----" -ForegroundColor Green;
    Write-Host "Exiting in 5 seconds...";
    Write-Host "---------------------" -ForegroundColor Green;
}

# Prompt user for input
$UserLINEInput = Read-Host -Prompt 'Enter LINE Store URL'
$UserSaveDir = Read-Host -Prompt 'Enter directory to save stickers to'

if($UserLINEInput -eq '')
{
    Write-Host "-----Invalid Input !-----" -ForegroundColor Red;
    Write-Host "LINE Store URL is invalid!";
    Write-Host "Exiting in 5 seconds...";
    Write-Host "-------------------------" -ForegroundColor Red;
    Start-Sleep 5;
    exit;
}
elseif(($UserSaveDir -eq '') -or !(Test-Path $UserSaveDir)) 
{
    Write-Host "-----Invalid Directory!-----" -ForegroundColor Red;
    Write-Host "Check if directory to save stickers to is valid!";
    Write-Host "Exiting in 5 seconds...";
    Write-Host "----------------------------" -ForegroundColor Red;
    Start-Sleep 5;
    exit;
}
else
{
    Get-LINEStickers $UserLINEInput $UserSaveDir;
}