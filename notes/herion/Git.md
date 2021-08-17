### 1.撤销commit

--soft：不删除工作空间改动代码。

--hard：删除工作空间改动代码，回到上一次commit状态。

```
//之后的都不要了
git reset --soft HEAD~1 //撤销前一个版本
git reset --soft HEAD~2 //撤销前两个版本

git revert HEAD //可以撤销某一个版本，保留之后的版本
```

### 2.本地与远端冲突

```
git stash save "save message" //暂存本地代码
git pull
git stash pop //将存储代码与本地代码合并
```

### 3.新建分支

```
git branch bugFix //新建分支
git checkout bugFix //指向分支
```

### 4.合并分支

```
//1.merge 将指定分支合并到当前分支
git checkout main
git merge bugFix //将bugFix合并到main上
git checkout bugFix //指向分支
git merge main
//2.rebase 将当前分支复制到制定分支
git checkout bugFix //指向分支
git rebase main //将bugFix合并到main顶端
git checkout main
git rebase bugFix //将main移动到bugFix上
```

### 5.相对引用

```
git branch -f version1 version2 //将version1指向version2
```

