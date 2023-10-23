Output docs/assets/demo.gif

Set FontSize 28
Set Width 2000
Set Height 1000

Show
Type "make bootstrap"
Enter
Sleep 45s

Hide
Type "source .envrc"
Enter
Sleep 3s

Show
Type "vault operator raft list-peers"
Enter
Sleep 5s

Show
Type "kubectl get pods -A"
Enter
Sleep 5s

Show
Type "kubectl get secret -n esm esm-secret -o json | jq '.data | map_values(@base64d)'"
Enter
Sleep 5s
