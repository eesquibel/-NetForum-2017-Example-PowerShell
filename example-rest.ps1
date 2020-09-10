# Intended for PowerShell Core 7+

function Get-JWT {
	# Get the bearer token from our Dummy Auth API
	$token = Invoke-RestMethod -Uri https://nf-eesquibel.mshome.net/Example/api/DummyAuth -Method Post

	# Convert it to a SecureString so it can be used by Invoke-RestMethod
	return $token.data | ConvertTo-SecureString -AsPlainText
}

function Get-Memberships {
	param (
		[Hashtable]$where,
		[SecureString]$token
	)

	# Call our API, setting our Token and setting the Authentication to Bearer
	Invoke-RestMethod `
		-Token $token `
		-Authentication Bearer `
		-Uri https://nf-eesquibel.mshome.net/Example/api/mb_membership `
		-Method Get `
		-Body @{ "where" = ( $where | ConvertTo-Json -Depth 8 -Compress ) }

	# Use -Compress on ConvertTo-Json to remove white-space added for readability
}

# Update our Membership object
function Update-Membership {
	param (
		[Hashtable]$update,
		[string]$id,
		[SecureString]$token
	)

	# Call our API, setting our Token and setting the Authentication to Bearer
	# and setting our json content type and body
	Invoke-RestMethod `
		-Token $token `
		-Authentication Bearer `
		-Uri https://nf-eesquibel.mshome.net/Example/api/mb_membership/$id `
		-Method Put `
		-ContentType 'application/json' `
		-Body ($update | ConvertTo-Json)
}

# Get our bearer token
$token = Get-JWT

# Build our where clause for finding the records needing updating
# This is a quickly thrown together custom syntax.
# Something like GraphQL might be a better choice if you wanted more flexibility
$where = @{
	"mbt_code" = "Student";
	"mbr_auto_pay" = $true;
	"mbr_cpi_key" = "IS NOT NULL";
	"mbr_expire_date" = @{ "ge" = "2020-09-09" };
}

# Call the function to get the memberships, making sure to pass in our token
$memberships = Get-Memberships -token $token -where $where

# Preview to make sure it is pulling in the data correctly
$memberships | Format-Table

if ($false) { # For debug/demonstration purposes

	# Loop through the results
	foreach ($mbr in $memberships) {
		$mbr
		#break

		# Build the list of fields to update
		$update = @{
			"mbr_auto_pay" = $false;
			"mbr_cpi_key" = $null;
		}

		# Call the update function, passing in our token
		Update-Membership -token $token -id $mbr.mbr_key -update $update

		break # For debugging / demonstration
	}
}
