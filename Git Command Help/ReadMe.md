1) Download project from gitlab

```
git clone http://gitlab/yourproject.git
    or
git clone https://gitlabusername@gitlab.com/gitlabusername/project.git
```
now enter username and password


2) Update change in git

```
git commit -a -m "Comment"
git push
```

3) Some time all file not update in git so do following 

```
git status --ignored
```
it all display  changed files 

```
git add *
git commit -m "Update and merge code"
git push
```
it fource add all file to git


4) Update local project with latest git project

```
git fetch --all
git reset --hard origin/master
git pull origin master
```
If conflict file when pull so do below command it delete all local file changes then do above commands
```
git reset --hard HEAD
git clean -f -d
```


5) For comment specific branch

```
# on master branch
git checkout master
# Create a branch for feature 1
git checkout -b feature_1
# work on feature 1
git add .
git commit -m "Update and merge code"
git push
git push origin feature_1


# If branch already exist on cloude then use following cmd to create branch in local
git branch branch_name

# Get all branch list of local
git branch --all
```


6) Generate an SSH key pair

```
ssh-keygen -t ed25519 -C "<comment>"
```
Generating public/private ed25519 key pair.  
Enter file in which to save the key (/home/user/.ssh/id_ed25519): [Press Enter]  
Enter passphrase (empty for no passphrase):  
Enter same passphrase again: [Press Enter]  

Check For "~/.ssh/config" file    
AddKeysToAgent yes  
UseKeychain yes  
IdentityFile ~/.ssh/id_ed25519  

Add SHA to git lab account
```
tr -d '\n' < ~/.ssh/id_ed25519.pub | pbcopy
```

Referance:- https://docs.gitlab.com/ee/ssh/README.html#see-if-you-have-an-existing-ssh-key-pair



7) Git stash command  
When many person work on same project so all person work in different module  
Someone add module and push code  
You want to add that module on your local branch but your code is not commited so it conflict.  
This command store changes on locally then apply new updated code and display conflict for merge.  

When you have changes on your working copy, from command line do:
```
git stash 
```
This will stash your changes and clear your status report
```
git pull
```
This will pull changes from upstream branch. Make sure it says fast-forward in the report. If it doesn't, you are probably doing an unintended merge
```
git stash pop
```
This will apply stashed changes back to working copy and remove the changes from stash unless you have conflicts. In the case of conflict, they will stay in stash so you can start over if needed.  
if you need to see what is in your stash
```
git stash list
```
