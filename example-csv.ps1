# Intended for PowerShell Core 7+

function Get-JWT {
	$token = Invoke-RestMethod -Uri https://nf-eesquibel.mshome.net/Example/api/DummyAuth -Method Post
	return $token.data | ConvertTo-SecureString -AsPlainText
}

function Update-Individual {
	param (
		[Hashtable]$update,
		[string]$id,
		[SecureString]$token
	)

	Invoke-RestMethod `
		-Token $token `
		-Authentication Bearer `
		-Uri https://nf-eesquibel.mshome.net/Example/api/CO_Individual/$id `
		-Method Put `
		-ContentType 'application/json' `
		-Body ($update | ConvertTo-Json)
}

$token = Get-JWT

# Pull in our data
# This could also be JSON or XML, use the appropriate ConvertFrom cmdlet
$data = Get-Content -Raw -Path './ind-info.csv'

# Since we have a CSV, convert it to an array of objects
# Note ConvertFrom-Csv outputs an array of PSCustomObjects
# ConvertFrom-Json has a flag to output as hash tables (easier to manipulate)
$rows = $data | ConvertFrom-Csv `
	-Header "cst_key", "ind_first_name", "ind_last_name", "ind_badge_name", "eml_address"

# Preview to make sure it is pulling in the data correctly
$rows | Format-Table

if ($false) { # For debugging / demonstration

	# Loop through the records in the CSV
	foreach ($row in $rows) {

		# Format any fields as needed
		$eml_address = $row.eml_address -replace '^zz', '' -replace 'zz$', ''

		# Build the update object w/ the fields to change
		$update = @{
			ind_first_name = $row.ind_first_name;
			ind_last_name = $row.ind_last_name;
			ind_badge_name = $row.ind_first_name;
			eml_address = $eml_address;
		}

		# Call the update, making sure to give it the authentication token
		Update-Individual -token $token -id $row.cst_key -update $update

		break # For debugging / demonstration
	}
}
