I wrote this quick script when I there was no proper way to copy ALL subversion repos on my server.  As you may know. rsyncing subversion repos is NOT suggested as if you copy a repo during a transaction, this could seriously damage the backed up repo.  This is NOT safe.  So this script is meant to be run on the server which serves the subversion.  


Please set your variables at the start of the script.  It will enumerate all your repos and run a subversion hot copy for each one.  It will also maintain one previous backup.  (not really necessary as its version controlled, but its just a just in case feature).


**Use at own risk.**

Written by Ian Langdon (ianlangdon.ca)

