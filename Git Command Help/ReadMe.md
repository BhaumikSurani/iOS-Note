
##### 1. Download project from git
Note: work with "dev" branch master branch is allow only merge request.
```
git clone http://gitsite/yourproject.git
    or
git clone https://gitsiteusername@gitsite.com/gitsiteusername/project.git
```

##### 1. Change Branch
Note: work with "dev" branch master branch is allow only merge request.
```
# Get all branch list
git branch --all

git checkout branch_name
```

##### 2. Upload Code.
```
git checkout dev
git add .
git commit -m "You Code Comments"
git push origin dev
```

##### 3. Create new branch
```
git switch -c new_branch_name
# OR
git checkout -b new_branch_name
```

##### 4. Push Code to git and conflict Local to Git
When your local code is behind of server code so you have to merge code.
```
#fetch command is check latest code in server.
git fetch --all

git add .
git commit -m "Your Commit"

#Update your local code
git pull

#If pull not complete and display "Abort" then open file has conflict
#compare "<<<<HEAD" in this file and accept changes

#Merge code to server
git push origin main

#After push open screen in that press "esc" key 
#Type ':wq' and hit enter now you code merge to server code
```

##### 5. Pull code (Reset Your local code)
When your local code is behind of server code so you have to update code.
```
#fetch command is check latest code in server.
git fetch --all

#check for changes on local code
git status

#If your local code has changes so it not allow to update your code with latest code so need to reset.
#Note if you reset your code so current code will lose so backup your changes.
git reset --hard
git reset --hard HEAD

#Update your local code to latest code
git pull
```

##### 6. Pull code (Merge new commit code in you local)
When many person work on same project so all person work in different module  
Someone add module and push code  
You want to add that module on your local branch but your code is not commited so it conflict.  
This command store changes on locally then apply new updated code and display conflict for merge.  
```
git fetch --all

#This will stash your changes and clear your status report
git stash 

git pull

#This will apply stashed changes back to working copy and remove the changes from stash unless you have conflicts. In the case of conflict, they will stay in stash so you can start over if needed.
if you need to see what is in your stash
git stash pop

#List all stash
git stash list
```

##### 7. Merge origin/master branch to feature branch
When feature branch is behind the master branch and you want to add master branch commits in feature branch. At that time this process is used.  
```
# step1: change branch to master, and pull to update all commits
git checkout master
git pull

# step2: change branch to target, and pull to update commits
git checkout feature
git pull

# step3: merge master to feature(⚠️ current is feature branch)
git merge master
```

##### 8. Merge feature branch to origin/master branch
When master branch is behind the feature branch and you want to add feature branch commits in master branch. At that time this process is used.  
```
git checkout feature
git pull

git checkout master
git pull origin/master

git push origin/master
```

##### 9. Merge specific commit feature branch to origin/master branch  
When master branch is behind the feature branch and feature branch has many commits. Now you wants to merge specific commit to master branch. At that time this process is used.  
Ex:- Your feature branch has 10 commits and you want to merge 3 commits.  
```
#step 1:- change branch to feature
git checkout feature

#step 2:- list commit id with commit text
git log --oneline

#OUTPUT
#387b789 commit 3
#387b456 commit 2
#387b123 commit 1

#step 3:- change branch to master
git checkout master

#step 4:- Merge Specific Commit (387b456 is your commit id)
git cherry-pick 387b456

#step 5:- Verify Commit is Merged
git log --oneline
```
