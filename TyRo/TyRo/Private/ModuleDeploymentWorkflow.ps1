### Creating a new Azure DevOps Project
<#
1. Create a new project
2. Clone repo to a local reposiotory
3.
#>

# Import VS Team module
Import-Module VSTeam






### Process for starting a modern dev project w/ source control and CI/CD
<#
1. Create a new project on VSTS (aka new git repository)
2. Clone your repo locally (git clone <remoteRepo>)
3. Create/add your scripts/files/code/modules etc. (plaster > module creation)
4. Stage the files to git (git add . or git add -A)
5. Commit the changes to git (git commit -m 'initial commit)
6. Push your local repo to the remote master branch
#>

# Deploy module template locally
New-BDModule -ModuleName TyRo -ModulePath 'C:\scripts'

# initialize git
git init

# add all your untracked files
git add .

# commit the files you haven't staged
git commit -m 'initial commit'

# Add remote repo
git remote add origin https://anakin0471.visualstudio.com/TyRo/_git/TyRo

# Push to remote repo
git push -u origin --all







<#
Existing project in VSTS
1. Create a new project on VSTS
2. Clone in VS Code
#>

## https://help.github.com/articles/adding-an-existing-project-to-github-using-the-command-line/

# 1. Create a new repository in VSTS (visual studio team services)
# 2. get repo URL: Code | Clone | Clone to VS Code!

#PAT = kwi7pth22hipyo4qvf4i3nxhn7ls56hx3qjrtxrr455updqco4sa

# Deploy module template locally
new-bdmodule

# initialize git
git init

# add all your untracked files
git add .

# commit the files you haven't staged
git commit -m 'first commit'

# add remote repo url
git remote add origin https://anakin0471.visualstudio.com/TyRo/_git/TyRo

# verify remote server
git remote -v

# push the changes in your local repo to the remote repo
git push origin master

