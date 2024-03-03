function Remove-Package {
    param (
        [string]$displayName,
        [string]$packageId
    )
    Get-AppxPackage -Name $packageId | Export-Clixml -Path "Removed_$packageId.xml" 
    Get-AppxPackage -Name $packageId | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    if ($?) {
        Write-Host "$displayName removed successfully`n"
    }
}

function Reinstall-Package {
    param (
        [string]$displayName,
        [string]$packageId
    )
    Import-Clixml -Path "Removed_$packageId.xml" | Add-AppxPackage
    Remove-Item -Path "Removed_$packageId.xml" -Force  
    if ($?) {
        Write-Host "$displayName reinstalled successfully`n"
    }
}

function Show-Menu {
    Write-Host "No More Bloatware"
    Write-Host "-------------------------"
    Write-Host "1. Remove bloatware applications"
    Write-Host "2. Remove Microsoft Edge"
    Write-Host "3. Undo removal process"
    Write-Host "4. Exit"
    Write-Host "-------------------------"
}

$bloatwarePackages = @{
    "Microsoft.BingWeather" = "Weather",
    "Microsoft.DesktopAppInstaller" = "Desktop App Installer",
    "Microsoft.GetHelp" = "Get Help",
}

Show-Menu
do {
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        1 {
            Write-Host "Choose the bloatware applications to remove:`n"
            foreach ($package in $bloatwarePackages.GetEnumerator() | Sort-Object Name) {
                $displayName = $package.Value
                $packageId = $package.Key
                $choice = Read-Host "Remove $displayName? (Y/N)"
                if ($choice -eq "Y" -or $choice -eq "y") {
                    Remove-Package -displayName $displayName -packageId $packageId
                }
            }
            break
        }
        2 {
            $removeEdge = Read-Host "Remove Microsoft Edge? (Y/N)"
            if ($removeEdge -eq "Y" -or $removeEdge -eq "y") {
                Remove-Package -displayName "Microsoft Edge" -packageId "Microsoft.MicrosoftEdge"
            }
            break
        }
        3 {
            $undoChoice = Read-Host "Do you want to undo the removal process? (Y/N)"
            if ($undoChoice -eq "Y" -or $undoChoice -eq "y") {
                foreach ($package in $bloatwarePackages.GetEnumerator() | Sort-Object Name) {
                    $displayName = $package.Value
                    $packageId = $package.Key
                    Reinstall-Package -displayName $displayName -packageId $packageId
                }
                Reinstall-Package -displayName "Microsoft Edge" -packageId "Microsoft.MicrosoftEdge"
            }
            break
        }
        4 {
            Write-Host "Exiting..."
            break
        }
        default {
            Write-Host "Invalid choice. Please enter a valid option."
            break
        }
    }
} while ($choice -ne 4)
