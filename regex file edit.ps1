### Gets all file content in $FileDir (can be quite large if using wildcards/entire directory), 
### replaces each instance of $ToBeReplaced with $ReplaceWith destructively

### can use select-string c:\dir\ -pattern "corn" (to non-destructively search for pattern)

$FileDir = "c:\users\corn\test\*.txt" ### edits ALL text files in the directory
$ToBeReplaced = "\*BK:" ## need to escape wildcard
$ReplaceWith = "PIZZA"


(get-content -path $FileDir) | foreach-object {$_ -replace $ToBeReplaced, $ReplaceWith} | set-content -path $FileDir
