1) Download project from gitlab

```
git clone http://gitlab/yourproject.git
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
```


6) Generate an SSH key pair

```

```
