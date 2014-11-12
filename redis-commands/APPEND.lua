EXISTS mykey
Append mykey "Hello Everyone!"
Append mykey " Redis"
Append mykey " is"
Append mykey " fun!"
get mykey

Set mykey "foobar"
bitcount mykey
bitcount mykey 0 0
bitcount mykey 1 1
