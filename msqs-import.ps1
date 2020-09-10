# Intended for PowerShell 5

# Pull in our JSON data
$users = Get-Content -Path "D:\Sites\MOCK_DATA.json" -Raw | ConvertFrom-Json

# Get a reference to the queue we are going to use
$queue = Get-MsmqQueue -Name "deepdive-2020"

# Counter
$count = 0

foreach ($user in $users) {

    # Format the message as a JSON string
    # This will be added to the queue as XML in the format "<string>{ json }</string>"
    # MSQS can accept strongly-typed XML for better control over the format of the message,
    # But one of the use-cases for this demonstration is fast-prototyping
    $message = $user | ConvertTo-Json

    # Add the message to our queue, using a field from the data to label it (for reference only)
    $queue | Send-MsmqQueue -Body "$message" -Label $user.eml_address -Recoverable -Transactional | Out-Null

    # Increment and show the counter (for debugging)
    $count += 1
    $count

}
