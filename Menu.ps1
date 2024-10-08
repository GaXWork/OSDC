# Define menu options
$menuOptions = @{
    "1" = "OSDCloud plain";
    "2" = "Kunde A";
    "3" = "Kunde B";
}

# Function to display menu
function Show-Menu {
    Write-Host "Pick the customer:"
    foreach ($key in (1..3)) {
        Write-Host "$key) $($menuOptions[$key.ToString()])"
    }
}

# Function to handle menu selection
function Handle-Selection {
    param (
        [string]$selection
    )

    switch ($selection) {
        "1" {
            Write-Host "You chosed OSDCloud plain."
            # Handling her
            Start-OSDCloudGUI -BrandName 'ITM8' -BrandColor '#5A179B'
        }
        "2" {
            Write-Host "You chosed customer A."
            # Handling her
            & "$PSScriptRoot\CustomerA.ps1"
        }
        "3" {
            Write-Host "You chosed customer B."
            # Handling her
        }
        default {
            Write-Host "Not valid."
        }
    }
}

# Main script
do {
    Show-Menu
    $selection = Read-Host "Select the correct customer"
    Handle-Selection -selection $selection
  
} while ($continue -eq "yes")

Write-Host "The end"
